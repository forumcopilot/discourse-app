import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/utils/discourse_draft_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_draft_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_draft.dart';
import 'package:forumcopilot_sdk/models/results/fc_draft_result.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

/// A new message's draft carries its recipients, which change while the
/// text may not: they are saved on their own, and handed back on resume so
/// New Message can restore them (as the web's composer does).
void main() {
  late _Drafts drafts;

  setUp(() {
    drafts = _Drafts();
    SiteProxyFactory.register('drafts-test', _Factory(drafts));
    SiteProxyService.initialize(SiteContext(
      siteType: 'drafts-test',
      site: Site(
        id: null,
        name: 'Test',
        url: 'https://forum.example',
        description: '',
        endpoint: null,
        baseUrl: 'https://forum.example',
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'drafts-test',
      ),
    ));
  });

  DiscourseDraftController controller(List<String> recipients) =>
      DiscourseDraftController(
        draftKey: 'new_private_message_1',
        titleController: TextEditingController(),
        contentController: TextEditingController(),
        debounceDuration: const Duration(milliseconds: 1),
        extraData: const {'action': 'privateMessage'},
        extraDataBuilder: () => {'recipients': recipients.join(',')},
      );

  test('the restored draft is handed back with its recipients', () async {
    drafts.stored = FCDraft(
      draftKey: 'new_private_message_1',
      sequence: 3,
      data: {'reply': 'Hello', 'title': 'Meetup', 'recipients': 'bob,carol'},
    );
    final c = controller([]);
    final draft = await c.initialize();
    expect(draft?.data['recipients'], 'bob,carol');
    expect(c.contentController.text, 'Hello');
    expect(c.titleController.text, 'Meetup');
    c.dispose();
  });

  test('a change of recipients alone is saved', () async {
    final recipients = <String>['bob'];
    final c = controller(recipients);
    await c.initialize();
    c.contentController.text = 'Hello';
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(drafts.saves.last['recipients'], 'bob');
    expect(drafts.saves.last['action'], 'privateMessage');

    recipients.add('carol');
    c.touch();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(drafts.saves, hasLength(2));
    expect(drafts.saves.last['recipients'], 'bob,carol');
    expect(drafts.saves.last['reply'], 'Hello');

    // Nothing changed: nothing is sent.
    c.touch();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(drafts.saves, hasLength(2));
    c.dispose();
  });

  test('clearing the text deletes the draft', () async {
    drafts.stored = FCDraft(
      draftKey: 'new_private_message_1',
      sequence: 3,
      data: {'reply': 'Hello'},
    );
    final c = controller([]);
    await c.initialize();
    c.contentController.text = '';
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(drafts.deletes, ['new_private_message_1']);
    expect(drafts.saves, isEmpty);
    c.dispose();
  });

  test('what was typed just before closing is saved on the way out',
      () async {
    final c = DiscourseDraftController(
      draftKey: 'topic_5',
      titleController: TextEditingController(),
      contentController: TextEditingController(),
    );
    await c.initialize();
    c.contentController.text = 'Last words';
    c.dispose(); // well inside the 1.5 s debounce
    await Future<void>.delayed(Duration.zero);
    expect(drafts.saves.single['reply'], 'Last words');
  });

  test('a discarded draft is not saved again on the way out', () async {
    final c = DiscourseDraftController(
      draftKey: 'topic_5',
      titleController: TextEditingController(),
      contentController: TextEditingController(),
    );
    await c.initialize();
    c.contentController.text = 'Never mind';
    await c.discard();
    c.dispose();
    await Future<void>.delayed(Duration.zero);
    expect(drafts.saves, isEmpty);
    expect(drafts.deletes, ['topic_5']);
  });

  test('recipients the page restores itself are not a change', () async {
    drafts.stored = FCDraft(
      draftKey: 'new_private_message_1',
      sequence: 3,
      data: {'reply': 'Hello', 'title': 'Meetup', 'recipients': 'bob'},
    );
    final recipients = <String>[];
    final c = controller(recipients);
    final draft = await c.initialize();
    // New Message puts the draft's recipients back after initialize.
    recipients.add(draft!.data['recipients'] as String);
    expect(c.changedSinceOpened, isTrue);
    c.markOpened();
    expect(c.changedSinceOpened, isFalse);
    c.dispose();
  });

  test('changes are counted from what the composer opened with', () async {
    drafts.stored = FCDraft(
      draftKey: 'new_private_message_1',
      sequence: 3,
      data: {'reply': 'Hello', 'recipients': 'bob'},
    );
    final recipients = <String>['bob'];
    final c = controller(recipients);
    await c.initialize();
    expect(c.changedSinceOpened, isFalse);
    c.contentController.text = 'Hello there';
    expect(c.changedSinceOpened, isTrue);
    c.contentController.text = 'Hello';
    expect(c.changedSinceOpened, isFalse);
    recipients.add('carol');
    expect(c.changedSinceOpened, isTrue);
    // Emptied: nothing left to lose.
    c.contentController.text = '';
    expect(c.changedSinceOpened, isFalse);
    c.dispose();
  });
}

class _Drafts implements IFCDraftProxy {
  FCDraft? stored;
  final List<Map<String, dynamic>> saves = [];
  final List<String> deletes = [];

  @override
  Future<FCDeleteDraftResult> deleteDraftAsync(String draftKey,
      {int sequence = 0}) async {
    deletes.add(draftKey);
    return FCDeleteDraftResult(result: true);
  }

  @override
  Future<FCLoadDraftResult> loadDraftAsync(String draftKey) async =>
      FCLoadDraftResult(result: true, draft: stored);

  @override
  Future<FCSaveDraftResult> saveDraftAsync({
    required String draftKey,
    required Map<String, dynamic> data,
    int sequence = 0,
  }) async {
    saves.add(data);
    return FCSaveDraftResult(result: true, sequence: sequence + 1);
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
