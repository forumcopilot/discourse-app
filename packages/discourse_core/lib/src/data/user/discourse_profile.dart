import '../../util/html_text.dart';
import '../../util/site_url.dart';

/// The kinds of profile field a forum can define (`UserField.field_type`).
enum DiscourseUserFieldType { text, confirm, dropdown, multiselect }

/// One of the forum's own profile questions ("Pronouns", "Company"), as
/// `/site.json` lists them under `user_fields` (UserFieldSerializer).
class DiscourseUserFieldDef {
  const DiscourseUserFieldDef({
    required this.id,
    required this.name,
    this.description,
    this.type = DiscourseUserFieldType.text,
    this.editable = true,
    this.requiredForAll = false,
    this.requiredOnSignup = false,
    this.showOnProfile = false,
    this.showOnUserCard = false,
    this.options = const [],
  });

  final int id;
  final String name;

  /// The forum's explanation, as HTML-free text.
  final String? description;
  final DiscourseUserFieldType type;

  /// False when only staff may change it; the member sees it read-only.
  final bool editable;

  /// `requirement: for_all_users` — every member must answer.
  final bool requiredForAll;

  /// `requirement: on_signup` — asked at signup; once answered it cannot
  /// be cleared (UsersController#update refuses a blank value).
  final bool requiredOnSignup;
  final bool showOnProfile;
  final bool showOnUserCard;

  /// The choices of a dropdown or multiselect field.
  final List<String> options;

  bool get required => requiredForAll || requiredOnSignup;

  static DiscourseUserFieldDef? fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt();
    final name = json['name']?.toString().trim() ?? '';
    if (id == null || name.isEmpty) return null;
    final requirement = json['requirement']?.toString();
    final description = json['description']?.toString();
    return DiscourseUserFieldDef(
      id: id,
      name: name,
      description: description == null || description.trim().isEmpty
          ? null
          : stripHtmlToText(description),
      type: switch (json['field_type']?.toString()) {
        'confirm' => DiscourseUserFieldType.confirm,
        'dropdown' => DiscourseUserFieldType.dropdown,
        'multiselect' => DiscourseUserFieldType.multiselect,
        _ => DiscourseUserFieldType.text,
      },
      editable: json['editable'] != false,
      requiredForAll: requirement == 'for_all_users' ||
          (requirement == null && json['required'] == true),
      requiredOnSignup: requirement == 'on_signup',
      showOnProfile: json['show_on_profile'] == true,
      showOnUserCard: json['show_on_user_card'] == true,
      options: ((json['options'] as List?) ?? const [])
          .map((o) => o is Map ? o['value']?.toString() : o?.toString())
          .whereType<String>()
          .where((o) => o.isNotEmpty)
          .toList(growable: false),
    );
  }

  /// A value as the user JSON carries it (`user_fields: {"3": …}`), as the
  /// text a profile shows: a list joined, a confirm field as its name.
  static String? display(DiscourseUserFieldDef def, Object? value) {
    if (value == null) return null;
    if (def.type == DiscourseUserFieldType.confirm) {
      return value == true || value == 'true' ? def.name : null;
    }
    if (value is List) {
      final parts = value.map((v) => v.toString()).where((v) => v.isNotEmpty);
      return parts.isEmpty ? null : parts.join(', ');
    }
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }
}

/// What a forum allows people to do with their profile — the `client:
/// true` site settings `/site/settings.json` publishes. Defaults are
/// Discourse's own (config/site_settings.yml), so a forum that sent
/// nothing behaves like a stock one.
class DiscourseProfileSettings {
  const DiscourseProfileSettings({
    this.enableNames = true,
    this.enableUserStatus = false,
    this.allowFeaturedTopic = true,
    this.userSelectedPrimaryGroups = false,
    this.allowUsersToHideProfile = true,
    this.gravatarEnabled = true,
    this.gravatarName = 'Gravatar',
    this.selectableAvatars = const [],
    this.allowProfileBackgrounds = true,
    this.birthdaysEnabled = false,
    this.avatarManagedBySignIn = false,
    this.displayLocalTime = false,
  });

  /// `enable_names`: members have a display name besides the username.
  final bool enableNames;

