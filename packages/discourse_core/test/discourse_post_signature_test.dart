import 'dart:convert';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// ABDA ends each post its members create with "Sent from ABDA", linked to
/// its homepage. The line must never make a forum refuse, flag or hold a
/// post it would otherwise take, nor let through one it would refuse.
void main() {
  const linked = '<small>Sent from [ABDA](https://betterdiscourse.app)</small>';
  const plain = '<small>Sent from ABDA</small>';
  const reply = 'Thanks, that fixed it for me as well.';
  late SiteContext site;

  Map<String, dynamic> sign(Map<String, dynamic> body,
          {String path = '/posts.json'}) =>
      DiscoursePostSignature.applyTo(site, path, body) as Map<String, dynamic>;

  setUp(() {
    site = _site();
    DiscourseSiteCapabilities.reset();
    DiscourseMessageDetails.clear();
    DiscoursePostSignature.current = const DiscoursePostSignature(
        appName: 'ABDA', homepage: 'https://betterdiscourse.app');
    DiscoursePostSignature.enabled = true;
    site.setTrustLevel(1);
    site.setLinkPostingAccess('full');
  });

  tearDown(() {
    DiscoursePostSignature.current = null;
    DiscoursePostSignature.enabled = true;
    site.setTrustLevel(null);
    site.setLinkPostingAccess(null);
  });

  test('a reply ends with the linked line, through apiPost', () async {
    final client = _CapturingClient();
    await _Proxy(site, client).apiPost('/posts.json',
        body: {'topic_id': 7, 'raw': '$reply\n\n', 'archetype': 'regular'});
    expect(client.body!['raw'], '$reply\n\n$linked');
    expect(client.body!['topic_id'], 7);
  });

  test('nothing without a host line, or once the member turns it off', () {
    DiscoursePostSignature.enabled = false;
    expect(sign({'topic_id': 7, 'raw': reply})['raw'], reply);
    DiscoursePostSignature.enabled = true;
    DiscoursePostSignature.current = null;
    expect(sign({'topic_id': 7, 'raw': reply})['raw'], reply);
  });

  test('edits and other requests are left alone', () {
    expect(sign({'post': {'raw': reply}}, path: '/posts/5.json'),
        {'post': {'raw': reply}});
    expect(sign({'message': reply}, path: '/chat/3.json'), {'message': reply});
  });

  group('the link', () {
    test('not for a new member in a topic: link limits and host-spam flags',
        () {
      site.setTrustLevel(0);
      expect(sign({'topic_id': 7, 'raw': reply})['raw'], '$reply\n\n$plain');
      expect(
          sign({'title': 'Printer setup', 'raw': reply, 'category': 3})['raw'],
          '$reply\n\n$plain');
    });

    test('not where links are limited, off, or not reported', () {
      site.setTrustLevel(2);
      for (final access in ['limited', 'none', null]) {
        site.setLinkPostingAccess(access);
        expect(sign({'topic_id': 7, 'raw': reply})['raw'], '$reply\n\n$plain',
            reason: 'link_posting_access: $access');
      }
    });

    test('in a message, by the same rule', () {
      // A new message is checked for host spam before its topic exists, so
      // a new member's third linked message is refused (seen on a local
      // Discourse: "Sorry you cannot post a link to that host").
      final message = {
        'archetype': 'private_message',
        'target_recipients': 'sam',
        'title': 'Hello',
        'raw': reply,
      };
      expect(sign(message)['raw'], '$reply\n\n$linked');
      DiscourseMessageDetails.store(
          '42', const DiscourseMessageDetails(canLeave: true));
      expect(sign({'topic_id': 42, 'raw': reply})['raw'], '$reply\n\n$linked');
      site.setTrustLevel(0);
      expect(sign(message)['raw'], '$reply\n\n$plain');
      expect(sign({'topic_id': 42, 'raw': reply})['raw'], '$reply\n\n$plain');
    });
  });

  group("the forum's rules, without the line", () {
    test('a post too short to be accepted goes as written', () {
      expect(sign({'topic_id': 7, 'raw': 'thanks!'})['raw'], 'thanks!');
      expect(sign({'title': 'Hi', 'raw': 'Short first post'})['raw'],
          'Short first post');
    });

    test("the forum's own minimums, and a message's lower one", () {
      DiscourseSiteCapabilities.storeClientSettings(site.site.pluginUrl, {
        'min_post_length': 5,
        'min_first_post_length': 30,
        'min_personal_message_post_length': 8,
      });
      expect(sign({'topic_id': 7, 'raw': 'thanks!'})['raw'],
          'thanks!\n\n$linked');
      expect(sign({'title': 'Hi', 'raw': reply})['raw'], '$reply\n\n$linked');
      expect(sign({'title': 'Hi', 'raw': 'Twenty-two characters!'})['raw'],
          'Twenty-two characters!');
      expect(
          sign({'archetype': 'private_message', 'title': 'Hi', 'raw': 'Hi Sam!!'})['raw'],
          'Hi Sam!!\n\n$linked');
    });

    test('an emoji counts as one character, as Discourse counts it', () {
      const raw = ':smile: :smile: :smile: ok :)';
      expect(sign({'topic_id': 7, 'raw': raw})['raw'], raw);
    });

    test('uploads do not count where the forum says so', () {
      const raw = '![photo|800x600](upload://abcdefghijklmnop.jpeg)';
      expect(sign({'topic_id': 7, 'raw': raw})['raw'], '$raw\n\n$linked');
      DiscourseSiteCapabilities.storeClientSettings(
          site.site.pluginUrl, {'prevent_uploads_only_posts': true});
      expect(sign({'topic_id': 7, 'raw': raw})['raw'], raw);
    });

    test('all capitals goes as written', () {
      const raw = 'PLEASE HELP ME WITH THIS PRINTER NOW';
      expect(sign({'topic_id': 7, 'raw': raw})['raw'], raw);
    });

    test('too few different characters goes as written', () {
      const raw = 'aaaaaaaaaaaa bbbbbbbbbbbbb';
      expect(sign({'topic_id': 7, 'raw': raw})['raw'], raw);
    });

    test('a post the line would push past the maximum goes as written', () {
      DiscourseSiteCapabilities.storeClientSettings(
          site.site.pluginUrl, {'max_post_length': reply.length + 10});
      expect(sign({'topic_id': 7, 'raw': reply})['raw'], reply);
    });
  });
}

SiteContext _site() => SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Test',
        url: 'https://forum.example',
        description: '',
        endpoint: null,
        baseUrl: 'https://forum.example',
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      ),
    );

class _Proxy extends BaseDiscourseProxy {
  _Proxy(SiteContext site, DiscourseClient client) : super(site, client: client);
}

/// Records the body of the last POST instead of sending it.
class _CapturingClient extends DiscourseClient {
  Map<String, dynamic>? body;

  @override
  Future<FCCallResult> post(SiteContext context, String path,
      {Map<String, dynamic>? query,
      Object? body,
      Map<String, String>? extraHeaders}) async {
    this.body = (body is String ? jsonDecode(body) : body as Map)
        .cast<String, dynamic>();
    return FCCallResult(statusCode: 200, body: '{"id": 1}');
  }
}
