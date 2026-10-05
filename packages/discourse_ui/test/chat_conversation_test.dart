import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/chat/chat_channel_view.dart';
import 'package:discourse_ui/views/chat/widgets/chat_message_row.dart';
import 'package:discourse_ui/views/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// The conversation, rebuilt on Discourse's chat: runs of one person's
/// messages under one avatar and name, date lines, the "last visit" line
/// where unread begins (and opening there), reply previews, and "read" only
/// for what was seen.
const _site = 'https://chat.example';

SiteContext _ctx() => SiteContext(
      siteType: 'conv-test',
      site: Site(
        id: null,
        name: 'Chat',
        url: _site,
        description: '',
        endpoint: null,
        baseUrl: _site,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'conv-test',
      ),
    )..setLoginData(FCLoginResult(result: true, resultText: '', user: FCUser(id: '2', username: 'alice')));

Map<String, dynamic> _user(int id, String username) =>
    {'id': id, 'username': username, 'avatar_template': '/user_avatar/chat.example/$username/{size}/1.png'};

Map<String, dynamic> _msg(int id, int userId, String username, DateTime at, String text,
        {Map<String, dynamic>? replyTo}) =>
    {
      'id': id,
      'chat_channel_id': 1,
      'message': text,
      'cooked': '<p>$text</p>',
      'created_at': at.toUtc().toIso8601String(),
      'user': _user(userId, username),
      if (replyTo != null) 'in_reply_to': replyTo,
    };

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    DiscourseChatMessageExtras.clear();
    DiscourseChatChannelDetails.clear();
  });

  group('runs', () {
    FCChatMessage m(int id, int author, DateTime at) => FCChatMessage(
        id: id, channelId: 1, message: '', cooked: '', authorId: author, authorUsername: 'u$author', createdAt: at);
    final t = DateTime(2026, 10, 1, 9);

    test('same person within 5 minutes continues', () {
      expect(chatMessageContinuesRun(m(1, 7, t), m(2, 7, t.add(const Duration(minutes: 4)))), isTrue);
    });
    test('another person, a longer gap, a reply to something else, or a new day starts a run', () {
      expect(chatMessageContinuesRun(m(1, 7, t), m(2, 8, t)), isFalse);
      expect(chatMessageContinuesRun(m(1, 7, t), m(2, 7, t.add(const Duration(minutes: 6)))), isFalse);
      expect(
          chatMessageContinuesRun(m(1, 7, t), m(3, 7, t),
              replyTo: const DiscourseChatReplyTo(messageId: 99)),
          isFalse);
      expect(chatMessageContinuesRun(m(1, 7, DateTime(2026, 9, 30, 23, 58)), m(2, 7, DateTime(2026, 10, 1, 0, 1))),
          isFalse);
    });
  });

  group('conversation', () {
    late _Chat chat;

    setUp(() {
      chat = _Chat(_ctx());
      SiteProxyFactory.register('conv-test', _Factory(chat));
      SiteProxyService.initialize(_ctx());
    });

    tearDown(Get.reset);

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ChatChannelView(siteContext: _ctx(), channelId: 1)),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets("one avatar and name for a person's run; a line for each day", (tester) async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      chat.channel = {'id': 1, 'title': 'general', 'chatable_type': 'Category', 'current_user_membership': {'last_read_message_id': 13}};
      chat.messages = [
        _msg(10, 7, 'samr', yesterday, 'first'),
        _msg(11, 7, 'samr', yesterday.add(const Duration(minutes: 1)), 'second'),
        _msg(12, 8, 'priya', now.subtract(const Duration(minutes: 3)), 'third'),
        _msg(13, 8, 'priya', now.subtract(const Duration(minutes: 2)), 'fourth'),
      ];
      await pump(tester);
      expect(find.byType(ChatMessageRow), findsNWidgets(4));
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      // Two runs, two avatars and names; was one bubble, avatar and name each.
      expect(find.byType(UserAvatar), findsNWidgets(2));
      expect(find.text('samr'), findsOneWidget);
      expect(find.text('priya'), findsOneWidget);
      expect(find.text('last visit'), findsNothing, reason: 'all read');
    });

    testWidgets('unread starts under a "last visit" line, and is read only once seen', (tester) async {
      final base = DateTime.now().subtract(const Duration(hours: 2));
      chat.channel = {
        'id': 1,
        'title': 'general',
        'chatable_type': 'Category',
        'current_user_membership': {'last_read_message_id': 103},
      };
      chat.tracking = 7;
      chat.messages = [
        for (var i = 0; i < 40; i++)
          _msg(100 + i, i.isEven ? 7 : 8, i.isEven ? 'samr' : 'priya', base.add(Duration(minutes: i * 6)),
              'message number $i with enough words to take a line'),
      ];
      await pump(tester);
      expect(find.text('last visit'), findsOneWidget);
      // Opened at the line, not at the bottom.
      expect(find.text('message number 39 with enough words to take a line'), findsNothing);
      final readSoFar = chat.reads.isEmpty ? 0 : chat.reads.last;
      expect(readSoFar, lessThan(139), reason: 'the newest was not on screen');
      await tester.dragUntilVisible(find.text('message number 39 with enough words to take a line'),
          find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      // The view leaves: whatever is pending goes out.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(chat.reads.last, 139);
    });

    testWidgets('a reply shows what it answers', (tester) async {
      final now = DateTime.now();
      chat.channel = {'id': 1, 'title': 'general', 'chatable_type': 'Category'};
      chat.messages = [
        _msg(20, 7, 'samr', now.subtract(const Duration(minutes: 30)), 'Can someone check the German?'),
        _msg(21, 9, 'kim', now.subtract(const Duration(minutes: 20)), 'Morning all'),
        _msg(22, 8, 'priya', now.subtract(const Duration(minutes: 1)), 'On it',
            replyTo: {'id': 20, 'excerpt': 'Can someone check the German?', 'user': _user(7, 'samr')}),
        _msg(23, 9, 'kim', now, 'Thanks!', replyTo: {'id': 22, 'excerpt': 'On it', 'user': _user(8, 'priya')}),
      ];
      await pump(tester);
      expect(find.text('Can someone check the German?'), findsNWidgets(2), reason: 'the message, and the preview');
      // A reply to the message just above needs no preview, as on the web.
      expect(find.byIcon(Icons.reply), findsOneWidget);
    });

    testWidgets('a slow drag up from the newest message stays where the reader leaves it', (tester) async {
      // Seen on an iPhone (v1.0.47): every frame of a drag counts as a change
      // of the scroll metrics, and a reader within 48 points of the end was
      // put back at the end, so a chat could not be scrolled up at all.
      final base = DateTime.now().subtract(const Duration(hours: 3));
      chat.channel = {'id': 1, 'title': 'general', 'chatable_type': 'Category'};
      chat.messages = [
        for (var i = 0; i < 30; i++)
          _msg(200 + i, i.isEven ? 7 : 8, i.isEven ? 'samr' : 'priya', base.add(Duration(minutes: i * 6)),
              'message number $i'),
      ];
      await pump(tester);
      final position = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
      final bottom = position.maxScrollExtent;
      expect(position.pixels, bottom, reason: 'opens at the newest');
      final gesture = await tester.startGesture(tester.getCenter(find.byType(ListView)));
      for (var i = 0; i < 20; i++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(position.pixels, lessThan(bottom - 150), reason: 'the drag moved the list');
    });

    testWidgets('at the newest message, a message that grows keeps the reader there', (tester) async {
      final base = DateTime.now().subtract(const Duration(hours: 3));
      chat.channel = {'id': 1, 'title': 'general', 'chatable_type': 'Category'};
      chat.messages = [
        for (var i = 0; i < 30; i++)
          _msg(300 + i, i.isEven ? 7 : 8, i.isEven ? 'samr' : 'priya', base.add(Duration(minutes: i * 6)),
              'message number $i'),
      ];
      await pump(tester);
      final position = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
      final before = position.maxScrollExtent;
      // Someone reacts to the newest message: its row grows by the chips.
      chat.onEvent!(const DiscourseChatReaction(messageId: 329, emoji: 'heart', username: 'kim', added: true));
      await tester.pumpAndSettle();
      expect(position.maxScrollExtent, greaterThan(before));
      expect(position.pixels, position.maxScrollExtent);
    });

    testWidgets('the "last visit" line also when the channel says nothing of unread', (tester) async {
      // A channel opened from a link: its own response has the last read
      // message but no unread count.
      final base = DateTime.now().subtract(const Duration(hours: 1));
      chat.channel = {
        'id': 1,
        'title': 'general',
        'chatable_type': 'Category',
        'current_user_membership': {'last_read_message_id': 31},
      };
      chat.messages = [
        for (var i = 0; i < 4; i++) _msg(30 + i, 7, 'samr', base.add(Duration(minutes: i * 10)), 'line $i'),
      ];
      await pump(tester);
      expect(find.text('last visit'), findsOneWidget);
    });
  });
}