  /// `enable_user_status`: the "What are you doing?" line.
  final bool enableUserStatus;

  /// `allow_featured_topic_on_user_profiles`.
  final bool allowFeaturedTopic;

  /// `user_selected_primary_groups`: members pick their primary group.
  final bool userSelectedPrimaryGroups;

  /// `allow_users_to_hide_profile`.
  final bool allowUsersToHideProfile;

  /// `gravatar_enabled` and the name the forum gives the service.
  final bool gravatarEnabled;
  final String gravatarName;

  /// `selectable_avatars` when `selectable_avatars_mode` is on: the
  /// forum's own pictures to choose from. Absolute URLs.
  final List<String> selectableAvatars;

  /// `allow_profile_backgrounds`: web shows the cover and card images.
  final bool allowProfileBackgrounds;

  /// `cakeday_birthday_enabled` (the bundled cakeday plugin).
  final bool birthdaysEnabled;

  /// `discourse_connect_overrides_avatar`: the forum's own sign-in sets
  /// the picture, and `pick_avatar` refuses any other.
  final bool avatarManagedBySignIn;

  /// `display_local_time_in_user_card`.
  final bool displayLocalTime;

  factory DiscourseProfileSettings.fromClientSettings(
      Map<String, dynamic> s, {String? siteUrl}) {
    bool flag(String key, bool fallback) {
      final v = s[key];
      if (v is bool) return v;
      if (v is String) return v == 'true';
      return fallback;
    }

    final mode = s['selectable_avatars_mode']?.toString() ?? 'disabled';
    final avatars = mode == 'disabled'
        ? const <String>[]
        : (s['selectable_avatars']?.toString() ?? '')
            .split('|')
            .map((u) => u.trim())
            .where((u) => u.isNotEmpty)
            .map((u) => siteUrl == null ? u : absoluteSiteUrl(siteUrl, u))
            .toList(growable: false);
    final gravatarName = s['gravatar_name']?.toString().trim();
    return DiscourseProfileSettings(
      enableNames: flag('enable_names', true),
      enableUserStatus: flag('enable_user_status', false),
      allowFeaturedTopic: flag('allow_featured_topic_on_user_profiles', true),
      userSelectedPrimaryGroups: flag('user_selected_primary_groups', false),
      allowUsersToHideProfile: flag('allow_users_to_hide_profile', true),
      gravatarEnabled: flag('gravatar_enabled', true),
      gravatarName: gravatarName == null || gravatarName.isEmpty
          ? 'Gravatar'
          : gravatarName,
      selectableAvatars: avatars,
      allowProfileBackgrounds: flag('allow_profile_backgrounds', true),
      birthdaysEnabled: flag('cakeday_birthday_enabled', false),
      avatarManagedBySignIn: flag('enable_discourse_connect', false) &&
          flag('discourse_connect_overrides_avatar', false),
      displayLocalTime: flag('display_local_time_in_user_card', false),
    );
  }
}

/// A group as the user JSON lists it (BasicGroupSerializer), with what
/// the profile editor needs: whether it grants a title or a flair.
class DiscourseProfileGroup {
  const DiscourseProfileGroup({
    required this.id,
    required this.name,
    this.fullName,
    this.title,
    this.flairUrl,
    this.flairBgColor,
    this.flairColor,
    this.automatic = false,
  });

  final int id;
  final String name;
  final String? fullName;

  /// The title membership grants (`groups.title`), offered as a title.
  final String? title;

  /// An icon name ("far-face-smile") or an image URL.
  final String? flairUrl;

  /// Six-digit hex without '#'.
  final String? flairBgColor;
  final String? flairColor;

  /// Discourse's own groups (trust levels, staff): never offered as a
  /// primary group.
  final bool automatic;

  bool get hasFlair => flairUrl != null && flairUrl!.isNotEmpty;

  String get displayName =>
      (fullName != null && fullName!.isNotEmpty) ? fullName! : name;

