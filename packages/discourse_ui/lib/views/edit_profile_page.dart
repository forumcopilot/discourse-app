import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../l10n/generated/app_localizations.dart';
import '../theme/design_tokens.dart';
import '../utils/app_navigation.dart';
import '../utils/error_message.dart';
import '../utils/local_dates.dart';
import '../utils/snackbar_helper.dart';
import 'profile/profile_common.dart';
import 'profile/profile_pickers.dart';
import 'profile/profile_text_editors.dart';
import 'settings_page.dart';
import 'user_profile_page.dart';
import 'widgets/cached_redirect_image.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/section_header.dart';
import 'widgets/simple_list_app_bar.dart';
import 'widgets/user_avatar.dart';

/// Edit profile: everything about you the forum lets you change, as a short
/// overview in groups. Each row shows what is set; tapping it changes just
/// that, and the change is saved when it is made — a one-line text in a
/// dialog, About me and the forum's questions on a page of their own, a
/// choice in a sheet (with Undo), a switch when flipped. There is no
/// page-wide Save, so there is no long form to lose.
///
/// What the forum does not allow is left out: the display name where it has
/// no names, titles where none were earned, the primary group unless members
/// choose it, and so on. Fields the forum's own sign-in owns
/// (DiscourseConnect: `can_change_bio` and friends) show a lock — Discourse
/// ignores what is sent for them, and the old form claimed it saved.
///
/// Callers refresh what they show when this page closes.
class EditProfilePage extends StatefulWidget {
  final SiteContext siteContext;

  /// What the caller already shows, for the first frame.
  final FCUserInfoResult userInfo;

  /// For tests.
  final DiscourseProfileProxy? proxy;

