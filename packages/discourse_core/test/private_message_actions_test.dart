import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// What the private-message actions send, and what a loaded message says
/// the viewer may do. Each of these was a XenForo-shaped guess or a stub
/// before (see the PM review of 2026-09-22).
void main() {
  late _RecordingPmProxy proxy;

  setUp(() {
    DiscourseMessageDetails.clear();
    proxy = _RecordingPmProxy();
  });

  test('Mark unread asks Discourse to forget the last read post', () async {
    final r = await proxy.markConversationUnreadAsync('401970');
    expect(r.result, isTrue);
    expect(proxy.calls.single, 'DELETE /t/401970/timings.json {last: 1}');
  });

  test('the list\'s n-th window is Discourse page n', () async {
    proxy.nextGet = const {'topic_list': {'topics': []}};
    await proxy.getConversationsAsync(0, 19);
    await proxy.getConversationsAsync(20, 39);
    await proxy.getConversationsAsync(40, 59);
    final pages = proxy.calls
        .where((c) => c.startsWith('GET /topics/private-messages/'))
        .toList();
    expect(pages, [
      'GET /topics/private-messages/me.json {}',
      'GET /topics/private-messages/me.json {page: 1}',
      'GET /topics/private-messages/me.json {page: 2}',
    ]);
  });

  test('the archive is its own list, paged the same way', () async {
    proxy.nextGet = const {'topic_list': {'topics': []}};
    await proxy.getArchivedConversationsAsync(0, 19);
    await proxy.getArchivedConversationsAsync(20, 39);
    expect(proxy.calls, [
      'GET /topics/private-messages-archive/me.json {}',
      'GET /topics/private-messages-archive/me.json {page: 1}',
    ]);
  });

  test('a group is invited as a group', () async {
    final r = await proxy.inviteGroupAsync('401970', 'moderators');
    expect(r.result, isTrue);
    expect(proxy.calls.single,
        'POST /t/401970/invite-group.json {group: moderators}');
  });

  group('saving conversation details', () {
    for (final open in [false, true]) {
      test('reports a refused ${open ? 'reopen' : 'close'} after title saves',
          () async {
        proxy.putErrors['/t/7/status.json'] = DiscourseApiException(
          statusCode: 403,
          method: 'PUT',
          path: '/t/7/status.json',
          body: '{"errors":["You cannot change this conversation status."]}',
        );
        final result = await proxy.saveRawConversationAsync('7',
            conversationTitle: 'Updated title', conversationOpen: open);
        expect(result.result, isFalse);
        expect(result.resultText, 'You cannot change this conversation status.');
        expect(proxy.calls, [
          'PUT /t/7.json {title: Updated title}',
          'PUT /t/7/status.json {status: closed, enabled: ${!open}}',
        ]);
      });

      test('saves title and ${open ? 'reopens' : 'closes'} successfully', () async {
        final result = await proxy.saveRawConversationAsync('7',
            conversationTitle: 'Updated title', conversationOpen: open);
        expect(result.result, isTrue);
        expect(result.conversationTitle, 'Updated title');
        expect(proxy.calls, [
          'PUT /t/7.json {title: Updated title}',
          'PUT /t/7/status.json {status: closed, enabled: ${!open}}',
        ]);
      });
    }

    test('reports an unexpected status request failure', () async {
      proxy.putErrors['/t/7/status.json'] = StateError('connection interrupted');
      final result = await proxy.saveRawConversationAsync('7',
          conversationOpen: false);
      expect(result.result, isFalse);
      expect(result.resultText, isNotEmpty);
      expect(proxy.calls, ['PUT /t/7/status.json {status: closed, enabled: true}']);
    });

    test('does not change status when the title update fails', () async {
      proxy.putErrors['/t/7.json'] = DiscourseApiException(
        statusCode: 422,
        method: 'PUT',
        path: '/t/7.json',
        body: '{"errors":["Title is too short."]}',
      );
      final result = await proxy.saveRawConversationAsync('7',
          conversationTitle: 'x', conversationOpen: false);
      expect(result.result, isFalse);
      expect(result.resultText, 'Title is too short.');
      expect(proxy.calls, ['PUT /t/7.json {title: x}']);
    });

    test('title-only saves do not request a status change', () async {
      final result = await proxy.saveRawConversationAsync('7',
          conversationTitle: 'Updated title');
      expect(result.result, isTrue);
      expect(proxy.calls, ['PUT /t/7.json {title: Updated title}']);
    });
  });

  group('a loaded message', () {
    Map<String, dynamic> topic(Map<String, dynamic> details) => {
          'title': 'Hello',
          'posts_count': 3,
          'details': details,
          'post_stream': {
            'posts': [
              {'id': 1, 'post_number': 1, 'post_type': 1, 'username': 'a', 'cooked': '<p>hi</p>'},
              {'id': 2, 'post_number': 2, 'post_type': 3, 'username': 'a', 'cooked': '', 'action_code': 'user_left'},
              {'id': 3, 'post_number': 3, 'post_type': 1, 'username': 'b', 'cooked': '<p>yo</p>'},
            ],
          },
        };

    test('drops Discourse small actions, which have no body', () async {
      proxy.nextGet = topic(const {});
      final c = await proxy.getConversationAsync('7', 0, 19, true);
      expect(c.messages.map((m) => m.messageNumber), [1, 3]);
    });

    test('can be closed only with can_close_topic, not can_edit', () async {
      proxy.nextGet = topic(const {'can_edit': true});
      expect((await proxy.getConversationAsync('7', 0, 19, true)).canClose, isFalse);
      proxy.nextGet = topic(const {'can_edit': true, 'can_close_topic': true});
      expect((await proxy.getConversationAsync('7', 0, 19, true)).canClose, isTrue);
    });

    test('records whether it is archived, and its groups', () async {
      proxy.nextGet = {
        ...topic(const {
          'allowed_groups': [
            {'id': 3, 'name': 'moderators', 'display_name': 'Site Moderators', 'user_count': 4},
            {'id': 9, 'name': ''},
          ],
        }),
        'message_archived': true,
      };
      await proxy.getConversationAsync('7', 0, 19, true);
      final details = DiscourseMessageDetails.forTopic('7')!;
      expect(details.isArchived, isTrue);
      expect(details.groups.map((g) => g.label), ['Site Moderators'],
          reason: 'a group without a name cannot be shown or invited');
      expect(details.groups.single.name, 'moderators');
    });

    test('can be left only when can_remove_self_id is sent', () async {
      proxy.nextGet = topic(const {});
      await proxy.getConversationAsync('7', 0, 19, true);
      expect(DiscourseMessageDetails.forTopic('7')?.canLeave, isFalse);
      proxy.nextGet = topic(const {'can_remove_self_id': 42});
      await proxy.getConversationAsync('7', 0, 19, true);
      expect(DiscourseMessageDetails.forTopic('7')?.canLeave, isTrue);
    });
  });
}

/// Answers GETs with [nextGet] and records every call instead of sending it.
class _RecordingPmProxy extends DiscoursePrivateConversationProxy {
  _RecordingPmProxy() : super(_signedInContext());

  Map<String, dynamic> nextGet = const {};
  final List<String> calls = [];
  final Map<String, Object> putErrors = {};

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    calls.add('GET $path ${query ?? {}}');
    return nextGet;
  }

  @override
  Future<Map<String, dynamic>> apiPost(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    calls.add('POST $path ${body ?? {}}');
    return const {};
  }

  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    calls.add('PUT $path ${body ?? {}}');
    final error = putErrors[path];
    if (error != null) throw error;
    return const {'success': 'OK'};
  }

  @override
  Future<Map<String, dynamic>> apiDelete(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    calls.add('DELETE $path ${query ?? {}}');
    return const {};
  }
}

SiteContext _signedInContext() {
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
    user: FCUser(id: '1', username: 'me'),
  ));
  return ctx;
}
