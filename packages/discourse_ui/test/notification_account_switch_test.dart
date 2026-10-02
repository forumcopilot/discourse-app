import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/services/discourse_login_service.dart';
import 'package:discourse_ui/services/notification_grant_cleanup.dart';
import 'package:discourse_ui/services/notification_key_service.dart';
import 'package:discourse_ui/services/notification_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

SiteContext account(
    {String? id = '7', String url = 'https://forum.example/sub'}) {
  final context = SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Forum',
        url: url,
        baseUrl: url,
        endpoint: null,
        description: '',
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      ));
  if (id != null) {
    context.setLoginData(FCLoginResult(
      result: true,
      resultText: '',
      user: FCUser(id: id, username: 'user$id'),
    ));
  }
  return context;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final deleted = <String>[];
  var reachable = false;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'), (_) async => null);
    AppForumConfig.setNotificationsApiBaseUrl('https://relay.example/api');
    reachable = false;
    deleted.clear();
    NotificationKeyService.requestOverride = (method, path, body) async {
      expect(method, 'DELETE');
      deleted.add(body['client_id'] as String);
      return reachable ? {'ok': true} : null;
    };
  });
  tearDown(() async {
    await NotificationGrantCleanup.instance.retryPending();
    NotificationKeyService.requestOverride = null;
    AppForumConfig.setNotificationsApiBaseUrl(null);
  });

  test('offline logout persists old grant and retry never targets new grant',
      () async {
    final context = account();
    final login = DiscourseLoginService(context);
    final first = await login.beginNotificationsGrant();
    await login.markNotificationsGranted(installBound: true);
    await login.retireNotificationsGrant();
    await NotificationGrantCleanup.instance.retryPending();
    expect(await login.hasNotificationsGrant(), isFalse);
    final second = await login.beginNotificationsGrant();
    await login.markNotificationsGranted(installBound: true);
    expect(second.clientId, isNot(first.clientId));
    // A newly created service reads the durable grant ID after restart.
    expect(
        await DiscourseLoginService(account(id: '8')).notificationsClientId(),
        second.clientId);
    reachable = true;
    await NotificationGrantCleanup.instance.retryPending();
    expect(deleted, everyElement(first.clientId));
    final count = deleted.length;
    await NotificationGrantCleanup.instance.retryPending();
    expect(deleted.length, count);
    expect(await login.hasNotificationsGrant(), isTrue);
  });

  test('a late grant completion after logout cannot restore the old marker',
      () async {
    final context = account();
    final login = DiscourseLoginService(context);
    final first = await login.beginNotificationsGrant();
    final session = context.configurationSession;
    await login.retireNotificationsGrant();
    expect(
        await login.markNotificationsGranted(
            expectedSession: session, expectedClientId: first.clientId),
        isFalse);
    expect(await login.hasNotificationsGrant(), isFalse);
  });

  test('grant preferences do not carry over to a different account', () async {
    final login = DiscourseLoginService(account());
    await login.markNotificationsGranted();
    final other = DiscourseLoginService(account(id: '8'));
    expect(await other.hasNotificationsGrant(), isFalse);
    await other.retireNotificationsGrant();
    await NotificationGrantCleanup.instance.retryPending();
    expect(deleted, hasLength(1));
  });

  test('legacy grants are queued by their original ID before rotation',
      () async {
    final login = DiscourseLoginService(account());
    final legacy = await login.notificationsClientId();
    await login.markNotificationsGranted();
    await login.retireNotificationsGrant();
    await NotificationGrantCleanup.instance.retryPending();
    expect(deleted, contains(legacy));
    final next = await login.beginNotificationsGrant();
    expect(next.clientId, isNot(legacy));
  });

  test('late in-flight revoke cannot delete a new grant', () async {
    final login = DiscourseLoginService(account());
    final first = await login.beginNotificationsGrant();
    await login.markNotificationsGranted();
    final gate = Completer<Map<String, dynamic>?>();
    final started = Completer<void>();
    NotificationKeyService.requestOverride = (_, __, body) {
      deleted.add(body['client_id'] as String);
      if (!started.isCompleted) started.complete();
      return gate.future;
    };
    await login.retireNotificationsGrant();
    await started.future;
    final next = await login.beginNotificationsGrant();
    await login.markNotificationsGranted();
    gate.complete({'ok': true});
    await NotificationGrantCleanup.instance.retryPending();
    expect(deleted, [first.clientId]);
    expect(next.clientId, isNot(first.clientId));
    expect(await login.hasNotificationsGrant(), isTrue);
  });

  test('pending cleanup survives a preferences reload and keeps forum scope',
      () async {
    await NotificationGrantCleanup.enqueue('https://one.example/sub', 'old-a');
    await NotificationGrantCleanup.enqueue(
        'https://one.example/other', 'old-b');
    await (await SharedPreferences.getInstance()).reload();
    reachable = true;
    await NotificationGrantCleanup.instance.retryPending();
    expect(deleted, unorderedEquals(['old-a', 'old-b']));
  });

  for (final type in [2, 6, 12, 16, 22, 29, 800, 999]) {
    test(
        'type $type requires matching recipient and forum, including signed out',
        () {
      final route = DiscourseNotificationRoute.from({
        'type': 'discourse_notification',
        'site_url': 'https://forum.example/sub/',
        'recipient_user_id': '7',
        'notification_type': type,
        'topic_id': 42,
        'post_number': 1,
        'chat_channel_id': type == 29 ? 3 : null,
        'badge_id': 4,
        'group_name': 'team',
        'username': 'actor',
      });
      expect(route.permits(account()), isTrue);
      expect(route.permits(account(id: '8')), isFalse);
      expect(route.permits(account(id: null)), isFalse);
      expect(
          route.permits(account(url: 'https://forum.example/other')), isFalse);
      expect(route.permits(account(url: 'https://forum.example:444/sub')),
          isFalse);
    });
  }

  test('legacy or malformed push recipients fail closed; links still work', () {
    for (final recipient in [null, '', '7.5', 'invalid', '-1']) {
      final route = DiscourseNotificationRoute.from({
        'site_url': 'https://forum.example/sub',
        'recipient_user_id': recipient,
        'topic_id': 42,
      });
      expect(route.permits(account()), isFalse);
    }
    expect(
        const DiscourseNotificationRoute(
                kind: NotificationRouteKind.topicPage, topicId: '42')
            .permits(account(id: null)),
        isTrue);
  });
}
