import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Links in and out of the forum: what a link resolves to, and the address
/// the app hands out for a topic.
void main() {
  late _Recorder rec;
  setUp(() {
    rec = _Recorder();
    DiscourseTopicSlugs.clear();
  });

  group('getIdByUrl', () {
    test('a post short link asks the post for its topic', () async {
      rec.answers['/posts/555.json'] = {'id': 555, 'topic_id': 77, 'post_number': 3};
      final r = await _Forum(rec).getIdByUrl('https://forum.example/p/555');
      expect(r.result, isTrue);
      expect(r.topicId, '77');
      expect(r.postId, '555');
    });

    test('a slugless /t/{id}/{post_number} is topic then post number', () async {
      rec.answers['/t/77/4.json'] = {
        'post_stream': {
          'posts': [
            {'id': 900, 'post_number': 3},
            {'id': 901, 'post_number': 4},
          ],
        },
      };
      final r = await _Forum(rec).getIdByUrl('https://forum.example/t/77/4');
      expect(r.topicId, '77',
          reason: 'the second number is a post number, not the topic');
      expect(r.postId, '901');
    });

    test('a subfolder topic link', () async {
      final r = await _Forum(rec)
          .getIdByUrl('https://example.com/forum/t/some-topic/12');
      expect(r.result, isTrue);
      expect(r.topicId, '12');
      expect(r.postId, isNull);
      expect(rec.gets, isEmpty, reason: 'no post number, nothing to look up');
    });

    test('a category link', () async {
      final r =
          await _Forum(rec).getIdByUrl('https://forum.example/c/support/7');
      expect(r.forumId, '7');
    });
  });

  group('the topic address the app hands out', () {
    test('the topic view gives the slugged address and records the slug',
        () async {
      rec.answers['/t/77.json'] = _topic(77, 'how-to-share-links');
      final t = await _Post(rec).getThreadAsync('77', 1, 20, false);
      expect(t.result, isTrue, reason: t.resultText);
      expect(t.url, 'https://forum.example/t/how-to-share-links/77');
      expect(DiscourseTopicSlugs.of('https://forum.example', '77'),
          'how-to-share-links');
      expect(DiscourseTopicSlugs.of('https://forum.example/', '77'),
          'how-to-share-links',
          reason: 'a trailing slash on the forum URL is the same forum');
      expect(DiscourseTopicSlugs.of('https://other.example', '77'), isNull,
          reason: 'topic 77 on another forum is another topic');
    });

    test('entering at a post gives the same address', () async {
      rec.answers['/posts/901.json'] = {'id': 901, 'topic_id': 77, 'post_number': 4};
      rec.answers['/t/77/4.json'] = _topic(77, 'how-to-share-links');
      final t = await _Post(rec).getThreadByPostAsync('901', 20, false);
      expect(t.result, isTrue, reason: t.resultText);
      expect(t.url, 'https://forum.example/t/how-to-share-links/77');
    });

    test('a topic list records slugs', () async {
      rec.answers['/latest.json'] = {
        'users': [],
        'topic_list': {
          'topics': [
            {'id': 5, 'slug': 'first', 'title': 'First', 'posts_count': 1},
          ],
        },
      };
      final list = await _Topic(rec).getLatestTopicAsync(0, 19);
      expect(list.topics.single.url, 'https://forum.example/t/first/5');
      expect(DiscourseTopicSlugs.of('https://forum.example', '5'), 'first');
    });
  });
}

Map<String, dynamic> _topic(int id, String slug) => {
      'id': id,
      'slug': slug,
      'title': 'Title',
      'posts_count': 4,
      'highest_post_number': 4,
      'post_stream': {
        'posts': [
          {'id': 900, 'post_number': 1, 'username': 'a', 'cooked': '<p>x</p>'},
        ],
      },
      'details': <String, dynamic>{},
    };

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

/// Records requests and plays back canned answers by path.
class _Recorder {
  final Map<String, Map<String, dynamic>> answers = {};
  final List<String> gets = [];

  Future<Map<String, dynamic>> get(String path) async {
    if (path == '/site.json' || path == '/categories.json') {
      return const {'categories': []};
    }
    gets.add(path);
    final answer = answers[path];
    if (answer == null) throw StateError('unexpected GET $path');
    return answer;
  }
}

class _Forum extends DiscourseForumProxy {
  _Forum(this.rec) : super(_site());
  final _Recorder rec;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) =>
      rec.get(path);
}

class _Post extends DiscoursePostProxy {
  _Post(this.rec) : super(_site());
  final _Recorder rec;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) =>
      rec.get(path);
}

class _Topic extends DiscourseTopicProxy {
  _Topic(this.rec) : super(_site());
  final _Recorder rec;
  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) =>
      rec.get(path);
}
