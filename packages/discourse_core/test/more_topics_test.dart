import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The topics listed under a topic's last post. Payload shapes as the local
/// forum and meta.discourse.org send them: a topic view embeds each
/// poster's user, where a topic list ships user ids and a users table.
void main() {
  const forum = 'https://forum.example';

  Map<String, dynamic> listed(int id, {bool solved = false}) => {
        'id': id,
        'title': 'Topic $id',
        'slug': 'topic-$id',
        'posts_count': 7,
        'like_count': 3,
        'views': 40,
        'category_id': 4,
        'tags': ['badges'],
        'has_accepted_answer': solved,
        'unread_posts': 2,
        'last_posted_at': '2026-09-28T10:00:00Z',
        'created_at': '2026-09-20T10:00:00Z',
        'posters': [
          {
            'extras': null,
            'description': 'Original Poster',
            'user': {'id': 14, 'username': 'demo2', 'avatar_template': '/letter/d/{size}.png'},
          },
          {
            'extras': 'latest',
            'description': 'Most Recent Poster',
            'user': {'id': 15, 'username': 'bob', 'avatar_template': '/user_avatar/bob/{size}/1.png'},
          },
        ],
      };

  Map<String, dynamic> topicView({
    List<Map<String, dynamic>> suggested = const [],
    List<Map<String, dynamic>> related = const [],
  }) =>
      {
        'id': 26,
        'title': 'Open topic',
        'posts_count': 1,
        'details': {'created_by': {'id': 1, 'username': 'a'}},
        'post_stream': {
          'posts': [
            {'id': 101, 'post_number': 1, 'username': 'a', 'cooked': '<p>1</p>', 'created_at': '2026-09-24T08:00:00Z'},
          ],
        },
        'suggested_topics': suggested,
        if (related.isNotEmpty) 'related_topics': related,
      };

  setUp(DiscourseMoreTopics.clear);

  test('rows read like list rows: faces, category, tags, solved, unread',
      () async {
    DiscourseMoreTopics.storeFrom(
        forum, '26', topicView(suggested: [listed(31, solved: true)]));
    final proxy = _Topics({});
    final more = await proxy.getMoreTopicsAsync('26');
    final t = more.suggested.single;
    expect(t.authorName, 'demo2');
    expect(t.authorIconUrl, '$forum/letter/d/120.png',
        reason: 'the embedded poster was never found; every row had a placeholder');
    expect(t.lastPosterName, 'bob');
    expect(t.forumId, '4');
    expect(t.forumName, 'General');
    expect(t.tags, ['badges']);
    expect(t.isSolved, isTrue);
    expect(t.unreadCount, 2);
    expect(t.replyCount, 6);
    expect(proxy.gets.where((p) => p.startsWith('/t/')), isEmpty,
        reason: 'read from the load that opened the topic');
  });

  test("related topics (discourse-ai) are listed, not only suggested ones",
      () async {
    // meta.discourse.org to a guest: no suggestions, five related.
    DiscourseMoreTopics.storeFrom(
        forum, '26', topicView(related: [listed(41), listed(42)]));
    final more = await _Topics({}).getMoreTopicsAsync('26');
    expect(more.suggested, isEmpty);
    expect(more.related.map((t) => t.id), ['41', '42']);
    expect(DiscourseMoreTopics.hasAny(forum, '26'), isTrue);
  });

  test('a message reads its related messages', () async {
    DiscourseMoreTopics.storeFrom(forum, '26', {
      'related_messages': [listed(51)],
    });
    final more = await _Topics({}).getMoreTopicsAsync('26');
    expect(more.related.single.id, '51');
  });

  test('opening the topic records them; a topic not loaded is fetched once',
      () async {
    final posts = _Posts({'/t/26.json': topicView(suggested: [listed(31)])});
    await posts.getThreadAsync('26', 1, 20, true);
    expect(DiscourseMoreTopics.hasAny(forum, '26'), isTrue);

    final topics = _Topics({'/t/27.json': topicView(suggested: [listed(32)])});
    final more = await topics.getMoreTopicsAsync('27');
    expect(more.suggested.single.id, '32');
    expect(topics.gets.where((p) => p == '/t/27.json'), hasLength(1));
  });

  test('keyed by forum: the same topic id on another forum is not it', () {
    DiscourseMoreTopics.storeFrom(forum, '26', topicView(suggested: [listed(31)]));
    expect(DiscourseMoreTopics.hasAny('https://other.example', '26'), isFalse);
  });
}

SiteContext _ctx() => SiteContext(
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

class _Topics extends DiscourseTopicProxy {
  _Topics(this.byPath) : super(_ctx());
  final Map<String, Map<String, dynamic>> byPath;
  final gets = <String>[];
  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    gets.add(path);
    if (path == '/categories.json') {
      return {
        'category_list': {
          'categories': [
            {'id': 4, 'name': 'General'},
          ],
        },
      };
    }
    return byPath[path] ?? const {};
  }
}

class _Posts extends DiscoursePostProxy {
  _Posts(this.byPath) : super(_ctx());
  final Map<String, Map<String, dynamic>> byPath;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      byPath[path] ?? const {};
}
