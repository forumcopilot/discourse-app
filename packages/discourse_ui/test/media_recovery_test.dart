import 'dart:async';
import 'dart:ui' show SemanticsAction;

import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/views/widgets/full_screen_video_viewer.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:flutter/material.dart';
import 'package:discourse_ui/views/widgets/embed_cards.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

const _forum = 'https://forum.example.com';
final _siteContext = SiteContext(
  siteType: 'discourse',
  site: Site(
    id: null,
    name: 'Example',
    url: _forum,
    description: '',
    logoUrl: null,
    backgroundUrl: null,
    endpoint: null,
    baseUrl: _forum,
    siteType: 'discourse',
    language: null,
  ),
);

class _Player extends VideoPlayerPlatform {
  final streams = <int, StreamController<VideoEvent>>{};
  final disposed = <int>[];
  bool failNext = false;
  StreamController<VideoEvent> get events => streams[streams.length]!;
  int plays = 0;
  Duration position = Duration.zero;

  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = streams.length + 1;
    final fail = failNext;
    failNext = false;
    streams[id] = StreamController<VideoEvent>.broadcast(onListen: () {
      if (fail) {
        streams[id]!.addError(PlatformException(
            code: 'VideoError', message: 'Connection interrupted'));
      } else {
        streams[id]!.add(VideoEvent(
            eventType: VideoEventType.initialized,
            duration: const Duration(seconds: 3),
            size: const Size(640, 360)));
      }
    });
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => streams[playerId]!.stream;
  @override
  Future<void> dispose(int playerId) async {
    disposed.add(playerId);
  }

  @override
  Future<void> play(int playerId) async {
    plays++;
  }

  @override
  Future<void> pause(int playerId) async {}
  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> setVolume(int playerId, double volume) async {}
  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Future<Duration> getPosition(int playerId) async => position;
  @override
  Future<void> seekTo(int playerId, Duration value) async {
    position = value;
  }

  @override
  Widget buildViewWithOptions(VideoViewOptions options) => const SizedBox();
}

void main() {
  late _Player player;
  late VideoPlayerPlatform original;
  setUp(() {
    original = VideoPlayerPlatform.instance;
    player = _Player();
    VideoPlayerPlatform.instance = player;
  });
  tearDown(() async {
    VideoPlayerPlatform.instance = original;
    for (final stream in player.streams.values) {
      await stream.close();
    }
  });

  Future<void> open(WidgetTester tester, bool audio,
      {double textScale = 1, Locale locale = const Locale('en')}) async {
    await tester.pumpWidget(MaterialApp(
      locale: locale,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: audio
          ? const Scaffold(
              body: PostAudioPlayer(src: 'https://example.com/a.mp3'))
          : const FullScreenVideoViewer(videoUrl: 'https://example.com/v.mp4'),
    ));
    await tester.pumpAndSettle();
    if (audio) {
      final l10n =
          AppLocalizations.of(tester.element(find.byType(PostAudioPlayer)))!;
      await tester.tap(find.byTooltip(l10n.mediaPlay));
      await tester.pumpAndSettle();
    }
  }

  for (final audio in [true, false]) {
    for (final size in [const Size(320, 568), const Size(568, 320)]) {
      testWidgets(
          '${audio ? 'audio' : 'video'} recovery is accessible at $size with large text',
          (tester) async {
        // The view, not just the surface, so MediaQuery reports this screen.
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final semantics = tester.ensureSemantics();
        try {
          player.failNext = true;
          // German exercises longer translated labels on a compact display.
          await open(tester, audio, textScale: 2, locale: const Locale('de'));
          final l10n =
              AppLocalizations.of(tester.element(find.byType(Scaffold)))!;
          final error = tester.getSemantics(find.text(
            audio ? l10n.failedToLoadAudio : l10n.failedToLoadVideo,
          ));
          expect(error.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
          final retry = find.text(l10n.retryButton);
          await tester.ensureVisible(retry);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          final node = tester.getSemantics(retry);
          expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
          expect(
              node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
          // Activate through the screen-reader action instead of a pointer tap.
          tester.semantics.tap(find.semantics.byLabel(l10n.retryButton));
          await tester.pumpAndSettle();
          expect(find.byTooltip(l10n.mediaPause), findsOneWidget);
          expect(find.text(l10n.retryButton), findsNothing);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        } finally {
          semantics.dispose();
        }
      });
    }
    for (final initial in [true, false]) {
      testWidgets(
          '${audio ? 'audio' : 'video'} retries ${initial ? 'initial' : 'late'} failure',
          (tester) async {
        player.failNext = initial;
        await open(tester, audio);
        if (!initial) {
          player.events.addError(PlatformException(
              code: 'VideoError', message: 'Connection interrupted'));
          await tester.pumpAndSettle();
        }
        expect(find.text('Retry'), findsOneWidget);
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(player.streams.length, 2);
        // Let asynchronous platform disposal finish outside the frame clock.
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)));
        await tester.pump();
        expect(player.disposed, contains(1));
        expect(find.byTooltip('Pause'), findsOneWidget);
        expect(find.text('Retry'), findsNothing);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        // Let asynchronous platform disposal finish outside the frame clock.
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)));
        await tester.pump();
        expect(player.disposed, contains(2));
      });
    }
  }
  testWidgets('audio in a post table lays out', (tester) async {
    // Post tables size their cells from intrinsic sizes, which a
    // LayoutBuilder in the player cannot report.
    final html = CookedContent.parse(
      '<table><thead><tr><th>A</th><th>B</th></tr></thead><tbody><tr>'
      '<td>x</td><td><audio controls><source src="$_forum/a.mp3"></audio></td>'
      '</tr></tbody></table>',
      forumBaseUrl: _forum,
    ).html;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: 361,
            child: RichTextContent(siteContext: _siteContext, content: html),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(PostAudioPlayer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('video retries again after the retry fails', (tester) async {
    player.failNext = true;
    await open(tester, false);
    player.failNext = true;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Pause'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    // Let asynchronous platform disposal finish outside the frame clock.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump();
    expect(player.disposed, containsAll([1, 2, 3]));
  });

  testWidgets('a second video Retry before the next frame keeps one player',
      (tester) async {
    player.failNext = true;
    await open(tester, false);
    await tester.tap(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    // Let asynchronous platform disposal finish outside the frame clock.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump();
    final last = player.streams.length;
    expect(player.disposed, containsAll([for (var id = 1; id < last; id++) id]));
    expect(player.disposed, isNot(contains(last)));
    expect(find.byTooltip('Pause'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump();
    expect(player.disposed, contains(last));
  });
}
