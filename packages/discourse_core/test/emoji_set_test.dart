import 'dart:convert';
import 'dart:io';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'discourse_client_measurement_test.dart' show CountingServer, contextFor;

/// A standard emoji's artwork has a known address in the forum's emoji set
/// (`Emoji.url_for`, the web's `buildEmojiUrl`), so drawing one needs only
/// the client settings, not the forum's whole `/emojis.json`.
void main() {
  setUp(DiscourseEmojiSet.clear);

  test('the address follows the set, a tone as <name>/<tone>.png', () {
    expect(DiscourseEmojiSet.urlFor('https://f.example', 'wave'), isNull,
        reason: 'unknown until the settings are read');
    DiscourseEmojiSet.storeFromClientSettings(
        'https://f.example/', {'emoji_set': 'google'});
    expect(DiscourseEmojiSet.urlFor('https://f.example', 'wave'),
        'https://f.example/images/emoji/google/wave.png?v=15');
    expect(DiscourseEmojiSet.urlFor('https://f.example', 'wave', tone: 3),
        'https://f.example/images/emoji/google/wave/3.png?v=15');
  });

  test('a subfolder forum and external_emoji_url', () {
    DiscourseEmojiSet.storeFromClientSettings(
        'https://f.example/forum', {'emoji_set': 'twitter'});
    expect(DiscourseEmojiSet.urlFor('https://f.example/forum', 'heart'),
        'https://f.example/forum/images/emoji/twitter/heart.png?v=15');
    DiscourseEmojiSet.storeFromClientSettings('https://g.example', {
      'emoji_set': 'twitter',
      'external_emoji_url': 'https://cdn.example/emoji/',
    });
    expect(DiscourseEmojiSet.urlFor('https://g.example', 'heart'),
        'https://cdn.example/emoji/twitter/heart.png?v=15');
  });

  test('settings without a set leave the last one known', () {
    DiscourseEmojiSet.set('https://f.example', 'apple');
    DiscourseEmojiSet.storeFromClientSettings('https://f.example', {});
    expect(DiscourseEmojiSet.urlFor('https://f.example', 'heart'),
        'https://f.example/images/emoji/apple/heart.png?v=15');
  });

  group('read with the forum configuration', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    late CountingServer server;

    setUp(() async {
      HttpOverrides.global = null;
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      DiscourseClient.invalidateReadCache();
      DiscourseSiteCapabilities.reset();
      DiscourseSiteContextExtension.resetChatProbeCache();
      server = await CountingServer.start();
      server.routes['/about.json'] =
          (r) => r.response.write('{"about":{"version":"3.4"}}');
      server.routes['/site/settings.json'] = (r) =>
          r.response.write(jsonEncode({'emoji_set': 'fluentui'}));
      server.routes['/site.json'] =
          (r) => r.response.write('{"categories":[]}');
      server.routes['/chat/api/me/channels'] = (r) {
        r.response.statusCode = 404;
        r.response.write('{}');
      };
    });
    tearDown(() => server.close());

    test('getConfig records the emoji set from /site/settings.json',
        () async {
      await DiscourseConfigProxy(contextFor(server)).getConfig(server.baseUrl);
      expect(DiscourseEmojiSet.urlFor(server.baseUrl, 'tada'),
          '${server.baseUrl}/images/emoji/fluentui/tada.png?v=15');
    });
  });
}
