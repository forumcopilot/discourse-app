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

  group('CookedContent.parse — video', () {
    test('reads a lazy YouTube container and strips it from the HTML', () {
      const cooked = '''
<div class="youtube-onebox lazy-video-container"
  data-video-id="kPRA0W1kECg"
  data-video-title="15 Sorting Algorithms in 6 Minutes"
  data-provider-name="youtube">
  <a href="https://www.youtube.com/watch?v=kPRA0W1kECg" target="_blank" class="video-thumbnail">
    <img class="youtube-thumbnail" src="https://img.youtube.com/vi/kPRA0W1kECg/maxresdefault.jpg">
  </a>
</div>''';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      expect(content.youtubeUrls,
          ['https://www.youtube.com/watch?v=kPRA0W1kECg']);
      // Removed so the VideoCard below the post isn't shadowed by a bare
      // thumbnail image with no play affordance.
      expect(content.html, isNot(contains('lazy-video-container')));
      // The thumbnail is chrome, not a gallery image.
      expect(content.imageUrls, isEmpty);
      // And it must not also show up as a generic link preview.
      expect(content.linkUrls, isEmpty);
    });

    test('recovers the video from a non-lazy embed iframe', () {
      // flutter_html cannot render an <iframe>, so without this the post
      // would show an empty gap where the video should be.
      const cooked = '<div class="video-container">'
          '<iframe src="https://www.youtube.com/embed/kPRA0W1kECg" '
          'frameborder="0" allowfullscreen></iframe></div>';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      expect(content.youtubeUrls,
          ['https://www.youtube.com/watch?v=kPRA0W1kECg']);
      expect(content.html, isNot(contains('video-container')));
    });

    test('routes a Twitter onebox to the tweet card', () {
      const cooked = '''
<aside class="onebox twitterstatus" data-onebox-src="https://twitter.com/discourse/status/1234567890">
  <header class="source"><a href="https://twitter.com/discourse/status/1234567890">twitter.com</a></header>
  <article class="onebox-body"><p>a tweet</p></article>
</aside>''';

      final content = CookedContent.parse(cooked, forumBaseUrl: _forum);

      expect(content.twitterUrls,
          ['https://twitter.com/discourse/status/1234567890']);
      expect(content.linkUrls, isEmpty);
      expect(content.html, isNot(contains('onebox-body')));
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
}
