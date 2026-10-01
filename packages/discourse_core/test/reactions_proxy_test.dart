import 'dart:async';
import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';

/// Reacting, listing who reacted, a forum's own emoji, and live counts.
void main() {
  setUp(() {
    DiscourseValidReactions.clear();
    DiscourseCustomEmoji.clear();
  });

  group('toggling', () {
    test('without the plugin, removing a like deletes it', () async {
      // Defect: the picker never said the reader had liked, so the fallback
      // sent a second like, which Discourse refuses.
      final proxy = _Recording();
      DiscourseValidReactions.storeFromTopicView(proxy.siteContext.site.url, {
        'post_stream': {
          'posts': [
            {'id': 1}
          ]
        },
      });
      proxy.nextResponse = _postJson(likes: 0);
      final result = await proxy.toggleReactionAsync('42', 'heart', viewerReacted: true);
      expect(result.result, isTrue);
      expect(proxy.calls, ['DELETE /post_actions/42.json'],
          reason: 'straight to the like path, no toggle request to 404 first');
      expect(result.reactions, isEmpty);
    });

    test('without the plugin, a new like posts one', () async {
      final proxy = _Recording();
      DiscourseValidReactions.storeFromTopicView(proxy.siteContext.site.url, {
        'post_stream': {
          'posts': [
            {'id': 1}
          ]
        },
      });
      proxy.nextResponse = _postJson(likes: 3, liked: true);
      final result = await proxy.toggleReactionAsync('42', 'heart', viewerReacted: false);
      expect(proxy.calls, ['POST /post_actions.json']);
      expect(result.reactions.single.count, 3);
      expect(result.reactions.single.viewerReacted, isTrue);
    });

    test('an unknown forum tries the plugin and falls back on 404', () async {
      final proxy = _Recording()..putStatus = 404;
      proxy.nextResponse = _postJson(likes: 0);
      await proxy.toggleReactionAsync('42', 'heart', viewerReacted: true);
      expect(proxy.calls, [
        'PUT /discourse-reactions/posts/42/custom-reactions/heart/toggle.json',
        'DELETE /post_actions/42.json',
      ]);
    });

    test('with the plugin, every reaction goes through its toggle', () async {
      final proxy = _Recording();
      DiscourseValidReactions.store(proxy.siteContext.site.url, ['heart', 'rocket']);
      proxy.nextResponse = {
        'reactions': [
          {'id': 'rocket', 'type': 'emoji', 'count': 2},
        ],
        'current_user_reaction': {'id': 'rocket', 'type': 'emoji', 'can_undo': true},
      };
      final result = await proxy.toggleReactionAsync('42', 'rocket', viewerReacted: false);
      expect(proxy.calls, ['PUT /discourse-reactions/posts/42/custom-reactions/rocket/toggle.json']);
      expect(result.reactions.single.viewerReacted, isTrue);
      expect(result.reactions.single.canUndo, isTrue);
    });

    test("the picker offers this forum's set, not another's", () async {
      final a = _Recording(url: 'https://a.example');
      final b = _Recording(url: 'https://b.example');
      DiscourseValidReactions.store('https://a.example', ['heart', 'rocket', 'eyes']);
      DiscourseValidReactions.storeFromTopicView('https://b.example', {
        'post_stream': {
          'posts': [
            {'id': 1}
          ]
        },
      });
      expect((await a.getAvailableReactionsAsync()).reactions, ['heart', 'rocket', 'eyes']);
      expect((await b.getAvailableReactionsAsync()).reactions, ['heart']);
      expect(b.calls, isEmpty, reason: 'known, so no request');
    });
  });

  group('who reacted', () {
    test('names come with the plugin list', () async {
      final proxy = _Recording()
        ..nextResponse = {
          'users': [
            {'id': 7, 'username': 'samr', 'name': 'Sam Rivera', 'avatar_template': '/a/{size}.png', 'reaction': 'rocket'},
            {'id': 8, 'username': 'jonas', 'name': '', 'avatar_template': '', 'reaction': 'heart'},
          ],
          'total_rows': 2,
        };
      final result = await proxy.getReactionUsersAsync('42', reactionId: 'rocket');
      expect(proxy.calls.single, startsWith('GET /discourse-reactions/posts/42/reactions-users-list.json'));
      expect(proxy.lastQuery?['reaction_value'], 'rocket');
      expect(result.users.first.name, 'Sam Rivera');
      expect(result.users.first.reaction, 'rocket');
      expect(result.users.last.name, isNull, reason: 'an empty name is no name');
      expect(result.total, 2);
    });

    test('without the plugin, the like list stands in, each row a like', () async {
      final proxy = _Recording()..getStatus = {'/discourse-reactions/posts/42/reactions-users-list.json': 404};
      proxy.nextResponse = {
        'post_action_users': [
          {'id': 7, 'username': 'samr', 'name': 'Sam Rivera', 'avatar_template': ''},
        ],
      };
      final result = await proxy.getReactionUsersAsync('42');
      expect(result.result, isTrue);
      expect(result.users.single.reaction, 'heart');
      expect(result.users.single.name, 'Sam Rivera');
    });
  });

  group("a forum's own emoji", () {
    test('is looked up once, from /emojis.json, as an absolute address', () async {
      var fetches = 0;
      DiscourseCustomEmoji.fetchOverride = (_) async {
        fetches++;
        return {
          'default': [
            {'name': 'discourse', 'url': '//cdn.example/meta/discourse.png'},
          ],
          'smileys_&_emotion': [
            {'name': 'grinning', 'url': '/images/emoji/twitter/grinning.png'},
          ],
        };
      };
      addTearDown(() => DiscourseCustomEmoji.fetchOverride = null);
      final ctx = _context('https://meta.example/');
      expect(DiscourseCustomEmoji.urlFor(ctx.site.url, 'discourse'), isNull);
      final before = DiscourseCustomEmoji.revision.value;
      await Future.wait([
        DiscourseCustomEmoji.ensureLoaded(ctx),
        DiscourseCustomEmoji.ensureLoaded(ctx),
      ]);
      await DiscourseCustomEmoji.ensureLoaded(ctx);
      expect(fetches, 1);
      expect(DiscourseCustomEmoji.revision.value, before + 1);
      expect(DiscourseCustomEmoji.urlFor(ctx.site.url, 'discourse'), 'https://cdn.example/meta/discourse.png');
      expect(DiscourseCustomEmoji.urlFor('https://meta.example', 'grinning'),
          'https://meta.example/images/emoji/twitter/grinning.png');
    });

    test('a list that cannot be read is not asked for again', () async {
      var fetches = 0;
      DiscourseCustomEmoji.fetchOverride = (_) async {
        fetches++;
        throw Exception('offline');
      };
      addTearDown(() => DiscourseCustomEmoji.fetchOverride = null);
      final ctx = _context('https://meta.example');
      await DiscourseCustomEmoji.ensureLoaded(ctx);
      await DiscourseCustomEmoji.ensureLoaded(ctx);
      expect(fetches, 1);
      expect(DiscourseCustomEmoji.isLoaded(ctx.site.url), isTrue);
      expect(DiscourseCustomEmoji.urlFor(ctx.site.url, 'discourse'), isNull);
    });
  });

  group('live counts', () {
    late _HeldPolls server;
    late DiscourseMessageBus bus;
    late SiteContext ctx;
    late List<String> fetched;
    late List<DiscourseReactionUpdate> updates;
    late StreamSubscription<DiscourseReactionUpdate> sub;
    late void Function() stop;

    setUp(() {
      server = _HeldPolls();
      ctx = _context('https://live.example')
        ..setLoginData(FCLoginResult(result: true, resultText: '', user: FCUser(id: '2', username: 'alice')));
      bus = DiscourseMessageBus(ctx, client: server, minInterval: Duration.zero);
      fetched = [];
      updates = [];
      DiscourseLiveReactions.debounce = const Duration(milliseconds: 20);
      sub = DiscourseLiveReactions.updates.listen(updates.add);
      stop = DiscourseLiveReactions.watch(ctx, '7', bus: bus, fetch: (postId) async {
        fetched.add(postId);
        return [FCPostReaction(id: 'heart', count: 5)];
      });
    });

    tearDown(() async {
      stop();
      bus.close();
      await sub.cancel();
      DiscourseLiveReactions.debounce = const Duration(milliseconds: 1500);
    });

    Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 60));

    test("someone's reaction refetches that post once", () async {
      await server.nextPoll;
      expect(server.polls.single.keys, containsAll(['/topic/7/reactions', '/topic/7']));
      server.answer([
        {'channel': '/topic/7/reactions', 'message_id': 1, 'data': {'post_id': 42, 'reactions': ['heart']}},
        {'channel': '/topic/7', 'message_id': 2, 'data': {'id': 42, 'type': 'liked', 'user_id': 9}},
      ]);
      await server.nextPoll;
      await settle();
      expect(fetched, ['42'], reason: 'two messages about one post, one fetch');
      expect(updates.single.postId, '42');
      expect(updates.single.siteUrl, 'https://live.example');
      expect(updates.single.reactions.single.count, 5);
    });

    test("the reader's own change is not fetched again", () async {
      DiscourseLiveReactions.noteOwnChange('https://live.example', '42');
      await server.nextPoll;
      server.answer([
        {'channel': '/topic/7/reactions', 'message_id': 1, 'data': {'post_id': 42}},
        {'channel': '/topic/7', 'message_id': 2, 'data': {'id': 43, 'type': 'liked', 'user_id': 2}},
        {'channel': '/topic/7', 'message_id': 3, 'data': {'id': 44, 'type': 'revised', 'user_id': 9}},
      ]);
      await server.nextPoll;
      await settle();
      expect(fetched, isEmpty,
          reason: 'own reaction, own like (user 2 is the reader), and a revision');
    });

    test('nothing is fetched once the topic is closed', () async {
      await server.nextPoll;
      server.answer([
        {'channel': '/topic/7/reactions', 'message_id': 1, 'data': {'post_id': 42}},
      ]);
      await server.nextPoll;
      stop();
      await settle();
      expect(fetched, isEmpty);
    });
  });
}

