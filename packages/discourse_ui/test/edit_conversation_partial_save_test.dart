import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/private_messaging/conversation/pages/edit_conversation_page.dart';
import 'package:discourse_ui/views/private_messaging/message_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:discourse_ui/l10n/kit_strings.dart';

/// A message's title and its open state are saved by separate requests.
/// When the title saves and closing is refused, the editor stays open with
/// the error; if it is then left without saving again, the message behind
/// it must still be refreshed to show the new title.
const _siteType = 'pm-edit-test';

SiteContext _ctx() => SiteContext(
      siteType: _siteType,
      configDataOutput: FCConfigResult(),
      site: Site(
        id: null,
        name: 'Test',
        url: 'https://forum.example',
        description: '',
        endpoint: null,
        baseUrl: 'https://forum.example',
        logoUrl: null,
        backgroundUrl: null,
        siteType: _siteType,
      ),
    )..setLoginData(FCLoginResult(
        result: true, resultText: '', user: FCUser(id: '2', username: 'mod')));

void main() {
  late _Conversations conversations;
  setUp(() {
    final ctx = _ctx();
    conversations = _Conversations(ctx);
    SiteProxyFactory.register(_siteType, _Factory(conversations));
    SiteProxyFactory.initialize(ctx);
  });

  /// Opens the editor as the message page does; [result] gets what
  /// [MessageActions.editTitle] answers once it closes.
  Future<void> open(WidgetTester tester, void Function(bool) result) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result(await MessageActions.editTitle(
                context,
                siteContext: _ctx(),
                topicId: '7',
                canClose: true)),
            child: const Text('Edit'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
  }

  AppLocalizations l10n(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(EditConversationPage)))!;

  testWidgets(
      'a title saved before closing failed refreshes the message, '
      'though the editor is then discarded', (tester) async {
    bool? changed;
    await open(tester, (v) => changed = v);
    final strings = l10n(tester);
    await tester.enterText(find.byType(TextField), 'New title');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, strings.save));
    await tester.pumpAndSettle();

    expect(conversations.puts, ['/t/7.json', '/t/7/status.json']);
    // The refusal shows, and the editor stays open to try again.
    expect(find.text('You are not permitted to close this message.'),
        findsOneWidget);
    expect(find.byType(EditConversationPage), findsOneWidget);
    expect(changed, isNull);

    // The moderator gives up: Close, then Discard changes (the switch is
    // still unsaved).
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.kit.discardChanges));
    await tester.pumpAndSettle();
    expect(find.byType(EditConversationPage), findsNothing);
    expect(changed, isTrue,
        reason: 'the forum has the new title; the message must refresh');
  });

  testWidgets('a title that did not save leaves the message as it was',
      (tester) async {
    conversations.refuseTitle = true;
    bool? changed;
    await open(tester, (v) => changed = v);
    final strings = l10n(tester);
    await tester.enterText(find.byType(TextField), 'New title');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, strings.save));
    await tester.pumpAndSettle();
    // Nothing more is tried once the title is refused.
    expect(conversations.puts, ['/t/7.json']);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.kit.discardChanges));
    await tester.pumpAndSettle();
    expect(changed, isFalse);
  });
}

class _Conversations extends DiscoursePrivateConversationProxy {
  _Conversations(super.context);

  final puts = <String>[];
  bool refuseTitle = false;

  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      {
        'title': 'Old title',
        'closed': false,
        'details': {'can_edit': true, 'can_close_topic': true},
      };

  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    puts.add(path);
    if (path == '/t/7/status.json') {
      throw DiscourseApiException(
          statusCode: 403,
          method: 'PUT',
          path: path,
          body: '{"errors":["You are not permitted to close this message."]}');
    }
    if (refuseTitle) {
      throw DiscourseApiException(
          statusCode: 422,
          method: 'PUT',
          path: path,
          body: '{"errors":["Title is too short."]}');
    }
    return {
      'basic_topic': {'id': 7, 'title': 'New title'}
    };
  }
}

class _Factory implements SiteProxyFactory {
  _Factory(this.conversations);
  final _Conversations conversations;

  @override
  IFCPrivateConversationProxy createPrivateConversationProxy(
          SiteContext context) =>
      conversations;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
