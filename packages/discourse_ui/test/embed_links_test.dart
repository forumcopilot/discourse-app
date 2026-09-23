import 'package:discourse_ui/utils/embed_links.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which site an embed in a post belongs to, and which page its preview
/// opens: the video or post itself, never the bare player.
void main() {
  group('iframes', () {
    EmbedLink link(String src, {String? title}) => EmbedLink.fromIframe(src, title: title)!;

    test('YouTube: watch page, start time and playlist kept, still from YouTube', () {
      final l = link('https://www.youtube.com/embed/aqz-KE-bpKQ?start=42&list=PL123',
          title: 'YouTube video player');
      expect(l.provider, same(EmbedLink.youtube));
      expect(l.url, 'https://www.youtube.com/watch?v=aqz-KE-bpKQ&t=42&list=PL123');
      expect(l.youtubeId, 'aqz-KE-bpKQ');
      expect(l.thumbnailUrl, 'https://i.ytimg.com/vi/aqz-KE-bpKQ/hqdefault.jpg');
      expect(l.title, isNull, reason: '"YouTube video player" names nothing');
      expect(link('//www.youtube-nocookie.com/embed/aqz-KE-bpKQ').youtubeId, 'aqz-KE-bpKQ');
      expect(link('https://www.youtube.com/embed/videoseries?list=PL9').url,
          'https://www.youtube.com/playlist?list=PL9');
    });

    test('Vimeo keeps the private-link hash', () {
      expect(link('https://player.vimeo.com/video/76979871?h=8272103f6e&app_id=1').url,
          'https://vimeo.com/76979871/8272103f6e');
      expect(link('https://player.vimeo.com/video/76979871').url, 'https://vimeo.com/76979871');
    });

    test('Dailymotion gets its public still', () {
      final l = link('https://www.dailymotion.com/embed/video/x8abc12');
      expect(l.provider, same(EmbedLink.dailymotion));
      expect(l.url, 'https://www.dailymotion.com/video/x8abc12');
      expect(l.thumbnailUrl, 'https://www.dailymotion.com/thumbnail/video/x8abc12');
      expect(link('https://geo.dailymotion.com/player/xabc.html?video=x8abc12').url,
          'https://www.dailymotion.com/video/x8abc12');
    });

    test('Twitch, Loom, Bilibili and Facebook videos open their pages', () {
      expect(link('https://player.twitch.tv/?video=v123456&parent=forum.example.com').url,
          'https://www.twitch.tv/videos/123456');
      expect(link('https://player.twitch.tv/?channel=somechannel&parent=x').url,
          'https://www.twitch.tv/somechannel');
      expect(link('https://clips.twitch.tv/embed?clip=FunnyClip&parent=x').url,
          'https://clips.twitch.tv/FunnyClip');
      expect(link('https://www.loom.com/embed/0123abcd').url, 'https://www.loom.com/share/0123abcd');
      expect(link('https://player.bilibili.com/player.html?bvid=BV1xx411c7mD').url,
          'https://www.bilibili.com/video/BV1xx411c7mD');
      final fb = link(
          'https://www.facebook.com/plugins/video.php?href=https%3A%2F%2Fwww.facebook.com%2Fpage%2Fvideos%2F1%2F');
      expect(fb.provider, same(EmbedLink.facebookVideo));
      expect(fb.provider.kind, EmbedKind.video);
      expect(fb.url, 'https://www.facebook.com/page/videos/1/');
    });

    test('social posts open the post, not the embed', () {
      expect(link('https://embed.reddit.com/r/flutterdev/comments/abc/t/?embed=true').url,
          'https://www.reddit.com/r/flutterdev/comments/abc/t/');
      expect(link('https://www.instagram.com/p/CODE123/embed/captioned/').url,
          'https://www.instagram.com/p/CODE123/');
      expect(link('https://platform.twitter.com/embed/Tweet.html?id=42').url,
          'https://x.com/i/status/42');
      expect(link('https://www.instagram.com/p/CODE123/embed').provider.kind, EmbedKind.post);
    });

    test('audio: Spotify page and title, SoundCloud and Bandcamp fallback link', () {
      final s = link('https://open.spotify.com/embed/track/4uLU6hMCjMI75M1A2tKUQC?utm_source=generator',
          title: 'Spotify Embed: Never Gonna Give You Up');
      expect(s.provider, same(EmbedLink.spotify));
      expect(s.url, 'https://open.spotify.com/track/4uLU6hMCjMI75M1A2tKUQC');
      expect(s.title, 'Never Gonna Give You Up');
      expect(link('https://open.spotify.com/embed-podcast/episode/abc').url,
          'https://open.spotify.com/episode/abc');

      final b = EmbedLink.fromIframe(
        'https://bandcamp.com/EmbeddedPlayer/album=1/size=large/',
        innerHref: 'https://artist.bandcamp.com/album/record',
        innerText: 'Record by Artist',
      )!;
      expect(b.provider, same(EmbedLink.bandcamp));
      expect(b.url, 'https://artist.bandcamp.com/album/record');
      expect(b.title, 'Record by Artist');
      expect(link('https://w.soundcloud.com/player/?url=https%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F1')
          .provider.kind, EmbedKind.audio);
    });

    test('maps drop the embed-only parameter; Steam opens the store page', () {
      final m = link('https://maps.google.com/maps?q=London&output=embed');
      expect(m.provider, same(EmbedLink.googleMaps));
      expect(m.url, 'https://maps.google.com/maps?q=London');
      final steam = link('https://store.steampowered.com/widget/620/');
      expect(steam.provider.name, 'Steam');
      expect(steam.url, 'https://store.steampowered.com/app/620/');
    });

    test('anything else names its host', () {
      final l = link('https://www.example-widgets.net/widget/7');
      expect(l.provider.name, 'example-widgets.net');
      expect(l.provider.kind, EmbedKind.page);
      expect(l.url, 'https://www.example-widgets.net/widget/7');
    });

    test('not an http(s) player: nothing', () {
      expect(EmbedLink.fromIframe('javascript:alert(1)'), isNull);
      expect(EmbedLink.fromIframe('about:blank'), isNull);
    });
  });

  group('lazy videos', () {
    test('YouTube with start time, from the data attributes', () {
      final l = EmbedLink.fromLazyVideo({
        'data-provider-name': 'youtube',
        'data-video-id': 'aqz-KE-bpKQ',
        'data-video-title': 'Big Buck Bunny',
        'data-video-start-time': '42',
      })!;
      expect(l.url, 'https://www.youtube.com/watch?v=aqz-KE-bpKQ&t=42');
      expect(l.title, 'Big Buck Bunny');
      expect(l.thumbnailUrl, 'https://i.ytimg.com/vi/aqz-KE-bpKQ/hqdefault.jpg');
    });

    test('the forum\'s link and stored thumbnail win', () {
      final l = EmbedLink.fromLazyVideo(
        {'data-provider-name': 'vimeo', 'data-video-id': '1?h=2&app_id=3'},
        href: 'https://vimeo.com/1/2',
        thumbnailUrl: 'https://forum.example.com/uploads/t.jpeg',
      )!;
      expect(l.url, 'https://vimeo.com/1/2');
      expect(l.thumbnailUrl, 'https://forum.example.com/uploads/t.jpeg');
      expect(EmbedLink.fromLazyVideo({'data-provider-name': 'tiktok', 'data-video-id': '7'})!
          .portrait, isTrue);
    });
  });

  group('video links the forum did not embed', () {
    test('YouTube watch, share, Shorts and live URLs', () {
      for (final url in [
        'https://www.youtube.com/watch?v=aqz-KE-bpKQ',
        'https://youtu.be/aqz-KE-bpKQ?si=x',
        'https://m.youtube.com/watch?feature=share&v=aqz-KE-bpKQ',
        'https://www.youtube.com/shorts/aqz-KE-bpKQ',
        'https://www.youtube.com/live/aqz-KE-bpKQ',
      ]) {
        expect(EmbedLink.fromUrl(url)?.youtubeId, 'aqz-KE-bpKQ', reason: url);
      }
      expect(EmbedLink.fromUrl('https://www.youtube.com/shorts/aqz-KE-bpKQ')!.portrait, isTrue);
    });

    test('other video sites; ordinary pages stay links', () {
      expect(EmbedLink.fromUrl('https://vimeo.com/76979871')?.provider, same(EmbedLink.vimeo));
      expect(EmbedLink.fromUrl('https://www.tiktok.com/@a/video/7')?.provider, same(EmbedLink.tiktok));
      expect(EmbedLink.fromUrl('https://dai.ly/x8abc12')?.url,
          'https://www.dailymotion.com/video/x8abc12');
      expect(EmbedLink.fromUrl('https://www.twitch.tv/videos/1')?.provider, same(EmbedLink.twitch));
      expect(EmbedLink.fromUrl('https://vimeo.com/channels/staffpicks'), isNull);
      expect(EmbedLink.fromUrl('https://www.youtube.com/@somechannel'), isNull);
      expect(EmbedLink.fromUrl('https://example.com/watch?v=aqz-KE-bpKQ'), isNull);
    });
  });
}
