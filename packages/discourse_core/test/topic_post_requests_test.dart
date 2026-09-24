import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_core/src/proxy/draft_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:forumcopilot_sdk/models/search/fc_search_filters.dart';

/// What the topic and post proxies send (full review, batch 1: requests
/// that could not do what the app claimed). Each expectation is the request
/// Discourse needs, checked against the local forum.
void main() {
  late _Recorder rec;
  setUp(() => rec = _Recorder());

  group('mark all as read', () {
    test("'0' (all forums) selects every category", () async {
      final proxy = _Forum(rec);
      await proxy.markAllAsRead('0');
      expect(rec.last, ('PUT', '/topics/bulk'));
      expect(rec.body, {
        'filter': 'unread',
        'operation': {'type': 'dismiss_posts'},
      }, reason: 'category_id 0 narrowed it to a category that does not exist');
      await proxy.markAllAsRead('');
      expect((rec.body as Map).containsKey('category_id'), isFalse);
    });

    test('a category takes its subcategories', () async {
      await _Forum(rec).markAllAsRead('6');
      expect(rec.body, {
        'filter': 'unread',
        'operation': {'type': 'dismiss_posts'},
        'category_id': 6,
        'include_subcategories': true,
      });
    });
  });

  group('replies', () {
    test('a reply to a post names it; a reply to the topic does not',
        () async {
      final proxy = _Post(rec);
      rec.nextPost = {'id': 900, 'raw': 'hi'};
      await proxy.replyPostAsync('3', '26', '', 'hi', null, null, false,
          replyToPostNumber: 2);
      expect(rec.last, ('POST', '/posts.json'));
      expect(rec.body, {
        'topic_id': 26,
        'raw': 'hi',
        'archetype': 'regular',
        'reply_to_post_number': 2,
      });

      await proxy.replyPostAsync('3', '26', '', 'hi', null, null, false);
      expect((rec.body as Map).containsKey('reply_to_post_number'), isFalse);

      await proxy.replyWhisperAsync('26', 'psst', replyToPostNumber: 5);
      expect((rec.body as Map)['reply_to_post_number'], 5);
      expect((rec.body as Map)['whisper'], 'true');
    });
  });

  group('editing', () {
    test("a first post's edit carries the topic's new title", () async {
      final proxy = _Post(rec);
      rec.nextPut = {
        'post': {'raw': 'body text', 'cooked': '<p>body text</p>'},
      };
      final saved = await proxy.saveRawPostAsync(
          '49', 'A better title', 'body text', false, null, null, null, null);
      expect(rec.last, ('PUT', '/posts/49.json'));
      expect(rec.body, {
        'post': {'raw': 'body text'},
        'title': 'A better title',
      });
      expect(saved.postContent, 'body text',
          reason: 'the answer nests the post under "post"');

      await proxy.saveRawPostAsync(
          '350', '', 'reply text', false, null, null, null, null);
      expect((rec.body as Map).containsKey('title'), isFalse,
          reason: 'a reply has no title to send');
    });
  });

  group('drafts', () {
    test('a category id stored as a string still loads', () async {
      final proxy = _Draft(rec);
      rec.nextGet = {
        'draft': '{"title":"Hello","reply":"x","categoryId":"7"}',
        'draft_sequence': 3,
      };
      final loaded = await proxy.loadDraftAsync('new_topic');
      expect(loaded.result, isTrue);
      expect(loaded.draft!.categoryId, 7);

      rec.nextGet = {
        'drafts': [
          {
            'draft_key': 'new_topic',
            'sequence': 3,
            'data': '{"title":"Hello","reply":"x","categoryId":"7"}',
            'created_at': '2026-09-24T08:00:00Z',
          },
        ],
      };
      final list = await proxy.getMyDraftsAsync();
      expect(list.result, isTrue,
          reason: 'a string categoryId used to throw and fail the whole page');
      expect(list.items.single.categoryId, 7);
    });
  });

  test('"I liked" is Discourse\'s in:likes', () {
    expect(
      DiscourseSearchProxy.discourseSearchFragment(
          const FCSearchFilters(personal: {FCSearchPersonal.liked})),
      'in:likes',
    );
    final both = DiscourseSearchProxy.discourseSearchFragment(
        const FCSearchFilters(
            personal: {FCSearchPersonal.bookmarks, FCSearchPersonal.liked}));
    expect(both.split(' '), containsAll(['in:bookmarks', 'in:likes']));
    expect(both, isNot(contains('in:liked')));
  });

  group('top', () {
    test('always /top.json with the period, and pages past the first',
        () async {
      final proxy = _Topic(rec);
      rec.nextGet = const {'topic_list': {'topics': []}};
      await proxy.getTopTopicsGlobalAsync(period: 'all', page: 2);
      expect(rec.gets.lastWhere((g) => g.$1 == '/top.json').$2,
          {'period': 'all', 'page': '2'},
          reason: 'no period means best_period_for, not all time');
      await proxy.getTopTopicsGlobalAsync(period: 'weekly');
      expect(rec.gets.lastWhere((g) => g.$1 == '/top.json').$2,
          {'period': 'weekly'},
          reason: '/top/weekly.json redirects and drops the page');
    });
  });
}

SiteContext _signedIn() {
  final ctx = SiteContext(
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
  ctx.setLoginData(FCLoginResult(
    result: true,
    resultText: '',
    user: FCUser(id: '2', username: 'alice'),
  ));
  return ctx;
}

/// Records requests and plays back canned answers.
class _Recorder {
  Map<String, dynamic> nextGet = const {};
  Map<String, dynamic> nextPost = const {};
  Map<String, dynamic> nextPut = const {};
  (String, String)? last;
  Object? body;
  final List<(String, Map<String, dynamic>)> gets = [];

  Future<Map<String, dynamic>> get(String path, Map<String, dynamic>? query) async {
    last = ('GET', path);
    gets.add((path, {...?query}));
    // Category names are fetched on the side; not what is tested.
    return path == '/site.json' || path == '/categories.json'
        ? const {'categories': []}
        : nextGet;
  }

  Future<Map<String, dynamic>> post(String path, Object? b) async {
    last = ('POST', path);
    body = b;
    return nextPost;
  }

  Future<Map<String, dynamic>> put(String path, Object? b) async {
    last = ('PUT', path);
    body = b;
    return nextPut;
  }
}

class _Forum extends DiscourseForumProxy {
  _Forum(this.rec) : super(_signedIn());
  final _Recorder rec;
  @override
  Future<Map<String, dynamic>> apiPut(String path,
          {Map<String, dynamic>? query, Object? body}) =>
      rec.put(path, body);
}

class _Post extends DiscoursePostProxy {
  _Post(this.rec) : super(_signedIn());
  final _Recorder rec;
  @override
  Future<Map<String, dynamic>> apiPost(String path,
          {Map<String, dynamic>? query, Object? body}) =>
      rec.post(path, body);
  @override
  Future<Map<String, dynamic>> apiPut(String path,
          {Map<String, dynamic>? query, Object? body}) =>
      rec.put(path, body);
}

class _Draft extends DiscourseDraftProxy {
  _Draft(this.rec) : super(_signedIn());
  final _Recorder rec;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) =>
      rec.get(path, query);
}

class _Topic extends DiscourseTopicProxy {
  _Topic(this.rec) : super(_signedIn());
  final _Recorder rec;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) =>
      rec.get(path, query);
}
