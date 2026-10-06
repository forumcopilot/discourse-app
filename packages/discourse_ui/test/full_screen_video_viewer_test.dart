import 'dart:async';

import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/widgets/full_screen_video_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class _Player extends VideoPlayerPlatform {
  final events = StreamController<VideoEvent>();
  int plays = 0;
  Duration position = Duration.zero;

  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    events.add(VideoEvent(
      eventType: VideoEventType.initialized,
      duration: const Duration(seconds: 3),
      size: const Size(640, 360),
    ));
    return 1;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => events.stream;
  @override
  Future<void> dispose(int playerId) async {}
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
    await player.events.close();
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home:
          const FullScreenVideoViewer(videoUrl: 'https://example.com/clip.mp4'),
    ));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
    expect(find.byTooltip('Pause'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
  }

  testWidgets('completion changes Pause to Play and can replay',
      (tester) async {
    await open(tester);
    player.events.add(VideoEvent(eventType: VideoEventType.completed));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.play_circle_filled), findsOneWidget);
    expect(find.byTooltip('Play'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.play_circle_filled));
    await tester.pumpAndSettle();
    expect(player.plays, 2);
    expect(player.position, Duration.zero);
    expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a playback failure after initialization shows an error',
      (tester) async {
    await open(tester);
    player.events.addError(
        PlatformException(code: 'VideoError', message: 'Playback interrupted'));
    await tester.pumpAndSettle();
    expect(find.text('Playback interrupted'), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle_filled), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
