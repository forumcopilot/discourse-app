import 'dart:async';
import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:discourse_ui/services/discourse_login_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GrantedAuth extends DiscourseAuthManager {
  GrantedAuth(this.context) : super(context);
  final SiteContext context;
  @override
  Future<DiscourseUserApiKey> completeHandshake(String payloadBase64,
      {bool persist = true}) async {
    await context.setUserApiCredentials(
        userApiKey: 'dummy-key', userApiClientId: 'client');
    return const DiscourseUserApiKey(
        key: 'dummy-key', clientId: 'client', pushEnabled: false);
  }
}

class LoginClient extends DiscourseClient {
  LoginClient(
      {this.configOffline = false, this.sessionStatus = 200, this.siteHold});
  final bool configOffline;
  final int sessionStatus;

  /// Holds `/site.json` until completed: a forum slow to answer it.
  final Completer<void>? siteHold;
  final paths = <String>[];
  @override
  Future<FCCallResult> get(SiteContext context, String path,
      {Map<String, dynamic>? query,
      Map<String, String>? extraHeaders,
      bool useCache = true}) async {
    paths.add(path);
    expect(context.hasUserApiKey, isTrue);
    if (path == '/session/current.json') {
      if (sessionStatus != 200) {
        return FCCallResult(statusCode: sessionStatus, body: '{}');
      }
      return FCCallResult(
          statusCode: 200,
          body: jsonEncode({
            'current_user': {'id': 7, 'username': 'member', 'trust_level': 2},
          }));
    }
    expect(useCache, isFalse);
    if (path == '/site.json') await siteHold?.future;
    if (configOffline) {
      return FCCallResult(statusCode: 0, body: '{"error":"offline"}');
    }
    return FCCallResult(
        statusCode: 200,
        body: jsonEncode(path == '/site.json'
            ? {
                'top_menu_items': ['latest'],
                'can_create_tag': true
              }
            : <String, dynamic>{}));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    DiscourseSiteCapabilities.reset();
  });
  test('a sign-in that fails after the key is stored reloads capabilities',
      () async {
    // Storing the key drops them; without a reload the forum stayed on
    // defaults (no logo, colours, Home views) for the rest of the session.
    const url = 'https://forum.example';
    final context = SiteContext(
        siteType: 'discourse',
        site: Site(
            name: 'Forum',
            url: url,
            baseUrl: url,
            description: '',
            siteType: 'discourse'));
    final client = LoginClient(sessionStatus: 502);
    await expectLater(
        DiscourseLoginService(context,
                client: client, authManager: GrantedAuth(context))
            .finishLogin('dummy-payload'),
        throwsStateError);
    expect(context.isLoggedIn, isFalse);
    expect(client.paths, contains('/site.json'));
    expect(DiscourseSiteCapabilities.forSite(url).canCreateTag, isTrue);
  });

  test('a slow forum configuration does not hold sign-in on a spinner',
      () async {
    const url = 'https://forum.example';
    final context = SiteContext(
        siteType: 'discourse',
        site: Site(
            name: 'Forum',
            url: url,
            baseUrl: url,
            description: '',
            siteType: 'discourse'));
    final saved = DiscourseLoginService.configurationRefreshTimeout;
    DiscourseLoginService.configurationRefreshTimeout =
        const Duration(milliseconds: 100);
    addTearDown(
        () => DiscourseLoginService.configurationRefreshTimeout = saved);
    final hold = Completer<void>();
    final client = LoginClient(siteHold: hold);
    // Without the budget this waits for /site.json, which Dio lets run for
    // its 15 s connect and 30 s idle timeouts.
    await DiscourseLoginService(context,
            client: client, authManager: GrantedAuth(context))
        .finishLogin('dummy-payload')
        .timeout(const Duration(seconds: 5));
    expect(context.isLoggedIn, isTrue);
    expect(DiscourseSiteCapabilities.forSite(url).canCreateTag, isFalse);
    // The configuration carries on and lands after sign-in.
    hold.complete();
    await pumpEventQueue();
    expect(DiscourseSiteCapabilities.forSite(url).canCreateTag, isTrue);
  });

  for (final offline in [false, true]) {
    test(
        offline
            ? 'configuration failure does not undo successful login'
            : 'login notification sees refreshed capabilities', () async {
      const url = 'https://forum.example';
      final context = SiteContext(
          siteType: 'discourse',
          site: Site(
              name: 'Forum',
              url: url,
              baseUrl: url,
              description: '',
              siteType: 'discourse'));
      DiscourseSiteCapabilities.store(url, {
        'top_menu_items': ['latest']
      });
      final client = LoginClient(configOffline: offline);
      bool? permissionAtLogin;
      context.isLoggedInNotifier.addListener(() {
        if (context.isLoggedIn) {
          permissionAtLogin =
              DiscourseSiteCapabilities.forSite(url).canCreateTag;
        }
      });
      await DiscourseLoginService(context,
              client: client, authManager: GrantedAuth(context))
          .finishLogin('dummy-payload');
      expect(context.isLoggedIn, isTrue);
      expect(permissionAtLogin, !offline);
      expect(client.paths, contains('/site.json'));
    });
  }
}