  const EditProfilePage({
    super.key,
    required this.siteContext,
    required this.userInfo,
    this.proxy,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final DiscourseProfileProxy _proxy =
      widget.proxy ?? DiscourseProfileProxy(widget.siteContext);

  DiscourseEditableProfile? _profile;
  DiscourseProfileSettings _settings = const DiscourseProfileSettings();
  List<DiscourseUserFieldDef> _fields = const [];
  Object? _error;

  /// Which photo is uploading: 'cover', 'card' or 'avatar'.
  String? _uploading;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final rules = await _proxy.forumRules();
      final profile = await _proxy.loadMine();
      if (!mounted) return;
      setState(() {
        _settings = rules.settings;
        _fields = rules.fields;
        _profile = profile;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// Saves one change, shows the profile the forum answers with, and says
  /// so — with Undo when [undo] can put it back.
  Future<bool> _save(
    Future<DiscourseEditableProfile?> Function() write, {
    String? done,
    Future<DiscourseEditableProfile?> Function()? undo,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final updated = await write();
      if (!mounted) return false;
      setState(() => _profile = updated ?? _profile);
      if (done != null) {
        // Timed even with Undo: the change is already saved, and an Undo
        // that stays until tapped would hold the next message back.
        SnackbarHelper.showInfo(
          context,
          done,
          persist: false,
          action: undo == null
              ? null
              : SnackBarAction(
                  label: l10n.undo,
                  onPressed: () => _save(undo),
                ),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
            context, describeError(e, fallback: l10n.profileSaveFailed));
      }
      return false;
    }
  }

  // ===== Photos =====

  Future<void> _changePicture() async {
    final profile = _profile!;
    final changed = await changeProfilePicture(
      context: context,
      siteContext: widget.siteContext,
      profile: profile,
      settings: _settings,
      proxy: _proxy,
      onUploading: (busy) {
        if (mounted) setState(() => _uploading = busy ? 'avatar' : null);
      },
    );
    if (changed && mounted) {
      await refreshSessionAvatar(widget.siteContext);
      final fresh = await _proxy.loadMine().catchError((_) => profile);
      if (mounted) setState(() => _profile = fresh);
    }
  }

  Future<void> _changeBackground({required bool card}) async {
    final l10n = AppLocalizations.of(context)!;
    final profile = _profile!;
    final current =
        card ? profile.cardBackgroundUrl : profile.profileBackgroundUrl;
    final choice = await showBackgroundImageSheet(
      context: context,
      card: card,
      currentUrl: current,
      profile: profile,
      siteUrl: widget.siteContext.site.url,
    );
    if (choice == null || !mounted) return;
    if (choice.remove) {
      await _save(() => _proxy.clearBackgroundImage(card: card),
          done: card ? l10n.cardBackgroundRemoved : l10n.coverRemoved,
          undo: current == null
              ? null
              : () => _proxy.update({
                    card
                        ? 'card_background_upload_url'
                        : 'profile_background_upload_url': current,
                  }));
      return;
    }
    final photo = choice.photo;
    if (photo == null) return;
    setState(() => _uploading = card ? 'card' : 'cover');
    await _save(() => _proxy.setBackgroundImage(
        card: card, imageExtension: photo.extension, bytes: photo.bytes));
    if (mounted) setState(() => _uploading = null);
  }

  // ===== Text =====

  Future<void> _editLine({
    required String title,
    required String key,
    required String? value,
    String? helper,
    TextInputType? keyboardType,
    int? maxLength,
    bool required = false,
  }) async {
    await showProfileTextDialog(
      context: context,
      title: title,
      initialValue: value ?? '',
      helper: helper,
      keyboardType: keyboardType,
      maxLength: maxLength,
      required: required,
      onSave: (text) => _save(() => _proxy.update({key: text})),
    );
  }

  Future<void> _editAbout() async {
    final profile = _profile!;
    await AppNavigation.pushForm<void>(
      context,
      AboutMePage(
        initialValue: profile.bioRaw ?? '',
        onSave: (text) => _save(() => _proxy.update({'bio_raw': text})),
      ),
    );
  }

  Future<void> _editForumQuestions() async {
    final profile = _profile!;
    await AppNavigation.pushForm<void>(
      context,
      ForumQuestionsPage(
        fields: _fields,
        values: profile.userFields,
        onSave: (values) => _save(() => _proxy.updateUserFields(values)),
      ),
    );
  }

  Future<void> _changeUsername() async {
    final l10n = AppLocalizations.of(context)!;
    final profile = _profile!;
    if (!profile.canEditUsername) {
      SnackbarHelper.showInfo(context, l10n.usernameLockedExplanation);
      return;
    }
    final changed = await showChangeUsernameDialog(
      context: context,
      currentUsername: profile.username,
      proxy: _proxy,
    );
    if (changed == null || !mounted) return;
    await _save(() => _proxy.loadMine(), done: l10n.usernameChanged(changed));
  }

  // ===== Choices =====

  Future<void> _changeTitle() async {
    final l10n = AppLocalizations.of(context)!;
    final profile = _profile!;
    final picked = await showTitleSheet(
        context: context, profile: profile, proxy: _proxy);
    if (picked == null || picked == (profile.title ?? '') || !mounted) return;
    final previous = profile.title ?? '';
    await _save(() => _proxy.update({'title': picked}),
        done: picked.isEmpty ? l10n.titleRemoved : l10n.titleChangedTo(picked),
        undo: () => _proxy.update({'title': previous}));
  }

  Future<void> _changeFlair() async {
    final l10n = AppLocalizations.of(context)!;
    final profile = _profile!;
    final picked = await showFlairSheet(
        context: context,
        profile: profile,
        siteUrl: widget.siteContext.site.url);
    if (picked == null || !mounted) return;
    final newId = picked.groupId;
    if (newId == profile.flairGroupId) return;
    final previous = profile.flairGroupId;
    await _save(() => _proxy.update({'flair_group_id': newId ?? ''}),
        done: newId == null
            ? l10n.flairRemoved
            : l10n.flairChangedTo(profile.groupById(newId)?.displayName ?? ''),
        undo: () => _proxy.update({'flair_group_id': previous ?? ''}));
  }

  Future<void> _changePrimaryGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final profile = _profile!;
    final picked =
        await showPrimaryGroupSheet(context: context, profile: profile);
    if (picked == null || !mounted) return;
    final newId = picked.groupId;
    if (newId == profile.primaryGroupId) return;
    final previous = profile.primaryGroupId;
    await _save(() => _proxy.update({'primary_group_id': newId ?? ''}),
        done: newId == null
            ? l10n.primaryGroupRemoved
            : l10n.primaryGroupChangedTo(
                profile.groupById(newId)?.displayName ?? ''),
        undo: () => _proxy.update({'primary_group_id': previous ?? ''}));
  }

  Future<void> _changeFeaturedTopic() async {
    final l10n = AppLocalizations.of(context)!;
    final profile = _profile!;
    final picked = await showFeaturedTopicSheet(
        context: context, profile: profile, proxy: _proxy);
    if (picked == null || !mounted) return;
    final previous = profile.featuredTopicId;
    if (picked.topicId == previous) return;
    await _save(
      () async {
        final id = picked.topicId;
        if (id == null) {
          await _proxy.clearFeaturedTopic();
        } else {
          await _proxy.featureTopic(id);
        }
        return _proxy.loadMine();
      },
      done: picked.topicId == null
          ? l10n.featuredTopicRemoved
          : l10n.featuredTopicChanged,
      undo: () async {
        if (previous == null) {
          await _proxy.clearFeaturedTopic();
        } else {
          await _proxy.featureTopic(previous);
        }
        return _proxy.loadMine();
      },
    );
  }

  Future<void> _changeTimezone() async {
    final l10n = AppLocalizations.of(context)!;
    final profile = _profile!;
    final picked =
        await showTimezoneSheet(context: context, current: profile.timezone);
    if (picked == null || picked == profile.timezone || !mounted) return;
    final previous = profile.timezone;
    await _save(() => _proxy.update({'timezone': picked}),
        done: l10n.timezoneChangedTo(picked),
        undo: previous == null
            ? null
            : () => _proxy.update({'timezone': previous}));
  }

  Future<void> _changeBirthday() async {
    final l10n = AppLocalizations.of(context)!;
    final profile = _profile!;
    final picked =
        await showBirthdayPicker(context: context, current: profile.birthday);
    if (picked == null || !mounted) return;
    final day = picked.day;
    if (day == profile.birthday) return;
    await _save(() => _proxy.setBirthday(day),
        done: day == null ? l10n.birthdayRemoved : l10n.birthdaySaved);
  }

  Future<void> _setHideProfile(bool hide) async {
    final l10n = AppLocalizations.of(context)!;
    await _save(() => _proxy.update({'hide_profile': hide}),
        done: hide ? l10n.profileNowHidden : l10n.profileNowPublic,
        undo: () => _proxy.update({'hide_profile': !hide}));
  }

  // ===== Build =====

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = _profile;
    return Scaffold(
      appBar: SimpleListAppBar(
        title: l10n.editProfile,
        actions: [
          IconButton(
            tooltip: l10n.seeProfileAsOthersDo,
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () => AppNavigation.push<void>(
              context,
              UserProfilePage(
                siteContext: widget.siteContext,
                userName: profile?.username ?? widget.userInfo.username,
              ),
            ),
          ),
        ],
      ),
      body: profile == null
          ? (_error == null
              ? const Center(child: CircularProgressIndicator())
              : EmptyStateView.error(
                  message: l10n.profileLoadFailed,
                  hint: describeError(_error),
                  onRetry: _load,
                ))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.only(bottom: DesignTokens.spacingXL),
                children: _rows(context, profile),
              ),
            ),
    );
  }

