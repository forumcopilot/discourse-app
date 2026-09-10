# Measuring scroll performance on a device

How the before/after numbers in `perf-audit-2026-09.md` were produced, so
the same measurement can be repeated on this app or ported to a sibling
(the XenForo app). Everything here was learned the hard way on 2026-09-09;
the "what does not work" section will save the most time.

## The idea

A `flutter drive --profile` integration test that:

1. starts the real app (`app.main()`), on a real phone, in profile mode;
2. opens one fixed public forum;
3. flings the topic list eight times, then opens a topic and flings the
   thread eight times;
4. records every frame's build and raster time during each set of flings
   with `SchedulerBinding.addTimingsCallback`, and prints one summary line
   per screen.

Same phone, same forum, same gestures, before and after a change. The
output is two lines like:

```
PERF topic_list frames=1183 build p50=6.9 p90=14.9 p99=24.1 max=89 | raster p50=6.0 p90=9.1 p99=11.7 max=26 | total>16.7ms=366 total>33ms=16 build>16.7ms=54 raster>16.7ms=1
PERF thread     frames=965  build p50=0.8 p90=2.3 p99=30.2 max=83 | raster p50=4.6 p90=5.7 p99=7.7  max=10 | total>16.7ms=20  total>33ms=11 build>16.7ms=15 raster>16.7ms=0
```

## Setup

`pubspec.yaml`, dev dependencies:

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_driver:
    sdk: flutter
```

`test_driver/perf_driver.dart`:

```dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

`integration_test/scroll_perf_test.dart` — the ABDA version is reproduced
at the end of this document. The parts to adapt for another app are marked
`// ADAPT`.

Phone: USB-connected, developer mode, `adb devices` shows it. Note its id.

## Running

```bash
flutter drive --profile -d <device-id> \
  --driver=test_driver/perf_driver.dart \
  --target=integration_test/scroll_perf_test.dart > /tmp/drive.log 2>&1
grep PERF /tmp/drive.log
```

About three minutes per run: a profile build, install, the test, uninstall.
Keep the whole log; it also holds the app's own debug output, which is
useful for counting things (see "Reading the log" below).

**Run it twice** on the baseline before changing anything. Two runs agreed
within ~0.2 ms on p50 and ~10 % on jank counts, which tells you what size
of change is real.

## Before and after

The Discourse module lives in its own repo and the apps pin a commit SHA.
To measure a working copy without tagging it:

1. In the app repo, create `pubspec_overrides.yaml` (gitignored) pointing
   the module packages at the sibling checkout by path.
2. `rm -rf .dart_tool/flutter_build build/app/intermediates/flutter` —
   see trap 1 below; this is not optional.
3. `flutter pub get`, then run the drive as above.
4. Delete `pubspec_overrides.yaml` and `flutter pub get` again before
   committing anything; with the override active `pubspec.lock` shows path
   sources and must not be committed.

For an app whose UI is in-repo (XenForo), skip the override and just build
from the branch.

## Reading the numbers

- **Budget.** A 120 Hz phone has 8.3 ms per frame; 60 Hz has 16.7 ms.
  Build and raster run on different threads, so each must fit on its own.
  The summary reports counts over 16.7 ms and 33 ms (one and two dropped
  frames at 60 Hz) because those are what people feel.
- **build p50 high** = the widget tree is doing too much on every frame
  (non-virtualized lists, parsing in `build()`, rebuild storms). This was
  the topic list: 6.9 ms median, a third of frames over 16.7 ms.
