import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Capability reads outside getConfig — the flag dialog's flag types, Edit
/// profile's rules — fill in what startup did not read. A reply to the
/// previous sign-in must not land in the next one's capabilities, which is
/// what the config proxy's own reads already guard against.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const url = 'https://caps.example';
  late SiteContext context;
  late String signedIn;

  Map<String, dynamic> siteFor(String who) => {
        'top_menu_items': ['latest'],
        'can_create_tag': who == 'b',
        'categories': [
          {'id': who == 'b' ? 99 : 1, 'name': 'Seen by $who'},
        ],
        'post_action_types': [
          {
            'id': 4,
            'name_key': 'inappropriate',
            'name': 'Inappropriate for $who',
            'is_flag': true,
            'applies_to': ['Post'],
            'enabled': true,
          },
        ],
      };

  Map<String, dynamic> settingsFor(String who) => {
        'top_menu': 'latest',
        'enable_names': who == 'b',
      };

  /// What the forum answers whoever is signed in when the request goes out.
  Map<String, dynamic> reply(String path) => switch (path) {
        '/site.json' => siteFor(signedIn),
        '/site/settings.json' => settingsFor(signedIn),
        _ => throw StateError('unexpected $path'),
      };

  /// The next sign-in takes over, and its getConfig reads the forum.
  Future<void> signInAs(String who) async {
    await context.setUserApiCredentials(
        userApiKey: 'dummy-$who', userApiClientId: 'client');
    signedIn = who;
    DiscourseSiteCapabilities.beginSession(url, context.configurationSession);
    DiscourseSiteCapabilities.storeClientSettings(url, settingsFor(who));
    DiscourseSiteCapabilities.store(url, siteFor(who));
  }

  DiscourseSiteCapabilities caps() => DiscourseSiteCapabilities.forSite(url);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    DiscourseSiteCapabilities.reset();
    context = _ctx(url);
    await context.setUserApiCredentials(
        userApiKey: 'dummy-a', userApiClientId: 'client');
    signedIn = 'a';
  });

  group('flag types', () {
    test("a reply to the previous sign-in does not replace the next one's",
        () async {
      final forum = _Replies(reply, hold: '/site.json');
      final pending = _Posts(context, forum).flagTypesAsync();
      await forum.held.future;

      await signInAs('b');
      forum.release();
      final types = await pending;

      expect(caps().categories.single['name'], 'Seen by b');
      expect(caps().canCreateTag, isTrue);
      expect(types.single.name, 'Inappropriate for b');
    });

    test(
        'a reply to a sign-in that has ended is not kept for the '
        'signed-out reader', () async {
      final forum = _Replies(reply, hold: '/site.json');
      final pending = _Posts(context, forum).flagTypesAsync();
      await forum.held.future;

      await context.clearUserApiCredentials();
      signedIn = 'guest';
      forum.release();
      final types = await pending;

      expect(DiscourseSiteCapabilities.isResolved(url), isFalse,
          reason: "the signed-out reader's capabilities are read anew");
      expect(types, isEmpty);
    });

    test('an unchanged sign-in stores what it read, once', () async {
      final forum = _Replies(reply);
      final proxy = _Posts(context, forum);
      expect((await proxy.flagTypesAsync()).single.name,
          'Inappropriate for a');
      await proxy.flagTypesAsync();
      expect(forum.gets, ['/site.json']);
      expect(caps().categories.single['name'], 'Seen by a');
    });
  });

  group("the forum's profile rules", () {
    test('a settings reply to the previous sign-in is not stored', () async {
      final forum = _Replies(reply, hold: '/site/settings.json');
      final pending = _Profile(context, forum).forumRules();
      await forum.held.future;

      await signInAs('b');
      forum.release();
      final rules = await pending;

      expect(caps().profileSettings!.enableNames, isTrue);
      expect(rules.settings.enableNames, isTrue);
      expect(caps().categories.single['name'], 'Seen by b');
      expect(forum.gets, ['/site/settings.json'],
          reason: "b's capabilities were already read");
    });

    test('a site reply to the previous sign-in is not stored', () async {
      DiscourseSiteCapabilities.storeClientSettings(url, settingsFor('a'));
      final forum = _Replies(reply, hold: '/site.json');
      final pending = _Profile(context, forum).forumRules();
      await forum.held.future;

      await signInAs('b');
      forum.release();
      await pending;

      expect(caps().categories.single['name'], 'Seen by b');
      expect(caps().canCreateTag, isTrue);
    });

    test('an unchanged sign-in stores both replies', () async {
      final forum = _Replies(reply);
      final rules = await _Profile(context, forum).forumRules();
      expect(forum.gets, ['/site/settings.json', '/site.json']);
      expect(rules.settings.enableNames, isFalse);
      expect(caps().profileSettings!.enableNames, isFalse);
      expect(caps().categories.single['name'], 'Seen by a');
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
    );

/// The forum, answering as whoever is signed in when a request goes out;
/// the [hold] path waits for [release] before its answer arrives.
class _Replies {
  _Replies(this._reply, {this.hold});
  final Map<String, dynamic> Function(String path) _reply;
  final String? hold;
  final gets = <String>[];
  final held = Completer<void>();
  final _gate = Completer<void>();

  void release() => _gate.complete();

  Future<Map<String, dynamic>> get(String path) async {
    gets.add(path);
    final body = _reply(path);
    if (path == hold && !held.isCompleted) {
      held.complete();
      await _gate.future;
    }
    return body;
  }
}

class _Posts extends DiscoursePostProxy {
  _Posts(super.context, this.forum);
  final _Replies forum;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) =>
      forum.get(path);
}

class _Profile extends DiscourseProfileProxy {
  _Profile(super.context, this.forum);
  final _Replies forum;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) =>
      forum.get(path);
}
