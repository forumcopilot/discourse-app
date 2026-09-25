import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Profiles, activity feeds, groups, invites and staff tools that behaved
/// differently from Discourse (full review, batch 2). Payload shapes as
/// the local forum sends them.
void main() {
  group('profile', () {
    test('the website is the address as entered, for the edit form',
        () async {
      final info = await _Users({
        '/u/bob.json': {
          'user': {
            'id': 3,
            'username': 'bob',
            'website': 'https://www.example.com/blog',
            'website_name': 'example.com/blog',
          },
        },
      }).getUserInfoAsync('bob', null);
      expect(info.website, 'https://www.example.com/blog',
          reason: 'website_name saved back rewrote the address');
    });

    test('Delete spammer is offered when Discourse would allow it', () async {
      Future<bool> offered(Object? canBeDeleted) async => (await _Users({
            '/u/bob.json': {
              'user': {'id': 3, 'username': 'bob', 'can_be_deleted': canBeDeleted},
            },
          }).getUserInfoAsync('bob', null))
              .canSpamClean;
      expect(await offered(true), isTrue);
      expect(await offered(null), isFalse,
          reason: 'moderators may not delete established users');
    });

    test('whether members may delete their own account', () async {
      expect(
          await _Users({
            '/session/current.json': {
              'current_user': {'id': 2, 'can_delete_account': true},
            },
          }).canDeleteOwnAccountAsync(),
          isTrue);
      expect(
          await _Users({
            '/session/current.json': {
              'current_user': {'id': 2},
            },
          }).canDeleteOwnAccountAsync(),
          isFalse,
          reason: 'sent only when true');
    });
  });

  group('deleting your own account', () {
    test("is the website's Delete My Account call", () async {
      final users = _Users(const {});
      final result = await users.deleteOwnAccountAsync();
      expect(result.deleted, isTrue);
      expect(users.deletes.single, '/u/alice.json');
      expect(users.lastDeleteQuery,
          {'context': '/u/alice/preferences/account'});
    });

    test('a refusal is reported, not taken for success', () async {
      final users = _Users(const {})
        ..deleteError = DiscourseApiException(
            statusCode: 403,
            method: 'DELETE',
            path: '/u/alice.json',
            body: '{"errors":["You are not permitted to view the requested resource."]}');
      final result = await users.deleteOwnAccountAsync();
      expect(result.deleted, isFalse);
      expect(result.message, isNotEmpty);
    });
  });

  group('activity feeds', () {
    Map<String, dynamic> actions(int n, {int filter = 5}) => {
          'user_actions': [
            for (var i = 0; i < n; i++)
              {
                'action_type': filter,
                'topic_id': 100 + i,
                'post_id': 1000 + i,
                'post_number': filter == 4 ? 1 : 2,
                'title': 'Topic $i',
                'username': 'bob',
                'created_at': '2026-09-24T08:00:00Z',
              },
          ],
        };

    test('a full page says there is more; a short one ends the feed',
        () async {
      final users = _Users({'/user_actions.json': actions(30)});
      final first = await users.getUserActionsAsync(0, 'bob', actionFilter: 1);
      expect(first.list.length, 30);
      expect(first.total, greaterThan(30),
          reason: 'total was the page length, so paging stopped at 30');

      users.byPath['/user_actions.json'] = actions(4);
      final last = await users.getUserActionsAsync(30, 'bob', actionFilter: 1);
      expect(users.queries.last['offset'], '30');
      expect(last.total, 34);
    });

    test('topics started page from an offset', () async {
      final users = _Users({'/user_actions.json': actions(30, filter: 4)});
      final first = await users.getUserCreatedTopicsAsync(0, 'bob');
      expect(first.total, greaterThan(first.list.length));
      await users.getUserCreatedTopicsAsync(30, 'bob');
      expect(users.queries.last, {
        'username': 'bob',
        'filter': '4',
        'offset': '30',
      });
    });
  });

  test("group members: the page, without the owners again on every page",
      () async {
    Map<String, dynamic> user(int id) =>
        {'id': id, 'username': 'u$id', 'avatar_template': '/a/{size}.png'};
    final groups = _Groups({
      '/groups/testers/members.json': {
        // Owners first, as GroupsController#members orders them.
        'members': [for (var i = 1; i <= 3; i++) user(i)],
        'owners': [user(1)],
        'meta': {'total': 6, 'limit': 3, 'offset': 0},
      },
    });
    final first = await groups.getGroupMembersAsync('testers', limit: 3);
    expect([for (final m in first.members) m.id], [1, 2, 3]);

    groups.byPath['/groups/testers/members.json'] = {
      'members': [for (var i = 4; i <= 6; i++) user(i)],
      'owners': [user(1)],
      'meta': {'total': 6, 'limit': 3, 'offset': 3},
    };
    final second =
        await groups.getGroupMembersAsync('testers', offset: 3, limit: 3);
    expect([for (final m in second.members) m.id], [4, 5, 6],
        reason: 'the owner came back at the top of every page');
    expect(second.total, 6);
  });

  group('invite links', () {
    test('allow what the forum dialog offers, within its limit', () async {
      final member = _Invites(userType: 'normal', settings: {
        'invite_link_max_redemptions_limit_users': 10,
      });
      await member.createInviteLinkAsync();
      expect((member.lastBody as Map)['max_redemptions_allowed'], 10,
          reason: 'the server default of 1 made a shared link single-use');

      final capped = _Invites(userType: 'normal', settings: {
        'invite_link_max_redemptions_limit_users': 5,
      });
      await capped.createInviteLinkAsync();
      expect((capped.lastBody as Map)['max_redemptions_allowed'], 5);

      final staff = _Invites(userType: 'moderator', settings: {
        'invite_link_max_redemptions_limit': 5000,
      });
      await staff.createInviteLinkAsync();
      expect((staff.lastBody as Map)['max_redemptions_allowed'], 100);
    });
  });

  group('review queue', () {
    const queue = {
      'reviewables': [
        {
          'id': 3,
          'type': 'ReviewableFlaggedPost',
          'status': 0,
          'version': 1,
          'topic_id': 96,
          'raw': 'The flagged reply.',
          'created_by_id': 2,
          'reviewable_score_ids': [3],
          'bundled_action_ids': ['3-agree', '3-disagree'],
        },
      ],
      'users': [
        {'id': 2, 'username': 'alice'},
      ],
      'reviewable_scores': [
        {'id': 3, 'score_type_id': 7, 'user_id': 2, 'reason': null},
      ],
      'score_types': [
        {'id': 7, 'title': 'Something Else', 'type': 'notify_moderators'},
      ],
      'bundled_actions': [
        {
          'id': '3-agree',
          'label': 'Yes',
          'action_ids': ['post-agree_and_hide', 'post-agree_and_keep'],
        },
        {
          'id': '3-disagree',
          'label': 'No',
          'action_ids': ['post-disagree'],
        },
      ],
      'actions': [
        {
          'id': 'post-agree_and_hide',
          'server_action': 'agree_and_hide',
          'label': 'Hide post',
          'completed_message': 'Post hidden, user has been notified.',
        },
        {'id': 'post-agree_and_keep', 'server_action': 'agree_and_keep', 'label': 'Keep post'},
        {'id': 'post-disagree', 'server_action': 'disagree', 'label': 'Keep post'},
      ],
      'meta': {
        'total_rows_reviewables': 1,
        'score_types': [
          {'id': 7, 'name': 'Something Else'},
        ],
      },
    };

    test("a flagged post shows its text, who flagged it and why", () async {
      final list = await _Moderation(queue).getReviewablesAsync();
      final row = list.reviewables.single;
      expect(row.raw, 'The flagged reply.',
          reason: 'flagged posts send raw at the top level, not in payload');
      expect(row.scores.single.type, 'Something Else');
      expect(row.scores.single.username, 'alice');
    });

    test('the two "Keep post" actions are told apart by their bundle',
        () async {
      final actions =
          (await _Moderation(queue).getReviewablesAsync()).reviewables.single.actions;
      final keeps = actions.where((a) => a.label == 'Keep post').toList();
      expect([for (final a in keeps) a.bundleLabel], ['Yes', 'No']);
      expect(actions.first.completedMessage,
          'Post hidden, user has been notified.');
    });

    test('a reject reason reaches the server', () async {
      final mod = _Moderation(queue);
      await mod.performReviewableActionAsync(9, 'delete_user',
          version: 2, rejectReason: 'Spam signup');
      expect(mod.lastQuery, {'version': '2', 'reject_reason': 'Spam signup'});
    });
  });

  group('Delete spammer', () {
    test("is Discourse's delete-as-spammer call", () async {
      final mod = _Moderation(const {});
      final result = await mod.spamCleanUserAsync(userId: '3', username: 'bob');
      expect(result.result, isTrue);
      expect(mod.lastDelete, '/admin/users/3.json');
      expect(mod.lastQuery, {
        'delete_posts': 'true',
        'block_email': 'true',
        'block_urls': 'true',
        'block_ip': 'true',
        'delete_as_spammer': 'true',
        'context': '/u/bob',
      });
      expect(mod.puts, isEmpty, reason: 'no silence first');
    });

    test('a refusal is reported', () async {
      final mod = _Moderation(const {}, deleteAnswer: const {'deleted': false});
      final result = await mod.spamCleanUserAsync(userId: '3', username: 'bob');
      expect(result.result, isFalse);
    });
  });
}

