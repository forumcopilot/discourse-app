import 'package:discourse_core/discourse_core.dart';
import 'package:test/test.dart';

/// Every link shape a reader can bring to the app — pasted, shared from a
/// browser, or copied from the app itself — and where it points.
void main() {
  DiscourseLink parse(String url) {
    final link = DiscourseLink.parse(url);
    expect(link, isNotNull, reason: url);
    return link!;
  }

  group('forum root', () {
    test('an origin is the forum, nothing inside it', () {
      final link = parse('https://meta.discourse.org');
      expect(link.forumUrl, 'https://meta.discourse.org');
      expect(link.forumUrlCandidates, ['https://meta.discourse.org']);
      expect(link.pointsIntoForum, isFalse);
    });

    test('a bare host, as typed, reads as https', () {
      expect(parse('meta.discourse.org').forumUrl, 'https://meta.discourse.org');
      expect(parse('  Meta.Discourse.org/  ').forumUrl,
          'https://meta.discourse.org');
    });

    test('a trailing slash, query and fragment change nothing', () {
      final link = parse('https://meta.discourse.org/?ref=x#top');
      expect(link.forumUrl, 'https://meta.discourse.org');
      expect(link.pointsIntoForum, isFalse);
    });

    test('a port is kept', () {
      expect(parse('http://127.0.0.1:4200/latest').forumUrl,
          'http://127.0.0.1:4200');
      expect(parse('http://localhost:3000').forumUrl, 'http://localhost:3000');
    });
  });

  group('topic links', () {
    test('/t/{slug}/{id}', () {
      final link = parse('https://meta.discourse.org/t/what-is-discourse/12345');
      expect(link.forumUrl, 'https://meta.discourse.org');
      expect(link.topicId, 12345);
      expect(link.slug, 'what-is-discourse');
      expect(link.postNumber, isNull);
      expect(link.postId, isNull);
      expect(link.pointsIntoForum, isTrue);
    });

    test('/t/{slug}/{id}/{post_number}', () {
      final link = parse('https://meta.discourse.org/t/what-is-discourse/12345/4');
      expect(link.topicId, 12345);
      expect(link.slug, 'what-is-discourse');
      expect(link.postNumber, 4);
    });

    test('/t/{id}', () {
      final link = parse('https://meta.discourse.org/t/12345');
      expect(link.topicId, 12345);
      expect(link.slug, isNull);
      expect(link.postNumber, isNull);
    });

    test('/t/{id}/{post_number}: two numbers are a topic and a post number', () {
      // Discourse never makes an all-digit slug, so this is not slug + id.
      final link = parse('https://meta.discourse.org/t/12345/4');
      expect(link.topicId, 12345);
      expect(link.slug, isNull);
      expect(link.postNumber, 4);
    });

    test('the share credit and other queries are ignored', () {
      final link = parse('https://meta.discourse.org/t/some-topic/12345/7?u=alice');
      expect(link.topicId, 12345);
      expect(link.postNumber, 7);
    });

    test('a trailing slash is ignored', () {
      final link = parse('https://meta.discourse.org/t/some-topic/12345/7/');
      expect(link.topicId, 12345);
      expect(link.postNumber, 7);
    });

    test('#post_N names the post when the path does not', () {
      expect(parse('https://forum.example.com/t/some-topic/99#post_12').postNumber,
          12);
      expect(parse('https://forum.example.com/t/99/3#post_12').postNumber, 3,
          reason: 'the path wins');
      expect(parse('https://forum.example.com/t/99#reply').postNumber, isNull);
    });

    test('post number 1 and 0', () {
      expect(parse('https://forum.example.com/t/x/99/1').postNumber, 1);
      expect(parse('https://forum.example.com/t/x/99/0').postNumber, isNull);
    });

    test('/t/{slug}/{id}/last and /print still name the topic', () {
      final last = parse('https://forum.example.com/t/x/99/last');
      expect(last.topicId, 99);
      expect(last.postNumber, isNull);
      expect(parse('https://forum.example.com/t/x/99/print').topicId, 99);
    });

    test('the nested-replies view /n/ is the same topic', () {
      final link = parse('https://forum.example.com/n/some-topic/99/5');
      expect(link.topicId, 99);
      expect(link.postNumber, 5);
    });

    test('an encoded slug is kept as sent', () {
      final link = parse(
          'https://forum.example.cn/t/%E4%B8%AD%E6%96%87/42/2');
      expect(link.topicId, 42);
      expect(link.postNumber, 2);
    });

    test('/t/{slug} alone opens the forum: only the server knows the id', () {
      final link = parse('https://forum.example.com/t/some-topic');
      expect(link.forumUrl, 'https://forum.example.com');
      expect(link.pointsIntoForum, isFalse);
    });
  });

  group('post short links', () {
    test('/p/{post_id}', () {
      final link = parse('https://meta.discourse.org/p/987654');
      expect(link.postId, 987654);
      expect(link.topicId, isNull);
      expect(link.pointsIntoForum, isTrue);
    });

    test('/p/{post_id}/{user_id}', () {
      expect(parse('https://meta.discourse.org/p/987654/12').postId, 987654);
    });

    test('/p/ without a number is just the forum', () {
      expect(parse('https://meta.discourse.org/p/abc').pointsIntoForum, isFalse);
    });
  });

  group('subfolder installs', () {
    test('the path before the route is the forum', () {
      final link = parse('https://example.com/forum/t/some-topic/12/3');
      expect(link.forumUrl, 'https://example.com/forum');
      expect(link.basePath, '/forum');
      expect(link.forumUrlCandidates, ['https://example.com/forum']);
      expect(link.topicId, 12);
      expect(link.postNumber, 3);
    });

    test('deeper subfolders', () {
      final link = parse('https://example.com/community/forum/p/55');
      expect(link.forumUrl, 'https://example.com/community/forum');
      expect(link.postId, 55);
    });

    test('a subfolder category link', () {
      final link = parse('https://example.com/forum/c/help/5');
      expect(link.forumUrl, 'https://example.com/forum');
      expect(link.pointsIntoForum, isFalse);
    });

    test('a bare path may be a subfolder home or a page on the site', () {
      final link = parse('https://example.com/forum/');
      expect(link.forumUrl, isNull);
      expect(link.forumUrlCandidates,
          ['https://example.com/forum', 'https://example.com']);
    });

    test('a file name is a page, not a folder', () {
      expect(parse('https://example.com/index.php?topic=1').forumUrlCandidates,
          ['https://example.com']);
    });
  });

  group('http, https and www', () {
    test('the scheme is kept, not upgraded', () {
      expect(parse('http://forum.example.com/t/x/1').forumUrl,
          'http://forum.example.com');
      expect(parse('HTTPS://forum.example.com/t/x/1').forumUrl,
          'https://forum.example.com');
    });

    test('www is kept: whether it is the forum is the server’s answer', () {
      expect(parse('https://www.chiefdelphi.com/t/x/1').forumUrl,
          'https://www.chiefdelphi.com');
    });
  });

  group('categories, users and other pages open the forum', () {
    for (final path in [
      '/c/support/7',
      '/c/support/sub/9',
      '/u/alice',
      '/u/alice/activity',
      '/tag/flutter',
      '/latest',
      '/top?period=weekly',
      '/g/staff',
      '/search?q=x',
      '/chat/c/general/2',
    ]) {
      test(path, () {
        final link = parse('https://forum.example.com$path');
        expect(link.forumUrl, 'https://forum.example.com');
        expect(link.pointsIntoForum, isFalse);
      });
    }
  });

  group('not links', () {
    for (final input in [
      '',
      '   ',
      'not a url',
      'hello world https://x.com',
      'mailto:a@b.com',
      'ftp://forum.example.com/t/x/1',
      'https://',
      'https:///t/x/1',
      'javascript:alert(1)',
      'nohost',
    ]) {
      test('"$input"', () => expect(DiscourseLink.parse(input), isNull));
    }
  });

  group('webUrl — what Copy link and Share hand out', () {
    test('a topic', () {
      expect(
          DiscourseLink.webUrl('https://forum.example.com',
              topicId: '123', slug: 'some-topic'),
          'https://forum.example.com/t/some-topic/123');
    });

    test('a post past the first', () {
      expect(
          DiscourseLink.webUrl('https://forum.example.com/',
              topicId: '123', slug: 'some-topic', postNumber: 4),
          'https://forum.example.com/t/some-topic/123/4');
    });

    test('the first post links as the topic, as on the web', () {
      expect(
          DiscourseLink.webUrl('https://forum.example.com',
              topicId: '123', slug: 'some-topic', postNumber: 1),
          'https://forum.example.com/t/some-topic/123');
    });

    test('an unknown slug is written "topic", as the web does', () {
      expect(
          DiscourseLink.webUrl('https://forum.example.com',
              topicId: '123', slug: '  ', postNumber: 2),
          'https://forum.example.com/t/topic/123/2');
      expect(DiscourseLink.webUrl('https://forum.example.com', topicId: '9'),
          'https://forum.example.com/t/topic/9');
    });

    test('a subfolder forum keeps its path', () {
      expect(
          DiscourseLink.webUrl('https://example.com/forum',
              topicId: '12', slug: 'x', postNumber: 3),
          'https://example.com/forum/t/x/12/3');
    });

    test('round-trips through parse', () {
      final url = DiscourseLink.webUrl('https://example.com/forum',
          topicId: '12', slug: 'some-topic', postNumber: 3);
      final link = DiscourseLink.parse(url)!;
      expect(link.forumUrl, 'https://example.com/forum');
      expect(link.topicId, 12);
      expect(link.slug, 'some-topic');
      expect(link.postNumber, 3);
    });
  });
  group('inForum — a link in the forum’s own content', () {
    const forum = 'https://forum.example.com';
    DiscourseLink? inForum(String href, [String at = forum]) =>
        DiscourseLink.inForum(at, href);

    test('relative and absolute hrefs to this forum', () {
      expect(inForum('/t/x/12/3')!.kind, DiscourseLinkKind.topic);
      expect(inForum('/t/x/12/3')!.url, 'https://forum.example.com/t/x/12/3');
      expect(inForum('https://forum.example.com/t/x/12')!.topicId, 12);
      expect(inForum('//forum.example.com/t/x/12')!.topicId, 12);
      expect(inForum('t/x/12')!.topicId, 12, reason: 'relative to the base');
    });

    test('www and http are the same forum', () {
      expect(inForum('https://www.forum.example.com/t/x/12')?.topicId, 12);
      expect(inForum('http://forum.example.com/t/x/12')?.topicId, 12);
      expect(inForum('https://forum.example.com/u/a', 'https://www.forum.example.com')
          ?.username, 'a');
    });

    test('anything else is not this forum', () {
      expect(inForum('https://other.example.com/t/x/12'), isNull);
      expect(inForum('https://example.com/t/x/12'), isNull);
      expect(inForum('mailto:someone@forum.example.com'), isNull);
      expect(inForum('tel:+123'), isNull);
      expect(inForum(''), isNull);
    });

    test('a subfolder forum: its own links carry the base path', () {
      const sub = 'https://example.com/forum';
      final link = inForum('/forum/t/x/12/3', sub)!;
      expect(link.topicId, 12);
      expect(link.postNumber, 3);
      expect(link.url, 'https://example.com/forum/t/x/12/3',
          reason: 'not /forum/forum/…');
      expect(inForum('https://example.com/forum/c/help/4', sub)!.categoryId, 4);
      expect(inForum('/t/x/12', sub)!.url, 'https://example.com/forum/t/x/12',
          reason: 'a rooted path without the base is taken under it');
      expect(inForum('https://example.com/blog/post', sub), isNull,
          reason: 'the rest of the host is not the forum');
      expect(inForum('https://example.com/forum', sub)!.kind,
          DiscourseLinkKind.forum);
    });
  });

  group('kinds', () {
    DiscourseLink k(String path) =>
        DiscourseLink.inForum('https://f.example', path)!;

    test('topics and posts', () {
      expect(k('/t/x/1').kind, DiscourseLinkKind.topic);
      expect(k('/t/x/1/9').postNumber, 9);
      expect(k('/p/77').kind, DiscourseLinkKind.post);
      expect(k('/p/77').postId, 77);
      expect(k('/t/only-a-slug').kind, DiscourseLinkKind.page);
    });

    test('categories, with and without an id', () {
      final c = k('/c/hardware/arduino/12');
      expect(c.kind, DiscourseLinkKind.category);
      expect(c.categoryId, 12);
      expect(c.categorySlugs, ['hardware', 'arduino']);
      expect(k('/c/hardware/12/l/top').categoryId, 12);
      expect(k('/c/hardware/12/none').categoryId, 12);
      final bySlug = k('/c/hardware');
      expect(bySlug.categoryId, isNull);
      expect(bySlug.categorySlugs, ['hardware']);
      expect(k('/c').kind, DiscourseLinkKind.list);
      expect(k('/c').listName, 'categories');
    });

    test('tags', () {
      expect(k('/tag/flutter').tagName, 'flutter');
      expect(k('/tag/c%2B%2B').tagName, 'c++');
      expect(k('/tag/flutter/l/top').tagName, 'flutter');
      expect(k('/tags/c/dev/5/flutter').tagName, 'flutter');
      expect(k('/tags/intersection/a/b').tagName, 'a');
      expect(k('/tags').kind, DiscourseLinkKind.tags);
      expect(k('/tag').kind, DiscourseLinkKind.tags);
    });

    test('users, groups and badges', () {
      final u = k('/u/alice/activity/likes-given');
      expect(u.kind, DiscourseLinkKind.user);
      expect(u.username, 'alice');
      expect(u.userTab, 'activity/likes-given');
      expect(k('/users/bob').username, 'bob');
      expect(k('/u').kind, DiscourseLinkKind.users);
      expect(k('/g/staff').groupName, 'staff');
      expect(k('/groups').kind, DiscourseLinkKind.groups);
      expect(k('/badges/3/welcome').badgeId, 3);
      expect(k('/badges').kind, DiscourseLinkKind.badges);
    });

    test('chat', () {
      final m = k('/chat/c/general/2/345');
      expect(m.kind, DiscourseLinkKind.chat);
      expect(m.chatChannelId, 2);
      expect(m.chatMessageId, 345);
      expect(k('/chat/c/-/2').chatChannelId, 2);
      expect(k('/chat/c/general/2/t/9').chatMessageId, isNull,
          reason: 'a thread opens its channel');
      expect(k('/chat').chatChannelId, isNull);
    });

    test('search, lists and my pages', () {
      expect(k('/search?q=hello%20world%20in%3Atitle').searchQuery,
          'hello world in:title');
      expect(k('/search').searchQuery, isNull);
      expect(k('/latest').listName, 'latest');
      expect(k('/top?period=weekly').listName, 'top');
      expect(k('/categories').listName, 'categories');
      expect(k('/my/messages').myPath, 'messages');
      expect(k('/my/activity/bookmarks').myPath, 'activity/bookmarks');
    });

    test('what the server answers stays with the browser', () {
      for (final path in [
        '/uploads/default/original/1X/abc.pdf',
        '/secure-uploads/x.png',
        '/raw/12/3',
        '/posts/5/raw',
        '/invites/abc',
        '/t/x/12.json',
        '/latest.rss',
        '/session/sso',
        '/auth/google',
      ]) {
        expect(k(path).kind, DiscourseLinkKind.serverSide, reason: path);
      }
    });

    test('pages with no screen of their own', () {
      for (final path in ['/about', '/faq', '/guidelines', '/tos', '/privacy',
          '/review', '/admin/users', '/something-custom']) {
        expect(k(path).kind, DiscourseLinkKind.page, reason: path);
      }
      expect(k('/').kind, DiscourseLinkKind.forum);
    });
  });
}
