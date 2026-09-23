import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Who a private message lists as its participants.
///
/// Found on an iPhone 17 against meta.discourse.org (2026-09-22): a system
/// message the user had replied to showed "1 participant". Discourse leaves
/// out of `allowed_users` anyone covered by an allowed group — `system` is in
/// every staff and trust-level group — so the author has to come from
/// `created_by` and the posters from `participants`.
void main() {
  final proxy = DiscoursePrivateConversationProxy(SiteContext(
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

  Map<String, dynamic> user(int id, String name) => {
        'id': id,
        'username': name,
        'avatar_template': '/user_avatar/forum.example/$name/{size}/1.png',
      };

  test('a group-covered author still appears, first', () {
    final details = {
      'created_by': user(-1, 'system'),
      'allowed_users': [user(190598, 'forumcopilot')],
      'allowed_groups': [
        {'id': 3, 'name': 'staff'}
      ],
      'participants': [
        {...user(-1, 'system'), 'post_count': 1},
        {...user(190598, 'forumcopilot'), 'post_count': 1},
      ],
    };
    final names =
        proxy.participantsFrom(details).map((p) => p.username).toList();
    expect(names, ['system', 'forumcopilot']);
  });

  test('someone allowed who has not posted is still listed', () {
    final details = {
      'created_by': user(1, 'alice'),
      'allowed_users': [user(1, 'alice'), user(2, 'bob'), user(3, 'carol')],
      'participants': [
        {...user(1, 'alice'), 'post_count': 2},
      ],
    };
    expect(proxy.participantsFrom(details).map((p) => p.userId),
        ['1', '2', '3']);
  });

  test('avatars resolve against the forum', () {
    final p = proxy.participantsFrom({'created_by': user(1, 'alice')}).single;
    expect(p.iconUrl,
        'https://forum.example/user_avatar/forum.example/alice/90/1.png');
  });

  test('missing fields give an empty list, not an error', () {
    expect(proxy.participantsFrom(const {}), isEmpty);
  });
}
