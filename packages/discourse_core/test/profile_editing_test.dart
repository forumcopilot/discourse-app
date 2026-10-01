import 'package:discourse_core/discourse_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';

/// Edit profile and the user card: what the app reads from
/// `/u/{username}.json`, `/u/{username}/card.json`, `/site.json` and
/// `/site/settings.json`, and what it writes back. Payload shapes as
/// UserSerializer, UserCardSerializer and UserFieldSerializer send them.
void main() {
  group('the editable profile', () {
    test('reads permissions, groups, fields and the picture in use', () {
      final p = DiscourseEditableProfile.fromUserJson({
        'id': 2,
        'username': 'alice',
        'name': 'Alice Nguyen',
        'can_edit_name': true,
        'can_edit_username': false,
        'can_change_bio': false,
        'can_upload_profile_header': true,
        'can_upload_user_card_background': true,
        'uploaded_avatar_id': 12,
        'custom_avatar_upload_id': 12,
        'gravatar_avatar_upload_id': 30,
        'title': 'Community lead',
        'flair_group_id': 41,
        'primary_group_id': 41,
        'groups': [
          {'id': 10, 'name': 'trust_level_0', 'automatic': true},
          {
            'id': 41,
            'name': 'designers',
            'full_name': 'Designers',
            'title': 'Designer',
            'flair_url': 'paintbrush',
            'flair_bg_color': '#7B4FC9',
            'flair_color': 'FFFFFF',
          },
          {'id': 42, 'name': 'hosts', 'flair_url': '/uploads/flair.png'},
        ],
        'user_fields': {'1': 'she/her', '3': true, '4': ['Typography']},
        'user_option': {'timezone': 'Asia/Ho_Chi_Minh', 'hide_profile': true},
        'birthdate': '1904-03-12',
        'featured_topic': {'id': 42, 'fancy_title': 'Meetup guide'},
        'card_background_upload_url': '/uploads/card.png',
        'status': {'description': 'Travelling', 'emoji': 'palm_tree'},
      }, siteUrl: 'https://forum.example');

      expect(p.canEditName, isTrue);
      expect(p.canChangeBio, isFalse,
          reason: "the forum's sign-in owns it; a write would be ignored");
      expect(p.canChangeLocation, isTrue,
          reason: 'absent means no override, not "locked"');
      expect(p.avatarKind, DiscourseAvatarKind.uploaded);
      expect(p.flairGroup?.displayName, 'Designers');
      expect(p.flairGroup?.flairBgColor, '7B4FC9');
      expect(p.flairGroups.map((g) => g.id), [41, 42]);
      expect(p.groupById(42)?.flairUrl, 'https://forum.example/uploads/flair.png');
      expect(p.primaryGroupChoices.map((g) => g.id), [41, 42],
          reason: "Discourse's own groups cannot be primary");
      expect(p.userFields, {1: 'she/her', 3: true, 4: ['Typography']});
      expect(p.timezone, 'Asia/Ho_Chi_Minh');
      expect(p.hideProfile, isTrue);
      expect(p.birthday, DateTime(1904, 3, 12));
      expect(p.featuredTopicTitle, 'Meetup guide');
      expect(p.cardBackgroundUrl, 'https://forum.example/uploads/card.png');
      expect(p.status?.emoji, 'palm_tree');
    });

    test('no uploaded picture means the letter avatar', () {
      final p = DiscourseEditableProfile.fromUserJson(
          {'id': 1, 'username': 'bob'}, siteUrl: 'https://forum.example');
      expect(p.avatarKind, DiscourseAvatarKind.letter);
      expect(
          DiscourseEditableProfile.fromUserJson(
                  {'id': 1, 'username': 'bob', 'uploaded_avatar_id': 30,
                   'gravatar_avatar_upload_id': 30},
                  siteUrl: 'https://forum.example')
              .avatarKind,
          DiscourseAvatarKind.gravatar);
    });
  });

  group("the forum's rules", () {
    test('profile questions from /site.json', () {
      DiscourseSiteCapabilities.store('https://rules.example', {
        'top_menu_items': ['latest'],
        'user_fields': [
          {
            'id': 1,
            'name': 'Pronouns',
            'field_type': 'text',
            'editable': true,
            'requirement': 'optional',
            'show_on_profile': true,
          },
          {
            'id': 2,
            'name': 'Favourite tool',
            'field_type': 'dropdown',
            'requirement': 'for_all_users',
            'options': ['Figma', 'Sketch'],
            'description': '<p>Pick <b>one</b></p>',
          },
          {'id': 3, 'name': 'Member number', 'editable': false},
          {'id': 4, 'name': ''},
        ],
      });
      final fields =
          DiscourseSiteCapabilities.forSite('https://rules.example').userFields;
      expect(fields.map((f) => f.name),
          ['Pronouns', 'Favourite tool', 'Member number']);
      expect(fields[1].type, DiscourseUserFieldType.dropdown);
      expect(fields[1].required, isTrue);
      expect(fields[1].options, ['Figma', 'Sketch']);
      expect(fields[1].description, 'Pick one');
      expect(fields[2].editable, isFalse);
    });

    test('settings from /site/settings.json, with stock defaults', () {
      final stock = DiscourseProfileSettings.fromClientSettings(const {});
      expect(stock.enableNames, isTrue);
      expect(stock.enableUserStatus, isFalse);
      expect(stock.selectableAvatars, isEmpty);

      final s = DiscourseProfileSettings.fromClientSettings({
        'enable_user_status': true,
        'selectable_avatars_mode': 'no_one',
        'selectable_avatars': '/uploads/a.png|/uploads/b.png',
        'cakeday_enabled': true,
        'cakeday_birthday_enabled': true,
        'user_selected_primary_groups': true,
        'gravatar_name': 'Libravatar',
      }, siteUrl: 'https://forum.example');
      expect(s.enableUserStatus, isTrue);
      expect(s.selectableAvatars, [
        'https://forum.example/uploads/a.png',
        'https://forum.example/uploads/b.png',
      ]);
      expect(s.birthdaysEnabled, isTrue);
      expect(
          DiscourseProfileSettings.fromClientSettings(
              {'cakeday_birthday_enabled': true}).birthdaysEnabled,
          isFalse,
          reason: 'with the cakeday plugin off, a birthday is never shown');
      expect(s.userSelectedPrimaryGroups, isTrue);
      expect(s.gravatarName, 'Libravatar');

      expect(
          DiscourseProfileSettings.fromClientSettings({
            'selectable_avatars_mode': 'disabled',
            'selectable_avatars': '/uploads/a.png',
          }).selectableAvatars,
          isEmpty,
          reason: 'the list is kept when the mode is off; select_avatar refuses');
    });
  });

  group('writing', () {
    test('a change goes to PUT /u/{username}.json and reads the answer', () async {
      final rec = _Rec();
      rec.putAnswer = {
        'success': 'OK',
        'user': {'id': 2, 'username': 'alice', 'name': 'Alice N.'},
      };
      final p = await _Profile(rec).update({'name': 'Alice N.'});
      expect(rec.calls.single, 'PUT /u/alice.json');
      expect(rec.bodies.single, {'name': 'Alice N.'});
      expect(p.name, 'Alice N.');
    });

    test('profile questions: false, a cleared answer and a list', () async {
      final rec = _Rec();
      rec.putAnswer = {'user': {'id': 2, 'username': 'alice'}};
      await _Profile(rec).updateUserFields({3: false, 1: null, 4: ['A', 'B']});
      expect(rec.bodies.single, {
        'user_fields': {'3': 'false', '1': '', '4': ['A', 'B']},
      });
    });

    test('a birthday keeps no year', () async {
      final rec = _Rec();
      rec.putAnswer = {'user': {'id': 2, 'username': 'alice'}};
      await _Profile(rec).setBirthday(DateTime(1990, 3, 7));
      expect(rec.bodies.single, {'date_of_birth': '1904-03-07'});
      await _Profile(rec).setBirthday(null);
      expect(rec.bodies.last, {'date_of_birth': null});
    });

    test('backgrounds clear with an empty URL', () async {
      final rec = _Rec();
      rec.putAnswer = {'user': {'id': 2, 'username': 'alice'}};
      await _Profile(rec).clearBackgroundImage(card: true);
      expect(rec.bodies.single, {'card_background_upload_url': ''});
    });

    test('the letter avatar is picked without an upload', () async {
      final rec = _Rec();
      await _Profile(rec).pickAvatar(DiscourseAvatarKind.letter, uploadId: 5);
      expect(rec.calls.single, 'PUT /u/alice/preferences/avatar/pick.json');
      expect(rec.bodies.single, {'type': 'system'});
      await _Profile(rec).pickAvatar(DiscourseAvatarKind.gravatar, uploadId: 30);
      expect(rec.bodies.last, {'type': 'gravatar', 'upload_id': 30});
    });

    test('a forum picture is selected by its path', () async {
      final rec = _Rec();
      await _Profile(rec)
          .selectForumAvatar('https://forum.example/uploads/default/a.png');
      expect(rec.bodies.single, {'url': '/uploads/default/a.png'});
    });

    test('a status always has an emoji and ends in UTC', () async {
      final rec = _Rec();
      final ends = DateTime.utc(2026, 10, 5, 2);
      await _Profile(rec).setStatus(
          DiscourseUserStatus(description: 'Away', endsAt: ends.toLocal()));
      expect(rec.calls.single, 'PUT /user-status.json');
      expect(rec.bodies.single, {
        'description': 'Away',
        'emoji': 'speech_balloon',
        'ends_at': '2026-10-05T02:00:00.000Z',
      });
      await _Profile(rec).clearStatus();
      expect(rec.calls.last, 'DELETE /user-status.json');
    });

    test('a new username is recorded on the session', () async {
      final rec = _Rec();
      rec.putAnswer = {'id': 2, 'username': 'alice_n'};
      final proxy = _Profile(rec);
      expect(await proxy.changeUsername('alice_n'), 'alice_n');
      expect(rec.calls.single, 'PUT /u/alice/preferences/username.json');
      expect(proxy.siteContext.currentUsername, 'alice_n');
    });

    test('an unavailable username says why', () async {
      final rec = _Rec();
      rec.getAnswers['/u/check_username.json'] = {
        'available': false,
        'suggestion': 'alice2',
      };
      expect(await _Profile(rec).checkUsername('alice'),
          'Not available. Try alice2');
      rec.getAnswers['/u/check_username.json'] = {'available': true};
      expect(await _Profile(rec).checkUsername('alice_n'), isNull);
    });
  });

  test('titles come from groups and from badges that grant one', () async {
    final rec = _Rec();
    rec.getAnswers['/user-badges/alice.json'] = {
      'badges': [
        {'id': 1, 'name': 'Leader', 'allow_title': true},
        {'id': 2, 'name': 'Welcome', 'allow_title': false},
        {'id': 3, 'name': 'Designer', 'allow_title': true},
      ],
      'user_badges': [
        {'id': 9, 'badge_id': 1, 'granted_at': '2026-01-05T00:00:00Z'},
        {'id': 10, 'badge_id': 2},
        {'id': 11, 'badge_id': 3},
      ],
    };
    final profile = DiscourseEditableProfile.fromUserJson({
      'id': 2,
      'username': 'alice',
      'has_title_badges': true,
      'groups': [
        {'id': 41, 'name': 'designers', 'full_name': 'Designers', 'title': 'Designer'},
      ],
    }, siteUrl: 'https://forum.example');
    final titles = await _Profile(rec).titleOptions(profile);
    expect(titles.map((t) => t.title), ['Designer', 'Leader']);
    expect(titles.first.groupName, 'Designers',
        reason: 'the group and the badge grant the same title; one row');
    expect(titles.last.fromBadge, isTrue);
    expect(titles.last.grantedAt, DateTime.utc(2026, 1, 5));
  });

  group('the user card', () {
    const defs = [
      DiscourseUserFieldDef(id: 1, name: 'Pronouns', showOnUserCard: true),
      DiscourseUserFieldDef(id: 2, name: 'Company', showOnProfile: true),
      DiscourseUserFieldDef(
          id: 3,
          name: 'Mentor',
          type: DiscourseUserFieldType.confirm,
          showOnUserCard: true),
    ];

    test('reads badges, card fields and the post count', () {
      final card = DiscourseUserCard.fromJson({
        'user_badges': [
          {'id': 5, 'badge_id': 7},
          {'id': 6, 'badge_id': 8},
        ],
        'badges': [
          {'id': 7, 'name': 'Great Topic', 'badge_type_id': 1, 'icon': 'certificate'},
          {'id': 8, 'name': 'Good Reply', 'badge_type_id': 2},
        ],
        'user': {
          'id': 3,
          'username': 'bob',
          'name': 'Bob Tran',
          'title': 'Meetup host',
          'card_background_upload_url': '/uploads/city.png',
          'flair_name': 'hosts',
          'flair_url': 'users',
          'flair_bg_color': 'C8581A',
          'status': {'description': 'In a meeting', 'emoji': 'calendar'},
          'bio_excerpt': 'Backend developer',
          'user_fields': {'1': 'he/him', '2': 'Riverside', '3': true},
          'topic_post_count': {'98': 12},
          'can_send_private_message_to_user': true,
          'can_chat_user': true,
          'can_ignore_user': true,
        },
      }, siteUrl: 'https://forum.example', fieldDefs: defs, topicId: 98);
      expect(card.cardBackgroundUrl, 'https://forum.example/uploads/city.png');
      expect(card.badges.map((b) => b.name), ['Great Topic', 'Good Reply']);
      expect(card.badges.first.badgeTypeId, 1);
      expect(card.fields.map((f) => '${f.name}: ${f.value}'),
          ['Pronouns: he/him', 'Mentor: Mentor'],
          reason: "only the forum's card fields; a confirm field shows its name");
      expect(card.topicPostCount, 12);
      expect(card.canChat, isTrue);
      expect(card.hasFlair, isTrue);
      expect(card.status?.description, 'In a meeting');
    });

    test('a hidden profile carries only who they are', () {
      final card = DiscourseUserCard.fromJson({
        'user': {
          'id': 4,
          'username': 'chris',
          'profile_hidden': true,
          'primary_group_name': 'beta',
          'topic_post_count': {'5': 3},
          'can_send_private_message_to_user': true,
        },
      }, siteUrl: 'https://forum.example');
      expect(card.profileHidden, isTrue);
      expect(card.topicPostCount, 3);
      expect(card.badges, isEmpty);
    });

    test('is asked for with the topic it was opened from', () async {
      final rec = _Rec();
      rec.getAnswers['/u/bob/card.json'] = {
        'user': {'id': 3, 'username': 'bob'},
      };
      rec.getAnswers['/site/settings.json'] = const {};
      rec.getAnswers['/site.json'] = const {};
      await _Profile(rec).loadCard('bob', topicId: 77);
      expect(rec.queries['/u/bob/card.json'], {'include_post_count_for': '77'});
    });
  });
}

