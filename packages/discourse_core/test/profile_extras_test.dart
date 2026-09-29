import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// What a profile says beyond the shared user model, and the summary's top
/// categories. Payload shapes as UserSerializer / UserSummarySerializer
/// send them.
void main() {
  setUp(DiscourseUserProfileExtras.clear);

  test('a profile load records title, status, background, featured topic',
      () async {
    final info = await _Users({
      '/u/alice.json': {
        'user': {
          'id': 7,
          'username': 'alice',
          'name': 'Alice',
          'post_count': 3,
          'title': 'Community lead',
          'status': {
            'emoji': 'beach_umbrella',
            'description': 'On holiday until Monday',
            'ends_at': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
          },
          'profile_background_upload_url': '/uploads/bg.png',
          'featured_topic': {'id': 42, 'title': 'Meetup venue ideas'},
          'timezone': 'Asia/Ho_Chi_Minh',
          'bio_cooked': '<p>Flutter dev &amp; Discourse fan</p>',
          'groups': [
            {'name': 'trust_level_2', 'automatic': true},
            {'name': 'meetup-hosts', 'automatic': false},
          ],
        },
      },
    }).getUserInfoAsync('alice', null);
    expect(info.result, isTrue);
    expect(info.userGroups, ['meetup-hosts'],
        reason: "automatic groups restate the trust level; web's profile skips them");

    final extras =
        DiscourseUserProfileExtras.forUser('https://forum.example', 'Alice')!;
    expect(extras.title, 'Community lead');
    expect(extras.hasStatus, isTrue);
    expect(extras.statusEmoji, 'beach_umbrella');
    expect(extras.backgroundUrl, 'https://forum.example/uploads/bg.png');
    expect(extras.featuredTopicId, 42);
    expect(extras.featuredTopicTitle, 'Meetup venue ideas');
    expect(extras.timezone, 'Asia/Ho_Chi_Minh');
    expect(extras.bioText, 'Flutter dev & Discourse fan');
  });

  test('an expired status is not shown', () {
    final extras = DiscourseUserProfileExtras(
      statusDescription: 'Back soon',
      statusEndsAt: DateTime.now().subtract(const Duration(hours: 1)),
    );
    expect(extras.hasStatus, isFalse);
  });

  test('the summary lists top categories and solutions', () async {
    final result = await _Users({
      '/u/alice/summary.json': {
        'user_summary': {
          'post_count': 30,
          'solved_count': 4,
          'can_see_summary_stats': true,
          'top_categories': [
            {'id': 4, 'name': 'General', 'color': '0088CC', 'topic_count': 2, 'post_count': 9},
            {'id': 0, 'name': ''},
          ],
        },
      },
    }).getUserSummaryAsync('alice');
    final s = result.summary!;
    expect(s.solvedCount, 4);
    expect(s.topCategories.single.name, 'General');
    expect(s.topCategories.single.postCount, 9);
  });
}

class _Users extends DiscourseUserProxy {
  _Users(this.byPath)
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
        ));
  final Map<String, Map<String, dynamic>> byPath;

  @override
  Future<Map<String, dynamic>> apiGet(String path,
          {Map<String, dynamic>? query}) async =>
      byPath[path] ?? const {};
}
