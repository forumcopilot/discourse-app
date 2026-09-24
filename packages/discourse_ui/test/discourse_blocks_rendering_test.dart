import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:discourse_ui/utils/local_dates.dart';
import 'package:discourse_ui/views/listitems/small_action_notice.dart';
import 'package:discourse_ui/views/widgets/discourse_blocks.dart';
import 'package:discourse_ui/views/widgets/post_content_callbacks.dart';
import 'package:discourse_ui/views/widgets/rich_text_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Discourse plugin markup the web draws with JavaScript: spoilers, local
/// dates, calendar events, math, Mermaid, polls in place, and small-action
/// posts. The HTML is the shape each plugin cooks, written out by hand.
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

final _bodyKey = GlobalKey();
final _opened = <String>[];

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

Future<void> _render(
  WidgetTester tester,
  String cooked, {
  Widget? Function(String)? pollBuilder,
  ThemeData? theme,
}) async {
  _opened.clear();
  final html = CookedContent.parse(cooked, forumBaseUrl: _forum).html;
  await tester.pumpWidget(_app(
    SizedBox(
      key: _bodyKey,
      width: 361,
      child: RichTextContent(
        siteContext: _ctx,
        content: html,
        callbacks: PostContentCallbacks(onUrlTap: _opened.add),
        pollBuilder: pollBuilder,
        webUrl: '$_forum/p/42',
      ),
    ),
    theme: theme,
  ));
  await tester.pumpAndSettle();
}

String _renderedText(WidgetTester tester) {
  final sb = StringBuffer();
  void walk(RenderObject r) {
    if (r is RenderParagraph) sb.write('${r.text.toPlainText()} ');
    r.visitChildren(walk);
  }

  walk(tester.renderObject(find.byKey(_bodyKey)));
  return sb.toString();
}

