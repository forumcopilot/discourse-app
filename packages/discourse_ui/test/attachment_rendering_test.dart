import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/forum_media.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/views/chat/widgets/chat_uploads.dart';
import 'package:discourse_ui/views/widgets/attachment_file_card.dart';
import 'package:discourse_ui/views/widgets/broken_image_widget.dart';
import 'package:discourse_ui/views/widgets/embed_cards.dart';
import 'package:discourse_ui/views/widgets/full_screen_image_viewer.dart';
import 'package:discourse_ui/views/widgets/image_actions.dart';
import 'package:discourse_ui/views/widgets/post_body_extensions.dart';
import 'package:discourse_ui/views/widgets/post_content_callbacks.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// How a post's and a chat message's uploads render and open: pictures,
/// files, videos. The HTML is the shape Discourse cooks, written by hand.
const _forum = 'https://forum.example.com';

final _ctx = SiteContext(
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

Widget _app(Widget child, {Locale? locale, List<NavigatorObserver> observers = const []}) => MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: observers,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(child: SizedBox(width: 361, child: child)),
        ),
      ),
    );

/// Three lightboxed uploads as Discourse cooks them: the anchor's href is
/// the original, the <img src> a resized copy.
String _lightboxed(int n) => '''
<div class="lightbox-wrapper"><a class="lightbox" href="/uploads/default/original/1X/pic$n.jpeg" title="pic$n">
<img src="/uploads/default/optimized/1X/pic${n}_2_690x460.jpeg" alt="pic$n" width="690" height="460">
<div class="meta"><span class="filename">pic$n</span></div></a></div>''';

final _threePictures = '<p>${_lightboxed(1)}</p><p>${_lightboxed(2)}</p><p>${_lightboxed(3)}</p>';

class _Pushes extends NavigatorObserver {
  final routes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => routes.add(route);
}

