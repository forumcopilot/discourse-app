import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/profile/profile_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  late _Profile proxy;
  FeaturedTopicChoice? choice;
  setUp(() {
    proxy = _Profile();
    choice = null;
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: Builder(
              builder: (context) => TextButton(
                    onPressed: () async {
                      choice = await showFeaturedTopicSheet(
                          context: context,
                          proxy: proxy,
                          profile: DiscourseEditableProfile.fromUserJson(
                              {'id': 2, 'username': 'alice'},
                              siteUrl: 'https://forum.example'));
                    },
                    child: const Text('Open picker'),
                  ))),
    ));
    await tester.tap(find.text('Open picker'));
    await tester.pumpAndSettle();
  }

  testWidgets('loads an older page and selects its topic', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(proxy.calls, [('', 0), ('', 1)]);
    expect(find.text('Recent topic'), findsOneWidget);
    expect(find.text('Older topic'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
    await tester.tap(find.text('Older topic'));
    await tester.pumpAndSettle();
    expect(choice?.topicId, 2);
  });

  testWidgets('a topic that comes round again on a later page is listed once',
      (tester) async {
    // A topic started between Load more taps pushes the list down a row,
    // so the next page begins with the last one already shown.
    proxy.repeatOnPage1 = true;
    await pump(tester);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.text('Recent topic'), findsOneWidget);
    expect(find.text('Older topic'), findsOneWidget);
  });

  testWidgets('search resets pagination, pages with the query, and clears',
      (tester) async {
    await pump(tester);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'needle');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('Recent topic'), findsNothing);
    expect(find.text('Search match 1'), findsOneWidget);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(proxy.calls.sublist(2), [('needle', 0), ('needle', 1)]);
    expect(find.text('Search match 2'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(proxy.calls.last, ('', 0));
    expect(find.text('Recent topic'), findsOneWidget);
    expect(find.text('Search match 2'), findsNothing);
  });

  testWidgets('failed later page retains topics and retries the same page',
      (tester) async {
    await pump(tester);
    proxy.failPage = 1;
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.text('Recent topic'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    proxy.failPage = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(proxy.calls, [('', 0), ('', 1), ('', 1)]);
    expect(find.text('Older topic'), findsOneWidget);
  });

  testWidgets('initial failure offers retry', (tester) async {
    proxy.failPage = 0;
    await pump(tester);
    expect(find.text('Retry'), findsOneWidget);
    proxy.failPage = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Recent topic'), findsOneWidget);
  });

  testWidgets('late page errors cannot replace a newer search', (tester) async {
    await pump(tester);
    final delayed = proxy.delayed = Completer<Map<String, dynamic>>();
    await tester.tap(find.text('Load more'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'needle');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    delayed.completeError(StateError('old request failed'));
    await tester.pumpAndSettle();
    expect(find.text('Search match 1'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    expect(find.textContaining('old request'), findsNothing);
  });

  testWidgets('returning to the same query still ignores an older page',
      (tester) async {
    await pump(tester);
    final delayed = proxy.delayed = Completer<Map<String, dynamic>>();
    await tester.tap(find.text('Load more'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'needle');
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    delayed.complete(_page('Stale topic', 99));
    await tester.pumpAndSettle();
    expect(find.text('Recent topic'), findsOneWidget);
    expect(find.text('Stale topic'), findsNothing);
    expect(find.text('Load more'), findsOneWidget);
  });
}

Map<String, dynamic> _page(String title, int id, {bool more = false}) => {
      'topic_list': {
        'topics': [
          {'id': id, 'title': title}
        ],
        if (more) 'more_topics_url': '/topics/created-by/alice?page=1',
      },
    };

class _Profile extends DiscourseProfileProxy {
  _Profile()
      : super(SiteContext(
            siteType: 'discourse',
            site: Site(
              id: null,
              name: 'Test',
              url: 'https://forum.example',
              baseUrl: 'https://forum.example',
              description: '',
              endpoint: null,
              logoUrl: null,
              backgroundUrl: null,
              siteType: 'discourse',
            ))
          ..setLoginData(FCLoginResult(
              result: true,
              resultText: '',
              user: FCUser(id: '2', username: 'alice'))));
  final calls = <(String, int)>[];
  bool repeatOnPage1 = false;
  int? failPage;
  Completer<Map<String, dynamic>>? delayed;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    // A search goes to the forum's search, whose pages count from 1; the
    // list's count from 0.
    final searching = path == '/search.json';
    final search =
        searching ? (query!['q'] as String).split(' @alice ').first : '';
    final page = searching
        ? int.parse(query!['page'] as String? ?? '1') - 1
        : int.parse(query?['page'] as String? ?? '0');
    calls.add((search, page));
    if (failPage == page) throw StateError('Please retry');
    if (searching) {
      final id = 10 + page;
      return {
        'posts': [
          {'topic_id': id}
        ],
        'topics': [
          {'id': id, 'title': 'Search match ${page + 1}'}
        ],
        'grouped_search_result': {'more_full_page_results': page == 0},
      };
    }
    if (page > 0 && delayed != null) return delayed!.future;
    if (page == 1 && repeatOnPage1) {
      return {
        'topic_list': {
          'topics': [
            {'id': 1, 'title': 'Recent topic'},
            {'id': 2, 'title': 'Older topic'},
          ],
        },
      };
    }
    return _page(page == 0 ? 'Recent topic' : 'Older topic', page + 1,
        more: page == 0);
  }
}
