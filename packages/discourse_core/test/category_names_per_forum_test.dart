import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Category ids are the forum's own. A host with several forums open in one
/// process (ABDA) must name each forum's rows from that forum's categories,
/// never from whichever forum warmed the cache first.
void main() {
  const forumA = 'https://a.example';
  const forumB = 'https://b.example';

  Map<String, dynamic> topicList(int topicId) => {
        'users': [
          {'id': 1, 'username': 'alice', 'avatar_template': '/a/{size}.png'},
        ],
        'topic_list': {
          'topics': [
            {
              'id': topicId,
              'title': 'Topic $topicId',
              'slug': 'topic-$topicId',
              'posts_count': 1,
              'category_id': 4,
              'posters': [
                {'user_id': 1, 'extras': null},
              ],
            },
          ],
        },
      };

  setUp(() {
    DiscourseTopicProxy.clearCategoryNames();
    DiscourseSiteCapabilities.reset();
    DiscourseMoreTopics.clear();
  });

  test('topic rows: the same category id is named by its own forum',
      () async {
    final a = _Topics(forumA, 'Support', {'/latest.json': topicList(10)});
    final b = _Topics(forumB, 'Off-topic', {'/latest.json': topicList(20)});
    final fromA = await a.getLatestTopicAsync(0, 29);
    final fromB = await b.getLatestTopicAsync(0, 29);
    expect(fromA.topics.single.forumName, 'Support');
    expect(fromB.topics.single.forumName, 'Off-topic',
        reason: "forum B's row was named from forum A's table");
    expect(b.gets, contains('/categories.json'));
  });

  test("a load in flight for one forum is not another forum's answer",
      () async {
    final gate = Completer<void>();
    final a = _Topics(forumA, 'Support', {'/latest.json': topicList(10)},
        categoriesGate: gate.future);
    final b = _Topics(forumB, 'Off-topic', {'/latest.json': topicList(20)},
        categoriesGate: gate.future);
    final both = Future.wait([
      a.getLatestTopicAsync(0, 29),
      b.getLatestTopicAsync(0, 29),
    ]);
    gate.complete();
    final results = await both;
    expect(results[0].topics.single.forumName, 'Support');
    expect(results[1].topics.single.forumName, 'Off-topic');
  });

  test("a category page's name is its own forum's", () async {
    final a = _Topics(forumA, 'Support', {'/c/4/l/latest.json': topicList(10)});
    final b =
        _Topics(forumB, 'Off-topic', {'/c/4/l/latest.json': topicList(20)});
    expect((await a.getTopicAsync('4', 0, 29)).forumName, 'Support');
    expect((await b.getTopicAsync('4', 0, 29)).forumName, 'Off-topic');
  });

  test('suggested topics are named by their own forum', () async {
    final view = {
      'suggested_topics': [
        {
          'id': 31,
          'title': 'Suggested',
          'category_id': 4,
          'posters': [
            {
              'extras': null,
              'user': {'id': 1, 'username': 'alice'},
            },
          ],
        },
      ],
    };
    DiscourseMoreTopics.storeFrom(forumA, '26', view);
    DiscourseMoreTopics.storeFrom(forumB, '26', view);
    final a = _Topics(forumA, 'Support', {});
    final b = _Topics(forumB, 'Off-topic', {});
    await a.getLatestTopicAsync(0, 29); // warms forum A first
    expect((await b.getMoreTopicsAsync('26')).suggested.single.forumName,
        'Off-topic');
    expect((await a.getMoreTopicsAsync('26')).suggested.single.forumName,
        'Support');
  });

  test("names from one forum's /site.json do not name another's rows",
      () async {
    DiscourseSiteCapabilities.store(forumA, {
      'top_menu_items': ['latest'],
      'categories': [
        {'id': 4, 'name': 'Support'},
      ],
    });
    final a = _Topics(forumA, 'unused', {'/latest.json': topicList(10)});
    final b = _Topics(forumB, 'Off-topic', {'/latest.json': topicList(20)});
    expect((await a.getLatestTopicAsync(0, 29)).topics.single.forumName,
        'Support');
    expect(a.gets, isNot(contains('/categories.json')),
        reason: 'forum A is named from its /site.json');
    expect((await b.getLatestTopicAsync(0, 29)).topics.single.forumName,
        'Off-topic');
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

/// A forum whose only category is id 4, named [categoryName].
class _Topics extends DiscourseTopicProxy {
  _Topics(String url, this.categoryName, this.byPath, {this.categoriesGate})
      : super(_ctx(url));
  final String categoryName;
  final Map<String, Map<String, dynamic>> byPath;
  final Future<void>? categoriesGate;
  final gets = <String>[];

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    gets.add(path);
    if (path == '/categories.json') {
      await categoriesGate;
      return {
        'category_list': {
          'categories': [
            {'id': 4, 'name': categoryName},
          ],
        },
      };
    }
    return byPath[path] ?? const {};
  }
}
