import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/views/widgets/post_content_callbacks.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// ABDA's "Sent from ABDA" line, as Discourse cooks it (checked against a
/// local Discourse), reads as a footnote in the app as on the web: smaller
/// than the post, with the name a link.
const _forum = 'https://forum.example.com';

void main() {
  testWidgets('the Sent from line is small, and its name a link',
      (tester) async {
    const cooked = '<p>Thanks, that fixed it for me as well.</p>\n'
        '<p><small>Sent from <a href="https://betterdiscourse.app" '
        'rel="noopener nofollow ugc">ABDA</a></small></p>';
    final html = CookedContent.parse(cooked, forumBaseUrl: _forum).html;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: RichTextContent(
          siteContext: SiteContext(
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
            ),
          ),
          content: html,
          callbacks: const PostContentCallbacks(),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final spans = <TextSpan>[];
    void walk(RenderObject r) {
      if (r is RenderParagraph) {
        r.text.visitChildren((s) {
          if (s is TextSpan && (s.text ?? '').trim().isNotEmpty) spans.add(s);
          return true;
        });
      }
      r.visitChildren(walk);
    }

    walk(tester.renderObject(find.byType(RichTextContent)));
    double sizeOf(TextSpan s) => s.style?.fontSize ?? 0;
    TextSpan span(String text) =>
        spans.firstWhere((s) => s.text!.contains(text));
    // Styles inherit down the span tree; the effective size is the nearest
    // one set, which the renderer sets on each run of text.
    final body = span('Thanks');
    final line = span('Sent from');
    final name = span('ABDA');
    expect(sizeOf(body), 16);
    expect(sizeOf(line), inExclusiveRange(10, 16)); // 13.28: small is 0.83em
    expect(sizeOf(name), sizeOf(line));
    expect(name.recognizer, isA<TapGestureRecognizer>());
  });
}
