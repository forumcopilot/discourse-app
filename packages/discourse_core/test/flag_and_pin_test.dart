import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The forum's own flag types (web's flag modal reads them from /site.json)
/// and web's "Pin Topic…" (pinned or pinned globally, until a date).
void main() {
  group('flag types from /site.json', () {
    final site = {
      'top_menu_items': ['latest'],
      'post_action_types': [
        {'id': 6, 'name_key': 'notify_user', 'name': 'Send @%{username} a message', 'description': 'Talk to them.', 'is_flag': true, 'require_message': true, 'applies_to': ['Post', 'Chat::Message'], 'enabled': true},
        {'id': 3, 'name_key': 'off_topic', 'name': 'Off-Topic', 'description': 'Not relevant', 'is_flag': true, 'require_message': false, 'applies_to': ['Post'], 'enabled': true},
        {'id': 4, 'name_key': 'inappropriate', 'name': 'Inappropriate', 'description': 'A violation of <a href="/guidelines">our community guidelines</a>', 'is_flag': true, 'applies_to': ['Post', 'Topic']},
        {'id': 10, 'name_key': 'illegal', 'name': 'Illegal', 'is_flag': true, 'require_message': true, 'applies_to': ['Post', 'Topic'], 'enabled': true},
        {'id': 1001, 'name_key': 'custom_topic_only', 'name': 'Topic only', 'is_flag': true, 'applies_to': ['Topic'], 'enabled': true},
        {'id': 1002, 'name_key': 'custom_off', 'name': 'Turned off', 'is_flag': true, 'applies_to': ['Post'], 'enabled': false},
        {'id': 2, 'name_key': 'like', 'name': 'Like', 'is_flag': false, 'applies_to': ['Post']},
      ],
    };

    test('flags on posts that are on, in the forum order and words', () {
      DiscourseSiteCapabilities.store('https://f.example', site);
      final types = DiscourseSiteCapabilities.forSite('https://f.example').flagTypes;
      expect(types.map((t) => t.nameKey),
          ['notify_user', 'off_topic', 'inappropriate', 'illegal'],
          reason: 'a like, a topic-only flag and a disabled one are no post flags');
      expect(types[2].description, 'A violation of our community guidelines');
      expect(types[3].requireMessage, isTrue,
          reason: 'Illegal needs a message, which the old list did not even offer');
      expect(types.first.isMessageToAuthor, isTrue);
      expect(types.first.nameFor('alice'), 'Send @alice a message');
    });

    test("the forum's minimum message length", () {
      DiscourseSiteCapabilities.storeClientSettings(
          'https://f.example', {'min_personal_message_post_length': 4});
      expect(DiscourseSiteCapabilities.forSite('https://f.example').minPersonalMessageLength, 4);
    });

    test('read on demand when the forum has not been read yet', () async {
      final proxy = _Posts(_ctx('https://g.example'), site);
      final types = await proxy.flagTypesAsync();
      expect(types, hasLength(4));
      expect(proxy.gets, ['/site.json']);
      await proxy.flagTypesAsync();
      expect(proxy.gets, ['/site.json'], reason: 'once per forum');
    });
  });

  group('Pin Topic…', () {
    const url = 'https://forum.example';
    setUp(() {
      DiscourseTopicStatus.clear();
      DiscourseTopicStatus.store(url, '7', DiscourseTopicStatus.fromTopicView({}));
    });

    test('in its category until a date', () async {
      final proxy = _Moderation(_ctx(url));
      final r = await proxy.pinTopicAsync('7', until: DateTime(2026, 10, 9));
      expect(r.result, isTrue);
      expect(proxy.puts.single.$1, '/t/7/status.json');
      expect(proxy.puts.single.$2, {
        'status': 'pinned',
        'enabled': 'true',
        'until': '2026-10-09',
      });
      final s = DiscourseTopicStatus.forTopic(url, '7')!;
      expect((s.pinned, s.pinnedGlobally), (true, false));
    });

    test('globally', () async {
      final proxy = _Moderation(_ctx(url));
      await proxy.pinTopicAsync('7', globally: true, until: DateTime(2026, 12, 1));
      expect((proxy.puts.single.$2 as Map)['status'], 'pinned_globally');
      expect(DiscourseTopicStatus.forTopic(url, '7')!.pinnedGlobally, isTrue);
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

class _Posts extends DiscoursePostProxy {
  _Posts(super.context, this.site);
  final Map<String, dynamic> site;
  final gets = <String>[];
  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    gets.add(path);
    return site;
  }
}

class _Moderation extends DiscourseModerationProxy {
  _Moderation(super.context);
  final puts = <(String, Object?)>[];
  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    puts.add((path, body));
    return const {'success': 'OK'};
  }
}
