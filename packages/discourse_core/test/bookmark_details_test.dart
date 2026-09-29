import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// The bookmark list's search, the category and tags each row carries, and
/// pinning — web's bookmark list features the app now uses.
void main() {
  setUp(DiscourseBookmarkDetails.clear);

  test('search sends q; rows record their category and tags', () async {
    final proxy = _Bookmarks();
    final result = await proxy.getBookmarksWithRemindersAsync(query: ' release ');
    expect(proxy.lastQuery?['q'], 'release');
    expect(result.entries.single.name, 'Check before release');
    final details =
        DiscourseBookmarkDetails.forBookmark('https://forum.example', 9)!;
    expect(details.categoryId, 4);
    expect(details.tags, ['roadmap', 'mobile'],
        reason: 'tags arrive as names or as objects');
  });

  test('pinning toggles through toggle_pin', () async {
    final proxy = _Bookmarks();
    final result = await proxy.toggleBookmarkPinAsync(9);
    expect(result.result, isTrue);
    expect(proxy.puts, ['/bookmarks/9/toggle_pin.json']);
  });
}

class _Bookmarks extends DiscourseBookmarkProxy {
  _Bookmarks()
      : super(SiteContext(
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
        )..setLoginData(FCLoginResult(
            result: true,
            resultText: '',
            user: FCUser(id: '2', username: 'tung'),
          )));

  Map<String, dynamic>? lastQuery;
  final puts = <String>[];

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    lastQuery = query;
    return {
      'user_bookmark_list': {
        'bookmarks': [
          {
            'id': 9,
            'title': 'Roadmap',
            'name': 'Check before release',
            'bookmarkable_type': 'Post',
            'category_id': 4,
            'tags': [
              'roadmap',
              {'id': 3, 'name': 'mobile', 'slug': 'mobile'},
            ],
          },
        ],
      },
    };
  }

  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    puts.add(path);
    return const {};
  }
}
