// App-level smoke test: verifies that ForumCopilotApp builds and renders a
// (Get)MaterialApp inside the headless widget-test environment.
//
// Why this test needs the setup below (it used to hang for the full 10-minute
// testWidgets timeout):
//
// 1. Startup code awaits platform channels (SharedPreferences in
//    SettingsContext.loadFromDevice / DiscourseSiteController._initializeApp,
//    flutter_secure_storage in the Discourse auth manager). Unmocked channels
//    never answer inside the test's FakeAsync zone, so those awaits pended
//    forever and their 10-second AsyncUtils.withTimeout timers stayed pending
//    ("Pending timers" failure). Mocking the channels lets startup run to a
//    quiescent state (the bootstrap page's "Retry Connection" error UI, since
//    the test HTTP client answers every request with HTTP 400).
// 2. SettingsContext.loadFromDevice fire-and-forgets Get.updateLocale(), whose
//    forceAppUpdate() -> RendererBinding.performReassemble() calls
//    scheduleWarmUpFrame(). Under AutomatedTestWidgetsFlutterBinding that
//    trips the 'schedulerPhase == SchedulerPhase.idle' assertion, which
//    surfaces as an uncaught zone error. The runZonedGuarded below tolerates
//    exactly that known GetX-vs-test-binding artifact and fails on anything
//    else.
// 3. ForumCopilotApp.initState calls setupErrorHandling(), which replaces
//    FlutterError.onError and PlatformDispatcher.onError. flutter_test
//    requires FlutterError.onError back at teardown — combined with (2) the
//    harness's own error reporting deadlocked, which is what turned a failure
//    into the historical 10-minute hang. Both handlers are restored in a
//    tearDown.
//
// All mocks live here in the test; production code is untouched.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:discourse_ui/forumcopilot_app.dart';

void main() {
  testWidgets('ForumCopilotApp smoke test', (WidgetTester tester) async {
    // In-memory SharedPreferences so settings/context loads complete.
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // Empty flutter_secure_storage so credential hydration completes
    // (no persisted User API Key -> guest path).
    const MethodChannel secureStorageChannel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      secureStorageChannel,
      (MethodCall call) async {
        switch (call.method) {
          case 'read':
            return null;
          case 'readAll':
            return <String, String>{};
          case 'containsKey':
            return false;
          default:
            return null; // write / delete / deleteAll: no-op
        }
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(secureStorageChannel, null);
    });

    // setupErrorHandling() (run in ForumCopilotApp.initState) replaces the
    // global error handlers; flutter_test requires them back at teardown.
    final originalFlutterOnError = FlutterError.onError;
    final originalPlatformOnError = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = originalFlutterOnError;
      PlatformDispatcher.instance.onError = originalPlatformOnError;
    });

    final List<Object> unexpectedZoneErrors = <Object>[];
    await runZonedGuarded(() async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ForumCopilotApp());

      // Verify that the app loads without crashing: the widget tree built
      // and a MaterialApp (GetMaterialApp) is rendered.
      expect(find.byType(MaterialApp), findsOneWidget);

      // Drain startup async work so no fake timers are left pending at
      // teardown: run the post-frame init, expire the 10s startup timeouts
      // (getConfig fails fast against the test HTTP client), then let the
      // progress-dialog route transition finish.
      await tester.pump();
      await tester.pump(const Duration(seconds: 11));
      await tester.pump(const Duration(seconds: 1));
    }, (Object error, StackTrace stack) {
      // Tolerate only the known GetX reassemble artifact (see header note 2);
      // anything else fails the test below.
      final bool isKnownGetxReassembleAssert = error is AssertionError &&
          error.toString().contains('schedulerPhase == SchedulerPhase.idle') &&
          stack.toString().contains('forceAppUpdate');
      if (!isKnownGetxReassembleAssert) {
        unexpectedZoneErrors.add(error);
      }
    });

    expect(unexpectedZoneErrors, isEmpty);

    // Still alive after startup settled into its quiescent state.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