  static DiscourseProfileGroup? fromJson(Map<String, dynamic> g,
      {required String siteUrl}) {
    final id = (g['id'] as num?)?.toInt();
    final name = g['name']?.toString() ?? '';
    if (id == null || name.isEmpty) return null;
    String? text(Object? v) {
      final s = v?.toString().trim();
      return s == null || s.isEmpty ? null : s;
    }

    final flair = text(g['flair_url']);
    return DiscourseProfileGroup(
      id: id,
      name: name,
      fullName: text(g['full_name']),
      title: text(g['title']),
      flairUrl: flair == null
          ? null
          : (flair.contains('/') ? absoluteSiteUrl(siteUrl, flair) : flair),
      flairBgColor: text(g['flair_bg_color'])?.replaceFirst('#', ''),
      flairColor: text(g['flair_color'])?.replaceFirst('#', ''),
      automatic: g['automatic'] == true,
    );
  }
}

/// The "What are you doing?" line (UserStatusSerializer).
class DiscourseUserStatus {
  const DiscourseUserStatus({
    required this.description,
    this.emoji,
    this.endsAt,
  });

  final String description;

  /// A shortcode without colons ("beach_umbrella").
  final String? emoji;
  final DateTime? endsAt;

  bool get isActive =>
      description.isNotEmpty &&
      (endsAt == null || endsAt!.isAfter(DateTime.now()));

  static DiscourseUserStatus? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final description = raw['description']?.toString().trim() ?? '';
    if (description.isEmpty) return null;
    final emoji = raw['emoji']?.toString().replaceAll(':', '').trim();
    return DiscourseUserStatus(
      description: description,
      emoji: emoji == null || emoji.isEmpty ? null : emoji,
      endsAt: DateTime.tryParse(raw['ends_at']?.toString() ?? '')?.toLocal(),
    );
  }
}

/// A picture the forum keeps for a person, by kind — the three
/// `pick_avatar` types plus the forum's selectable ones.
enum DiscourseAvatarKind { uploaded, letter, gravatar, forum }

/// The signed-in member's own profile, everything Edit profile shows and
/// what the forum lets them change. From `/u/{username}.json`
/// (UserSerializer, with its private attributes, since it is their own).
class DiscourseEditableProfile {
  const DiscourseEditableProfile({
    required this.id,
    required this.username,
    this.name,
    this.avatarTemplate,
    this.uploadedAvatarId,
    this.customAvatarUploadId,
    this.customAvatarTemplate,
    this.gravatarAvatarUploadId,
    this.gravatarAvatarTemplate,
    this.systemAvatarTemplate,
    this.canEditName = false,
    this.canEditUsername = false,
    this.canChangeBio = true,
    this.canChangeLocation = true,
    this.canChangeWebsite = true,
    this.canUploadProfileHeader = false,
    this.canUploadCardBackground = false,
    this.bioRaw,
    this.bioCooked,
    this.location,
    this.website,
    this.title,
    this.flairGroupId,
    this.primaryGroupId,
    this.groups = const [],
    this.userFields = const {},
    this.timezone,
    this.hideProfile = false,
    this.birthday,
    this.featuredTopicId,
    this.featuredTopicTitle,
    this.profileBackgroundUrl,
    this.cardBackgroundUrl,
    this.status,
    this.hasTitleBadges = false,
    this.createdAt,
  });

  final int id;
  final String username;
  final String? name;

  /// `/user_avatar/…/{size}/…` templates, relative to the forum.
  final String? avatarTemplate;
  final int? uploadedAvatarId;
  final int? customAvatarUploadId;
  final String? customAvatarTemplate;
  final int? gravatarAvatarUploadId;
  final String? gravatarAvatarTemplate;
  final String? systemAvatarTemplate;

  final bool canEditName;
  final bool canEditUsername;

  /// False where the forum's own sign-in (DiscourseConnect) writes these;
  /// Discourse then ignores what is sent (UserUpdater#update).
  final bool canChangeBio;
  final bool canChangeLocation;
  final bool canChangeWebsite;
  final bool canUploadProfileHeader;
  final bool canUploadCardBackground;

  final String? bioRaw;
  final String? bioCooked;
  final String? location;
  final String? website;
  final String? title;
  final int? flairGroupId;
  final int? primaryGroupId;
  final List<DiscourseProfileGroup> groups;

