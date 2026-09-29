import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// What each Discourse notification says and opens in the app's list — the
/// rows as `/notifications.json` serves them (data shapes from the Discourse
/// source: PostAlerter, discourse-solved, discourse-assign, chat,
/// discourse-reactions, bookmarks).
void main() {
  Future<FCAlert> alertFor(Map<String, dynamic> row) async {
    final alerts = await _Social({
      'notifications': [
        {'id': 1, 'read': false, 'created_at': '2026-09-29T08:00:00Z', ...row},
      ],
    }).getAlertAsync(1, 20, true);
    return alerts.items.single;
  }

  test('a collapsed reply says "3 replies" and names the newest author', () async {
    final a = await alertFor({
      'notification_type': 2, 'topic_id': 5, 'post_number': 7, 'fancy_title': 'Busy',
      'data': {'display_username': '3 replies', 'original_username': 'bob', 'original_post_id': 999},
    });
    expect(a.message, '3 replies in "Busy"');
    expect(a.fromUsername, 'bob');
  });

  test('likes from several people name them', () async {
    final a = await alertFor({
      'notification_type': 5, 'topic_id': 5, 'post_number': 2, 'fancy_title': 'T',
      'data': {'display_username': 'jane', 'username2': 'bob', 'count': 5},
    });
    expect(a.message, 'jane, bob and 3 others liked your post in "T"');
  });

  test('an accepted answer says who and what, with its own mark', () async {
    final a = await alertFor({
      'notification_type': 14, 'topic_id': 5, 'post_number': 3, 'fancy_title': 'Help',
      'data': {'message': 'solved.accepted_notification', 'display_username': 'staff', 'topic_title': 'Help'},
    });
    expect(a.message, 'staff accepted your answer in "Help"');
    expect(a.action, 'solved');
    expect(a.contentType, 'thread');
  });

  test('a group message summary opens the group\'s inbox', () async {
    final a = await alertFor({
      'notification_type': 16,
      'data': {'group_id': 3, 'group_name': 'support', 'inbox_count': 4, 'username': 'alice'},
    });
    expect([a.contentType, a.contentId, a.message], ['group_inbox', 'support', '4 new messages in your support inbox']);
  });

  test('consolidated reactions name the person and open them, not an empty topic', () async {
    final a = await alertFor({
      'notification_type': 25,
      'data': {'display_username': 'kim', 'consolidated': true, 'count': 6},
    });
    expect([a.message, a.contentType], ['kim reacted to 6 of your posts', 'user']);
  });

  test('a chat bookmark reminder opens its chat message, titled by the bookmark', () async {
    final a = await alertFor({
      'notification_type': 24,
      'data': {'title': 'A chat message', 'bookmarkable_url': '/chat/c/-/2/9', 'bookmarkable_type': 'Chat::Message', 'bookmarkable_id': 9, 'display_username': 'alice'},
    });
    expect([a.message, a.contentType, a.contentId, a.postId], ['Reminder: "A chat message"', 'chat_channel', '2', '9']);
  });

  test('a watched chat thread opens its channel, has a mark, and names who replied', () async {
    final a = await alertFor({
      'notification_type': 40,
      'data': {'username': 'kim', 'username2': 'lee', 'count': 2, 'chat_channel_id': 3, 'chat_thread_id': 42, 'chat_message_id': 900, 'description': 'Plans'},
    });
    expect(a.message, 'kim and lee replied in a thread you watch: "Plans"');
    expect([a.contentType, a.contentId, a.postId, a.action], ['chat_channel', '3', null, 'chat']);
  });

  test('a group assignment is worded for the group', () async {
    final a = await alertFor({
      'notification_type': 34, 'topic_id': 5, 'post_number': 1, 'fancy_title': 'Bug',
      'data': {'message': 'discourse_assign.assign_group_notification', 'display_username': 'Support Team'},
    });
    expect(a.message, '"Bug" was assigned to your group Support Team');
  });

  test('invitations to a topic and to an event get their own marks', () async {
    final topic = await alertFor({'notification_type': 13, 'topic_id': 5, 'fancy_title': 'T', 'data': {'display_username': 'a'}});
    final event = await alertFor({'notification_type': 28, 'topic_id': 6, 'fancy_title': 'T', 'data': {'display_username': 'host', 'event_name': 'Party'}});
    expect([topic.action, event.action, event.message], ['invite', 'event', 'host invited you to "Party"']);
  });

  test('a new follower opens their profile', () async {
    final a = await alertFor({'notification_type': 800, 'data': {'display_username': 'fan'}});
    expect([a.message, a.contentType, a.fromUsername], ['fan started following you', 'user', 'fan']);
  });

  test('a moved post names the mover', () async {
    final a = await alertFor({'notification_type': 10, 'topic_id': 5, 'fancy_title': 'New home', 'data': {'display_username': 'mod'}});
    expect(a.message, 'mod moved a post to "New home"');
  });

  test('a badge names nobody — its display_username is the reader', () async {
    final a = await alertFor({'notification_type': 12, 'data': {'badge_id': 3, 'badge_name': 'Nice Post', 'username': 'alice'}});
    expect([a.fromUsername, a.contentType], ['', 'badge']);
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

class _Social extends DiscourseSocialProxy {
  _Social(this.answer) : super(_signedIn());
  final Map<String, dynamic> answer;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      answer;
}
