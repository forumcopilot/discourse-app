import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/chat/chat_channel_view.dart';
import 'package:discourse_ui/views/chat/widgets/chat_message_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:get/get.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A chat message's long-press sheet and the composer, as Discourse's:
/// quick reactions, reply, edit in the composer, copy, @ suggestions,
/// "typing", and the channel's draft.
const _site = 'https://chat.example';

SiteContext _ctx() => SiteContext(
      siteType: 'act-test',
      site: Site(
        id: null,
        name: 'Chat',
        url: _site,
        description: '',
        endpoint: null,
        baseUrl: _site,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'act-test',
      ),
    )..setLoginData(FCLoginResult(result: true, resultText: '', user: FCUser(id: '2', username: 'alice')));

Map<String, dynamic> _msg(int id, int userId, String username, String text) => {
      'id': id,
      'chat_channel_id': 1,
      'message': text,
      'cooked': '<p>$text</p>',
      'created_at': DateTime.now().subtract(Duration(minutes: 30 - id)).toUtc().toIso8601String(),
      'user': {'id': userId, 'username': username},
      if (userId != 2) 'available_flags': ['spam', 'inappropriate'],
    };

void main() {
  late _Chat chat;
  final clipboard = <String>[];

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    DiscourseChatMessageExtras.clear();
    DiscourseChatDrafts.clear();
    chat = _Chat(_ctx());
    SiteProxyFactory.register('act-test', _Factory(chat));
    SiteProxyService.initialize(_ctx());
    clipboard.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform,
        (call) async {
      if (call.method == 'Clipboard.setData') clipboard.add((call.arguments as Map)['text'] as String);
      return null;
    });
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

  Future<void> longPress(WidgetTester tester, String text) async {
    await tester.longPress(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets("someone else's message: reactions, reply, copy, flag — not edit or delete", (tester) async {
    chat.messages = [_msg(10, 7, 'samr', 'Can someone check the German?')];
    await pump(tester);
    await longPress(tester, 'Can someone check the German?');
    expect(find.text('Copy text'), findsOneWidget);
    expect(find.text('Copy link'), findsOneWidget);
    expect(find.text('Flag'), findsOneWidget);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Delete'), findsNothing);
    expect(find.byTooltip('Reply'), findsOneWidget);
    expect(find.byTooltip('React with emoji'), findsOneWidget);
    await tester.tap(find.text('Copy text'));
    await tester.pumpAndSettle();
    expect(clipboard.single, 'Can someone check the German?');
  });

  testWidgets('reply: a banner over the composer, and the reply names what it answers', (tester) async {
    chat.messages = [_msg(10, 7, 'samr', 'Can someone check the German?')];
    await pump(tester);
    await longPress(tester, 'Can someone check the German?');
    await tester.tap(find.byTooltip('Reply'));
    await tester.pumpAndSettle();
    expect(find.text('Replying to samr'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'On it');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
    expect(chat.sent.single, {'message': 'On it', 'in_reply_to_id': 10});
    expect(find.text('Replying to samr'), findsNothing);
  });

  testWidgets('edit: your message fills the composer, and saving edits it', (tester) async {
    chat.messages = [_msg(11, 2, 'alice', 'helo')];
    await pump(tester);
    await longPress(tester, 'helo');
    expect(find.text('Flag'), findsNothing, reason: 'not your own');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Editing message'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'helo');
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
    expect(chat.edits.single['message'], 'hello');
    expect(find.text('Editing message'), findsNothing);
  });

  testWidgets('@ suggests people, and a pick completes the name', (tester) async {
    chat.messages = [_msg(10, 7, 'samr', 'hi')];
    await pump(tester);
    await tester.enterText(find.byType(TextField), 'thanks @sa');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Sam Rivera'), findsOneWidget);
    await tester.tap(find.text('Sam Rivera'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'thanks @samr ');
  });

  testWidgets('who is typing shows under the conversation', (tester) async {
    chat.messages = [_msg(10, 7, 'samr', 'hi')];
    await pump(tester);
    chat.onTyping!([const DiscourseChatUser(userId: 7, username: 'samr')]);
    await tester.pump();
    expect(find.text('samr is typing…'), findsOneWidget);
    chat.onTyping!(const []);
    await tester.pump();
    expect(find.textContaining('typing'), findsNothing);
  });

  testWidgets("the channel opens with the draft left in it, and typing keeps it", (tester) async {
    DiscourseChatDrafts.remember(_site, 1, 'half a thought');
    chat.messages = [_msg(10, 7, 'samr', 'hi')];
    await pump(tester);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'half a thought');
    await tester.enterText(find.byType(TextField), 'half a thought, finished');
    await tester.pump(const Duration(seconds: 3));
    expect(chat.drafts.last, 'half a thought, finished');
  });

  testWidgets('messages are rows with one header per run', (tester) async {
    chat.messages = [_msg(10, 7, 'samr', 'one'), _msg(11, 7, 'samr', 'two')];
    await pump(tester);
    expect(find.byType(ChatMessageRow), findsNWidgets(2));
    expect(find.text('samr'), findsOneWidget);
  });
}

class _Chat extends DiscourseChatProxy {
  _Chat(super.context);

  List<Map<String, dynamic>> messages = const [];
  final List<Map<String, dynamic>> sent = [];
  final List<Map<String, dynamic>> edits = [];
  final List<String> drafts = [];
  void Function(List<DiscourseChatUser>)? onTyping;

  @override
  Future<Map<String, dynamic>> apiGet(String path, {Map<String, dynamic>? query}) async {
    if (path == '/chat/api/channels/1') {
      return {
        'channel': {'id': 1, 'title': 'general', 'chatable_type': 'Category', 'meta': {'can_delete_self': true}},
      };
    }
    if (path == '/chat/api/channels/1/messages') return {'messages': messages.reversed.toList()};
    if (path == '/u/search/users.json') {
      return {
        'users': [
          {'username': 'samr', 'name': 'Sam Rivera'},
        ],
      };
    }
    return const {};
  }

  @override
  Future<Map<String, dynamic>> apiPost(String path, {Map<String, dynamic>? query, Object? body}) async {
    if (path == '/chat/1') {
      sent.add(Map<String, dynamic>.from(jsonDecode(jsonEncode(body)) as Map));
      return {'message_id': 99};
    }
    return const {};
  }

  @override
  Future<Map<String, dynamic>> apiPut(String path, {Map<String, dynamic>? query, Object? body}) async {
    if (path.startsWith('/chat/api/channels/1/messages/')) {
      edits.add(Map<String, dynamic>.from(jsonDecode(jsonEncode(body)) as Map));
    }
    return const {};
  }

  @override
  Future<FCChatActionResult> markChannelReadAsync(int channelId, {int? messageId}) async =>
      FCChatActionResult(result: true);

  @override
  void Function()? watchChannel(int channelId, void Function(DiscourseChatEvent event) onEvent) => () {};

  @override
  void Function() watchTyping(int channelId, void Function(List<DiscourseChatUser> typing) onChange, {int? threadId}) {
    onTyping = onChange;
    return () {};
  }

  @override
  Future<void> setTypingAsync(int channelId, {required bool typing, int? threadId}) async {}

  @override
  Future<FCChatActionResult> saveChatDraftAsync(int channelId, String text, {int? threadId}) async {
    drafts.add(text);
    return FCChatActionResult(result: true);
  }
}

class _Factory implements SiteProxyFactory {
  _Factory(this.chat);
  final _Chat chat;

  @override
  IFCChatProxy createChatProxy(SiteContext context) => chat;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