void main() {
  group('pictures in a post', () {
    testWidgets('tapping the second of three lightboxed pictures opens the gallery at the second',
        (tester) async {
      final cooked = CookedContent.parse(_threePictures, forumBaseUrl: _forum).html;
      final tapped = <String>[];
      await tester.pumpWidget(_app(RichTextContent(
        siteContext: _ctx,
        content: cooked,
        callbacks: PostContentCallbacks(onImageTap: (url, _, __) => tapped.add(url)),
      )));
      await tester.pump();

      await tester.tap(find.byType(Image).at(1));
      expect(tapped, ['$_forum/uploads/default/original/1X/pic2.jpeg'],
          reason: 'the original, which the gallery lists — not the resized <img src>');

      // What ImageActions.handleShowImage opens for that tap.
      final gallery = ImageActions.bodyGallery(_threePictures, tapped.single, forumBaseUrl: _forum);
      expect(gallery.urls, hasLength(3));
      expect(gallery.index, 1);
    });

    test('the gallery lists pictures in the order the post shows them', () {
      final cooked = '<p><img src="/uploads/default/original/1X/plain.png" width="100" height="80"></p>'
          '${_lightboxed(1)}';
      expect(CookedContent.parse(cooked, forumBaseUrl: _forum).imageUrls, [
        '$_forum/uploads/default/original/1X/plain.png',
        '$_forum/uploads/default/original/1X/pic1.jpeg',
      ]);
    });

    testWidgets('an inline picture has the grid\'s 8dp corners; an icon keeps its own', (tester) async {
      await tester.pumpWidget(_app(RichTextContent(
        siteContext: _ctx,
        content: '<p><img src="/uploads/default/original/1X/big.png" width="690" height="388"></p>'
            '<p><img src="/uploads/default/original/1X/icon.png" width="16" height="16"></p>',
      )));
      await tester.pump();

      ClipRRect? clipOf(int i) {
        final clips = find.ancestor(of: find.byType(Image).at(i), matching: find.byType(ClipRRect));
        return clips.evaluate().isEmpty ? null : tester.widget<ClipRRect>(clips.first);
      }

      expect(clipOf(0)?.borderRadius, BorderRadius.circular(ImageGrid.radius));
      expect(clipOf(1), isNull);
    });

    testWidgets('an upload the forum could not find shows the broken-picture box', (tester) async {
      const cooked = '<p><img src="/images/transparent.png" alt="lost photo" '
          'data-orig-src="upload://a1b2c3.png" width="690" height="388"></p>';
      final tapped = <String>[];
      await tester.pumpWidget(_app(RichTextContent(
        siteContext: _ctx,
        content: cooked,
        callbacks: PostContentCallbacks(onImageTap: (url, _, __) => tapped.add(url)),
      )));
      await tester.pump();

      expect(find.byType(BrokenImagePlaceholder), findsOneWidget);
      expect(find.text('lost photo'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      // Not a picture to open, in place or in the gallery.
      await tester.tap(find.byType(BrokenImagePlaceholder));
      expect(tapped, isEmpty);
      expect(CookedContent.parse(cooked, forumBaseUrl: _forum).imageUrls, isEmpty);
    });
  });

  group('videos', () {
    testWidgets('an uploaded video is announced as "Video", not its hash file name', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(RichTextContent(
        siteContext: _ctx,
        content: '<div class="video-placeholder-container" '
            'data-video-src="/uploads/default/original/1X/0f3c9a7be1d24e.mp4"></div>',
      )));
      await tester.pump();

      expect(find.bySemanticsLabel('Video'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('0f3c9a7be1d24e')), findsNothing);
      semantics.dispose();
    });

    testWidgets("a chat video keeps its author's file name", (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(const PostVideoCard(
          src: '$_forum/uploads/default/original/1X/0f3c9a.mp4', title: 'holiday.mp4')));
      expect(find.bySemanticsLabel('holiday.mp4'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('files', () {
    testWidgets('the Download tooltip is translated', (tester) async {
      await tester.pumpWidget(_app(
        RichTextContent(
          siteContext: _ctx,
          content: '<p><a class="attachment" href="/uploads/short-url/abc.pdf">spec.pdf</a> (1.2 MB)</p>',
        ),
        locale: const Locale('de'),
      ));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Herunterladen'), findsOneWidget);
    });

    testWidgets('opening a file downloads it signed in, shows progress, then offers it to the system',
        (tester) async {
      // The forum refuses a guest (prevent_anons_from_downloading_files).
      final gate = Completer<void>();
      final seen = <bool>[];
      ForumMedia.debugDio = Dio()
        ..httpClientAdapter = _Adapter((r) async {
          final keyed = r.headers.containsKey('User-Api-Key');
          seen.add(keyed);
          if (!keyed) return ResponseBody.fromString('', 404);
          await gate.future;
          return ResponseBody.fromBytes(Uint8List.fromList('%PDF'.codeUnits), 200);
        });
      addTearDown(() => ForumMedia.debugDio = null);
      final shared = <MethodCall>[];
      const channel = MethodChannel('dev.fluttercommunity.plus/share');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        shared.add(call);
        return 'dev.fluttercommunity.plus/share/success';
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

      await tester.pumpWidget(_app(const AttachmentFileCard(
        name: 'spec.pdf',
        url: '$_forum/uploads/short-url/abc.pdf',
        size: '1.2 MB',
        auth: ForumMediaAuth(siteUrl: _forum, credentials: {'User-Api-Key': 'k', 'User-Api-Client-Id': 'c'}),
      )));

      await tester.runAsync(() async {
        await tester.tap(find.text('spec.pdf'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();
      // While it downloads, Download is a progress ring that cancels.
      expect(find.byTooltip('Cancel'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.runAsync(() async {
        gate.complete();
        for (var i = 0; i < 20 && shared.isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      });
      await tester.pump();

      expect(seen, [false, true], reason: 'asked without the key, then with it once refused');
      final paths = (shared.single.arguments as Map)['paths'] as List;
      expect(paths.single, endsWith('/spec.pdf'));
      expect(File(paths.single as String).readAsStringSync(), '%PDF');
      expect(find.byTooltip('Download'), findsOneWidget);
      await tester.runAsync(() => File(paths.single as String).parent.delete(recursive: true));
    });
  });

  group('chat uploads use the post widgets', () {
    FCAttachment upload(String name, {int? width, int? height, int size = 2048}) => FCAttachment(
          id: name,
          filename: name,
          fileSize: size,
          url: '$_forum/uploads/default/original/1X/${name.hashCode}.${name.split('.').last}',
          isImage: width != null,
          width: width,
          height: height,
          canViewUrl: true,
        );

    testWidgets('pictures as a grid without captions; a file, a video and a sound as in a post',
        (tester) async {
      final pushes = _Pushes();
      await tester.pumpWidget(_app(
        ChatUploads(
          siteContext: _ctx,
          messageId: 7,
          uploads: [
            upload('beach.jpg', width: 800, height: 600),
            upload('dunes.png', width: 600, height: 800),
            upload('sunset.webp', width: 1000, height: 500),
            upload('report.pdf'),
            upload('holiday.mp4'),
            upload('voice.m4a'),
          ],
        ),
        observers: [pushes],
      ));
      await tester.pump();

      expect(find.byType(ImageGrid), findsOneWidget);
      for (final name in ['beach.jpg', 'dunes.png', 'sunset.webp']) {
        expect(find.text(name), findsNothing, reason: 'no file-name caption under a picture');
      }
      expect(find.widgetWithText(AttachmentFileCard, 'report.pdf'), findsOneWidget);
      final download = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.download_rounded));
      expect(download.onPressed, isNotNull, reason: 'a chat file can be opened');
      expect(find.byType(PostVideoCard), findsOneWidget);
      expect(find.byType(PostAudioPlayer), findsOneWidget);

      // The second picture (masonry puts it in the right-hand column) opens
      // the gallery on the second picture.
      final pages = pushes.routes.length;
      final dunes = '${'dunes.png'.hashCode}';
      await tester.tap(find.byWidgetPredicate((w) =>
          w is Image && w.image is NetworkImage && (w.image as NetworkImage).url.contains(dunes)));
      final route = pushes.routes.skip(pages).single as MaterialPageRoute;
      final viewer = route.builder(tester.element(find.byType(ChatUploads))) as FullScreenImageViewer;
      expect(viewer.imageUrls, hasLength(3));
      expect(viewer.initialIndex, 1);
      expect(viewer.imageUrls[1], contains(dunes));
      route.navigator!.removeRoute(route);
      await tester.pump();
    });

    testWidgets('one picture is drawn as a post draws one: its proportions, 8dp corners', (tester) async {
      await tester.pumpWidget(_app(ChatUploads(
        siteContext: _ctx,
        messageId: 8,
        uploads: [upload('cat.png', width: 400, height: 200)],
      )));
      await tester.pump();

      expect(find.byType(ImageGrid), findsNothing);
      expect(find.text('cat.png'), findsNothing);
      final clip = tester.widget<ClipRRect>(
          find.ancestor(of: find.byType(Image), matching: find.byType(ClipRRect)).first);
      expect(clip.borderRadius, BorderRadius.circular(ImageGrid.radius));
      final size = tester.getSize(find.byType(AspectRatio));
      expect(size.width, 361, reason: 'the width it has, no wider than the picture (400)');
      expect(size.width / size.height, closeTo(2, 0.01));
    });
  });
}

class _Adapter implements HttpClientAdapter {
  _Adapter(this.answer);

  final Future<ResponseBody> Function(RequestOptions request) answer;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
          Future<void>? cancelFuture) =>
      answer(options);

  @override
  void close({bool force = false}) {}
}