Map<String, dynamic> _postJson({required int likes, bool liked = false}) => {
      'id': 42,
      'actions_summary': [
        {
          'id': 2,
          if (likes > 0) 'count': likes,
          if (liked) 'acted': true,
          if (liked) 'can_undo': true,
        },
      ],
    };

class _Recording extends DiscoursePostProxy {
  _Recording({String url = 'https://forum.example'}) : super(_context(url));

  Map<String, dynamic> nextResponse = const {};
  final List<String> calls = [];
  Map<String, dynamic>? lastQuery;
  int? putStatus;
  Map<String, int> getStatus = const {};

  Never _fail(int code, String method, String path) => throw DiscourseApiException(
      statusCode: code, method: method, path: path, body: '');

  @override
  Future<Map<String, dynamic>> apiGet(String path, {Map<String, dynamic>? query}) async {
    calls.add('GET $path');
    lastQuery = query;
    final code = getStatus[path];
    if (code != null) _fail(code, 'GET', path);
    return nextResponse;
  }

  @override
  Future<Map<String, dynamic>> apiPut(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('PUT $path');
    if (putStatus != null) _fail(putStatus!, 'PUT', path);
    return nextResponse;
  }

  @override
  Future<Map<String, dynamic>> apiPost(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('POST $path');
    return nextResponse;
  }

  @override
  Future<Map<String, dynamic>> apiDelete(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('DELETE $path');
    return nextResponse;
  }
}

class _HeldPolls extends DiscourseClient {
  final List<Map<String, dynamic>> polls = [];
  final List<Completer<FCCallResult>> _held = [];
  Completer<void> _arrived = Completer<void>();

  Future<void> get nextPoll async {
    await _arrived.future.timeout(const Duration(seconds: 2));
    _arrived = Completer<void>();
  }

  void answer(List<Object> messages) => _held.removeAt(0).complete(
      FCCallResult(statusCode: 200, body: jsonEncode(messages)));

  @override
  Future<FCCallResult> post(
    SiteContext context,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, String>? extraHeaders,
  }) {
    polls.add((jsonDecode(body as String) as Map).cast<String, dynamic>());
    final c = Completer<FCCallResult>();
    _held.add(c);
    if (!_arrived.isCompleted) _arrived.complete();
    return c.future;
  }
}

SiteContext _context(String url) => SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Test',
        url: url,
        description: '',
        endpoint: null,
        baseUrl: url,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      ),
    );
