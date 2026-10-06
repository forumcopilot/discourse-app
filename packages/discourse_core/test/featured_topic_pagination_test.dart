import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  test('uses Discourse continuation metadata rather than an assumed page size',
      () async {
    final proxy = _Profile()
      ..response = {
        'topic_list': {
          'topics': [
            {
              'id': 7,
              'title': 'Older topic',
              'posts_count': 4,
              'category_id': 2,
              'created_at': '2026-01-01T00:00:00Z'
            }
          ],
          'more_topics_url': '/topics/created-by/alice?page=1',
        }
      };
    final first = await proxy.myTopicsPage();
    expect(first.nextPage, 1);
    expect(first.topics.single.replies, 3);
    expect(first.topics.single.categoryId, 2);
    expect(first.topics.single.createdAt, DateTime.utc(2026));
    await proxy.myTopicsPage(page: 1);
    expect(proxy.paths, everyElement('/topics/created-by/alice.json'));
    expect(proxy.queries, [
      {'order': 'created'},
      {'order': 'created', 'page': '1'}
    ]);
  });

  test('lists by creation, so a reply between pages cannot move a topic',
      () async {
    // Discourse's default for this list is bumped_at: a topic that got a
    // reply between Load more taps jumped to the top, the next page
    // repeated a row and the bumped one was never shown.
    final proxy = _Profile()..response = {'topic_list': {'topics': []}};
    await proxy.myTopicsPage();
    await proxy.myTopicsPage(page: 3);
    expect(proxy.queries.map((q) => q['order']), ['created', 'created']);
    expect(proxy.queries.any((q) => q.containsKey('ascending')), isFalse,
        reason: 'newest first, as the list reads');
  });

  test("search asks for the member's public topics by title, every page",
      () async {
    // topics_by's `search` matched any post in a topic, replies by others
    // included; the forum's own picker searches titles (ChooseTopic).
    final proxy = _Profile()
      ..response = {
        'posts': [
          {'id': 70, 'topic_id': 8, 'post_number': 1},
          {'id': 71, 'topic_id': 7, 'post_number': 1},
        ],
        'topics': [
          {
            'id': 7,
            'title': 'Flutter tips',
            'posts_count': 3,
            'category_id': 2,
            'created_at': '2026-01-01T00:00:00Z'
          },
          {'id': 8, 'title': 'Flutter news', 'posts_count': 1},
        ],
        'grouped_search_result': {'more_full_page_results': true},
      };
    final result = await proxy.myTopicsPage(query: ' flutter ');
    expect(proxy.paths, ['/search.json']);
    expect(proxy.queries.single, {
      'q': 'flutter @alice in:title in:first status:public order:latest_topic',
    });
    // In the results' order, which is their posts'.
    expect(result.topics.map((t) => t.id), [8, 7]);
    expect(result.topics.last.replies, 2);
    expect(result.topics.last.categoryId, 2);
    expect(result.topics.last.createdAt, DateTime.utc(2026));
    expect(result.nextPage, 1);
    // /search.json counts pages from 1.
    await proxy.myTopicsPage(query: 'flutter', page: 1);
    expect(proxy.queries.last['page'], '2');
    expect(proxy.queries.last['q'], startsWith('flutter @alice in:title'));
  });

  test("search stops where the forum's search does", () async {
    final proxy = _Profile()
      ..response = {
        'posts': [
          {'topic_id': 7}
        ],
        'topics': [
          {'id': 7, 'title': 'Flutter tips'}
        ],
        'grouped_search_result': {'more_full_page_results': false},
      };
    expect((await proxy.myTopicsPage(query: 'flutter')).nextPage, isNull);
    proxy.response = {
      ...proxy.response,
      'grouped_search_result': {'more_full_page_results': true},
    };
    // SearchController::PAGE_LIMIT is 10: page 9 here is its last.
    expect((await proxy.myTopicsPage(query: 'flutter', page: 9)).nextPage,
        isNull);
    final calls = proxy.paths.length;
    final beyond = await proxy.myTopicsPage(query: 'flutter', page: 10);
    expect(beyond.topics, isEmpty);
    expect(proxy.paths.length, calls, reason: 'the server would refuse it');
  });

  test('a final nonempty page has no continuation', () async {
    final proxy = _Profile()
      ..response = {
        'topic_list': {
          'topics': [
            {'id': 9, 'title': 'Last'}
          ],
        }
      };
    expect((await proxy.myTopicsPage(page: 2)).nextPage, isNull);
  });

  test('an empty page stops even if the server includes a next URL', () async {
    final proxy = _Profile()
      ..response = {
        'topic_list': {
          'topics': [],
          'more_topics_url': '/topics/created-by/alice?page=99',
        }
      };
    expect((await proxy.myTopicsPage()).nextPage, isNull);
  });

  test('never follows an external continuation URL', () async {
    final proxy = _Profile()
      ..response = {
        'topic_list': {
          'topics': [
            {'id': 7}
          ],
          'more_topics_url': 'https://other.example/steal',
        }
      };
    final first = await proxy.myTopicsPage();
    await proxy.myTopicsPage(page: first.nextPage!);
    expect(proxy.paths, everyElement('/topics/created-by/alice.json'));
  });
}

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
  Map<String, dynamic> response = {};
  final paths = <String>[];
  final queries = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    paths.add(path);
    queries.add(query ?? {});
    return response;
  }
}
