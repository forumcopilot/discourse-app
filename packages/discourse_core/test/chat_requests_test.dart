import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// What the chat proxy sends and records (chat review, batch 2).
void main() {
  late _RecordingChatProxy proxy;
  setUp(() {
    DiscourseChatUploads.clear();
    DiscourseChatPermissions.clear();
    proxy = _RecordingChatProxy();
  });

  test('chat search says who can chat, people and groups', () async {
    proxy.nextGet = {
      'users': [
        {
          'model': {'username': 'bob', 'name': 'Bob', 'can_chat': true, 'has_chat_enabled': true},
        },
        {
          'model': {'username': 'carol', 'can_chat': true, 'has_chat_enabled': false},
        },
      ],
      'groups': [
        {
          'model': {'name': 'team', 'full_name': 'The Team', 'can_chat': true},
        },
      ],
    };
    final found = await proxy.searchChatablesAsync('@b');
    expect(proxy.calls.single, startsWith('GET /chat/api/chatables.json'));
    expect(proxy.lastQuery!['term'], 'b');
    expect([for (final c in found) '${c.isGroup ? 'g' : 'u'}:${c.name}:${c.canChat}'],
        ['u:bob:true', 'u:carol:false', 'g:team:true'],
        reason: 'carol has chat turned off');
  });

  test('a DM names groups as target_groups', () async {
    proxy.nextPost = {
      'channel': {'id': 9, 'title': 'bob, team', 'chatable_type': 'DirectMessage'},
    };
    await proxy.createDirectMessageChannelAsync(['bob'], groups: ['team'], upsert: true);
    expect(proxy.lastBody, {
      'target_usernames': ['bob'],
      'target_groups': ['team'],
      'upsert': true,
    });
  });

  test('uploads are kept per message, and an edit sends them back', () async {
    proxy.nextGet = {
      'messages': [
        {
          'id': 70,
          'chat_channel_id': 5,
          'message': '',
          'cooked': '',
          'created_at': '2026-09-23T09:00:00Z',
          'user': {'id': 3, 'username': 'bob'},
          'uploads': [
            {
              'id': 12,
              'url': '/uploads/default/original/1X/abc.png',
              'original_filename': 'cat.png',
              'filesize': 1234,
              'width': 800,
              'height': 600,
              'extension': 'png',
            },
          ],
        },
      ],
    };
    await proxy.getMessagesAsync(5);
    final uploads = DiscourseChatUploads.forMessage('https://forum.example', 70);
    expect(uploads.single.filename, 'cat.png');
    expect(uploads.single.isImage, isTrue);
    expect(uploads.single.url,
        'https://forum.example/uploads/default/original/1X/abc.png');

    // Discourse sends an original's url protocol-relative; it takes the
    // forum's scheme (http on a local forum), not a forced https.
    proxy.nextGet = {
      'messages': [
        {
          'id': 71, 'chat_channel_id': 5, 'message': '', 'cooked': '',
          'created_at': '2026-09-23T09:00:00Z', 'user': {'id': 3, 'username': 'bob'},
          'uploads': [
            {'id': 13, 'url': '//cdn.forum.example/o/x.png', 'width': 10, 'extension': 'png'},
          ],
        },
      ],
    };
    await proxy.getMessagesAsync(5);
    expect(DiscourseChatUploads.forMessage('https://forum.example', 71).single.url,
        'https://cdn.forum.example/o/x.png');

    await proxy.editMessageAsync(5, 70, 'now with words');
    expect(proxy.lastBody, {'message': 'now with words', 'upload_ids': [12]},
        reason: 'without upload_ids Discourse detaches the image');
  });

  test('files go with the message by id, and the sender sees them at once',
      () async {
    // What the chat-composer upload answered (UploadSerializer).
    DiscourseChatUploads.rememberUpload(
      'https://forum.example',
      DiscourseChatUploads.fromJson('https://forum.example', {
        'id': 31,
        'url': '/uploads/default/original/1X/cat.png',
        'original_filename': 'cat.png',
        'filesize': 2048,
        'width': 640,
        'height': 480,
        'extension': 'png',
      }),
    );
    proxy.nextPost = {'success': 'OK', 'message_id': 90};
    final sent = await proxy.sendMessageAsync(5, '', uploadIds: [31]);
    expect(sent.result, isTrue, reason: 'files alone are a message');
    expect(proxy.calls.single, 'POST /chat/5');
    expect(proxy.lastBody, {'message': '', 'upload_ids': [31]});
    final shown = DiscourseChatUploads.forMessage('https://forum.example', 90);
    expect(shown.single.filename, 'cat.png');
    expect(shown.single.url,
        'https://forum.example/uploads/default/original/1X/cat.png');
    // Taken once: a later message does not pick the same file up again.
    expect(DiscourseChatUploads.takeUploads('https://forum.example', [31]),
        isEmpty);

    proxy.calls.clear();
    proxy.nextPost = {'success': 'OK', 'message_id': 91};
    await proxy.sendMessageAsync(5, 'just words');
    expect(proxy.lastBody, {'message': 'just words'},
        reason: 'no upload_ids key without files');
    final empty = await proxy.sendMessageAsync(5, '  ');
    expect(empty.result, isFalse);
  });

  test('opening on a message asks for the messages around it', () async {
    proxy.nextGet = const {'messages': []};
    await proxy.getMessagesAsync(5, targetMessageId: 70, direction: '');
    expect(proxy.lastQuery, {'page_size': '30', 'target_message_id': '70'});
  });

  test('channel meta becomes the viewer\'s permissions', () async {
    proxy.nextGet = {
      'channel': {
        'id': 4,
        'title': 'mobile-dev',
        'status': 'closed',
        'meta': {
          'can_delete_self': true,
          'can_delete_others': false,
          'can_moderate': false,
          'user_silenced': false,
        },
      },
    };
    await proxy.getChannelAsync(4);
    final p = DiscourseChatPermissions.forChannel('https://forum.example', 4)!;
    expect(p.canDeleteSelf, isTrue);
    expect(p.canDeleteOthers, isFalse);
    expect(p.canWriteIn('closed'), isFalse, reason: 'only moderators post in a closed channel');
    expect(p.canWriteIn('open'), isTrue);
    expect(const DiscourseChatPermissions(canModerate: true).canWriteIn('closed'), isTrue);
    expect(const DiscourseChatPermissions(silenced: true).canWriteIn('open'), isFalse);
  });
}

class _RecordingChatProxy extends DiscourseChatProxy {
  _RecordingChatProxy()
      : super(SiteContext(
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
        ));

  Map<String, dynamic> nextGet = const {};
  Map<String, dynamic> nextPost = const {};
  final List<String> calls = [];
  Map<String, dynamic>? lastQuery;
  Object? lastBody;

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    calls.add('GET $path');
    lastQuery = query;
    return nextGet;
  }

  @override
  Future<Map<String, dynamic>> apiPost(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    calls.add('POST $path');
    lastBody = body;
    return nextPost;
  }

  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    calls.add('PUT $path');
    lastBody = body;
    return const {};
  }
}
