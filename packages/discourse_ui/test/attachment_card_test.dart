import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-image uploads in cooked HTML render as a card, not a bare link.
///
/// Discourse cooks `[notes.txt|attachment](upload://…) (117 Bytes)` to
/// `<a class="attachment" href="…">notes.txt</a> (117 Bytes)` — the size
/// is loose text after the anchor. The renderer folds it into the card and
/// must not also leave it dangling in the paragraph.
void main() {
  const url = 'https://forum.example';
  final siteContext = SiteContext(
    siteType: 'discourse',
    site: Site(
      id: null,
      name: 'Example',
      url: url,
      description: 'attachment card test',
      endpoint: null,
      baseUrl: url,
      logoUrl: null,
      backgroundUrl: null,
      siteType: 'discourse',
    ),
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester, String html) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: RichTextContent(siteContext: siteContext, content: html),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('an attachment link becomes a card with name, size and actions',
      (tester) async {
    await pump(
      tester,
      '<p><a class="attachment" href="/uploads/short-url/abc.txt">notes.txt</a> (117 Bytes)</p>',
    );

    expect(find.text('notes.txt'), findsOneWidget);
    expect(find.textContaining('117 Bytes'), findsOneWidget);
    // The loose "(117 Bytes)" after the anchor was folded into the card.
    expect(find.textContaining('(117 Bytes)'), findsNothing);
    expect(find.byTooltip('Share'), findsOneWidget);
    expect(find.byTooltip('Download'), findsOneWidget);
  });

  testWidgets('an attachment without a size still renders as a card',
      (tester) async {
    await pump(
      tester,
      '<p><a class="attachment" href="/uploads/short-url/abc.pdf">spec.pdf</a></p>',
    );
    expect(find.text('spec.pdf'), findsOneWidget);
    expect(find.byTooltip('Download'), findsOneWidget);
  });

  testWidgets('an ordinary link is not turned into a card', (tester) async {
    await pump(tester, '<p>See <a href="https://example.com/x">the docs</a>.</p>');
    expect(find.byTooltip('Download'), findsNothing);
    expect(find.textContaining('the docs'), findsOneWidget);
  });
}