class _Chat extends DiscourseChatProxy {
  _Chat(super.context);

  Map<String, dynamic> channel = const {};
  List<Map<String, dynamic>> messages = const [];
  int tracking = 0;
  final List<int> reads = [];

  @override
  Future<Map<String, dynamic>> apiGet(String path, {Map<String, dynamic>? query}) async {
    if (path == '/chat/api/channels/1') return {'channel': channel};
    if (path == '/chat/api/channels/1/messages') {
      final target = int.tryParse('${query?['target_message_id'] ?? ''}');
      final direction = query?['direction'];
      var list = [...messages];
      if (target != null && direction == 'future') list = list.where((m) => (m['id'] as int) > target).toList();
      if (target != null && direction == 'past') list = list.where((m) => (m['id'] as int) < target).toList();
      return {'messages': list.reversed.toList()};
    }
    return const {};
  }

  @override
  Future<FCChatChannelResult> getChannelAsync(int channelId) async {
    final result = await super.getChannelAsync(channelId);
    final ch = result.channel;
    if (ch != null && tracking > 0) ch.unreadCount = tracking;
    return result;
  }

  @override
  Future<FCChatActionResult> markChannelReadAsync(int channelId, {int? messageId}) async {
    if (messageId != null) reads.add(messageId);
    return FCChatActionResult(result: true);
  }

  @override
  void Function()? watchChannel(int channelId, void Function(DiscourseChatEvent event) onEvent) {
    this.onEvent = onEvent;
    return () {};
  }

  void Function(DiscourseChatEvent event)? onEvent;
}

class _Factory implements SiteProxyFactory {
  _Factory(this.chat);
  final _Chat chat;

  @override
  IFCChatProxy createChatProxy(SiteContext context) => chat;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