  /// The forum's profile fields, by field id. A text or dropdown field's
  /// value is a string, a multiselect's a list, a confirm field's a bool.
  final Map<int, Object?> userFields;
  final String? timezone;
  final bool hideProfile;

  /// Month and day only; cakeday stores the year as 1904.
  final DateTime? birthday;
  final int? featuredTopicId;
  final String? featuredTopicTitle;
  final String? profileBackgroundUrl;
  final String? cardBackgroundUrl;
  final DiscourseUserStatus? status;
  final bool hasTitleBadges;
  final DateTime? createdAt;

  /// Which picture is in use, as Discourse decides it (User#avatar_template:
  /// the uploaded id names the custom or gravatar upload, none = letter).
  DiscourseAvatarKind get avatarKind {
    final id = uploadedAvatarId;
    if (id == null) return DiscourseAvatarKind.letter;
    if (id == gravatarAvatarUploadId) return DiscourseAvatarKind.gravatar;
    if (id == customAvatarUploadId) return DiscourseAvatarKind.uploaded;
    return DiscourseAvatarKind.forum;
  }

  DiscourseProfileGroup? groupById(int? id) {
    if (id == null) return null;
    for (final g in groups) {
      if (g.id == id) return g;
    }
    return null;
  }

  DiscourseProfileGroup? get flairGroup => groupById(flairGroupId);
  DiscourseProfileGroup? get primaryGroup => groupById(primaryGroupId);

  /// Groups whose flair can be worn.
  List<DiscourseProfileGroup> get flairGroups =>
      groups.where((g) => g.hasFlair).toList(growable: false);

  /// Groups that can be the primary group: not Discourse's own.
  List<DiscourseProfileGroup> get primaryGroupChoices =>
      groups.where((g) => !g.automatic).toList(growable: false);

  /// An avatar template at [size] px, absolute.
  static String? avatarUrl(String siteUrl, String? template, int size) {
    if (template == null || template.isEmpty) return null;
    return absoluteSiteUrl(siteUrl, template.replaceAll('{size}', '$size'));
  }

