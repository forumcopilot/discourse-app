import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'discourse_client_measurement_test.dart' show CountingServer, contextFor;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CountingServer server;
  var allowTags = false;
  var minSearchLength = 3;
  var chatStatus = 404;
  var siteStatus = 200;
  Completer<void>? holdSite;
  Completer<void>? siteStarted;

  setUp(() async {
    HttpOverrides.global = null;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    DiscourseClient.invalidateReadCache();
    DiscourseSiteCapabilities.reset();
    DiscourseSiteContextExtension.resetChatProbeCache();
    allowTags = false;
    minSearchLength = 3;
    chatStatus = 404;
    siteStatus = 200;
    holdSite = null;
    siteStarted = null;
    server = await CountingServer.start();
    server.routes['/about.json'] =
        (r) => r.response.write('{"about":{"version":"3.4"}}');
    server.routes['/site/settings.json'] = (r) => r.response.write(jsonEncode({
          'min_search_term_length': minSearchLength,
        }));
    server.routes['/chat/api/me/channels'] = (r) {
      r.response.statusCode = chatStatus;
      r.response.write('{}');
    };
    server.routes['/site.json'] = (r) async {
      final reply = jsonEncode({
        'top_menu_items': ['latest'],
        'can_create_tag': allowTags,
        'can_tag_topics': allowTags,
        'categories': [
          {'id': allowTags ? 99 : 1, 'name': allowTags ? 'Private' : 'Public'}
        ],
      });
      final gate = holdSite;
      holdSite = null;
      siteStarted?.complete();
      siteStarted = null;
      if (gate != null) await gate.future;
      r.response.statusCode = siteStatus;
      r.response.write(reply);
    };
  });
  tearDown(() => server.close());

  DiscourseSiteCapabilities caps() =>
      DiscourseSiteCapabilities.forSite(server.baseUrl);

  test('force refresh fetches current capabilities, settings, and chat support',
      () async {
    final context = contextFor(server);
    final proxy = DiscourseConfigProxy(context);
    await proxy.getConfig(server.baseUrl);
    allowTags = true;
    minSearchLength = 7;
    chatStatus = 200;
    final config = await proxy.getConfig(server.baseUrl, forceRefresh: true);
    expect(caps().canCreateTag, isTrue);
    expect(config.minSearchLength, 7);
    expect(context.chatEnabled, isTrue);
    final subsequent = await proxy.getConfig(server.baseUrl);
    expect(subsequent.minSearchLength, 7);
    for (final path in [
      '/about.json',
      '/site.json',
      '/site/settings.json',
      '/chat/api/me/channels'
    ]) {
      expect(server.count(path: path),
          path == '/site/settings.json' || path == '/about.json' ? 3 : 2,
          reason: path);
    }
  });

  test('unchanged session keeps capabilities and chat probes memoized',
      () async {
    final context = contextFor(server);
    await DiscourseConfigProxy(context).getConfig(server.baseUrl);
    await DiscourseConfigProxy(context).getConfig(server.baseUrl);
    expect(server.count(path: '/site.json'), 1);
    expect(server.count(path: '/chat/api/me/channels'), 1);
  });

  test(
      'login and logout clear permissions immediately and reload without force',
      () async {
    final context = contextFor(server);
    final proxy = DiscourseConfigProxy(context);
    await proxy.getConfig(server.baseUrl);
    await context.setUserApiCredentials(
        userApiKey: 'dummy-member', userApiClientId: 'client');
    expect(DiscourseSiteCapabilities.isResolved(server.baseUrl), isFalse);
    allowTags = true;
    await proxy.getConfig(server.baseUrl);
    expect(caps().canCreateTag, isTrue);
    await context.clearUserApiCredentials();
    expect(caps().canCreateTag, isFalse);
    expect(caps().categories, isEmpty);
    allowTags = false;
    await proxy.getConfig(server.baseUrl);
    expect(caps().canCreateTag, isFalse);
    expect(caps().categories.single['id'], 1);
    expect(server.count(path: '/site.json'), 3);
  });

  test('restoring credentials refreshes a previously anonymous context',
      () async {
    final saved = contextFor(server);
    await saved.setUserApiCredentials(
        userApiKey: 'dummy-member', userApiClientId: 'client');
    final context = contextFor(server);
    final proxy = DiscourseConfigProxy(context);
    await proxy.getConfig(server.baseUrl);
    await context.loadUserApiCredentials();
    allowTags = true;
    await proxy.getConfig(server.baseUrl);
    expect(caps().canTagTopics, isTrue);
    await context.loadUserApiCredentials();
    await proxy.getConfig(server.baseUrl);
    expect(server.count(path: '/site.json'), 2);
  });

  test('a late anonymous response cannot overwrite the logged-in capabilities',
      () async {
    final context = contextFor(server);
    final proxy = DiscourseConfigProxy(context);
    final gate = Completer<void>();
    final started = Completer<void>();
    holdSite = gate;
    siteStarted = started;
    final anonymous = proxy.getConfig(server.baseUrl);
    await started.future;
    await context.setUserApiCredentials(
        userApiKey: 'dummy-member', userApiClientId: 'client');
    allowTags = true;
    await proxy.getConfig(server.baseUrl);
    gate.complete();
    await anonymous;
    expect(caps().canCreateTag, isTrue);
    expect(caps().categories.single['id'], 99);
  });

  test('failed refresh stays unresolved and can retry', () async {
    final proxy = DiscourseConfigProxy(contextFor(server));
    allowTags = true;
    await proxy.getConfig(server.baseUrl);
    siteStatus = 500;
    await proxy.getConfig(server.baseUrl, forceRefresh: true);
    expect(DiscourseSiteCapabilities.isResolved(server.baseUrl), isFalse);
    expect(caps().canCreateTag, isFalse);
    siteStatus = 200;
    allowTags = false;
    await proxy.getConfig(server.baseUrl);
    expect(DiscourseSiteCapabilities.isResolved(server.baseUrl), isTrue);
    expect(caps().canCreateTag, isFalse);
  });
  test('concurrent loads within one session share the capability request',
      () async {
    final proxy = DiscourseConfigProxy(contextFor(server));
    final gate = Completer<void>();
    final started = Completer<void>();
    holdSite = gate;
    siteStarted = started;
    final first = proxy.getConfig(server.baseUrl);
    await started.future;
    final second = proxy.getConfig(server.baseUrl);
    gate.complete();
    await Future.wait([first, second]);
    expect(server.count(path: '/site.json'), 1);
  });

  test('a newer forced refresh wins over an older pending response', () async {
    final proxy = DiscourseConfigProxy(contextFor(server));
    final gate = Completer<void>();
    final started = Completer<void>();
    holdSite = gate;
    siteStarted = started;
    final first = proxy.getConfig(server.baseUrl, forceRefresh: true);
    await started.future;
    allowTags = true;
    await proxy.getConfig(server.baseUrl, forceRefresh: true);
    gate.complete();
    await first;
    expect(caps().canCreateTag, isTrue);
    expect(server.count(path: '/site.json'), 2);
  });

  test('credential invalidation leaves another forum untouched', () async {
    const otherForum = 'https://other.example/forum';
    DiscourseSiteCapabilities.store(otherForum, {
      'top_menu_items': ['latest'],
      'can_create_tag': true,
    });
    final context = contextFor(server);
    await DiscourseConfigProxy(context).getConfig(server.baseUrl);
    await context.setUserApiCredentials(
        userApiKey: 'dummy-member', userApiClientId: 'client');
    expect(DiscourseSiteCapabilities.forSite(otherForum).canCreateTag, isTrue);
  });
  test('late settings cannot repopulate either capability or HTTP caches',
      () async {
    final context = contextFor(server);
    final proxy = DiscourseConfigProxy(context);
    final gate = Completer<void>();
    final started = Completer<void>();
    var firstSettings = true;
    server.routes['/site/settings.json'] = (r) async {
      if (firstSettings) {
        firstSettings = false;
        started.complete();
        await gate.future;
        r.response.write('{"min_search_term_length":3,"top_menu":"latest"}');
      } else {
        r.response.write('{"min_search_term_length":7,"top_menu":"hot"}');
      }
    };
    final older = proxy.getConfig(server.baseUrl);
    await started.future;
    await proxy.getConfig(server.baseUrl, forceRefresh: true);
    gate.complete();
    await older;
    expect(caps().topMenu, ['hot']);
    final latest = await proxy.getConfig(server.baseUrl);
    expect(latest.minSearchLength, 7);
    expect(caps().topMenu, ['hot']);
  });
}
