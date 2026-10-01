import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_level.dart';

/// What the topic page draws a topic's status from (DiscourseTopicStatus),
/// read from the topic view as TopicViewSerializer sends it, and kept in
/// step with the actions the app takes.
void main() {
  setUp(DiscourseTopicStatus.clear);

  group('from the topic view', () {
    test('a pinned, closed, unlisted topic with its staff permissions', () {
      final s = DiscourseTopicStatus.fromTopicView({
        'pinned': true,
        'unpinned': null,
        'pinned_globally': true,
        'pinned_until': '2026-10-09T10:00:00.000Z',
        'closed': true,
        'archived': false,
        'visible': false,
        'deleted_at': null,
        'archetype': 'regular',
        'slow_mode_seconds': 3600,
        'topic_timer': {
          'status_type': 'open',
          'execute_at': '2026-10-04T10:00:00.000Z',
          'duration_minutes': null,
          'based_on_last_post': false,
          'category_id': null,
        },
        'details': {
          'notification_level': 3,
          'notifications_reason_id': 1,
          'can_create_post': true,
          'can_edit': true,
          'can_pin_unpin_topic': true,
          'can_close_topic': true,
          'can_archive_topic': true,
          'can_toggle_topic_visibility': true,
          'can_delete': true,
          'can_move_posts': true,
        },
      });
      expect(s.pinned, isTrue);
      expect(s.unpinned, isFalse);
      expect(s.pinnedGlobally, isTrue);
      expect(s.pinnedUntil, DateTime.utc(2026, 10, 9, 10));
      expect(s.closed, isTrue);
      expect(s.visible, isFalse);
      expect(s.deleted, isFalse);
      expect(s.notificationLevel, 3);
      expect(s.notificationsReasonId, 1);
      expect(s.slowModeSeconds, 3600);
      expect(s.timer?.statusType, 'open');
      expect(s.timer?.executeAt, DateTime.utc(2026, 10, 4, 10));
      expect(
          [s.canCreatePost, s.canEdit, s.canPinUnpin, s.canClose, s.canArchive,
           s.canToggleVisibility, s.canDelete, s.canMovePosts],
          everyElement(isTrue));
      expect(s.canRecover, isFalse);
      expect(s.canPermanentlyDelete, isFalse);
    });

    test("a pin the reader cleared is still staff's pin", () {
      final s = DiscourseTopicStatus.fromTopicView(
          {'pinned': false, 'unpinned': true, 'pinned_globally': false});
      expect(s.pinned, isFalse);
      expect(s.unpinned, isTrue);
      expect(s.isPinnedByStaff, isTrue,
          reason: 'the ⋮ menu must offer Un-Pin Topic, not Pin Topic');
    });

    test('permissions Discourse leaves out are not granted', () {
      // TopicViewDetailsSerializer only includes a can_* it grants.
      final s = DiscourseTopicStatus.fromTopicView({
        'deleted_at': '2026-09-30T12:00:00.000Z',
        'is_warning': true,
        'archetype': 'private_message',
        'details': {'can_recover': true, 'can_permanently_delete': true},
      });
      expect(s.deleted, isTrue);
      expect(s.isWarning, isTrue);
      expect(s.isMessage, isTrue);
      expect(s.canRecover, isTrue);
      expect(s.canPermanentlyDelete, isTrue);
      expect([s.canClose, s.canPinUnpin, s.canDelete, s.canEdit], everyElement(isFalse));
      expect(s.visible, isTrue, reason: 'absent means listed');
      expect(s.notificationLevel, 1, reason: 'absent means Normal');
    });
  });

  group('topic loads record it', () {
    test('per forum: the same topic id on two forums stays apart', () async {
      final a = _PostProxy(_ctx('https://a.example'),
          {'id': 7, 'title': 'T', 'closed': true, 'post_stream': {'posts': []}});
      final b = _PostProxy(_ctx('https://b.example'),
          {'id': 7, 'title': 'T', 'pinned': true, 'post_stream': {'posts': []}});
      await a.getThreadAsync('7', 1, 20, false);
      await b.getThreadAsync('7', 1, 20, false);
      expect(DiscourseTopicStatus.forTopic('https://a.example', '7')?.closed, isTrue);
      expect(DiscourseTopicStatus.forTopic('https://a.example', '7')?.pinned, isFalse);
      expect(DiscourseTopicStatus.forTopic('https://b.example', '7')?.pinned, isTrue);
    });
  });

  group('actions update it', () {
    const site = 'https://forum.example';
    setUp(() => DiscourseTopicStatus.store(
        site,
        '7',
        DiscourseTopicStatus.fromTopicView({
          'pinned': true,
          'details': {'notification_level': 1},
        })));

    test('Unpinned clears the pin for the reader only: PUT /t/{id}/clear-pin',
        () async {
      final proxy = _TopicProxy(_ctx(site));
      expect(await proxy.setPinnedForMeAsync('7', pinned: false), isNull);
      expect(proxy.puts, ['/t/7/clear-pin']);
      final s = DiscourseTopicStatus.forTopic(site, '7')!;
      expect((s.pinned, s.unpinned), (false, true));

      expect(await proxy.setPinnedForMeAsync('7', pinned: true), isNull);
      expect(proxy.puts.last, '/t/7/re-pin');
      expect(DiscourseTopicStatus.forTopic(site, '7')!.pinned, isTrue);
    });

    test('a refused clear-pin says why and changes nothing', () async {
      final proxy = _TopicProxy(_ctx(site), fail: true);
      expect(await proxy.setPinnedForMeAsync('7', pinned: false), isNotNull);
      expect(DiscourseTopicStatus.forTopic(site, '7')!.pinned, isTrue);
    });

    test('staff toggles land in the record', () async {
      final proxy = _ModerationProxy(_ctx(site));
      await proxy.closeTopicAsync('7');
      await proxy.archiveTopicAsync('7', archived: true);
      await proxy.setTopicVisibilityAsync('7', visible: false);
      await proxy.unstickTopicAsync('7');
      final s = DiscourseTopicStatus.forTopic(site, '7')!;
      expect((s.closed, s.archived, s.visible, s.isPinnedByStaff),
          (true, true, false, false));
      await proxy.deleteTopicExtendedAsync('7');
      expect(DiscourseTopicStatus.forTopic(site, '7')!.deleted, isTrue);
      await proxy.undeleteTopicAsync('7', '');
      expect(DiscourseTopicStatus.forTopic(site, '7')!.deleted, isFalse);
    });

    test('a level the reader picks is theirs: reason 2, "user_changed"',
        () async {
      final proxy = _SubscriptionProxy(_ctx(site));
      final changes = DiscourseTopicStatus.changes.value;
      await proxy.setTopicNotificationLevelAsync('7', FCNotificationLevel.watching);
      final s = DiscourseTopicStatus.forTopic(site, '7')!;
      expect((s.notificationLevel, s.notificationsReasonId), (3, 2));
      expect(DiscourseTopicStatus.changes.value, greaterThan(changes),
          reason: 'the footer and menu redraw from the change');
    });
  });
}

