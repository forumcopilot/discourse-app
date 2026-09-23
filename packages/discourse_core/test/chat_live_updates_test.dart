import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// What chat's MessageBus payloads (Chat::Publisher) become, and where a
/// channel's subscription starts.
void main() {
  late _ChannelProxy proxy;
  setUp(() => proxy = _ChannelProxy());

  Map<String, dynamic> message(int id, String cooked) => {
        'id': id,
        'chat_channel_id': 5,
        'message': cooked,
        'cooked': '<p>$cooked</p>',
        'created_at': '2026-09-23T08:00:00Z',
        'user': {'id': 9, 'username': 'alice'},
      };

  test('sent, edit and processed carry the whole message', () {
    for (final kind in ['sent', 'edit', 'processed', 'restore']) {
      final e = proxy.chatEventFrom(
          {'type': kind, 'chat_message': message(11, 'hi')});
      expect(e, isA<DiscourseChatMessageChanged>());
      final changed = e as DiscourseChatMessageChanged;
      expect(changed.kind, kind);
      expect(changed.isNew, kind == 'sent');
      expect(changed.message.id, 11);
      expect(changed.message.cooked, '<p>hi</p>');
    }
  });

  test('delete and bulk_delete name the messages', () {
    final one = proxy.chatEventFrom({'type': 'delete', 'deleted_id': 11});
    expect((one as DiscourseChatMessagesDeleted).messageIds, [11]);
    final many = proxy.chatEventFrom({
      'type': 'bulk_delete',
      'deleted_ids': [11, 12],
    });
    expect((many as DiscourseChatMessagesDeleted).messageIds, [11, 12]);
  });

  test('a reaction says who, which emoji, and whether it was added', () {
    final e = proxy.chatEventFrom({
      'type': 'reaction',
      'action': 'remove',
      'emoji': 'heart',
      'chat_message_id': 11,
      'user': {'id': 9, 'username': 'alice'},
    }) as DiscourseChatReaction;
    expect(e.messageId, 11);
    expect(e.emoji, 'heart');
    expect(e.username, 'alice');
    expect(e.added, isFalse);
  });

  test('kinds the app does not show are ignored', () {
    expect(proxy.chatEventFrom({'type': 'thread_created'}), isNull);
    expect(proxy.chatEventFrom({'type': 'notice'}), isNull);
    expect(proxy.chatEventFrom({'type': 'sent'}), isNull,
        reason: 'no message to show');
  });

  test('watching starts where the last channel fetch left off', () async {
    proxy.channelJson = {
      'id': 5,
      'title': 'general',
      'meta': {
        'message_bus_last_ids': {'channel_message_bus_last_id': 321},
      },
    };
    await proxy.getChannelAsync(5);
    final bus = DiscourseMessageBus.of(proxy.siteContext);
    final stop = proxy.watchChannel(5, (_) {});
    expect(stop, isNotNull);
    expect(bus.lastIds['/chat/5'], 321);
    stop!();
    bus.close();
  });
}

class _ChannelProxy extends DiscourseChatProxy {
  _ChannelProxy()
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

  Map<String, dynamic> channelJson = const {};

  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      {'channel': channelJson};
}
