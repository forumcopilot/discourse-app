import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Markup from real posts that made the renderer throw, found by the
/// 2026-09-23 re-crawl of every directory forum. Each must lay out with no
/// Flutter error.
const _cases = {
  // adminforge.de, amazondeveloper: a linked image in a table cell. The link
  // puts the image in a baseline-aligned placeholder, and the table's column
  // sizing asked RenderImage for a dry baseline it cannot give.
  'linked image in a table cell':
      '<table><tbody><tr><td><a href="https://x.org/u"><img loading="lazy" src="https://x.org/a.png" '
          'width="58" height="50"></a>Support our work.</td></tr></tbody></table>',
  // bcorpcommunity, bioexcel, blenderartists, concarne: the same inside a paragraph.
  'linked image in a paragraph in a table cell':
      '<table><tr><td colspan="2"><p><a href="https://x.org/u"><img src="https://x.org/a.png" width="123" height="45">'
          '</a></p></td></tr><tr><td><p><img src="https://x.org/b.png" width="29" height="29"></p></td>'
          '<td><p>A certified B Corp.</p></td></tr></table>',
  // anoma.net, beeminder: inline maths wider than the line overflowed it.
  'inline maths wider than the line':
      r'<p>Rate: <span class="math">\sum_{i=0}^{n} a_i b_i c_i d_i e_i f_i g_i h_i + '
          r'\frac{x_1 + x_2 + x_3 + x_4 + x_5 + x_6}{y_1 y_2 y_3 y_4 y_5 y_6 y_7}</span> per block.</p>',
  'inline maths in a table cell':
      r'<table><tr><td>Cost</td><td><span class="math">\frac{a+b}{c} \cdot \sum_{k=1}^{m} w_k</span></td></tr></table>',
};

void main() {
  for (final entry in _cases.entries) {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      testWidgets('${entry.key} (${theme.brightness.name})', (tester) async {
        final errors = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (d) => errors.add(d.exceptionAsString().split('\n').first);
        try {
          await tester.pumpWidget(MaterialApp(
            theme: theme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 361,
                  child: RichTextContent(
                    siteContext: SiteContext(
                      siteType: 'discourse',
                      site: Site(
                        id: null,
                        name: 'x',
                        url: 'https://x.org',
                        description: '',
                        logoUrl: null,
                        backgroundUrl: null,
                        endpoint: null,
                        baseUrl: 'https://x.org',
                        siteType: 'discourse',
                        language: null,
                      ),
                    ),
                    content: CookedContent.parse(entry.value, forumBaseUrl: 'https://x.org').html,
                  ),
                ),
              ),
            ),
          ));
          await tester.pump();
        } finally {
          FlutterError.onError = previous;
        }
        expect(errors, isEmpty);
      });
    }
  }
}
