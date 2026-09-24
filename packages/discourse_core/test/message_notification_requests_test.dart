import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Messages, notifications and the people picker (full review, batch 1).
void main() {
  test('the message list says there is more when Discourse does', () async {
    final proxy = _Messages({
      '/topics/private-messages/alice.json': {
        'topic_list': {
          'topics': [for (var i = 1; i <= 30; i++) _pm(i)],
          'more_topics_url': '/topics/private-messages/alice?page=1',
        },
      },
      '/topics/private-messages-sent/alice.json': {
        'topic_list': {
          'topics': [for (var i = 31; i <= 34; i++) _pm(i)],
        },
      },
    });
    final first = await proxy.getConversationsAsync(0, 19);
    expect(first, isA<DiscourseConversationsResult>());
    expect(first.list.length, 34,
        reason: 'inbox and sent merged — never 20, which the list compared with');
    expect((first as DiscourseConversationsResult).hasMore, isTrue);

    final last = await _Messages({
      '/topics/private-messages/alice.json': {
        'topic_list': {'topics': [_pm(1)]},
      },
      '/topics/private-messages-sent/alice.json': {
        'topic_list': {'topics': []},
      },
    }).getConversationsAsync(0, 19);
    expect((last as DiscourseConversationsResult).hasMore, isFalse);
  });

  test('"membership accepted" opens the group', () async {
    final alerts = await _Social({
      'notifications': [
        {
          'id': 501,
          'notification_type': 22,
          'read': false,
          'created_at': '2026-09-24T08:00:00Z',
          'data': {'group_id': 41, 'group_name': 'mobile-testers'},
        },
      ],
    }).getAlertAsync(1, 20, true);
    final alert = alerts.items.single;
    expect(alert.contentType, 'group',
        reason: 'the data has no user; routed to a profile it said '
            '"Username is missing"');
    expect(alert.contentId, 'mobile-testers');
  });

  group('people picker', () {
    test('recipients get only groups the viewer may message', () async {
      final proxy = _Users();
      await proxy.searchUserAsync('tr', 1, 20);
      expect(proxy.lastQuery, {
        'term': 'tr',
        'topic_allowed_users': 'true',
        'include_messageable_groups': 'true',
      }, reason: 'include_groups offered trust_level_0…4, refused on send');
    });

    test('mentions get mentionable groups; the directory gets people only',
        () async {
      final proxy = _Users();
      await proxy.searchUsersAsync('tr',
          groups: DiscourseUserSearchGroups.mentionable);
      expect(proxy.lastQuery!['include_mentionable_groups'], 'true');
      expect(proxy.lastQuery!.containsKey('include_messageable_groups'), isFalse);

      await proxy.searchUsersAsync('tr', groups: DiscourseUserSearchGroups.none);
      expect(proxy.lastQuery!.keys.where((k) => k.contains('groups')), isEmpty);
    });
  });
}

Map<String, dynamic> _pm(int id) => {
      'id': id,
      'title': 'Message $id',
      'fancy_title': 'Message $id',
      'last_posted_at': '2026-09-${(id % 28 + 1).toString().padLeft(2, '0')}T08:00:00Z',
      'posters': const [],
      'participants': const [],
    };

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

class _Messages extends DiscoursePrivateConversationProxy {
  _Messages(this.byPath) : super(_signedIn());
  final Map<String, Map<String, dynamic>> byPath;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      byPath[path] ?? const {};
}

class _Social extends DiscourseSocialProxy {
  _Social(this.answer) : super(_signedIn());
  final Map<String, dynamic> answer;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      answer;
}

class _Users extends DiscourseUserProxy {
  _Users() : super(_signedIn());
  Map<String, dynamic>? lastQuery;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    lastQuery = query;
    return const {'users': [], 'groups': []};
  }
}
