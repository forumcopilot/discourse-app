import 'dart:async';
import 'dart:io';

import 'package:discourse_core/discourse_core.dart' show DiscourseUploadMetadata;
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';
// ignore: depend_on_referenced_packages
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Uploads go into the text where the writer is, as on the web: a
/// placeholder at the cursor while the file uploads, then the Markdown
/// Discourse renders. Removing the tile takes the Markdown out; deleting the
/// Markdown drops the tile and tells the page. They used to sit in a list
/// under the text and be appended at the end on send.
void main() {
  late Directory tmp;
  late File photo;

  setUp(() async {
    DiscourseUploadMetadata.reset();
    tmp = await Directory.systemTemp.createTemp('composer_uploads');
    photo = File('${tmp.path}/beach.png')..writeAsBytesSync(_png);
    FilePicker.platform = _Picker([photo.path]);
  });

  tearDown(() => tmp.delete(recursive: true));

  Future<({TextEditingController text, Completer<String?> upload, List<String> removed})>
      pumpComposer(WidgetTester tester) async {
    final text = TextEditingController(text: 'Before\nAfter');
    final upload = Completer<String?>();
    final removed = <String>[];
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MessageComposePage(
        siteContext: _site(),
        title: 'Reply',
        autoFocusContent: false,
        contentController: text,
        onSubmit: (_, __) async => true,
        onFileUpload: (_) => upload.future,
        onRemoveAttachment: (id) async => removed.add(id),
      ),
    ));
    // Past the composer's delayed first focus (it is told not to focus).
    await tester.pump(const Duration(milliseconds: 150));
    // The cursor after "Before", where the photo should go.
    text.selection = const TextSelection.collapsed(offset: 6);
    return (text: text, upload: upload, removed: removed);
  }

  testWidgets('a photo goes where the cursor is, then becomes its Markdown',
      (tester) async {
    final c = await pumpComposer(tester);
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Upload image'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    expect(c.text.text, 'Before\n[Uploading: beach.png…]()\nAfter');
    expect(find.bySemanticsLabel('beach.png'), findsOneWidget);

    c.upload.complete('upload://abc.png');
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(c.text.text, 'Before\n![image](upload://abc.png)\nAfter');
  });

  testWidgets('removing the tile takes its Markdown out of the text',
      (tester) async {
    final c = await pumpComposer(tester);
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Upload image'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    c.upload.complete('upload://abc.png');
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    await tester.tap(find.byTooltip('Remove'));
    await tester.pump();
    expect(c.text.text, 'Before\nAfter');
    expect(c.removed, ['upload://abc.png']);
    expect(find.bySemanticsLabel('beach.png'), findsNothing);
  });

  testWidgets('deleting the Markdown drops the tile and tells the page',
      (tester) async {
    final c = await pumpComposer(tester);
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Upload image'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    c.upload.complete('upload://abc.png');
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    c.text.text = 'Before\nAfter';
    await tester.pump();
    expect(find.bySemanticsLabel('beach.png'), findsNothing);
    expect(c.removed, ['upload://abc.png']);
  });

  testWidgets('three photos picked together go in a grid', (tester) async {
    final more = [
      for (final n in ['a', 'b'])
        File('${tmp.path}/$n.png')..writeAsBytesSync(_png),
    ];
    FilePicker.platform = _Picker([photo.path, ...more.map((f) => f.path)]);
    final c = await pumpComposer(tester);
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Upload image'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    expect(
        c.text.text,
        'Before\n[grid]\n[Uploading: beach.png…]()\n'
        '[Uploading: a.png…]()\n[Uploading: b.png…]()\n[/grid]\nAfter');
    c.upload.complete(null);
  });

  testWidgets('a failed upload takes its placeholder out', (tester) async {
    final c = await pumpComposer(tester);
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip('Upload image'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    c.upload.complete(null); // the page has said why
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(c.text.text, 'Before\nAfter');
    expect(find.bySemanticsLabel('beach.png'), findsNothing);
  });
}

SiteContext _site() => SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Test',
        url: 'https://forum.example',
        description: '',
        endpoint: null,
        baseUrl: 'https://forum.example',
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      ),
    );

class _Picker extends FilePicker with MockPlatformInterfaceMixin {
  _Picker(this.paths);
  final List<String> paths;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async =>
      FilePickerResult([
        for (final p in paths)
          PlatformFile(
              path: p,
              name: p.split('/').last,
              size: File(p).lengthSync()),
      ]);
}

/// A 1×1 PNG.
const _png = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0,
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];
