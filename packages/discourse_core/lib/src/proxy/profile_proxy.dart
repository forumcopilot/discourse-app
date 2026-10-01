import 'dart:typed_data';

import 'package:forumcopilot_sdk/context/site_context.dart';

import '../base_discourse_proxy.dart';
import '../context/discourse_site_context_extension.dart';
import '../data/site/discourse_site_capabilities.dart';
import '../data/user/discourse_profile.dart';
import 'attachment_proxy.dart';

/// Discourse-only: the signed-in member's own profile, everything Edit
/// profile reads and writes, and the user card of anyone.
///
/// Not on an SDK interface: the XenForo-shaped `IFCAccountProxy` has one
/// "update profile" call with free-form fields, and Discourse splits a
/// profile across several endpoints (the profile itself, the avatar, the
/// featured topic, the username, the status) with rules the forum decides.
///
/// Calls throw on failure ([DiscourseApiException] carries the forum's own
/// message); the caller shows it.
class DiscourseProfileProxy extends BaseDiscourseProxy {
  DiscourseProfileProxy(SiteContext context, {DiscourseAttachmentProxy? uploads})
      : _uploads = uploads,
        super(context);

  final DiscourseAttachmentProxy? _uploads;

  String get _me {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      throw StateError('Not signed in');
    }
    return Uri.encodeComponent(username);
  }

  String get _siteUrl => siteContext.site.url;

  // ===== The forum's rules =====

  /// What this forum lets members do with their profile, and its profile
  /// questions. Read at startup with the forum's settings; fetched here
  /// only when startup could not.
  Future<({DiscourseProfileSettings settings, List<DiscourseUserFieldDef> fields})>
      forumRules() async {
    final key = siteContext.site.pluginUrl;
    var caps = DiscourseSiteCapabilities.forSite(key);
    if (caps.profileSettings == null) {
      try {
        DiscourseSiteCapabilities.storeClientSettings(
            key, await apiGet('/site/settings.json'));
      } catch (_) {
        // Stock defaults below.
      }
    }
    if (!DiscourseSiteCapabilities.isResolved(key)) {
      try {
        DiscourseSiteCapabilities.store(key, await apiGet('/site.json'));
      } catch (_) {
        // No profile questions known.
      }
    }
    caps = DiscourseSiteCapabilities.forSite(key);
    return (
      settings: caps.profileSettings ?? const DiscourseProfileSettings(),
      fields: caps.userFields,
    );
  }

  // ===== Reading =====

  /// The member's own profile (`GET /u/{username}.json`).
  Future<DiscourseEditableProfile> loadMine() async {
    final body = await apiGet('/u/$_me.json');
    return _profileFrom(body);
  }

  DiscourseEditableProfile _profileFrom(Map<String, dynamic> body) {
    final user = (body['user'] as Map?)?.cast<String, dynamic>();
    if (user == null) throw StateError('The forum sent no profile');
    return DiscourseEditableProfile.fromUserJson(user, siteUrl: _siteUrl);
  }

  /// The titles the member may wear: the badges they earned that grant one
  /// (`/user-badges/{username}.json`) and their groups' titles, as web's
  /// account page lists them (User#availableTitles).
  Future<List<DiscourseTitleOption>> titleOptions(
      DiscourseEditableProfile profile) async {
    final options = <String, DiscourseTitleOption>{};
    for (final g in profile.groups) {
      final title = g.title;
      if (title != null && !options.containsKey(title)) {
        options[title] =
            DiscourseTitleOption(title: title, groupName: g.displayName);
      }
    }
    if (profile.hasTitleBadges) {
      final body = await apiGet('/user-badges/$_me.json',
          query: {'grouped': 'true'});
      final badges = <int, Map>{
        for (final b in ((body['badges'] as List?) ?? const []).whereType<Map>())
          if (b['id'] is num) (b['id'] as num).toInt(): b,
      };
      for (final ub
          in ((body['user_badges'] as List?) ?? const []).whereType<Map>()) {
        final b = badges[(ub['badge_id'] as num?)?.toInt()];
        if (b == null || b['allow_title'] != true) continue;
        final name = b['name']?.toString().trim() ?? '';
        if (name.isEmpty || options.containsKey(name)) continue;
        options[name] = DiscourseTitleOption(
          title: name,
          badgeName: name,
          grantedAt: DateTime.tryParse(ub['granted_at']?.toString() ?? ''),
        );
      }
    }
    final list = options.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return list;
  }

  /// The member's own topics, newest first, for choosing a featured one
  /// (`/topics/created-by/{username}.json`). [query] narrows by title.
  Future<List<({int id, String title, int replies, DateTime? createdAt, int? categoryId})>>
      myTopics({String query = '', int page = 0}) async {
    final body = await apiGet('/topics/created-by/$_me.json',
        query: {if (page > 0) 'page': '$page'});
    final topics = (((body['topic_list'] as Map?)?['topics'] as List?) ??
            const [])
        .whereType<Map>();
    final q = query.trim().toLowerCase();
    return [
      for (final t in topics)
        if (t['id'] is num &&
            (q.isEmpty ||
                (t['title']?.toString().toLowerCase().contains(q) ?? false)))
          (
            id: (t['id'] as num).toInt(),
            title: (t['fancy_title'] ?? t['title'] ?? '').toString(),
            replies: ((t['posts_count'] as num?)?.toInt() ?? 1) - 1,
            createdAt: DateTime.tryParse(t['created_at']?.toString() ?? ''),
            categoryId: (t['category_id'] as num?)?.toInt(),
          ),
    ];
  }

  /// Someone's user card (`/u/{username}/card.json`). With [topicId], how
  /// many posts they have in that topic (`include_post_count_for`).
  Future<DiscourseUserCard> loadCard(String username, {int? topicId}) async {
    final rules = await forumRules();
    final body = await apiGet('/u/${Uri.encodeComponent(username)}/card.json',
        query: {if (topicId != null) 'include_post_count_for': '$topicId'});
    return DiscourseUserCard.fromJson(body,
        siteUrl: _siteUrl, fieldDefs: rules.fields, topicId: topicId);
  }

  // ===== Writing =====

  /// Changes the given profile fields (`PUT /u/{username}.json`) and
  /// returns the profile as the forum now has it. Keys are UserUpdater's:
  /// `name`, `bio_raw`, `location`, `website`, `title`, `flair_group_id`,
  /// `primary_group_id`, `timezone`, `hide_profile`, `date_of_birth`,
  /// `profile_background_upload_url`, `card_background_upload_url`.
  Future<DiscourseEditableProfile> update(Map<String, dynamic> fields) async {
    final body = await apiPut('/u/$_me.json', body: fields);
    if (body['user'] is Map) return _profileFrom(body);
    return loadMine();
  }

  /// Answers the forum's profile questions, by field id. A confirm field
  /// takes a bool, a multiselect a list, the rest a string; null clears.
  Future<DiscourseEditableProfile> updateUserFields(Map<int, Object?> values) =>
      update({
        'user_fields': {
          for (final e in values.entries)
            '${e.key}': switch (e.value) {
              // UsersController#update reads "false" as unanswered.
              false => 'false',
              true => 'true',
              null => '',
              final v => v,
            },
        },
      });

  /// The birthday the cakeday plugin shows; the year is not kept.
  Future<DiscourseEditableProfile> setBirthday(DateTime? day) => update({
        'date_of_birth': day == null
            ? null
            : '1904-${day.month.toString().padLeft(2, '0')}-'
                '${day.day.toString().padLeft(2, '0')}',
      });

  /// Uploads [bytes] as the cover (`profile_background`) or the card
  /// background (`card_background`) and sets it.
  Future<DiscourseEditableProfile> setBackgroundImage({
    required bool card,
    required String imageExtension,
    required Uint8List bytes,
  }) async {
    final type = card ? 'card_background' : 'profile_background';
    final upload = await (_uploads ?? DiscourseAttachmentProxy(siteContext))
        .uploadProfileImageAsync(type, imageExtension, bytes);
    final url = upload.url;
    if (!upload.result || url == null || url.isEmpty) {
      throw StateError(upload.resultText?.isNotEmpty == true
          ? upload.resultText!
          : 'Upload failed');
    }
    return update({'${type}_upload_url': url});
  }

  /// Removes the cover or the card background.
  Future<DiscourseEditableProfile> clearBackgroundImage({required bool card}) =>
      update({
        card ? 'card_background_upload_url' : 'profile_background_upload_url':
            '',
      });

  /// Uses the letter avatar, the Gravatar, or an earlier upload
  /// (`PUT /u/{username}/preferences/avatar/pick.json`).
  Future<void> pickAvatar(DiscourseAvatarKind kind, {int? uploadId}) async {
    await apiPut('/u/$_me/preferences/avatar/pick.json', body: {
      'type': switch (kind) {
        DiscourseAvatarKind.letter => 'system',
        DiscourseAvatarKind.gravatar => 'gravatar',
        _ => 'uploaded',
      },
      if (kind != DiscourseAvatarKind.letter && uploadId != null)
        'upload_id': uploadId,
    });
  }

  /// Fetches the member's Gravatar into the forum
  /// (`POST /user_avatar/{username}/refresh_gravatar.json`). Null when they
  /// have none.
  Future<int?> refreshGravatar() async {
    final body = await apiPost('/user_avatar/$_me/refresh_gravatar.json');
    return (body['gravatar_upload_id'] as num?)?.toInt();
  }

  /// Uses one of the forum's own pictures
  /// (`PUT /u/{username}/preferences/avatar/select.json`).
  Future<void> selectForumAvatar(String url) async {
    final path = Uri.tryParse(url)?.path ?? url;
    await apiPut('/u/$_me/preferences/avatar/select.json',
        body: {'url': path});
  }

  /// Pins [topicId] to the top of the member's profile.
  Future<void> featureTopic(int topicId) async {
    await apiPut('/u/$_me/feature-topic.json', body: {'topic_id': topicId});
  }

  Future<void> clearFeaturedTopic() async {
    await apiPut('/u/$_me/clear-featured-topic.json');
  }

  /// Whether [username] is free (`GET /u/check_username.json`): null when
  /// it is, else the forum's reason.
  Future<String?> checkUsername(String username) async {
    final body = await apiGet('/u/check_username.json',
        query: {'username': username});
    if (body['available'] == true) return null;
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) return errors.join('; ');
    final suggestion = body['suggestion']?.toString();
    return suggestion == null || suggestion.isEmpty
        ? 'Not available'
        : 'Not available. Try $suggestion';
  }

  /// Renames the member (`PUT /u/{username}/preferences/username.json`)
  /// and records the new name on the session. Returns it.
  Future<String> changeUsername(String newUsername) async {
    final body = await apiPut('/u/$_me/preferences/username.json',
        body: {'new_username': newUsername});
    final changed = body['username']?.toString() ?? newUsername;
    final login = siteContext.loginDataOutput;
    final user = login?.user;
    if (login != null && user != null) {
      final renamed = login.copyWith(user: user.copyWith(username: changed));
      siteContext.setLoginData(renamed);
      // The offline-launch snapshot too, or a launch without a connection
      // would come back under the old name.
      try {
        await siteContext.saveLoginSnapshot(renamed.toJson());
      } catch (_) {}
    }
    return changed;
  }

  /// Sets the member's status (`PUT /user-status.json`). Discourse
  /// requires an emoji; web's picker starts on a speech balloon.
  Future<void> setStatus(DiscourseUserStatus status) async {
    await apiPut('/user-status.json', body: {
      'description': status.description,
      'emoji': status.emoji ?? 'speech_balloon',
      if (status.endsAt != null)
        'ends_at': status.endsAt!.toUtc().toIso8601String(),
    });
  }

  Future<void> clearStatus() async {
    await apiDelete('/user-status.json');
  }
}