  List<Widget> _rows(BuildContext context, DiscourseEditableProfile p) {
    final l10n = AppLocalizations.of(context)!;
    final s = _settings;
    final canBackgrounds = s.allowProfileBackgrounds;
    final titled = p.title != null ||
        p.hasTitleBadges ||
        p.groups.any((g) => g.title != null);
    final answered = [
      for (final f in _fields)
        if (DiscourseUserFieldDef.display(f, p.userFields[f.id]) != null) f,
    ];
    final missing = _fields
        .where((f) =>
            f.required &&
            f.editable &&
            DiscourseUserFieldDef.display(f, p.userFields[f.id]) == null)
        .toList();
    final zone = timeZoneNamed(p.timezone);
    final locale = Localizations.localeOf(context).toString();

    return [
      _PhotosHeader(
        profile: p,
        siteUrl: widget.siteContext.site.url,
        canChangeCover: canBackgrounds && p.canUploadProfileHeader,
        pictureManaged: s.avatarManagedBySignIn,
        uploading: _uploading,
        onChangeCover: () => _changeBackground(card: false),
        onChangePicture: _changePicture,
      ),
      if (canBackgrounds && p.canUploadCardBackground)
        _ProfileRow(
          label: l10n.cardBackground,
          subtitle: l10n.cardBackgroundExplanation,
          leading: _CardThumb(url: p.cardBackgroundUrl),
          busy: _uploading == 'card',
          onTap: () => _changeBackground(card: true),
        ),
      SectionHeader(l10n.profileSectionNameAndAbout),
      _ProfileRow(
        label: l10n.username,
        value: '@${p.username}',
        locked: !p.canEditUsername,
        onTap: _changeUsername,
      ),
      if (s.enableNames)
        _ProfileRow(
          label: l10n.displayName,
          value: p.name ?? l10n.notSet,
          locked: !p.canEditName,
          onTap: p.canEditName
              ? () => _editLine(
                    title: l10n.displayName,
                    key: 'name',
                    value: p.name,
                    helper: l10n.displayNameHelper(p.username),
                    maxLength: 255,
                  )
              : null,
        ),
      _ProfileRow(
        label: l10n.aboutMe,
        subtitle: _bioPreview(p) ?? l10n.notSet,
        locked: !p.canChangeBio,
        onTap: p.canChangeBio ? _editAbout : null,
      ),
      _ProfileRow(
        label: l10n.location,
        value: p.location ?? l10n.notSet,
        locked: !p.canChangeLocation,
        onTap: p.canChangeLocation
            ? () => _editLine(
                  title: l10n.location,
                  key: 'location',
                  value: p.location,
                  maxLength: 100,
                )
            : null,
      ),
      _ProfileRow(
        label: l10n.website,
        value: p.website == null ? l10n.notSet : _shortUrl(p.website!),
        locked: !p.canChangeWebsite,
        onTap: p.canChangeWebsite
            ? () => _editLine(
                  title: l10n.website,
                  key: 'website',
                  value: p.website,
                  keyboardType: TextInputType.url,
                  maxLength: 255,
                )
            : null,
      ),
      if (titled || p.flairGroups.isNotEmpty ||
          (s.userSelectedPrimaryGroups && p.primaryGroupChoices.isNotEmpty))
        SectionHeader(l10n.profileSectionNextToName),
      if (titled)
        _ProfileRow(
          label: l10n.title,
          value: p.title ?? l10n.noTitle,
          onTap: _changeTitle,
        ),
      if (p.flairGroups.isNotEmpty || p.flairGroupId != null)
        _ProfileRow(
          label: l10n.flair,
          value: p.flairGroup?.displayName ?? l10n.noFlair,
          valueLeading: p.flairGroup == null
              ? null
              : UserFlairBadge(
                  flairUrl: p.flairGroup!.flairUrl!,
                  bgHex: p.flairGroup!.flairBgColor,
                  fgHex: p.flairGroup!.flairColor,
                  size: 20,
                ),
          onTap: _changeFlair,
        ),
      if (s.userSelectedPrimaryGroups && p.primaryGroupChoices.isNotEmpty)
        _ProfileRow(
          label: l10n.primaryGroup,
          value: p.primaryGroup?.displayName ?? l10n.none,
          onTap: _changePrimaryGroup,
        ),
      if (s.allowFeaturedTopic || _fields.isNotEmpty)
        SectionHeader(l10n.profileSectionOnProfile),
      if (s.allowFeaturedTopic)
        _ProfileRow(
          label: l10n.featuredTopic,
          subtitle: p.featuredTopicTitle ?? l10n.featuredTopicNone,
          onTap: _changeFeaturedTopic,
        ),
      if (_fields.isNotEmpty)
        _ProfileRow(
          label: l10n.moreAboutYou,
          subtitle: missing.isNotEmpty
              ? l10n.forumQuestionNeedsAnswer(missing.first.name)
              : (answered.isEmpty
                  ? l10n.forumQuestionsNoneAnswered
                  : _namesSummary(l10n, answered.map((f) => f.name).toList())),
          subtitleIsError: missing.isNotEmpty,
          onTap: _editForumQuestions,
        ),
      SectionHeader(l10n.profileSectionPrivacyAndTime),
      _ProfileRow(
        label: l10n.timezone,
        subtitle: p.timezone == null
            ? l10n.notSet
            : (zone == null
                ? p.timezone!
                : l10n.timezoneWithTime(p.timezone!,
                    DateFormat.jm(locale).format(tz.TZDateTime.now(zone)))),
        onTap: _changeTimezone,
      ),
      if (s.birthdaysEnabled)
        _ProfileRow(
          label: l10n.birthday,
          value: p.birthday == null
              ? l10n.notSet
              : DateFormat.MMMMd(locale).format(p.birthday!),
          onTap: _changeBirthday,
        ),
      if (s.allowUsersToHideProfile)
        SwitchListTile(
          title: Text(l10n.hideMyProfile),
          subtitle: Text(l10n.hideMyProfileExplanation),
          value: p.hideProfile,
          onChanged: _setHideProfile,
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
            DesignTokens.spacingL, DesignTokens.spacingL, 0),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => AppNavigation.push<void>(
              context,
              ForumSettingsPage(siteContext: widget.siteContext),
            ),
            icon: const Icon(Icons.manage_accounts_outlined),
            label: Text(l10n.emailPasswordInAccount),
          ),
        ),
      ),
    ];
  }

  String? _bioPreview(DiscourseEditableProfile p) {
    final cooked = p.bioCooked;
    final text = cooked != null ? stripHtmlToText(cooked) : p.bioRaw;
    final t = text?.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t == null || t.isEmpty ? null : t;
  }

  String _shortUrl(String url) =>
      url.replaceFirst(RegExp(r'^https?://(www\.)?'), '').replaceFirst(RegExp(r'/$'), '');

  String _namesSummary(AppLocalizations l10n, List<String> names) {
    if (names.length <= 3) return names.join(', ');
    return l10n.namesAndMore(names.take(3).join(', '), names.length - 3);
  }
}

