import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/host/discourse_host.dart';
import 'package:discourse_ui/services/notification_forum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/models/domain/site.dart';

Site forum(String url, {int? id}) => Site(
      id: id,
      name: 'Forum',
      url: url,
      baseUrl: url,
      description: '',
      endpoint: null,
      logoUrl: null,
      backgroundUrl: null,
      siteType: 'discourse',
    );

void main() {
  tearDown(() => DiscourseHost.resolveForum = null);

  test('same forum tolerates host case, default port and trailing slash', () {
    expect(
        NotificationForum.matches(forum('https://EXAMPLE.com:443/forum/'),
            forum('https://example.com/forum')),
        isTrue);
  });

  test('the scheme does not separate a forum, as the relay keys it', () {
    // The backend files http:// and https:// of one host as one forum and
    // echoes whichever registered first as site_url.
    final current = forum('https://example.com/forum');
    for (final url in [
      'http://example.com/forum',
      'http://EXAMPLE.com:80/forum/',
      'https://example.com:443/forum',
    ]) {
      expect(NotificationForum.matches(current, forum(url)), isTrue,
          reason: url);
    }
    expect(NotificationForum.identity('https://Example.COM:8443/Sub/'),
        'example.com:8443/Sub');
  });

  test('same host cannot reuse another port or subfolder session', () {
    final current = forum('https://example.com/forum');
    for (final url in [
      'https://example.com:80/forum',
      'http://example.com:443/forum',
      'https://example.com:8443/forum',
      'https://example.com',
      'https://example.com/forum/nested',
      'https://example.com/Forum',
      'https://www.example.com/forum',
    ]) {
      expect(NotificationForum.matches(current, forum(url)), isFalse,
          reason: url);
    }
  });

  test('equal directory IDs cannot override different base URLs', () {
    expect(
        NotificationForum.matches(forum('https://example.com/a', id: 1),
            forum('https://example.com/b', id: 1)),
        isFalse);
  });

  test('a persisted forum with a changed ID still has the same identity', () {
    expect(
        NotificationForum.matches(forum('https://example.com', id: 1),
            forum('https://example.com', id: 2)),
        isTrue);
  });

  test('missing or malformed forum addresses do not match', () {
    expect(NotificationForum.matches(null, null), isFalse);
    for (final url in [
      '',
      '/relative',
      'ftp://example.com',
      'https://user@example.com',
      'https://example.com/?x=1',
      'https://example.com/#top',
    ]) {
      expect(NotificationForum.matches(forum(url), forum(url)), isFalse,
          reason: url);
    }
  });

  test('host resolver receives the payload and selects the forum', () async {
    final target = forum('https://example.com/sub');
    final payload = {'site_url': target.url};
    DiscourseHost.resolveForum = (id, data) async {
      expect(id, 7);
      expect(data, same(payload));
      return target;
    };
    expect(await NotificationForum.resolve(7, payload), same(target));
  });

  test('host no-match cannot open the template forum', () async {
    DiscourseHost.resolveForum = (_, __) async => null;
    expect(await NotificationForum.resolve(0, {}), isNull);
  });

  test('host error cannot open the template forum', () async {
    DiscourseHost.resolveForum = (_, __) async => throw StateError('offline');
    expect(await NotificationForum.resolve(0, {}), isNull);
  });

  test('standalone app retains configured forum resolution', () async {
    expect((await NotificationForum.resolve(0, {}))?.pluginUrl,
        AppForumConfig.buildSite().pluginUrl);
  });
}
