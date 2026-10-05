import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/utils/discourse_draft_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SiteContext site;
  late _Drafts drafts;
  late DiscourseDraftController controller;
  var disposed = false;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
            (_) async => null);
    site = SiteContext(
        siteType: 'draft-session',
        site: const Site(
            name: 'Test',
            url: 'https://draft.example',
            baseUrl: 'https://draft.example',
            description: '',
            siteType: 'draft-session'));
    await site.setUserApiCredentials(
        userApiKey: 'first', userApiClientId: 'first');
    drafts = _Drafts(site);
    SiteProxyFactory.register('draft-session', _Factory(drafts));
    SiteProxyService.initialize(site);
    controller = DiscourseDraftController(
        draftKey: 'topic_42',
        titleController: TextEditingController(),
        contentController: TextEditingController(),
        debounceDuration: const Duration(milliseconds: 5));
    disposed = false;
  });
  tearDown(() async {
    if (!disposed) controller.dispose();
    await Future<void>.delayed(Duration.zero);
    controller.titleController.dispose();
    controller.contentController.dispose();
  });
  Future<void> switchAccount() => site.setUserApiCredentials(
      userApiKey: 'second', userApiClientId: 'second');
  final sessionError =
      throwsA(predicate((e) => e.toString().contains('Your sign-in changed')));

  test('switch before initialization never reads the replacement account draft',
      () async {
    await switchAccount();
    expect(await controller.initialize(), isNull);
    expect(drafts.loads, 0);
  });
  test('late load cannot restore old text or recipient metadata', () async {
    drafts.loadGate = Completer<void>();
    var hydrated = false;
    final loading = controller.initialize(onRestored: (_) => hydrated = true);
    await switchAccount();
    drafts.loadGate!.complete();
    expect(await loading, isNull);
    expect(controller.contentController.text, isEmpty);
    expect(hydrated, isFalse);
  });
  for (final operation in ['save', 'discard']) {
    test('$operation after account switch reports failure without a request',
        () async {
      await controller.initialize();
      controller.contentController.text = 'Keep this writing';
      await switchAccount();
      await expectLater(
          operation == 'save' ? controller.flushNow() : controller.discard(),
          sessionError);
      expect(controller.contentController.text, 'Keep this writing');
      expect(drafts.saves, isEmpty);
      expect(drafts.deletes, isEmpty);
    });
    test('$operation waiting for a load cannot target the new account',
        () async {
      drafts.loadGate = Completer<void>();
      final loading = controller.initialize();
      controller.contentController.text = 'Keep this writing';
      final pending =
          operation == 'save' ? controller.flushNow() : controller.discard();
      final assertion = expectLater(pending, sessionError);
      await switchAccount();
      drafts.loadGate!.complete();
      await loading;
      await assertion;
      expect(drafts.saves, isEmpty);
      expect(drafts.deletes, isEmpty);
    });
  }
  test('debounced autosave cannot send old writing as the new account',
      () async {
    await controller.initialize();
    controller.contentController.text = 'Old account writing';
    await switchAccount();
    await Future<void>.delayed(const Duration(milliseconds: 25));
    expect(drafts.saves, isEmpty);
  });
  test('late save does not trigger a queued save on the new account', () async {
    await controller.initialize();
    drafts.saveGate = Completer<void>();
    controller.contentController.text = 'First edit';
    final saving = controller.flushNow();
    final assertion = expectLater(saving, sessionError);
    await Future<void>.delayed(Duration.zero);
    expect(drafts.saves, ['first']);
    controller.contentController.text = 'Second edit';
    await Future<void>.delayed(const Duration(milliseconds: 25));
    await switchAccount();
    drafts.saveGate!.complete();
    await assertion;
    expect(drafts.saves, ['first']);
  });
  test('discard waiting for a save cannot delete the new account draft',
      () async {
    await controller.initialize();
    drafts.saveGate = Completer<void>();
    controller.contentController.text = 'First edit';
    final saving = controller.flushNow();
    final saveAssertion = expectLater(saving, sessionError);
    await Future<void>.delayed(Duration.zero);
    final discardAssertion = expectLater(controller.discard(), sessionError);
    await switchAccount();
    drafts.saveGate!.complete();
    await saveAssertion;
    await discardAssertion;
    expect(drafts.deletes, isEmpty);
  });
  test(
      'disposal waiting for a save cannot write the final snapshot as the new account',
      () async {
    await controller.initialize();
    drafts.saveGate = Completer<void>();
    controller.contentController.text = 'First edit';
    final assertion = expectLater(controller.flushNow(), sessionError);
    await Future<void>.delayed(Duration.zero);
    controller.contentController.text = 'Final edit';
    controller.dispose();
    disposed = true;
    await switchAccount();
    drafts.saveGate!.complete();
    await assertion;
    await Future<void>.delayed(Duration.zero);
    expect(drafts.saves, ['first']);
  });
  test('a delete response after an account switch is not accepted as current',
      () async {
    await controller.initialize();
    drafts.deleteGate = Completer<void>();
    final assertion = expectLater(controller.discard(), sessionError);
    await Future<void>.delayed(Duration.zero);
    expect(drafts.deletes, ['first']);
    await switchAccount();
    drafts.deleteGate!.complete();
    await assertion;
    expect(controller.contentController.text, 'Saved text');
  });
  test(
      'post-submission cleanup skips another account without reporting submission failure',
      () async {
    await controller.initialize();
    await switchAccount();
    await controller.discard(afterSubmit: true);
    expect(drafts.deletes, isEmpty);
  });
  test('logout and sign-in with the same key still invalidate the composer',
      () async {
    await controller.initialize();
    await site.clearUserApiCredentials();
    await site.setUserApiCredentials(
        userApiKey: 'first', userApiClientId: 'first');
    controller.contentController.text = 'Old writing';
    await expectLater(controller.flushNow(), sessionError);
    expect(drafts.saves, isEmpty);
  });
  test('unchanged credentials still save and delete with the original sequence',
      () async {
    await controller.initialize();
    await site.setUserApiCredentials(
        userApiKey: 'first', userApiClientId: 'first');
    controller.contentController.text = 'Current writing';
    await controller.flushNow();
    await controller.discard();
    expect(drafts.saves, ['first']);
    expect(drafts.deletes, ['first']);
    expect(drafts.deletedSequence, 8);
  });
}

