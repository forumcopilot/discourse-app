import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:discourse_ui/services/discourse_link_handler.dart';
import 'package:discourse_ui/services/notification_route.dart';
import 'package:discourse_ui/views/site_home_tab.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Where a link tapped in a post, message or chat leads. Shapes and counts
/// from a survey of 10,835 recent posts on 219 directory forums
/// (2026-09-24): of the links into the same forum, about 70% were topics or
/// posts, 13% categories (mostly the badge in a quote header), then users,
/// tags and hashtags.
void main() {
  const forum = 'https://forum.example.com';
  setUpAll(() => DiscourseSiteCapabilities.store(forum, {
        'top_menu_items': ['latest'],
        'categories': [
          {'id': 7, 'slug': 'support', 'name': 'Support', 'parent_category_id': null},
          {'id': 9, 'slug': 'apps', 'name': 'Apps', 'parent_category_id': 7},
        ],
      }));

  SiteContext site({String url = forum, String? username}) {
    final ctx = SiteContext(
      siteType: 'discourse',
      site: Site(
        id: null,
        name: 'Example',
        url: url,
        description: '',
        endpoint: null,
        baseUrl: url,
        logoUrl: null,
        backgroundUrl: null,
        siteType: 'discourse',
      ),
    );
    if (username != null) {
      ctx.setLoginData(FCLoginResult(
          result: true, resultText: '', user: FCUser(id: '1', username: username)));
    }
    return ctx;
  }

  LinkDestination to(String href,
          {SiteContext? at, String? currentTopicId}) =>
      DiscourseLinkHandler.destinationFor(at ?? site(), href,
          currentTopicId: currentTopicId);

  group('topics and posts', () {
    test('a topic opens on its own screen, at the post the link names', () {
      final d = to('/t/some-topic/123/45');
      expect(d.kind, LinkDestinationKind.topic);
      expect(d.route!.topicId, '123');
      expect(d.route!.postNumber, 45,
          reason: 'the post number used to be dropped');
    });

    test('absolute links, www and http are the same forum', () {
      for (final href in [
        'https://forum.example.com/t/x/123',
        'https://www.forum.example.com/t/x/123',
        'http://forum.example.com/t/x/123',
      ]) {
        expect(to(href).kind, LinkDestinationKind.topic, reason: href);
      }
    });

    test('another post of the topic on screen moves within it', () {
      final d = to('/t/some-topic/123/45', currentTopicId: '123');
      expect(d.kind, LinkDestinationKind.jumpInTopic);
      expect(d.postNumber, 45);
      expect(to('/t/some-topic/123', currentTopicId: '123').postNumber, 1);
      expect(to('/t/other/124/2', currentTopicId: '123').kind,
          LinkDestinationKind.topic);
    });

    test('a post short link is looked up, not guessed', () {
      final d = to('/p/678');
      expect(d.kind, LinkDestinationKind.topic);
      expect(d.route!.kind, NotificationRouteKind.post);
      expect(d.route!.postId, '678');
      expect(d.route!.topicId, isNull);
    });
  });

  group('the forum’s other screens', () {
    test('a category, with its name for the title', () {
      final d = to('/c/support/7');
      expect(d.kind, LinkDestinationKind.category);
      expect(d.categoryId, '7');
      expect(d.categoryName, 'Support', reason: 'the title used to be blank');
    });

    test('a category named only by its slugs', () {
      expect(to('/c/support/apps').categoryId, '9');
      expect(to('/c/nope').kind, LinkDestinationKind.browser,
          reason: 'an unknown slug is the website’s to answer');
    });

    test('tags, users, groups, badges, chat and search', () {
      expect(to('/tag/flutter').tagName, 'flutter');
      expect(to('/tags').kind, LinkDestinationKind.tags);
      expect(to('/u/alice/activity').username, 'alice');
      expect(to('/u').kind, LinkDestinationKind.users);
      expect(to('/g/staff').groupName, 'staff');
      expect(to('/groups').kind, LinkDestinationKind.groups);
      expect(to('/badges/3/welcome').badgeId, 3);
      expect(to('/badges').kind, LinkDestinationKind.badges);
      final chat = to('/chat/c/general/2/345');
      expect(chat.kind, LinkDestinationKind.chatChannel);
      expect(chat.chatChannelId, 2);
      expect(chat.chatMessageId, 345);
      expect(to('/search?q=in%3Atitle%20hello').searchQuery, 'in:title hello');
    });

    test('the home, its lists, chat and the inbox are tabs of the home', () {
      expect(to('/').homeTab, SiteHomeTab.topics);
      expect(to('/latest').homeTab, SiteHomeTab.topics);
      expect(to('/top?period=weekly').homeTab, SiteHomeTab.topics);
      expect(to('/categories').homeTab, SiteHomeTab.categories);
      expect(to('/chat').homeTab, SiteHomeTab.inbox);
    });

    test('the reader’s own pages, when signed in', () {
      final me = site(username: 'bob');
      expect(to('/my/messages', at: me).homeTab, SiteHomeTab.inbox);
      expect(to('/my/notifications', at: me).homeTab, SiteHomeTab.notifications);
      expect(to('/my/activity/bookmarks', at: me).kind,
          LinkDestinationKind.bookmarks);
      final summary = to('/my/summary', at: me);
      expect(summary.kind, LinkDestinationKind.user);
      expect(summary.username, 'bob');
      expect(to('/my/preferences/account', at: me).kind,
          LinkDestinationKind.browser);
      expect(to('/my/messages').kind, LinkDestinationKind.browser,
          reason: 'a guest has no inbox; the website asks them to sign in');
    });
  });

  group('what stays out of the app', () {
    test('uploads, raw posts, invites and pages with no screen', () {
      for (final href in [
        '/uploads/default/original/1X/abc.pdf',
        '/raw/123/1',
        '/invites/xyz',
        '/about',
        '/tos',
        '/admin',
      ]) {
        final d = to(href);
        expect(d.kind, LinkDestinationKind.browser, reason: href);
        expect(d.url, startsWith('https://forum.example.com/'), reason: href);
      }
    });

    test('other sites, mail and in-page anchors', () {
      expect(to('https://github.com/x/y').kind, LinkDestinationKind.browser);
      expect(to('https://github.com/x/y').url, 'https://github.com/x/y');
      expect(to('https://medium.com/@author/post').kind,
          LinkDestinationKind.browser,
          reason: 'an @ in a URL is not a mention');
      expect(to('mailto:a@b.com').kind, LinkDestinationKind.email);
      expect(to('someone@example.com').kind, LinkDestinationKind.email);
      expect(to('#p-123-heading').kind, LinkDestinationKind.none,
          reason: 'the heading anchors used to open the forum in the browser');
    });
  });

  test('a subfolder forum reads its own links under its base path', () {
    final sub = site(url: 'https://example.com/forum');
    final d = to('https://example.com/forum/t/x/12/3', at: sub);
    expect(d.kind, LinkDestinationKind.topic);
    expect(d.route!.topicId, '12');
    expect(to('https://example.com/blog/post', at: sub).kind,
        LinkDestinationKind.browser);
  });
}