SiteContext _signedIn() {
  final ctx = SiteContext(
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
  ctx.setLoginData(FCLoginResult(
    result: true,
    resultText: '',
    user: FCUser(id: '2', username: 'alice'),
  ));
  return ctx;
}

class _Rec {
  final List<String> calls = [];
  final List<Object?> bodies = [];
  final Map<String, Map<String, dynamic>> getAnswers = {};
  final Map<String, Map<String, dynamic>?> queries = {};
  Map<String, dynamic> putAnswer = const {'success': 'OK'};
}

class _Profile extends DiscourseProfileProxy {
  _Profile(this.rec) : super(_signedIn());
  final _Rec rec;

  @override
  Future<Map<String, dynamic>> apiGet(String path,
      {Map<String, dynamic>? query}) async {
    rec.calls.add('GET $path');
    rec.queries[path] = query;
    final a = rec.getAnswers[path];
    if (a == null) {
      throw DiscourseApiException(
          statusCode: 404, method: 'GET', path: path, body: '');
    }
    return a;
  }

  @override
  Future<Map<String, dynamic>> apiPut(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    rec.calls.add('PUT $path');
    rec.bodies.add(body);
    return rec.putAnswer;
  }

  @override
  Future<Map<String, dynamic>> apiDelete(String path,
      {Map<String, dynamic>? query, Object? body}) async {
    rec.calls.add('DELETE $path');
    return const {'success': 'OK'};
  }
}
