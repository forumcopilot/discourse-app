import 'package:discourse_ui/utils/cooked_content.dart';
import 'package:flutter_test/flutter_test.dart';

/// The HTML fixtures below are the shapes Discourse actually cooks, taken
/// from the Discourse source:
///   * onebox layout — `app/assets/.../styleguide` sample posts, which use
///     the `aside.onebox[data-onebox-src]` structure `PrettyText` keys on.
///   * lazy videos — `plugins/discourse-lazy-videos/lib/.../lazy_youtube.rb`
///   * lightbox — `lib/cooked_post_processor.rb`
const String _forum = 'https://forum.example.com';

void main() {
  group('CookedContent.parse — links', () {
    test('does not mistake image and favicon srcs for links in the post', () {
      // This is the regression the BBCode pipeline caused: its
      // `findPlainUrls` swept the raw HTML with a bare URL regex, so the
      // favicon, the thumbnail and the anchor all came back as three
      // separate "links" and each got its own preview card.
      const cooked = '''
<p>Check this out:</p>
<aside class="onebox allowlistedgeneric" data-onebox-src="https://en.wikipedia.org/wiki/Discourse_(software)">
  <header class="source">
    <img src="https://en.wikipedia.org/static/favicon/wikipedia.ico" class="site-icon" width="16" height="16" />
    <a href="https://en.wikipedia.org/wiki/Discourse_(software)" target="_blank" rel="noopener">en.wikipedia.org</a>
  </header>
  <article class="onebox-body">
    <img src="https://upload.wikimedia.org/thumb.jpg" class="thumbnail" width="200" height="200" />
    <h3><a href="https://en.wikipedia.org/wiki/Discourse_(software)" target="_blank" rel="noopener">Discourse (software)</a></h3>
    <p>An open source Internet forum.</p>
  </article>
</aside>''';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      // The server already rendered the preview, so we add no card of our
      // own — and certainly not one per image.
      expect(content.linkUrls, isEmpty);
      expect(content.imageUrls, isEmpty);
      // ...and the onebox survives into the rendered HTML.
      expect(content.html, contains('onebox-body'));
    });

    test('collects plain external anchors', () {
      const cooked =
          '<p>See <a href="https://example.com/article">this</a> and '
          '<a href="https://other.test/page">that</a>.</p>';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      expect(content.linkUrls,
          containsAll(['https://example.com/article', 'https://other.test/page']));
    });

    test('skips mentions, hashtags, attachments, anchors and same-forum links',
        () {
      const cooked = '''
<p>
  <a class="mention" href="/u/codinghorror">@codinghorror</a>
  <a class="hashtag-cooked" href="/c/support/6">#support</a>
  <a class="attachment" href="/uploads/short-url/abc.pdf">spec.pdf</a>
  <a href="#heading-1">jump</a>
  <a href="mailto:someone@example.com">mail me</a>
  <a href="https://forum.example.com/t/some-topic/42">our own topic</a>
  <a href="https://example.com/keep">keep this one</a>
</p>''';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      expect(content.linkUrls, ['https://example.com/keep']);
    });

    test('ignores anchors inside quotes', () {
      const cooked = '''
<aside class="quote" data-post="3" data-topic="42">
  <blockquote><p><a href="https://example.com/quoted">quoted link</a></p></blockquote>
</aside>
<p><a href="https://example.com/mine">my link</a></p>''';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      expect(content.linkUrls, ['https://example.com/mine']);
    });
  });

  group('CookedContent.parse — embeds stay in place', () {
    test('keeps a lazy YouTube container where the author put it', () {
      const cooked = '''
<p>Before</p>
<div class="youtube-onebox lazy-video-container"
  data-video-id="kPRA0W1kECg"
  data-video-title="15 Sorting Algorithms in 6 Minutes"
  data-provider-name="youtube">
  <a href="https://www.youtube.com/watch?v=kPRA0W1kECg" target="_blank" class="video-thumbnail">
    <img class="youtube-thumbnail" src="https://img.youtube.com/vi/kPRA0W1kECg/maxresdefault.jpg">
  </a>
</div>
<p>After</p>''';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      // RichTextContent draws it in place, between the two paragraphs.
      final html = content.html;
      expect(html, contains('lazy-video-container'));
      expect(html.indexOf('Before'), lessThan(html.indexOf('lazy-video-container')));
      expect(html.indexOf('lazy-video-container'), lessThan(html.indexOf('After')));
      // The thumbnail is chrome, not a gallery image, nor a link preview.
      expect(content.imageUrls, isEmpty);
      expect(content.linkUrls, isEmpty);
    });

    test('keeps iframes and tweet oneboxes', () {
      const cooked = '<div class="video-container">'
          '<iframe src="https://www.youtube.com/embed/kPRA0W1kECg" '
          'frameborder="0" allowfullscreen></iframe></div>'
          '<aside class="onebox twitterstatus" data-onebox-src="https://twitter.com/discourse/status/1234567890">'
          '<article class="onebox-body"><div class="tweet">a tweet</div></article></aside>';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      expect(content.html, contains('<iframe'));
      expect(content.html, contains('a tweet'));
      expect(content.linkUrls, isEmpty);
    });

    test('drops what an inline style hides, as a browser would', () {
      // Older YouTube oneboxes: a hidden thumbnail beside the player.
      const cooked = '<p><img class="youtube-thumbnail onebox" style="display: none;" '
          'src="https://img.youtube.com/vi/kPRA0W1kECg/maxresdefault.jpg">'
          '<iframe src="https://www.youtube.com/embed/kPRA0W1kECg"></iframe>'
          '<span style="color: red">kept</span></p>';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      expect(content.html, isNot(contains('maxresdefault')));
      expect(content.html, contains('<iframe'));
      expect(content.html, contains('kept'));
    });
  });

  group('CookedContent.parse — images', () {
    test('prefers the lightbox original over the resized img src', () {
      const cooked = '''
<div class="lightbox-wrapper">
  <a class="lightbox" href="/uploads/default/original/1X/abc123.jpeg" title="photo">
    <img src="/uploads/default/optimized/1X/abc123_2_690x460.jpeg" width="690" height="460">
  </a>
</div>''';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      expect(content.imageUrls,
          ['$_forum/uploads/default/original/1X/abc123.jpeg']);
    });

    test('collects a plain inline upload and resolves it against the forum',
        () {
      const cooked = '<p><img src="/uploads/default/original/1X/pic.png" '
          'alt="pic" width="400" height="300"></p>';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      expect(content.imageUrls, ['$_forum/uploads/default/original/1X/pic.png']);
    });

    test('never treats emoji or avatars as gallery images', () {
      const cooked = '<p>hi <img src="/images/emoji/twitter/wave.png?v=12" '
          'title=":wave:" class="emoji" alt=":wave:"> '
          '<img src="/user_avatar/forum/sam/45/1_2.png" class="avatar"></p>';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      expect(content.imageUrls, isEmpty);
    });
  });

  test('empty content is handled without throwing', () {
    final content = CookedContent.parse('', forumBaseUrl: _forum);
    expect(content.html, isEmpty);
    expect(content.linkUrls, isEmpty);
    expect(content.imageUrls, isEmpty);
  });

  group('CookedContent.parse — what web hides, and author colours', () {
    test('drops the lightbox caption and .hidden content', () {
      const cooked = '''
<div class="lightbox-wrapper"><a class="lightbox" href="/uploads/o.png"><img src="/uploads/r.png" width="690" height="388">
<div class="meta"><span class="filename">image</span><span class="informations">1672×941 318 KB</span></div></a></div>
<p>Excerpt<span class="excerpt hidden">full issue body</span></p>''';

      final html = CookedContent.parse(cooked, forumBaseUrl: _forum).html;

      expect(html, isNot(contains('1672×941')));
      expect(html, isNot(contains('full issue body')));
      expect(html, contains('Excerpt'));
    });

    test('normalises author colours and drops the ones a browser ignores', () {
      const cooked = '<p><font color="#PG985740">a</font> <font color="LimeGreen">b</font> '
          '<font color="#F0A">c</font> <font color="nonsense">d</font></p>';

      final html = CookedContent.parse(cooked, forumBaseUrl: _forum).html;

      expect(html, isNot(contains('PG985740')));
      expect(html, contains('color="#32cd32"'));
      expect(html, contains('color="#ff00aa"'));
      expect(html, isNot(contains('nonsense')));
    });
  });
}