class _Drafts implements IFCDraftProxy {
  _Drafts(this.site);
  final SiteContext site;
  Completer<void>? deleteGate;
  Completer<void>? loadGate;
  Completer<void>? saveGate;
  int loads = 0;
  final saves = <String?>[];
  final deletes = <String?>[];
  int? deletedSequence;
  @override
  Future<FCLoadDraftResult> loadDraftAsync(String key) async {
    loads++;
    await loadGate?.future;
    return FCLoadDraftResult(
        result: true,
        draft: FCDraft(
            draftKey: key,
            sequence: 7,
            data: {'reply': 'Saved text', 'recipients': 'alice'}));
  }

  @override
  Future<FCSaveDraftResult> saveDraftAsync(
      {required String draftKey,
      required Map<String, dynamic> data,
      int sequence = 0}) async {
    saves.add(site.userApiKey);
    await saveGate?.future;
    return FCSaveDraftResult(result: true, sequence: sequence + 1);
  }

  @override
  Future<FCDeleteDraftResult> deleteDraftAsync(String key,
      {int sequence = 0}) async {
    deletes.add(site.userApiKey);
    deletedSequence = sequence;
    await deleteGate?.future;
    return FCDeleteDraftResult(result: true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Factory implements SiteProxyFactory {
  _Factory(this.drafts);
  final _Drafts drafts;
  @override
  IFCDraftProxy createDraftProxy(SiteContext context) => drafts;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