void main() {
  testWidgets('a spoiler is blurred until tapped', (tester) async {
    await _render(tester, '<p>The butler is <span class="spoiler">the gardener</span>.</p>');
    expect(find.byType(SpoilerBox), findsOneWidget);
    expect(find.byType(ImageFiltered), findsOneWidget);
    await tester.tap(find.byType(SpoilerBox));
    await tester.pump();
    expect(find.byType(ImageFiltered), findsNothing);
    expect(_renderedText(tester), contains('the gardener'));
  });

  testWidgets('a block spoiler hides its paragraphs too', (tester) async {
    await _render(tester, '<div class="spoiler"><p>Line one</p><p>Line two</p></div>');
    expect(find.byType(ImageFiltered), findsOneWidget);
  });

  testWidgets('a local date is shown in the reader\'s time, not as UTC text', (tester) async {
    await _render(tester,
        '<p>Starts <span class="discourse-local-date" data-date="2030-09-18" data-time="11:12" '
        'data-timezone="Europe/Berlin">2030-09-18T09:12:00Z</span>.</p>');
    final text = _renderedText(tester);
    expect(text, isNot(contains('2030-09-18T09:12:00Z')));
    final local = DateTime.utc(2030, 9, 18, 9, 12).toLocal();
    expect(text, contains(formatMoment(local, 'LLL', 'en_US')));
    expect(find.byIcon(Icons.public), findsOneWidget);
  });

  testWidgets('an event is a card with its name, time, place and description', (tester) async {
    await _render(tester,
        '<div class="discourse-post-event" data-start="2020-06-05 22:00" data-end="2020-06-05 23:00" '
        'data-status="public" data-name="Server reset" data-location="The main hall" '
        'data-timezone="Europe/London"><p>Bring snacks.</p></div>');
    expect(find.byType(PostEventCard), findsOneWidget);
    final text = _renderedText(tester);
    expect(text, contains('Server reset'));
    expect(text, contains('The main hall'));
    expect(text, contains('Bring snacks.'));
    expect(text, contains('Expired'));
    expect(text, contains('JUN'));
  });

  testWidgets('math is typeset, not printed as TeX', (tester) async {
    await _render(tester,
        '<p>Energy: <span class="math">E = mc^2</span></p><div class="math">\n\\sum_{i=0}^{n} i\n</div>');
    expect(find.byType(Math), findsNWidgets(2));
    expect(_renderedText(tester), isNot(contains(r'\sum_')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('bad TeX falls back to its source instead of failing', (tester) async {
    await _render(tester, r'<p><span class="math">\frac{1}{</span></p>');
    expect(_renderedText(tester), contains(r'\frac{1}{'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a Mermaid block says what it is and offers the web', (tester) async {
    await _render(tester,
        '<pre data-code-wrap="mermaid"><code class="lang-mermaid">graph TD\n  A--&gt;B\n</code></pre>');
    expect(find.text('Mermaid'), findsOneWidget);
    expect(_renderedText(tester), contains('graph TD'));
    await tester.tap(find.text('View on Web'));
    expect(_opened, ['$_forum/p/42']);
  });

  testWidgets('a poll is drawn in place from the live data', (tester) async {
    await _render(
      tester,
      '<p>Before</p><div class="poll" data-poll-name="poll" data-poll-status="open">'
      '<div class="poll-container"><ul><li data-poll-option-id="a">Yes</li></ul></div>'
      '<div class="poll-info"><span class="info-number">0</span> voters</div></div><p>After</p>',
      pollBuilder: (name) => name == 'poll' ? const SizedBox(key: Key('live-poll'), height: 80) : null,
    );
    final poll = tester.getRect(find.byKey(const Key('live-poll')));
    expect(poll.top, greaterThan(tester.getRect(find.text('Before', findRichText: true)).bottom));
    expect(poll.bottom, lessThan(tester.getRect(find.text('After', findRichText: true)).top));
    expect(_renderedText(tester), isNot(contains('voters')));
  });

  testWidgets('without live data the cooked poll stays, minus its stale count', (tester) async {
    await _render(tester,
        '<div class="poll" data-poll-name="poll"><div class="poll-container"><ul><li>Yes</li></ul></div>'
        '<div class="poll-info"><span class="info-number">0</span> voters</div></div>');
    final text = _renderedText(tester);
    expect(text, contains('Yes'));
    expect(text, isNot(contains('voters')));
  });

  group('small actions', () {
    FCPost post(String code, {String? who, String content = ''}) => FCPost(
          id: '9',
          title: '',
          content: content,
          topicId: '7',
          authorId: '1',
          authorName: 'mod',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          actionCode: code,
          actionCodeWho: who,
        );

    testWidgets('one line, in Discourse\'s words, with the action\'s icon', (tester) async {
      await tester.pumpWidget(_app(SmallActionNotice(post: post('closed.enabled'), siteContext: _ctx)));
      expect(find.textContaining('Closed '), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('who the action names', (tester) async {
      await tester.pumpWidget(_app(SmallActionNotice(post: post('invited_user', who: 'sam'), siteContext: _ctx)));
      expect(find.textContaining('Invited @sam'), findsOneWidget);
    });

    testWidgets('a moderator\'s note under the notice is shown', (tester) async {
      await tester.pumpWidget(_app(SmallActionNotice(
          post: post('closed.enabled', content: '<p>Please open a new topic.</p>'), siteContext: _ctx)));
      await tester.pump();
      expect(find.textContaining('Please open a new topic.', findRichText: true), findsOneWidget);
    });

    testWidgets('German wording comes from Discourse\'s translation', (tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SmallActionNotice(post: post('pinned.enabled'), siteContext: _ctx)),
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('Angeheftet'), findsOneWidget);
    });

    test('an unknown plugin code has no words; the notice shows the date', () async {
      final l = await AppLocalizations.delegate.load(const Locale('en'));
      expect(actionCodeText(l, 'some_plugin_thing', when: 'x', who: ''), isNull);
      expect(actionCodeText(l, 'assigned_to_post', when: 'today', who: '@sam'),
          'Assigned @sam today');
    });
  });

  testWidgets('everything renders in the dark theme', (tester) async {
    await _render(
      tester,
      '<p><span class="spoiler">x</span> <span class="math">x^2</span></p>'
      '<div class="discourse-post-event" data-start="2030-01-01 10:00" data-name="New year" data-timezone="UTC"></div>',
      theme: AppTheme.darkTheme,
    );
    expect(find.byType(PostEventCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
