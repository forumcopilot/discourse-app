import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// What a chat message's sheet and the composer send: flags, bookmarks,
/// pins, drafts, @ and # suggestions, and "typing".
void main() {
  const site = 'https://chat.example';
  setUp(() {
    DiscourseChatMessageExtras.clear();
    DiscourseChatDrafts.clear();
  });

  test('flag, bookmark, unbookmark, pin', () async {
    final p = _Recording(site)..postResponse = {'id': 77};
    await p.flagChatMessageAsync(1, 21, 8, message: '  off topic  ');
    await p.setChatBookmarkAsync(21, bookmarked: true);
    expect(DiscourseChatMessageExtras.of(site, 21)?.bookmarkId, 77);
    await p.setChatBookmarkAsync(21, bookmarked: false);
    expect(DiscourseChatMessageExtras.of(site, 21)?.bookmarkId, isNull);
    await p.setChatPinnedAsync(1, 21, pinned: true);
    await p.setChatPinnedAsync(1, 21, pinned: false);
    expect(p.calls, [
      'POST /chat/api/channels/1/messages/21/flags {"flag_type_id":8,"message":"off topic"}',
      'POST /bookmarks.json {"bookmarkable_type":"Chat::Message","bookmarkable_id":21}',
      'DELETE /bookmarks/77.json',
      'POST /chat/api/channels/1/messages/21/pin',
      'DELETE /chat/api/channels/1/messages/21/pin',
    ]);
    expect(DiscourseChatMessageExtras.of(site, 21)?.flagged, isTrue);
  });

  test('a draft goes to the server, and an empty one drops it', () async {
    final p = _Recording(site);
    await p.saveChatDraftAsync(1, 'half a thought');
    expect(DiscourseChatDrafts.of(site, 1), 'half a thought');
    await p.saveChatDraftAsync(1, '');
    expect(DiscourseChatDrafts.of(site, 1), isNull);
    expect(p.calls, [
      'POST /chat/api/channels/1/drafts {"data":"{\\"message\\":\\"half a thought\\"}"}',
      'POST /chat/api/channels/1/drafts {"data":""}',
    ]);
  });

  test("the current user's drafts are read at sign-in", () {
    DiscourseChatDrafts.storeFromCurrentUser(site, [
      {'channel_id': 1, 'data': '{"message":"from the web"}'},
      {'channel_id': 2, 'thread_id': 9, 'data': '{"message":"in a thread"}'},
      {'channel_id': 3, 'data': '{"message":""}'},
    ]);
    expect(DiscourseChatDrafts.of(site, 1), 'from the web');
    expect(DiscourseChatDrafts.of(site, 2, threadId: 9), 'in a thread');
    expect(DiscourseChatDrafts.of(site, 3), isNull);
  });

  test('@ and # suggestions', () async {
    final p = _Recording(site)
      ..getResponses['/u/search/users.json'] = {
        'users': [
          {'username': 'samr', 'name': 'Sam Rivera', 'avatar_template': '/a/{size}.png'},
        ],
        'groups': [
          {'name': 'team', 'full_name': 'The Team'},
        ],
      }
      ..getResponses['/hashtags/search.json'] = {
        'results': [
          {'ref': 'support', 'text': 'Support', 'type': 'category'},
        ],
      };
    final people = await p.searchMentionsAsync('sa', channelId: 1);
    expect(people.map((u) => (u.username, u.isGroup)), [('samr', false), ('team', true)]);
    expect(people.first.avatarUrl, 'https://chat.example/a/48.png');
    final tags = await p.searchHashtagsAsync('sup');
    expect(tags.single.ref, 'support');
    expect(p.queries['/hashtags/search.json']?['order[]'], ['channel', 'category', 'tag']);
  });

  test('typing is announced once per half minute, and its end once', () async {
    final p = _Recording(site);
    await p.setTypingAsync(1, typing: true);
    await p.setTypingAsync(1, typing: true);
    await p.setTypingAsync(1, typing: false);
    await p.setTypingAsync(1, typing: false);
    expect(p.calls.length, 2);
    expect(p.calls.first, startsWith('POST /presence/update'));
    expect(p.calls.first, contains('"present_channels":["/chat-reply/1"]'));
    expect(p.calls.last, contains('"leave_channels":["/chat-reply/1"]'));
  });
}

class _Recording extends DiscourseChatProxy {
  _Recording(String url)
      : super(SiteContext(
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
        ));

  final List<String> calls = [];
  final Map<String, Map<String, dynamic>> getResponses = {};
  final Map<String, Map<String, dynamic>?> queries = {};
  Map<String, dynamic> postResponse = const {};

  String _b(Object? body) => body == null ? '' : ' ${jsonEncode(body)}';

  @override
  Future<Map<String, dynamic>> apiGet(String path, {Map<String, dynamic>? query}) async {
    queries[path] = query;
    return getResponses[path] ?? const {};
  }

  @override
  Future<Map<String, dynamic>> apiPost(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('POST $path${_b(body)}');
    return postResponse;
  }

  @override
  Future<Map<String, dynamic>> apiDelete(String path, {Map<String, dynamic>? query, Object? body}) async {
    calls.add('DELETE $path${_b(body)}');
    return const {};
  }
}
