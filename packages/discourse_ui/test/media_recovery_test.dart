import 'dart:async';

import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/widgets/full_screen_video_viewer.dart';
import 'package:flutter/material.dart';
import 'package:discourse_ui/views/widgets/embed_cards.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

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

  Future<void> open(WidgetTester tester, bool audio) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: audio
          ? const Scaffold(
              body: PostAudioPlayer(src: 'https://example.com/a.mp3'))
          : const FullScreenVideoViewer(videoUrl: 'https://example.com/v.mp4'),
    ));
    await tester.pumpAndSettle();
    if (audio) {
      await tester.tap(find.byTooltip('Play'));
      await tester.pumpAndSettle();
    }
  }

  for (final audio in [true, false]) {
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
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
        await tester.pump();
        expect(player.disposed, contains(1));
        expect(find.byTooltip('Pause'), findsOneWidget);
        expect(find.text('Retry'), findsNothing);
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        // Let asynchronous platform disposal finish outside the frame clock.
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
        await tester.pump();
        expect(player.disposed, contains(2));
      });
    }
  }
}