SiteContext _ctx(String url) => SiteContext(
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
    )..setLoginData(FCLoginResult(
        result: true, resultText: '', user: FCUser(id: '2', username: 'alice')));

class _PostProxy extends DiscoursePostProxy {
  _PostProxy(super.context, this.topic);
  final Map<String, dynamic> topic;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      path.startsWith('/t/') ? topic : const {'categories': []};
}

class _TopicProxy extends DiscourseTopicProxy {
  _TopicProxy(super.context, {this.fail = false});
  final bool fail;
  final puts = <String>[];
  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    if (fail) throw Exception('403');
    puts.add(path);
    return const {'success': 'OK'};
  }
}

class _ModerationProxy extends DiscourseModerationProxy {
  _ModerationProxy(super.context);
  @override
  Future<Map<String, dynamic>> apiPut(String path,
          {Map<String, dynamic>? query, Object? body}) async =>
      const {'success': 'OK'};
  @override
  Future<Map<String, dynamic>> apiDelete(String path,
          {Map<String, dynamic>? query, Object? body}) async =>
      const {};
}

class _SubscriptionProxy extends DiscourseSubscriptionProxy {
  _SubscriptionProxy(super.context);
  @override
  Future<Map<String, dynamic>> apiPost(String path,
          {Map<String, dynamic>? query, Object? body}) async =>
      const {'success': 'OK'};
}
