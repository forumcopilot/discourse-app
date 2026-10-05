import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/services/discourse_login_service.dart';
import 'package:discourse_ui/services/notification_key_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_account_switch_test.dart' show account;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SiteContext site;
  late DiscourseLoginService login;
  late SharedPreferences prefs;
  late String prefix;
  final calls = <Map<String, dynamic>>[];
  final until = DateTime.utc(2099, 1, 1);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
            (_) async => null);
    AppForumConfig.setNotificationsApiBaseUrl('https://relay.example/api');
    site = account();
    await site.setUserApiCredentials(
        userApiKey: 'first-key', userApiClientId: 'first-client');
    login = DiscourseLoginService(site);
    prefix = site.discourseStoragePrefix;
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        '${prefix}_notifications_client_suffix', 'first-grant');
    await login.markNotificationsGranted(installBound: true);
    calls.clear();
    NotificationKeyService.requestOverride = (method, path, body) async {
      calls.add({'method': method, 'path': path, ...body});
      return {'ok': true};
    };
  });
  tearDown(() {
    NotificationKeyService.requestOverride = null;
    AppForumConfig.setNotificationsApiBaseUrl(null);
  });
  Future<void> replaceGrant({bool changeAccount = true}) async {
    if (changeAccount) {
      await site.setUserApiCredentials(
          userApiKey: 'second-key', userApiClientId: 'second-client');
      site.setLoginData(FCLoginResult(
          result: true,
          resultText: '',
          user: FCUser(id: '8', username: 'user8')));
    }
    await prefs.setString(
        '${prefix}_notifications_client_suffix', 'second-grant');
    await login.markNotificationsGranted(installBound: true);
    await prefs
        .setStringList('${prefix}_notifications_muted_groups', ['reactions']);
    await prefs.setString(
        '${prefix}_notifications_dnd_reported', 'new-account-dnd');
  }

  Future<bool?> change(String kind) async {
    if (kind == 'mute') return login.setPushGroupMuted('messages', true);
    await login.syncDoNotDisturb(until);
    return null;
  }

  for (final kind in ['mute', 'dnd']) {
    for (final phase in ['before dispatch', 'response']) {
      test('$kind account switch during $phase preserves replacement settings',
          () async {
        final oldClientId = await login.notificationsClientId();
        final started = Completer<void>();
        final response = Completer<Map<String, dynamic>?>();
        NotificationKeyService.requestOverride = (method, path, body) async {
          calls.add({'method': method, 'path': path, ...body});
          if (!started.isCompleted) started.complete();
          return phase == 'response' ? response.future : {'ok': true};
        };
        final pending = change(kind);
        if (phase == 'response') await started.future;
        await replaceGrant();
        if (phase == 'response') response.complete({'ok': true});
        final result = await pending;
        if (kind == 'mute') expect(result, isFalse);
        expect(calls, hasLength(phase == 'before dispatch' ? 0 : 1));
        if (calls.isNotEmpty) expect(calls.single['client_id'], oldClientId);
        expect(await login.mutedPushGroups(), {'reactions'});
        expect(prefs.getString('${prefix}_notifications_dnd_reported'),
            'new-account-dnd');
      });
    }
    test('$kind grant replacement during client-ID lookup sends no request',
        () async {
      final gated = _GatedLogin(site);
      final pending = kind == 'mute'
          ? gated.setPushGroupMuted('messages', true)
          : gated.syncDoNotDisturb(until).then<bool?>((_) => null);
      await gated.started.future;
      await replaceGrant(changeAccount: false);
      gated.release.complete();
      final result = await pending;
      if (kind == 'mute') expect(result, isFalse);
      expect(calls, isEmpty);
      expect(await login.mutedPushGroups(), {'reactions'});
      expect(prefs.getString('${prefix}_notifications_dnd_reported'),
          'new-account-dnd');
    });
    test(
        '$kind late response cannot update a replacement grant for the same account',
        () async {
      final started = Completer<void>();
      final response = Completer<Map<String, dynamic>?>();
      NotificationKeyService.requestOverride = (_, __, body) {
        calls.add(body);
        started.complete();
        return response.future;
      };
      final pending = change(kind);
      await started.future;
      await replaceGrant(changeAccount: false);
      response.complete({'ok': true});
      final result = await pending;
      if (kind == 'mute') expect(result, isFalse);
      expect(calls, hasLength(1));
      expect(await login.mutedPushGroups(), {'reactions'});
      expect(prefs.getString('${prefix}_notifications_dnd_reported'),
          'new-account-dnd');
    });
    test('$kind unchanged session persists the acknowledged setting', () async {
      final clientId = await login.notificationsClientId();
      final result = await change(kind);
      expect(calls.single['client_id'], clientId);
      expect(calls.single['site_url'], site.site.url);
      if (kind == 'mute') {
        expect(result, isTrue);
        expect(await login.mutedPushGroups(), {'messages'});
        expect(calls.single['muted_groups'], ['messages']);
      } else {
        expect(prefs.getString('${prefix}_notifications_dnd_reported'),
            until.toIso8601String());
        await change(kind);
        expect(calls, hasLength(1), reason: 'acknowledged DND is deduplicated');
      }
    });
    test('$kind backend failure does not persist the setting', () async {
      NotificationKeyService.requestOverride = (_, __, ___) async => null;
      final result = await change(kind);
      if (kind == 'mute') expect(result, isFalse);
      expect(await login.mutedPushGroups(), isEmpty);
      expect(prefs.getString('${prefix}_notifications_dnd_reported'), isNull);
    });
  }
}

class _GatedLogin extends DiscourseLoginService {
  _GatedLogin(super.siteContext);
  final started = Completer<void>();
  final release = Completer<void>();
  @override
  Future<String> notificationsClientId() async {
    final clientId = await super.notificationsClientId();
    started.complete();
    await release.future;
    return clientId;
  }
}