  factory DiscourseEditableProfile.fromUserJson(Map<String, dynamic> user,
      {required String siteUrl}) {
    String? text(Object? v) {
      final s = v?.toString().trim();
      return s == null || s.isEmpty ? null : s;
    }

    String? url(Object? v) {
      final s = text(v);
      return s == null ? null : absoluteSiteUrl(siteUrl, s);
    }

    int? integer(Object? v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '');

    final option = (user['user_option'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final fields = <int, Object?>{};
    final rawFields = user['user_fields'];
    if (rawFields is Map) {
      rawFields.forEach((k, v) {
        final id = int.tryParse(k.toString());
        if (id != null) fields[id] = v;
      });
    }
    final featured = (user['featured_topic'] as Map?)?.cast<String, dynamic>();
    final birthdate = DateTime.tryParse(user['birthdate']?.toString() ??
        user['date_of_birth']?.toString() ??
        '');
    return DiscourseEditableProfile(
      id: integer(user['id']) ?? 0,
      username: user['username']?.toString() ?? '',
      name: text(user['name']),
      avatarTemplate: text(user['avatar_template']),
      uploadedAvatarId: integer(user['uploaded_avatar_id']),
      customAvatarUploadId: integer(user['custom_avatar_upload_id']),
      customAvatarTemplate: text(user['custom_avatar_template']),
      gravatarAvatarUploadId: integer(user['gravatar_avatar_upload_id']),
      gravatarAvatarTemplate: text(user['gravatar_avatar_template']),
      systemAvatarTemplate: text(user['system_avatar_template']),
      canEditName: user['can_edit_name'] == true,
      canEditUsername: user['can_edit_username'] == true,
      // Absent (an older server) means "no override": the flags only
      // exist to say a forum's sign-in owns the field.
      canChangeBio: user['can_change_bio'] != false,
      canChangeLocation: user['can_change_location'] != false,
      canChangeWebsite: user['can_change_website'] != false,
      canUploadProfileHeader: user['can_upload_profile_header'] == true,
      canUploadCardBackground: user['can_upload_user_card_background'] == true,
      bioRaw: user['bio_raw']?.toString(),
      bioCooked: text(user['bio_cooked']),
      location: text(user['location']),
      website: text(user['website']),
      title: text(user['title']),
      flairGroupId: integer(user['flair_group_id']),
      primaryGroupId: integer(user['primary_group_id']),
      groups: ((user['groups'] as List?) ?? const [])
          .whereType<Map>()
          .map((g) => DiscourseProfileGroup.fromJson(g.cast<String, dynamic>(),
              siteUrl: siteUrl))
          .whereType<DiscourseProfileGroup>()
          .toList(growable: false),
      userFields: fields,
      timezone: text(option['timezone'] ?? user['timezone']),
      hideProfile: option['hide_profile'] == true,
      birthday: birthdate == null
          ? null
          : DateTime(1904, birthdate.month, birthdate.day),
      featuredTopicId: integer(featured?['id']),
      featuredTopicTitle: text(featured?['fancy_title'] ?? featured?['title']),
      profileBackgroundUrl: url(user['profile_background_upload_url']),
      cardBackgroundUrl: url(user['card_background_upload_url']),
      status: DiscourseUserStatus.fromJson(user['status']),
      hasTitleBadges: user['has_title_badges'] == true,
      createdAt: DateTime.tryParse(user['created_at']?.toString() ?? ''),
    );
  }
}

/// A title a member may wear: a badge they earned that grants one, or a
/// group they are in that has one.
class DiscourseTitleOption {
  const DiscourseTitleOption({
    required this.title,
    this.badgeName,
    this.groupName,
    this.grantedAt,
  });

  /// The text written to `title` — the badge's display name or the
  /// group's title, which is what Guardian#can_grant_title? accepts.
  final String title;
  final String? badgeName;
  final String? groupName;
  final DateTime? grantedAt;

  bool get fromBadge => badgeName != null;
}

/// A badge someone chose to feature (`featured_user_badges`, sideloaded as
/// `badges` on the user card).
class DiscourseFeaturedBadge {
  const DiscourseFeaturedBadge({
    required this.id,
    required this.name,
    this.badgeTypeId,
    this.icon,
    this.imageUrl,
  });

  final int id;
  final String name;

  /// 1 gold, 2 silver, 3 bronze (BadgeType).
  final int? badgeTypeId;
  final String? icon;
  final String? imageUrl;
}

/// What the user card shows (`/u/{username}/card.json`, UserCardSerializer,
/// or HiddenProfileSerializer when the person hides their profile).
class DiscourseUserCard {
  const DiscourseUserCard({
    required this.id,
    required this.username,
    this.name,
    this.avatarTemplate,
    this.title,
    this.profileHidden = false,
    this.cardBackgroundUrl,
    this.flairName,
    this.flairUrl,
    this.flairBgColor,
    this.flairColor,
    this.primaryGroupName,
    this.status,
    this.bioExcerptHtml,
    this.location,
    this.website,
    this.websiteName,
    this.timezone,
    this.fields = const [],
    this.badges = const [],
    this.createdAt,
    this.lastPostedAt,
    this.lastSeenAt,
    this.topicPostCount,
    this.canSendPrivateMessage = false,
    this.canChat = false,
    this.canMute = false,
    this.canIgnore = false,
    this.muted = false,
    this.ignored = false,
    this.suspended = false,
  });

  final int id;
  final String username;
  final String? name;
  final String? avatarTemplate;
  final String? title;

  /// The person hides their profile: the card carries only who they are.
  final bool profileHidden;
  final String? cardBackgroundUrl;
  final String? flairName;
  final String? flairUrl;
  final String? flairBgColor;
  final String? flairColor;
  final String? primaryGroupName;
  final DiscourseUserStatus? status;

  /// Up to 350 characters of the cooked bio, links kept.
  final String? bioExcerptHtml;
  final String? location;
  final String? website;
  final String? websiteName;

  /// Present only where the forum shows local time on cards.
  final String? timezone;

  /// The forum's profile fields marked to show on the card, with values.
  final List<({String name, String value})> fields;
  final List<DiscourseFeaturedBadge> badges;
  final DateTime? createdAt;
  final DateTime? lastPostedAt;
  final DateTime? lastSeenAt;

  /// Their posts in the topic the card was opened from.
  final int? topicPostCount;
  final bool canSendPrivateMessage;
  final bool canChat;
  final bool canMute;
  final bool canIgnore;
  final bool muted;
  final bool ignored;
  final bool suspended;

  bool get hasFlair => flairUrl != null && flairUrl!.isNotEmpty;

  factory DiscourseUserCard.fromJson(Map<String, dynamic> body,
      {required String siteUrl,
      List<DiscourseUserFieldDef> fieldDefs = const [],
      int? topicId}) {
    final user = (body['user'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    String? text(Object? v) {
      final s = v?.toString().trim();
      return s == null || s.isEmpty ? null : s;
    }

    String? url(Object? v) {
      final s = text(v);
      return s == null ? null : absoluteSiteUrl(siteUrl, s);
    }

    int? integer(Object? v) =>
        v is num ? v.toInt() : int.tryParse(v?.toString() ?? '');
    DateTime? time(Object? v) => DateTime.tryParse(v?.toString() ?? '');

    // featured_user_badges embeds ids; `user_badges` and `badges` are
    // sideloaded beside the user.
    final badgesById = <int, Map<String, dynamic>>{
      for (final b in ((body['badges'] as List?) ?? const []).whereType<Map>())
        if (integer(b['id']) != null)
          integer(b['id'])!: b.cast<String, dynamic>(),
    };
    final badges = <DiscourseFeaturedBadge>[];
    for (final ub
        in ((body['user_badges'] as List?) ?? const []).whereType<Map>()) {
      final b = badgesById[integer(ub['badge_id'])];
      if (b == null) continue;
      final name = text(b['name']);
      if (name == null) continue;
      badges.add(DiscourseFeaturedBadge(
        id: integer(b['id'])!,
        name: name,
        badgeTypeId: integer(b['badge_type_id']),
        icon: text(b['icon']),
        imageUrl: url(b['image_url'] ?? b['image']),
      ));
    }

    final fields = <({String name, String value})>[];
    final rawFields = user['user_fields'];
    if (rawFields is Map) {
      for (final def in fieldDefs) {
        if (!def.showOnUserCard) continue;
        final value =
            DiscourseUserFieldDef.display(def, rawFields['${def.id}']);
        if (value != null) fields.add((name: def.name, value: value));
      }
    }
    final flair = text(user['flair_url']);
    return DiscourseUserCard(
      id: integer(user['id']) ?? 0,
      username: user['username']?.toString() ?? '',
      name: text(user['name']),
      avatarTemplate: text(user['avatar_template']),
      title: text(user['title']),
      profileHidden: user['profile_hidden'] == true,
      cardBackgroundUrl: url(user['card_background_upload_url']),
      flairName: text(user['flair_name']),
      flairUrl: flair == null
          ? null
          : (flair.contains('/') ? absoluteSiteUrl(siteUrl, flair) : flair),
      flairBgColor: text(user['flair_bg_color'])?.replaceFirst('#', ''),
      flairColor: text(user['flair_color'])?.replaceFirst('#', ''),
      primaryGroupName: text(user['primary_group_name']),
      status: DiscourseUserStatus.fromJson(user['status']),
      bioExcerptHtml: text(user['bio_excerpt']),
      location: text(user['location']),
      website: text(user['website']),
      websiteName: text(user['website_name']),
      timezone: text(user['timezone']),
      fields: fields,
      badges: badges,
      createdAt: time(user['created_at']),
      lastPostedAt: time(user['last_posted_at']),
      lastSeenAt: time(user['last_seen_at']),
      // `{"98": 12}`: keyed by the topic asked about.
      topicPostCount: switch (user['topic_post_count']) {
        final Map m when topicId != null => integer(m['$topicId']),
        final Map m => m.values.map(integer).whereType<int>().firstOrNull,
        final v => integer(v),
      },
      canSendPrivateMessage: user['can_send_private_message_to_user'] == true,
      canChat: user['can_chat_user'] == true,
      canMute: user['can_mute_user'] == true,
      canIgnore: user['can_ignore_user'] == true,
      muted: user['muted'] == true,
      ignored: user['ignored'] == true,
      suspended: user['suspended_till'] != null,
    );
  }
}
