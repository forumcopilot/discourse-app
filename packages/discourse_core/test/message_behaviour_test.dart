import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Messages and notifications that behaved differently from Discourse
/// (full review, batch 2).
void main() {
  setUp(DiscourseMessageDetails.clear);

  Map<String, dynamic> message({Map<String, dynamic>? details}) => {
        'id': 85,
        'title': 'A message',
        'posts_count': 3,
        'highest_post_number': 9,
        'details': details ??
            {
              'can_create_post': true,
              'participants': [],
              'allowed_users': [],
            },
        'post_stream': {
          'posts': [
            {'id': 1, 'post_number': 1, 'post_type': 1, 'username': 'alice', 'cooked': '<p>hi</p>', 'created_at': '2026-09-24T08:00:00Z'},
            {'id': 8, 'post_number': 8, 'post_type': 3, 'action_code': 'invited_user', 'username': 'user1', 'cooked': '', 'created_at': '2026-09-24T08:01:00Z'},
            {'id': 9, 'post_number': 9, 'post_type': 1, 'username': 'user1', 'cooked': '<p>reply</p>', 'created_at': '2026-09-24T08:02:00Z'},
          ],
        },
      };

  test('hidden small actions are remembered, to be reported read', () async {
    final c = await _Messages(message()).getConversationAsync('85', 0, 19, true);
    expect([for (final m in c.messages) m.messageNumber], [1, 9],
        reason: 'the small action has no row');
    expect(DiscourseMessageDetails.hiddenPostNumbers('85'), {8},
        reason: 'a notification can point at it; only its timing clears it');
  });

  test('a message pages up to its highest post number', () async {
    final c = await _Messages(message()).getConversationAsync('85', 0, 19, true);
    expect(c.totalMessageNum, 9,
        reason: 'posts_count (3) leaves small actions out of the numbering');
  });

  test('no can_create_post means no reply box', () async {
    final c = await _Messages(message(details: {
      'participants': [],
      'allowed_users': [],
    })).getConversationAsync('85', 0, 19, true);
    expect(c.canReply, isFalse, reason: 'Discourse omits the key for "no"');
  });

  test('a notification carries the post it is about', () async {
    final alerts = await _Social({
      'notifications': [
        {
          'id': 437,
          'notification_type': 2,
          'read': false,
          'topic_id': 26,
          'post_number': 2,
          'created_at': '2026-09-24T08:00:00Z',
          'data': {'original_post_id': 350, 'display_username': 'user1', 'topic_title': 'T'},
        },
      ],
    }).getAlertAsync(1, 20, true);
    expect(alerts.items.single.postId, '350');
    expect(alerts.items.single.position, 2);
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

class _Messages extends DiscoursePrivateConversationProxy {
  _Messages(this.answer) : super(_signedIn());
  final Map<String, dynamic> answer;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      answer;
}

class _Social extends DiscourseSocialProxy {
  _Social(this.answer) : super(_signedIn());
  final Map<String, dynamic> answer;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      answer;
}