SiteContext _signedIn({String userType = 'normal'}) {
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
    user: FCUser(id: '2', username: 'alice', userType: userType),
  ));
  return ctx;
}

class _Users extends DiscourseUserProxy {
  _Users(this.byPath) : super(_signedIn());
  final Map<String, Map<String, dynamic>> byPath;
  final List<Map<String, dynamic>> queries = [];
  final List<String> deletes = [];
  Map<String, dynamic>? lastDeleteQuery;
  DiscourseApiException? deleteError;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    queries.add({...?query});
    return byPath[path] ?? const {};
  }

  @override
  Future<Map<String, dynamic>> apiDelete(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    deletes.add(path);
    lastDeleteQuery = query;
    if (deleteError != null) throw deleteError!;
    return const {'success': 'OK'}; // users#destroy's success_json
  }
}

class _Groups extends DiscourseGroupProxy {
  _Groups(this.byPath) : super(_signedIn());
  final Map<String, Map<String, dynamic>> byPath;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      byPath[path] ?? const {};
}

class _Invites extends DiscourseInviteProxy {
  _Invites({required String userType, required this.settings})
      : super(_signedIn(userType: userType));
  final Map<String, dynamic> settings;
  Object? lastBody;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      path == '/site/settings.json' ? settings : const {};
  @override
  Future<Map<String, dynamic>> apiPost(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    lastBody = body;
    return const {'id': 1, 'link': 'https://forum.example/invites/x'};
  }
}

class _Moderation extends DiscourseModerationProxy {
  _Moderation(this.queue, {this.deleteAnswer = const {'deleted': true}})
      : super(_signedIn(userType: 'admin'));
  final Map<String, dynamic> queue;
  final Map<String, dynamic> deleteAnswer;
  Map<String, dynamic>? lastQuery;
  String? lastDelete;
  final List<String> puts = [];
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      path == '/review.json' ? queue : const {};
  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    puts.add(path);
    lastQuery = query;
    return const {'reviewable_perform_result': {'success': 'OK'}};
  }

  @override
  Future<Map<String, dynamic>> apiDelete(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    lastDelete = path;
    lastQuery = query;
    return deleteAnswer;
  }
}
