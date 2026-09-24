import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Topic and post behaviour that differed from Discourse (full review,
/// batch 2). Payload shapes as the local forum sends them.
void main() {
  Map<String, dynamic> topic({
    int? lastRead,
    int highest = 5,
    bool closed = true,
    bool pinned = true,
    int level = 3,
  }) =>
      {
        'id': 26,
        'title': 'A closed, pinned topic',
        'closed': closed,
        'pinned': pinned,
        'pinned_globally': false,
        'posts_count': highest,
        'highest_post_number': highest,
        if (lastRead != null) 'last_read_post_number': lastRead,
        'details': {'notification_level': level, 'created_by': {'id': 1, 'username': 'a'}},
        'post_stream': {
          'posts': [
            for (var n = 1; n <= highest; n++)
              {'id': 100 + n, 'post_number': n, 'username': 'a', 'cooked': '<p>$n</p>', 'created_at': '2026-09-24T08:00:00Z'},
          ],
        },
      };

  test('every way into a topic knows it is closed, pinned and watched',
      () async {
    final proxy = _Posts({
      '/t/26.json': topic(lastRead: 2),
      '/posts/103.json': {'topic_id': 26, 'post_number': 3},
      '/t/26/3.json': topic(),
    });
    final byUnread = await proxy.getThreadByUnreadAsync('26', 20, true);
    final byPost = await proxy.getThreadByPostAsync('103', 20, true);
    for (final t in [byUnread, byPost]) {
      expect(t.isClosed, isTrue, reason: 'no closed banner; staff toggle inverted');
      expect(t.isPinned, isTrue);
      expect(t.isSubscribed, isTrue, reason: 'Watching (3)');
    }
  });

  test('a topic opens after the last post read, as on the web', () async {
    Future<int> anchor(int? lastRead) async => (await _Posts({
          '/t/26.json': topic(lastRead: lastRead),
        }).getThreadByUnreadAsync('26', 20, true))
            .position;
    expect(await anchor(2), 3, reason: 'Topic#lastUnreadUrl: last read + 1');
    expect(await anchor(5), 5, reason: 'capped at the newest post');
    expect(await anchor(null), 1, reason: 'never opened: the first post');
  });

  test("a subcategory's notification level is found", () async {
    final proxy = _Subscriptions({
      'category_list': {
        'categories': [
          {
            'id': 4,
            'notification_level': 1,
            'subcategory_list': [
              {'id': 6, 'notification_level': 3},
            ],
          },
        ],
      },
    });
    final level = await proxy.getCategoryNotificationLevelAsync('6');
    expect(level.level, FCNotificationLevel.watching,
        reason: 'subcategories are nested, never top-level');
  });

  test("a bookmark carries its post's author", () async {
    final list = await _Bookmarks({
      'user_bookmark_list': {
        'bookmarks': [
          {
            'id': 3,
            'bookmarkable_type': 'Post',
            'title': 'Topic',
            'name': 'my label',
            'user': {'id': 7, 'username': 'mallory', 'avatar_template': '/a/{size}.png'},
          },
        ],
      },
    }).getBookmarksAsync();
    final b = list.items.single;
    expect(b.username, 'mallory');
    expect(b.avatarUrl, isNotNull);
    expect(b.name, 'my label', reason: "the top-level name is the bookmark's label");
  });

  test('a post held for approval is reported as awaiting moderation',
      () async {
    const queued = {
      'action': 'enqueued',
      'pending_post': {'id': 9, 'raw': 'hi'},
      'pending_count': 1,
    };
    final reply = await _Posts(const {}, post: queued)
        .replyPostAsync('8', '26', '', 'hi', null, null, false);
    expect(reply.result, isTrue);
    expect(reply.state, 1);
    expect(reply.postId, '');
    final created = await _Topics(queued).newTopic('8', 'Title here', 'body');
    expect(created.state, 1);
    expect(created.topicId, '', reason: 'there is no topic to open yet');
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

class _Posts extends DiscoursePostProxy {
  _Posts(this.byPath, {this.post = const {}}) : super(_signedIn());
  final Map<String, Map<String, dynamic>> byPath;
  final Map<String, dynamic> post;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      byPath[path] ?? const {};
  @override
  Future<Map<String, dynamic>> apiPost(String path,
          {Map<String, dynamic>? query, Object? body}) async =>
      post;
}

class _Topics extends DiscourseTopicProxy {
  _Topics(this.post) : super(_signedIn());
  final Map<String, dynamic> post;
  @override
  Future<Map<String, dynamic>> apiPost(String path,
          {Map<String, dynamic>? query, Object? body}) async =>
      post;
}

class _Subscriptions extends DiscourseSubscriptionProxy {
  _Subscriptions(this.answer) : super(_signedIn());
  final Map<String, dynamic> answer;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      answer;
}

class _Bookmarks extends DiscourseBookmarkProxy {
  _Bookmarks(this.answer) : super(_signedIn());
  final Map<String, dynamic> answer;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      answer;
}
