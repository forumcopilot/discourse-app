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
      {},
      {'page': '1'}
    ]);
  });

  test('search reaches the server on every page and keeps content matches',
      () async {
    final proxy = _Profile()
      ..response = {
        'topic_list': {
          'topics': [
            {'id': 7, 'title': 'A matching term in the body'}
          ],
          'more_topics_url': '/topics/created-by/alice?page=1&search=needle',
        }
      };
    final result = await proxy.myTopicsPage(query: ' needle ');
    expect(result.topics.single.id, 7,
        reason: 'server results must not be filtered again against the title');
    await proxy.myTopicsPage(query: 'needle', page: 1);
    expect(proxy.queries, [
      {'search': 'needle'},
      {'page': '1', 'search': 'needle'}
    ]);
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
