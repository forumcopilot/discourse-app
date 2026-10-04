import 'dart:async';

import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/private_messaging/conversation/pages/new_conversation_page.dart';
import 'package:discourse_ui/views/user_search_page.dart';
import 'package:discourse_ui/views/widgets/message_compose_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

void main() {
  late _Drafts drafts;
  late _Conversations conversations;
  late SiteContext site;

  setUp(() {
    drafts = _Drafts();
    conversations = _Conversations();
    site = SiteContext(
        siteType: 'recipient-draft-test',
        site: const Site(
            name: 'Test',
            url: 'https://draft.example',
            baseUrl: 'https://draft.example',
            description: '',
            siteType: 'recipient-draft-test'));
    SiteProxyFactory.register(
        'recipient-draft-test', _Factory(drafts, conversations));
    SiteProxyService.initialize(site);
  });

  Future<void> open(WidgetTester tester, {String? initialRecipient}) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: NewConversationPage(
          siteContext: site,
          initialRecipient: initialRecipient,
          draftKey: 'new_private_message_1'),
    ));
    await tester.pumpAndSettle();
  }

  MessageComposePage composer(WidgetTester tester) =>
      tester.widget<MessageComposePage>(find.byType(MessageComposePage));

  Future<void> removeAlice(WidgetTester tester) async {
    tester
        .widget<InputChip>(find.widgetWithText(InputChip, 'alice'))
        .onDeleted!();
    await tester.pump();
  }

  Future<void> pickBob(WidgetTester tester) async {
    tester.widget<ActionChip>(find.byType(ActionChip)).onPressed!();
    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byType(UserSearchPage)))
        .pop(<String, dynamic>{'username': 'bob'});
    await tester.pumpAndSettle();
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  for (final retry in [false, true]) {
    testWidgets(
        'removed recipient stays removed after ${retry ? "retried" : "delayed"} draft read',
        (tester) async {
      if (retry) {
        drafts.failLoad = true;
      } else {
        drafts.gate = Completer<void>();
      }
      await open(tester, initialRecipient: 'alice');
      await removeAlice(tester);
      if (retry) {
        drafts.failLoad = false;
        await composer(tester).onSaveDraft!();
      } else {
        drafts.gate!.complete();
      }
      await tester.pumpAndSettle();
      expect(find.widgetWithText(InputChip, 'alice'), findsNothing);
      expect(composer(tester).hasChanges!(), isTrue);
      await composer(tester).onSaveDraft!();
      expect(drafts.saves.single['recipients'], '');
      expect(drafts.saves.single['reply'], 'Server body');
      await expectLater(composer(tester).onSubmit('Title', 'Body'),
          throwsA(isA<Exception>()));
      expect(conversations.recipients, isNull);
      await close(tester);
    });
  }

  for (final replace in [false, true]) {
    testWidgets(
        '${replace ? "replacing" : "adding"} a recipient while loading determines save and send recipients',
        (tester) async {
      drafts.gate = Completer<void>();
      await open(tester, initialRecipient: replace ? 'alice' : null);
      if (replace) await removeAlice(tester);
      await pickBob(tester);
      drafts.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(InputChip, 'alice'), findsNothing);
      expect(find.widgetWithText(InputChip, 'bob'), findsOneWidget);
      expect(composer(tester).hasChanges!(), isTrue);
      await composer(tester).onSaveDraft!();
      expect(drafts.saves.single['recipients'], 'bob');
      await expectLater(composer(tester).onSubmit('Title', 'Body'),
          throwsA(isA<Exception>()));
      expect(conversations.recipients, ['bob']);
      await close(tester);
    });
  }

  testWidgets('untouched recipients restore without marking the draft changed',
      (tester) async {
    drafts.gate = Completer<void>();
    await open(tester);
    drafts.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(InputChip, 'alice'), findsOneWidget);
    expect(composer(tester).hasChanges!(), isFalse);
    await expectLater(
        composer(tester).onSubmit('Title', 'Body'), throwsA(isA<Exception>()));
    expect(conversations.recipients, ['alice']);
    await close(tester);
  });
}

class _Drafts implements IFCDraftProxy {
  Completer<void>? gate;
  bool failLoad = false;
  final saves = <Map<String, dynamic>>[];
  @override
  Future<FCLoadDraftResult> loadDraftAsync(String key) async {
    await gate?.future;
    if (failLoad) {
      return FCLoadDraftResult(result: false, resultText: 'Read failed');
    }
    return FCLoadDraftResult(
        result: true,
        draft: FCDraft(
          draftKey: key,
          sequence: 5,
          data: {
            'title': 'Server title',
            'reply': 'Server body',
            'recipients': 'alice'
          },
        ));
  }

  @override
  Future<FCSaveDraftResult> saveDraftAsync(
      {required String draftKey,
      required Map<String, dynamic> data,
      int sequence = 0}) async {
    saves.add(Map.of(data));
    return FCSaveDraftResult(result: true, sequence: sequence + 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Conversations implements IFCPrivateConversationProxy {
  List<String>? recipients;
  @override
  Future<FCNewConversationResult> newConversationAsync(
      List<String> userName, String subject, String textBody,
      {List<String>? attachmentIds,
      String? groupId,
      bool? openInvite,
      bool? conversationLocked}) async {
    recipients = List.of(userName);
    return FCNewConversationResult(
        result: false, resultText: 'Test refusal', convId: '');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Users implements IFCUserProxy {
  @override
  Future<FCSearchUserResult> searchUserAsync(
          String keywords, int page, int perpage) async =>
      FCSearchUserResult(result: true, list: []);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Factory implements SiteProxyFactory {
  _Factory(this.drafts, this.conversations);
  final _Drafts drafts;
  final _Conversations conversations;
  @override
  IFCDraftProxy createDraftProxy(SiteContext context) => drafts;
  @override
  IFCPrivateConversationProxy createPrivateConversationProxy(
          SiteContext context) =>
      conversations;
  @override
  IFCUserProxy createUserProxy(SiteContext context) => _Users();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