/// The cover with the picture over its edge, as the profile shows them,
/// each with its own way to change it.
class _PhotosHeader extends StatelessWidget {
  const _PhotosHeader({
    required this.profile,
    required this.siteUrl,
    required this.canChangeCover,
    required this.pictureManaged,
    required this.uploading,
    required this.onChangeCover,
    required this.onChangePicture,
  });

  final DiscourseEditableProfile profile;
  final String siteUrl;
  final bool canChangeCover;
  final bool pictureManaged;
  final String? uploading;
  final VoidCallback onChangeCover;
  final VoidCallback onChangePicture;

  static const double _coverHeight = 120;
  static const double _avatarRadius = 40;
  static const double _ring = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final cover = profile.profileBackgroundUrl;
    final avatarBox = (_avatarRadius + _ring) * 2;
    final avatarUrl = DiscourseEditableProfile.avatarUrl(
        siteUrl, profile.avatarTemplate, 240);
    Widget spinnerOver(double size) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.5),
            shape: size == avatarBox - _ring * 2
                ? BoxShape.circle
                : BoxShape.rectangle,
          ),
          alignment: Alignment.center,
          child: const SizedBox(
            width: DesignTokens.iconSizeL,
            height: DesignTokens.iconSizeL,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          DesignTokens.spacingL, DesignTokens.spacingS, DesignTokens.spacingL, 0),
      child: SizedBox(
        height: _coverHeight + avatarBox / 2 + DesignTokens.spacingS,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: _coverHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    cover == null
                        ? ColoredBox(color: colorScheme.surfaceContainerHigh)
                        : CachedRedirectImage(
                            imageUrl: cover,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => ColoredBox(
                                color: colorScheme.surfaceContainerHigh),
                            errorWidget: (_, __, ___) => ColoredBox(
                                color: colorScheme.surfaceContainerHigh),
                          ),
                    if (uploading == 'cover')
                      Center(child: spinnerOver(double.infinity)),
                  ],
                ),
              ),
            ),
            if (canChangeCover)
              PositionedDirectional(
                end: DesignTokens.spacingS,
                top: DesignTokens.spacingS,
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.onSurface,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: uploading == null ? onChangeCover : null,
                  icon: const Icon(Icons.photo_camera_outlined,
                      size: DesignTokens.iconSizeSMedium),
                  label: Text(cover == null ? l10n.addCover : l10n.changeCover),
                ),
              ),
            PositionedDirectional(
              start: DesignTokens.spacingM - _ring,
              top: _coverHeight - avatarBox / 2,
              child: Container(
                padding: const EdgeInsets.all(_ring),
                decoration: BoxDecoration(
                    color: colorScheme.surface, shape: BoxShape.circle),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    UserAvatar(
                      username: profile.username,
                      iconUrl: avatarUrl,
                      radius: _avatarRadius,
                    ),
                    if (uploading == 'avatar')
                      spinnerOver(avatarBox - _ring * 2),
                    Positioned(
                      right: -6,
                      bottom: -6,
                      child: pictureManaged
                          ? Tooltip(
                              message: l10n.pictureManagedBySignIn,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: colorScheme.surface, width: 2),
                                ),
                                child: Icon(Icons.lock_outline,
                                    size: DesignTokens.iconSizeS,
                                    color: colorScheme.onSurfaceVariant),
                              ),
                            )
                          : IconButton.filled(
                              tooltip: l10n.changeProfilePicture,
                              onPressed:
                                  uploading == null ? onChangePicture : null,
                              icon: const Icon(Icons.photo_camera_outlined,
                                  size: DesignTokens.iconSizeSMedium),
                              style: IconButton.styleFrom(
                                side: BorderSide(
                                    color: colorScheme.surface, width: 2),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The card background's thumbnail in its row.
class _CardThumb extends StatelessWidget {
  const _CardThumb({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
      child: SizedBox(
        width: 56,
        height: 36,
        child: url == null
            ? ColoredBox(
                color: colorScheme.surfaceContainerHigh,
                child: Icon(Icons.add_photo_alternate_outlined,
                    size: DesignTokens.iconSizeM,
                    color: colorScheme.onSurfaceVariant),
              )
            : CachedRedirectImage(imageUrl: url!, fit: BoxFit.cover),
      ),
    );
  }
}

/// One row of the overview: a label, what is set (on the line, or under it
/// when it is long text), and a chevron — or a lock where the forum does not
/// let it change.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    this.value,
    this.valueLeading,
    this.subtitle,
    this.subtitleIsError = false,
    this.leading,
    this.locked = false,
    this.busy = false,
    this.onTap,
  });

  final String label;
  final String? value;
  final Widget? valueLeading;
  final String? subtitle;
  final bool subtitleIsError;
  final Widget? leading;
  final bool locked;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final muted =
        textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant);
    final Widget trailing = busy
        ? const SizedBox(
            width: DesignTokens.iconSizeM,
            height: DesignTokens.iconSizeM,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : locked
            ? Icon(Icons.lock_outline,
                size: DesignTokens.iconSizeM,
                color: colorScheme.onSurfaceVariant,
                semanticLabel: l10n.locked)
            : Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant);
    // A locked row still answers a tap: it says why it is locked.
    final VoidCallback? tap = busy
        ? null
        : (onTap ??
            (locked
                ? () => SnackbarHelper.showInfo(
                    context, l10n.fieldManagedBySignIn)
                : null));
    return MergeSemantics(
      child: InkWell(
        onTap: tap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: subtitle == null ? 56 : 72),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(DesignTokens.spacingL,
                DesignTokens.spacingS, DesignTokens.spacingM, DesignTokens.spacingS),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: DesignTokens.spacingL),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: textTheme.bodyLarge),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: subtitleIsError
                              ? muted?.copyWith(color: colorScheme.error)
                              : muted,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (value != null) ...[
                  const SizedBox(width: DesignTokens.spacingL),
                  if (valueLeading != null) ...[
                    valueLeading!,
                    const SizedBox(width: DesignTokens.spacingS),
                  ],
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.45),
                    child: Text(value!,
                        style: muted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end),
                  ),
                ],
                const SizedBox(width: DesignTokens.spacingS),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
