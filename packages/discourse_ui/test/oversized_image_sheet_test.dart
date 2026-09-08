import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/l10n/generated/app_localizations_en.dart';
import 'package:discourse_ui/settings_context.dart';
import 'package:discourse_ui/utils/file_utils.dart';
import 'package:discourse_ui/views/widgets/oversized_image_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The consent sheet shown before an oversized image is rewritten.
///
/// This exists because the app used to shrink silently — a 20 MB PNG went
/// up as a 2.2 MB JPEG and nobody was told. The sheet is the fix, so it
/// must say the real numbers, must not remember anything unless asked, and
/// must remember exactly what was asked.
void main() {
  final l10n = AppLocalizationsEn();
  const fileBytes = 20 * 1024 * 1024;
  const maxBytes = 10 * 1024 * 1024;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SettingsContext.instance.alwaysResizeOversizedImages.value = false;
  });

  Future<OversizedImageChoice?> Function() pumpSheet(WidgetTester tester) {
    OversizedImageChoice? result;
    var closed = false;
    return () async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showOversizedImageSheet(
                  context,
                  fileName: 'big-photo.png',
                  fileBytes: fileBytes,
                  maxBytes: maxBytes,
                );
                closed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(closed, isFalse, reason: 'sheet should be open');
      return result;
    };
  }

  testWidgets('tells the user the file size and the forum limit',
      (tester) async {
    await pumpSheet(tester)();
    expect(find.text(l10n.imageIsTooLargeToUpload), findsOneWidget);
    expect(
      find.text(l10n.fileTooLargeForForum(
          'big-photo.png', formatFileSize(fileBytes), formatFileSize(maxBytes))),
      findsOneWidget,
    );
    expect(find.text(l10n.resizeAndUpload), findsOneWidget);
    expect(find.text(l10n.dontUpload), findsOneWidget);
  });

  testWidgets('declining returns skip and remembers nothing', (tester) async {
    final open = pumpSheet(tester);
    await open();
    await tester.tap(find.text(l10n.dontUpload));
    await tester.pumpAndSettle();
    expect(SettingsContext.instance.alwaysResizeOversizedImages.value, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('always_resize_oversized_images'), isNull);
  });

  testWidgets('resizing once does not turn on "always"', (tester) async {
    await pumpSheet(tester)();
    await tester.tap(find.text(l10n.resizeAndUpload));
    await tester.pumpAndSettle();
    expect(SettingsContext.instance.alwaysResizeOversizedImages.value, isFalse);
  });

  testWidgets('"don\'t ask again" persists only when ticked and confirmed',
      (tester) async {
    await pumpSheet(tester)();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text(l10n.resizeAndUpload));
    await tester.pumpAndSettle();

    expect(SettingsContext.instance.alwaysResizeOversizedImages.value, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('always_resize_oversized_images'), isTrue);
  });

  testWidgets('ticking the box and then declining remembers nothing',
      (tester) async {
    await pumpSheet(tester)();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text(l10n.dontUpload));
    await tester.pumpAndSettle();
    expect(SettingsContext.instance.alwaysResizeOversizedImages.value, isFalse);
  });
}
