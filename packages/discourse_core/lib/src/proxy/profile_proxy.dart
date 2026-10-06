import 'dart:typed_data';

import 'package:forumcopilot_sdk/context/site_context.dart';

import '../base_discourse_proxy.dart';
import '../context/discourse_site_context_extension.dart';
import '../data/site/discourse_site_capabilities.dart';
import '../data/user/discourse_profile.dart';
import 'attachment_proxy.dart';

/// One topic available to the profile's featured-topic picker.
typedef DiscourseProfileTopic = ({
  int id,
  String title,
  int replies,
  DateTime? createdAt,
  int? categoryId,
});

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
  /// only when startup could not. A reply that comes back after the sign-in
  /// changed is not stored ([DiscourseSiteCapabilities.readGuard]).
  Future<({DiscourseProfileSettings settings, List<DiscourseUserFieldDef> fields})>
      forumRules() async {
    final key = siteContext.site.pluginUrl;
    bool Function() guard() => DiscourseSiteCapabilities.readGuard(
        key, () => siteContext.configurationSession);
    if (DiscourseSiteCapabilities.forSite(key).profileSettings == null) {
      try {
        final current = guard();
        final settings = await apiGet('/site/settings.json');
        if (current()) {
          DiscourseSiteCapabilities.storeClientSettings(key, settings);
        }
      } catch (_) {
        // Stock defaults below.
      }
    }
    if (!DiscourseSiteCapabilities.isResolved(key)) {
      try {
        final current = guard();
        final site = await apiGet('/site.json');
        if (current()) DiscourseSiteCapabilities.store(key, site);
      } catch (_) {
        // No profile questions known.
      }
    }
    final caps = DiscourseSiteCapabilities.forSite(key);
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

  /// The member's own topics on one page. For pagination metadata, use
  /// [myTopicsPage]. A [query] searches their topics' titles.
  Future<List<DiscourseProfileTopic>> myTopics(
      {String query = '', int page = 0}) async =>
      (await myTopicsPage(query: query, page: page)).topics;

  /// Topics created by the signed-in member, with the server's indication
  /// of another page. A [query] is searched by Discourse before pagination
  /// ([_searchMyTopics]), rather than filtering only the first downloaded
  /// page by title.
  ///
  /// Newest created first (`order=created`: TopicQuery's SORTABLE_MAPPING
  /// sorts `topics.created_at`, descending unless `ascending=true`). The
  /// list's default order is `bumped_at`, so a topic that got a reply
  /// between two pages moved to the top: the next page repeated the row
  /// it pushed down, and the bumped topic was never shown.
  Future<({List<DiscourseProfileTopic> topics, int? nextPage})> myTopicsPage(
      {String query = '', int page = 0}) async {
    if (query.trim().isNotEmpty) return _searchMyTopics(query.trim(), page);
    final body = await apiGet('/topics/created-by/$_me.json', query: {
      'order': 'created',
      if (page > 0) 'page': '$page',
    });
    final list = (body['topic_list'] as Map?) ?? const {};
    final raw = (list['topics'] as List?) ?? const [];
    final more = list['more_topics_url'];
    return (
      topics: [
        for (final t in raw.whereType<Map>())
          if (_profileTopic(t) case final topic?) topic,
      ],
      // Rebuild the known endpoint with the next page;
      // never send credentials to a URL supplied in the response.
      nextPage: raw.isNotEmpty && more is String && more.isNotEmpty
          ? page + 1
          : null,
    );
  }

  /// `SearchController::PAGE_LIMIT`: `/search.json` refuses later pages.
  static const _searchPageLimit = 10;

  /// The member's public topics whose titles match [query], as the forum's
  /// own "Feature topic on profile" picker searches (ChooseTopic with
  /// `status:public`: the title typed plus that filter, a topic search),
  /// narrowed to the member's own topics as this picker lists them.
  ///
  /// topics_by's `search` matched the words anywhere in a topic, replies
  /// by others included (TopicQuery joins every post's search data), so
  /// many results did not have the words in their titles. Here:
  ///   * `in:title` matches the words against titles only;
  ///   * `@username in:first` keeps to topics the member started, even
  ///     when Discourse drops words shorter than `min_search_term_length`
  ///     (it then lists them all, as the forum's search page does);
  ///   * `status:public` leaves out what cannot be featured
  ///     (`can_feature_topic?` refuses read-restricted categories);
  ///   * `order:latest_topic` sorts by creation, as the unfiltered list
  ///     does, so pages hold still (relevance ties fall back to
  ///     `bumped_at`, the order that made pages repeat).
  /// Words match as Discourse's search matches them, from their start
  /// ("Flut" finds Flutter, "utter" does not, and stop words like "the"
  /// find nothing), the same as on the web.
  ///
  /// `/search.json` pages from 1 and says whether another follows with
  /// `grouped_search_result.more_full_page_results`; [page] counts from 0
  /// like the list's.
  Future<({List<DiscourseProfileTopic> topics, int? nextPage})>
      _searchMyTopics(String query, int page) async {
    if (page >= _searchPageLimit) {
      return (topics: const <DiscourseProfileTopic>[], nextPage: null);
    }
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      throw StateError('Not signed in');
    }
    final body = await apiGet('/search.json', query: {
      'q': '$query @$username in:title in:first status:public '
          'order:latest_topic',
      if (page > 0) 'page': '${page + 1}',
    });
    final byId = <int, DiscourseProfileTopic>{
      for (final t
          in ((body['topics'] as List?) ?? const []).whereType<Map>())
        if (_profileTopic(t) case final topic?) topic.id: topic,
    };
    // The results' order is their posts' (one per topic); `topics` holds
    // the side-loaded records.
    final order = [
      for (final p in ((body['posts'] as List?) ?? const []).whereType<Map>())
        if (p['topic_id'] is num) (p['topic_id'] as num).toInt(),
      ...byId.keys,
    ];
    final seen = <int>{};
    final topics = [
      for (final id in order)
        if (byId[id] case final topic? when seen.add(id)) topic,
    ];
    final more = (body['grouped_search_result'] as Map?)
            ?['more_full_page_results'] ==
        true;
    return (
      topics: topics,
      nextPage: topics.isNotEmpty && more && page + 1 < _searchPageLimit
          ? page + 1
          : null,
    );
  }

  static DiscourseProfileTopic? _profileTopic(Map t) {
    if (t['id'] is! num) return null;
    return (
      id: (t['id'] as num).toInt(),
      title: (t['fancy_title'] ?? t['title'] ?? '').toString(),
      replies: ((t['posts_count'] as num?)?.toInt() ?? 1) - 1,
      createdAt: DateTime.tryParse(t['created_at']?.toString() ?? ''),
      categoryId: (t['category_id'] as num?)?.toInt(),
    );
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

  /// Mutes or unmutes [username] for the member
  /// (`PUT /u/{username}/notification_level.json`). Ignoring, which also
  /// needs an end date, is `DiscourseUserProxy.ignoreUserAsync`.
  Future<void> setMuted(String username, bool muted) async {
    await apiPut('/u/${Uri.encodeComponent(username)}/notification_level.json',
        body: {'notification_level': muted ? 'mute' : 'normal'});
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