- **build p50 low, p99 high** = occasional expensive items entering the
  viewport (a post's HTML parse, a batch of image decodes). This was the
  thread: 0.8 ms median, 30 ms p99.
- **raster high** = GPU-side layers: `Opacity`, `ClipRRect`/antialiased
  clips, `ShaderMask`, `ColorFiltered`, `BackdropFilter`, shadows. Raster
  was never the bottleneck here, which pointed the work at the UI thread.
- The thread section opens whatever topic is second in Latest at run time,
  so its p99 is only comparable between runs made close together. The
  topic-list numbers are stable.

## Reading the log

The full drive log contains the app's `debugPrint` output. Counting lines
is a cheap way to see side effects a frame timer cannot:

```bash
grep -c 'Attempting to download' /tmp/drive.log   # image cache misses
grep -c 'Failed to decode image'  /tmp/drive.log   # decoder rejections
grep -c 'Invalid image data'      /tmp/drive.log   # file -> network fallbacks
```

Baseline was 598 / 10 / 88 for a two-screen scroll; after the avatar fixes
94 / 1 / 0. That finding came entirely from the log.

## What does not work (and cost half a day)

1. **Gradle ships a stale kernel.** After editing a path-dependency
   package outside the app directory, `flutter build`/`flutter drive`
   produced a fresh APK from the *old* Dart kernel: Gradle's Flutter task
   did not see the change. Symptom: numbers identical to the previous run.
   Fix: `rm -rf .dart_tool/flutter_build build/app/intermediates/flutter`
   before every measured build, then confirm with
   `stat .dart_tool/flutter_build/*/app.dill` that the kernel is newer than
   the edit.
2. **Android's frame stats do not see Flutter.** `dumpsys gfxinfo`
   reports zero frames; `dumpsys SurfaceFlinger --latency` returns no rows
   for the Flutter surface on Android 16. Collect timings inside the app.
3. **`binding.traceAction` report data never reached the driver.** The
   documented `reportData` → `TimelineSummary` path produced "no response
   data" every time on this Flutter (3.29). Printing the `FrameTiming`
   summary from inside the test is what works, and it needs no driver code.
4. **`pumpAndSettle` never settles** while a spinner or shimmer animates.
   Pump a fixed number of frames instead (`_settle` below).
5. **`app.main()` is `void async`.** It cannot be awaited; call it and
   pump until the first screen appears.
6. **Typing into a dialog through the harness is unreliable on a device.**
   Push the forum's page directly with the app's navigator key instead of
   driving the open-by-address UI.
7. **A tap can land on the wrong row** if the list is still settling. Scroll
   to the top with two flings and settle before tapping, and print the
   on-screen texts after the tap so the log proves which topic opened.
8. **`flutter drive` uninstalls the app when done.** Reinstall the build
   before poking at the device by hand (`adb shell run-as` etc.).
9. **Emulators.** Do not benchmark on one; the numbers mean nothing and
   the host machine here is not powerful enough to run it anyway.

## Porting to the XenForo app

- Replace the "open forum" block: push the app's thread-list page for a
  fixed public XenForo forum with long threads (pick one and keep it).
- Replace the two `_pumpUntil` markers ("Latest", "New to Discourse") with
  text that is reliably on that forum's first screen.
- Keep the fling geometry (`Offset(200, 760)`, `-520`, velocity 3000): it
  is in logical pixels and works on any phone-sized screen.
- Keep the labels `topic_list` and `thread` so the tables line up with the
  Discourse audit.

## The test, as used in ABDA

```dart
import 'package:abda/forums/discourse_probe.dart';           // ADAPT
import 'package:abda/main.dart' as app;                        // ADAPT
import 'package:discourse_ui/views/single_forum_bootstrap_page.dart'; // ADAPT
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'dart:ui' show FrameTiming;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('topic list and thread scrolling', (tester) async {
    app.main(); // void async: init runs, runApp follows; pump until it shows
    await _pumpUntil(tester, find.text('ABDA'), timeout: const Duration(seconds: 60)); // ADAPT
    if (find.text('Skip').evaluate().isNotEmpty) {                                      // ADAPT (onboarding)
      await tester.tap(find.text('Skip'));
      await _pumpUntil(tester, find.byTooltip('Open by address'));
    }

    // ADAPT: open one fixed forum directly, not through the UI.
    final probe = await probeDiscourse('https://meta.discourse.org');
    final site = probe.entry!.site;
    globalNavigatorKey.currentState!.push(MaterialPageRoute(
      builder: (_) => SingleForumBootstrapPage(site: site),
    ));
    await _pumpUntil(tester, find.text('Latest'), timeout: const Duration(seconds: 90));            // ADAPT
    await _pumpUntil(tester, find.textContaining('New to Discourse'), timeout: const Duration(seconds: 90)); // ADAPT
    await tester.pump(const Duration(seconds: 2));

    await _measure('topic_list', () => _flings(tester, 8));

    // Back to the top, then open the second row.
    await tester.fling(find.byType(Scrollable).first, const Offset(0, 4000), 8000);
    await _settle(tester, frames: 60);
    await tester.fling(find.byType(Scrollable).first, const Offset(0, 4000), 8000);
    await _settle(tester, frames: 60);
    await tester.tapAt(const Offset(200, 640));
    await tester.pump(const Duration(seconds: 6));
    await _settle(tester, frames: 30);

    // Prove the tap landed on a topic.
    final onScreen = find.byType(Text).evaluate()
        .map((e) => (e.widget as Text).data).whereType<String>().take(12).toList();
    // ignore: avoid_print
    print('PERF thread-screen latestChip=${find.text('Latest').evaluate().isNotEmpty} texts=$onScreen');
    await _measure('thread', () => _flings(tester, 8));
  });
}

/// Collects [FrameTiming] for every frame produced while [action] runs and
/// prints one summary line that `flutter drive` echoes to the console.
Future<void> _measure(String label, Future<void> Function() action) async {
  final frames = <FrameTiming>[];
  void collect(List<FrameTiming> t) => frames.addAll(t);
  SchedulerBinding.instance.addTimingsCallback(collect);
  await action();
  await Future<void>.delayed(const Duration(milliseconds: 500));
  SchedulerBinding.instance.removeTimingsCallback(collect);

  List<double> ms(Duration Function(FrameTiming) f) =>
      frames.map((t) => f(t).inMicroseconds / 1000).toList()..sort();
  double pct(List<double> v, double q) => v.isEmpty ? 0 : v[((v.length - 1) * q).round()];
  final build = ms((t) => t.buildDuration);
  final raster = ms((t) => t.rasterDuration);
  final total = ms((t) => t.totalSpan);
  int over(List<double> v, double b) => v.where((x) => x > b).length;
  // ignore: avoid_print
  print('PERF $label frames=${frames.length} '
      'build p50=${pct(build, .5).toStringAsFixed(1)} p90=${pct(build, .9).toStringAsFixed(1)} '
      'p99=${pct(build, .99).toStringAsFixed(1)} max=${build.isEmpty ? 0 : build.last.toStringAsFixed(0)} '
      '| raster p50=${pct(raster, .5).toStringAsFixed(1)} p90=${pct(raster, .9).toStringAsFixed(1)} '
      'p99=${pct(raster, .99).toStringAsFixed(1)} max=${raster.isEmpty ? 0 : raster.last.toStringAsFixed(0)} '
      '| total>16.7ms=${over(total, 16.7)} total>33ms=${over(total, 33)} '
      'build>16.7ms=${over(build, 16.7)} raster>16.7ms=${over(raster, 16.7)}');
}

Future<void> _flings(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.flingFrom(const Offset(200, 760), const Offset(0, -520), 3000);
    await _settle(tester, frames: 75);
  }
}

/// pumpAndSettle never settles while a spinner animates; pump a fixed count.
Future<void> _settle(WidgetTester tester, {required int frames}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 30)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  final texts = find.byType(Text).evaluate()
      .map((e) => (e.widget as Text).data).whereType<String>().take(30).toList();
  throw TestFailure('Timed out waiting for $finder; on screen: $texts');
}
```

## Results this method produced (Discourse module, Pixel 10a)

| metric | baseline | v1.0.7 | v1.0.8 |
|---|---|---|---|
| topic list build p50 / p90 | 6.9 / 14.9 ms | 3.3 / 11.3 ms | 0.8 / 2.1 ms |
| topic list frames over 16.7 ms | 31 % | 7 % | 3 % |
| thread worst frame | 83 ms | 51 ms | 47 ms |
| avatar cache misses / fallbacks | 598 / 88 | 129 / 0 | 94 / 0 |
