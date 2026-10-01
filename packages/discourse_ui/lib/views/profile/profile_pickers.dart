import 'dart:async';

import 'package:discourse_core/discourse_core.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../utils/app_navigation.dart';
import '../../utils/error_message.dart';
import '../../utils/local_dates.dart';
import '../../utils/snackbar_helper.dart';
import '../widgets/cached_redirect_image.dart';
import '../widgets/sheet_title.dart';
import '../widgets/user_avatar.dart';
import 'profile_common.dart';

/// A group picked in a sheet; a null id is "none".
class GroupChoice {
  const GroupChoice(this.groupId);
  final int? groupId;
}

/// A topic picked to feature; a null id clears it.
class FeaturedTopicChoice {
  const FeaturedTopicChoice(this.topicId);
  final int? topicId;
}

/// A birthday picked; null removes it.
class BirthdayChoice {
  const BirthdayChoice(this.day);
  final DateTime? day;
}

/// A new cover or card background, or its removal.
class BackgroundChoice {
  const BackgroundChoice({this.photo, this.remove = false});
  final PickedPhoto? photo;
  final bool remove;
}

// ===== Profile picture =====

sealed class _PictureChoice {
  const _PictureChoice();
}

class _UploadPicture extends _PictureChoice {
  const _UploadPicture(this.source);
  final ImageSource source;
}

class _PickPicture extends _PictureChoice {
  const _PickPicture(this.kind);
  final DiscourseAvatarKind kind;
}

class _ForumPicture extends _PictureChoice {
  const _ForumPicture(this.url);
  final String url;
}

/// The profile picture sheet: take or choose a photo, or use the letter
/// avatar, the Gravatar, an earlier upload or one of the forum's own
/// pictures — whichever the forum allows. Makes the change and says so.
/// True when the picture changed.
///
/// [profile] and [settings] are loaded here when the caller has none (the
/// Profile tab's camera badge).
Future<bool> changeProfilePicture({
  required BuildContext context,
  required SiteContext siteContext,
  DiscourseEditableProfile? profile,
  DiscourseProfileSettings? settings,
  DiscourseProfileProxy? proxy,
  void Function(bool uploading)? onUploading,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final p = proxy ?? DiscourseProfileProxy(siteContext);
  final canUpload = siteContext.loginDataOutput?.canUploadAvatar ?? false;
  if (profile == null || settings == null) {
    try {
      settings ??= (await p.forumRules()).settings;
      profile ??= await p.loadMine();
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(context, describeError(e));
      }
      return false;
    }
    if (!context.mounted) return false;
  }
  final me = profile;
  final rules = settings;
  if (rules.avatarManagedBySignIn) {
    SnackbarHelper.showInfo(context, l10n.pictureManagedBySignIn);
    return false;
  }
  final siteUrl = siteContext.site.url;
  final current = me.avatarKind;

  final choice = await showProfileSheet<_PictureChoice>(
    context: context,
    title: l10n.profilePicture,
    children: (sheet) {
      final colorScheme = Theme.of(sheet).colorScheme;
      final textTheme = Theme.of(sheet).textTheme;
      Widget label(String text) => Padding(
            padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                DesignTokens.spacingM, DesignTokens.spacingL, DesignTokens.spacingS),
            child: Text(text,
                style: textTheme.titleSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          );
      return [
        if (canUpload) ...[
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.takePhoto),
            onTap: () => Navigator.pop(sheet, const _UploadPicture(ImageSource.camera)),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.chooseFromLibrary),
            onTap: () =>
                Navigator.pop(sheet, const _UploadPicture(ImageSource.gallery)),
          ),
          const Divider(indent: DesignTokens.spacingL, endIndent: DesignTokens.spacingL),
        ],
        label(l10n.orUse),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS),
          child: Row(
            children: [
              if (me.customAvatarUploadId != null)
                Expanded(
                  child: _AvatarOption(
                    label: l10n.yourPhoto,
                    selected: current == DiscourseAvatarKind.uploaded,
                    imageUrl: DiscourseEditableProfile.avatarUrl(
                        siteUrl, me.customAvatarTemplate, 120),
                    username: me.username,
                    onTap: () => Navigator.pop(
                        sheet, const _PickPicture(DiscourseAvatarKind.uploaded)),
                  ),
                ),
              Expanded(
                child: _AvatarOption(
                  label: l10n.letterAvatar,
                  selected: current == DiscourseAvatarKind.letter,
                  imageUrl: DiscourseEditableProfile.avatarUrl(
                      siteUrl, me.systemAvatarTemplate, 120),
                  username: me.username,
                  onTap: () => Navigator.pop(
                      sheet, const _PickPicture(DiscourseAvatarKind.letter)),
                ),
              ),
              if (rules.gravatarEnabled)
                Expanded(
                  child: _AvatarOption(
                    label: rules.gravatarName,
                    selected: current == DiscourseAvatarKind.gravatar,
                    imageUrl: DiscourseEditableProfile.avatarUrl(
                        siteUrl, me.gravatarAvatarTemplate, 120),
                    username: me.username,
                    placeholderIcon: Icons.person_outline,
                    onTap: () => Navigator.pop(
                        sheet, const _PickPicture(DiscourseAvatarKind.gravatar)),
                  ),
                ),
            ],
          ),
        ),
        if (rules.selectableAvatars.isNotEmpty) ...[
          label(l10n.fromThisForum),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
            child: Wrap(
              spacing: DesignTokens.spacingM,
              runSpacing: DesignTokens.spacingM,
              children: [
                for (final (i, url) in rules.selectableAvatars.indexed)
                  Semantics(
                    button: true,
                    label: l10n.forumPictureN(i + 1),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(sheet, _ForumPicture(url)),
                      child: ClipOval(
                        child: CachedRedirectImage(
                          imageUrl: url,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ];
    },
  );
  if (choice == null || !context.mounted) return false;

  try {
    switch (choice) {
      case _UploadPicture(:final source):
        final photo = await pickProfilePhoto(source);
        if (photo == null) return false;
        onUploading?.call(true);
        try {
          final result = await SiteProxyFactory.getAttachmentProxy()
              .uploadAvatarAsync(photo.extension, photo.bytes);
          if (result.result != true) {
            throw Exception(result.resultText ?? l10n.profileSaveFailed);
          }
        } finally {
          onUploading?.call(false);
        }
      case _PickPicture(:final kind):
        if (kind == current) return false;
        switch (kind) {
          case DiscourseAvatarKind.letter:
            await p.pickAvatar(kind);
          case DiscourseAvatarKind.uploaded:
            await p.pickAvatar(kind, uploadId: me.customAvatarUploadId);
          case DiscourseAvatarKind.gravatar:
            final id = me.gravatarAvatarUploadId ?? await p.refreshGravatar();
            if (id == null) {
              if (context.mounted) {
                SnackbarHelper.showInfo(
                    context, l10n.noGravatarFound(rules.gravatarName));
              }
              return false;
            }
            await p.pickAvatar(kind, uploadId: id);
          case DiscourseAvatarKind.forum:
            return false;
        }
      case _ForumPicture(:final url):
        await p.selectForumAvatar(url);
    }
  } catch (e) {
    if (context.mounted) {
      SnackbarHelper.showError(
          context, describeError(e, fallback: l10n.profileSaveFailed));
    }
    return false;
  }
  if (context.mounted) {
    SnackbarHelper.showInfo(context, l10n.profilePictureChanged);
  }
  return true;
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.label,
    required this.selected,
    required this.username,
    required this.onTap,
    this.imageUrl,
    this.placeholderIcon,
  });

  final String label;
  final bool selected;
  final String username;
  final String? imageUrl;
  final IconData? placeholderIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final Widget picture = imageUrl == null && placeholderIcon != null
        ? CircleAvatar(
            radius: 32,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Icon(placeholderIcon,
                size: 32, color: colorScheme.onSurfaceVariant),
          )
        : UserAvatar(username: username, iconUrl: imageUrl, radius: 32);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? colorScheme.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: picture,
                  ),
                  if (selected)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: colorScheme.surfaceContainerLow, width: 2),
                        ),
                        child: Icon(Icons.check,
                            size: DesignTokens.iconSizeS,
                            color: colorScheme.onPrimary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacingS),
              Text(label,
                  style: textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Cover and card background =====

/// The cover or card background sheet: take or choose a photo, or remove
/// the one set. The photo is picked here; the caller uploads it.
Future<BackgroundChoice?> showBackgroundImageSheet({
  required BuildContext context,
  required bool card,
  required String? currentUrl,
  required DiscourseEditableProfile profile,
  required String siteUrl,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final action = await showProfileSheet<String>(
    context: context,
    title: card ? l10n.cardBackground : l10n.coverPhoto,
    subtitle: card ? l10n.cardBackgroundSheetHint : l10n.coverPhotoSheetHint,
    children: (sheet) {
      final colorScheme = Theme.of(sheet).colorScheme;
      return [
        if (currentUrl != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                DesignTokens.spacingS, DesignTokens.spacingL, DesignTokens.spacingS),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              child: AspectRatio(
                aspectRatio: card ? 2.5 : 3,
                child: CachedRedirectImage(imageUrl: currentUrl, fit: BoxFit.cover),
              ),
            ),
          ),
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: Text(l10n.takePhoto),
          onTap: () => Navigator.pop(sheet, 'camera'),
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: Text(l10n.chooseFromLibrary),
          onTap: () => Navigator.pop(sheet, 'library'),
        ),
        if (currentUrl != null)
          ListTile(
            leading: Icon(Icons.delete_outline, color: colorScheme.error),
            title: Text(card ? l10n.removeCardBackground : l10n.removeCover,
                style: TextStyle(color: colorScheme.error)),
            onTap: () => Navigator.pop(sheet, 'remove'),
          ),
      ];
    },
  );
  if (action == null) return null;
  if (action == 'remove') return const BackgroundChoice(remove: true);
  final photo = await pickProfilePhoto(
    action == 'camera' ? ImageSource.camera : ImageSource.gallery,
    maxSide: 1920,
  );
  return photo == null ? null : BackgroundChoice(photo: photo);
}

// ===== Title, flair, primary group =====

/// The titles the member may wear. The empty string is "no title".
Future<String?> showTitleSheet({
  required BuildContext context,
  required DiscourseEditableProfile profile,
  required DiscourseProfileProxy proxy,
}) {
  final l10n = AppLocalizations.of(context)!;
  final options = proxy.titleOptions(profile);
  final locale = Localizations.localeOf(context).toString();
  return showProfileSheet<String>(
    context: context,
    title: l10n.title,
    subtitle: l10n.titleSheetHint,
    children: (sheet) => [
      FutureBuilder<List<DiscourseTitleOption>>(
        future: options,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(DesignTokens.spacingXL),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(DesignTokens.spacingL),
              child: Text(describeError(snap.error)),
            );
          }
          final list = snap.data ?? const [];
          final current = profile.title ?? '';
          return RadioGroup<String>(
            groupValue: current,
            onChanged: (v) => Navigator.pop(sheet, v ?? ''),
            child: Column(
              children: [
                RadioListTile<String>(value: '', title: Text(l10n.noTitle)),
                for (final o in list)
                  RadioListTile<String>(
                    value: o.title,
                    selected: o.title == current,
                    title: Text(o.title),
                    subtitle: Text(o.fromBadge
                        ? (o.grantedAt == null
                            ? l10n.titleFromBadge
                            : l10n.titleFromBadgeEarned(DateFormat.yMMM(locale)
                                .format(o.grantedAt!.toLocal())))
                        : l10n.titleFromGroup(o.groupName ?? '')),
                  ),
                if (current.isNotEmpty && !list.any((o) => o.title == current))
                  RadioListTile<String>(
                    value: current,
                    selected: true,
                    title: Text(current),
                    subtitle: Text(l10n.titleGrantedByStaff),
                  ),
              ],
            ),
          );
        },
      ),
    ],
  );
}

/// The groups whose flair can be worn, with a preview of the picture
/// wearing it.
Future<GroupChoice?> showFlairSheet({
  required BuildContext context,
  required DiscourseEditableProfile profile,
  required String siteUrl,
}) {
  final l10n = AppLocalizations.of(context)!;
  final avatar =
      DiscourseEditableProfile.avatarUrl(siteUrl, profile.avatarTemplate, 120);
  return showProfileSheet<GroupChoice>(
    context: context,
    title: l10n.flair,
    subtitle: l10n.flairSheetHint,
    children: (sheet) {
      final colorScheme = Theme.of(sheet).colorScheme;
      final textTheme = Theme.of(sheet).textTheme;
      final current = profile.flairGroup;
      return [
        Container(
          margin: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
              DesignTokens.spacingS, DesignTokens.spacingL, DesignTokens.spacingS),
          padding: const EdgeInsets.all(DesignTokens.spacingM),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(
                      username: profile.username, iconUrl: avatar, radius: 20),
                  if (current != null)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: UserFlairBadge(
                        flairUrl: current.flairUrl!,
                        bgHex: current.flairBgColor,
                        fgHex: current.flairColor,
                        size: 20,
                        ringColor: colorScheme.surfaceContainerHigh,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name ?? profile.username,
                        style: textTheme.titleSmall),
                    if (profile.title != null)
                      Text(profile.title!,
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
        RadioGroup<int>(
          groupValue: profile.flairGroupId ?? -1,
          onChanged: (v) =>
              Navigator.pop(sheet, GroupChoice(v == null || v < 0 ? null : v)),
          child: Column(
            children: [
              RadioListTile<int>(
                value: -1,
                title: Text(l10n.noFlair),
                secondary: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.outline),
                  ),
                ),
              ),
              for (final g in profile.flairGroups)
                RadioListTile<int>(
                  value: g.id,
                  selected: g.id == profile.flairGroupId,
                  title: Text(g.displayName),
                  secondary: UserFlairBadge(
                    flairUrl: g.flairUrl!,
                    bgHex: g.flairBgColor,
                    fgHex: g.flairColor,
                    size: 32,
                  ),
                ),
            ],
          ),
        ),
      ];
    },
  );
}

Future<GroupChoice?> showPrimaryGroupSheet({
  required BuildContext context,
  required DiscourseEditableProfile profile,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showProfileSheet<GroupChoice>(
    context: context,
    title: l10n.primaryGroup,
    subtitle: l10n.primaryGroupSheetHint,
    children: (sheet) => [
      RadioGroup<int>(
        groupValue: profile.primaryGroupId ?? -1,
        onChanged: (v) =>
            Navigator.pop(sheet, GroupChoice(v == null || v < 0 ? null : v)),
        child: Column(
          children: [
            RadioListTile<int>(value: -1, title: Text(l10n.none)),
            for (final g in profile.primaryGroupChoices)
              RadioListTile<int>(
                value: g.id,
                selected: g.id == profile.primaryGroupId,
                title: Text(g.displayName),
              ),
          ],
        ),
      ),
    ],
  );
}

// ===== Featured topic =====

Future<FeaturedTopicChoice?> showFeaturedTopicSheet({
  required BuildContext context,
  required DiscourseEditableProfile profile,
  required DiscourseProfileProxy proxy,
}) {
  return showModalBottomSheet<FeaturedTopicChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.9,
      child: _FeaturedTopicPicker(profile: profile, proxy: proxy),
    ),
  );
}

class _FeaturedTopicPicker extends StatefulWidget {
  const _FeaturedTopicPicker({required this.profile, required this.proxy});
  final DiscourseEditableProfile profile;
  final DiscourseProfileProxy proxy;

  @override
  State<_FeaturedTopicPicker> createState() => _FeaturedTopicPickerState();
}

class _FeaturedTopicPickerState extends State<_FeaturedTopicPicker> {
  List<({int id, String title, int replies, DateTime? createdAt, int? categoryId})>?
      _topics;
  Object? _error;
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final query = _query;
    try {
      final topics = await widget.proxy.myTopics(query: query);
      if (!mounted || query != _query) return;
      setState(() {
        _topics = topics;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _search(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query = text;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final topics = _topics;
    final current = widget.profile.featuredTopicId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l10n.featureATopic),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingM),
          child: Text(l10n.featureATopicHint,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
          child: SearchBar(
            hintText: l10n.searchYourTopics,
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            onChanged: _search,
          ),
        ),
        if (current != null)
          ListTile(
            leading: Icon(Icons.close, color: colorScheme.error),
            title: Text(l10n.removeFeaturedTopic,
                style: TextStyle(color: colorScheme.error)),
            onTap: () =>
                Navigator.pop(context, const FeaturedTopicChoice(null)),
          ),
        Expanded(
          child: topics == null
              ? (_error == null
                  ? const Center(child: CircularProgressIndicator())
                  : Center(child: Text(describeError(_error))))
              : topics.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.spacingXL),
                        child: Text(
                          _query.isEmpty
                              ? l10n.noTopicsToFeature
                              : l10n.noTopicsMatch,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : RadioGroup<int>(
                      groupValue: current ?? -1,
                      onChanged: (v) =>
                          Navigator.pop(context, FeaturedTopicChoice(v)),
                      child: ListView(
                        children: [
                          for (final t in topics)
                            RadioListTile<int>(
                              value: t.id,
                              selected: t.id == current,
                              title: Text(t.title),
                              subtitle: Text([
                                l10n.nReplies(t.replies),
                                if (t.createdAt != null)
                                  DateFormat.yMMM(locale)
                                      .format(t.createdAt!.toLocal()),
                              ].join(' · ')),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(DesignTokens.spacingL),
                            child: Text(l10n.featuredTopicRules,
                                style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                          ),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }
}

// ===== Time zone =====

/// Every time zone, searchable, with the ones that match this phone's
/// clock first. The app cannot read the phone's zone by name, so it offers
/// the zones at the phone's current UTC offset rather than guessing one.
Future<String?> showTimezoneSheet({
  required BuildContext context,
  required String? current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.9,
      child: _TimezonePicker(current: current),
    ),
  );
}

class _TimezonePicker extends StatefulWidget {
  const _TimezonePicker({required this.current});
  final String? current;

  @override
  State<_TimezonePicker> createState() => _TimezonePickerState();
}

class _TimezonePickerState extends State<_TimezonePicker> {
  late final List<({String name, Duration offset})> _zones;
  String _query = '';

  @override
  void initState() {
    super.initState();
    timeZoneNamed('UTC'); // loads the database
    _zones = [
      for (final e in tz.timeZoneDatabase.locations.entries)
        if (e.key.contains('/') && !e.key.startsWith('Etc/'))
          (name: e.key, offset: tz.TZDateTime.now(e.value).timeZoneOffset),
    ]..sort((a, b) => a.name.compareTo(b.name));
  }

  String _offsetLabel(Duration d) {
    final sign = d.isNegative ? '−' : '+';
    final m = d.inMinutes.abs();
    final h = m ~/ 60;
    final min = m % 60;
    return 'UTC$sign$h${min == 0 ? '' : ':${min.toString().padLeft(2, '0')}'}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final phone = DateTime.now().timeZoneOffset;
    final q = _query.trim().toLowerCase().replaceAll(' ', '_');
    final matches = q.isEmpty
        ? _zones
        : _zones.where((z) => z.name.toLowerCase().contains(q)).toList();
    final current = q.isEmpty
        ? _zones.where((z) => z.name == widget.current).toList()
        : const <({String name, Duration offset})>[];
    final suggested = q.isEmpty
        ? _zones
            .where((z) => z.offset == phone && z.name != widget.current)
            .toList()
        : const <({String name, Duration offset})>[];
    Widget row(({String name, Duration offset}) z) => ListTile(
          title: Text(z.name.replaceAll('_', ' ')),
          subtitle: Text(_offsetLabel(z.offset)),
          selected: z.name == widget.current,
          trailing: z.name == widget.current ? const Icon(Icons.check) : null,
          onTap: () => Navigator.pop(context, z.name),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l10n.timezone),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
          child: SearchBar(
            hintText: l10n.searchTimezones,
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final z in current) row(z),
              if (current.isNotEmpty) const Divider(),
              if (suggested.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                      DesignTokens.spacingS, DesignTokens.spacingL, 0),
                  child: Text(l10n.timezonesMatchingPhone(_offsetLabel(phone)),
                      style: textTheme.titleSmall
                          ?.copyWith(color: colorScheme.primary)),
                ),
                for (final z in suggested) row(z),
                const Divider(),
              ],
              for (final z in matches) row(z),
            ],
          ),
        ),
      ],
    );
  }
}

// ===== Birthday =====

/// Month and day, as the cakeday plugin keeps them; the year is never
/// asked for.
Future<BirthdayChoice?> showBirthdayPicker({
  required BuildContext context,
  required DateTime? current,
}) {
  return showDialog<BirthdayChoice>(
    context: context,
    builder: (_) => _BirthdayDialog(current: current),
  );
}

class _BirthdayDialog extends StatefulWidget {
  const _BirthdayDialog({required this.current});
  final DateTime? current;

  @override
  State<_BirthdayDialog> createState() => _BirthdayDialogState();
}

class _BirthdayDialogState extends State<_BirthdayDialog> {
  late int _month = widget.current?.month ?? DateTime.now().month;
  late int _day = widget.current?.day ?? 1;

  // A leap year, so 29 February can be picked.
  int get _daysInMonth => DateTime(2000, _month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final months = DateFormat.MMMM(locale);
    if (_day > _daysInMonth) _day = _daysInMonth;
    return AlertDialog(
      title: Text(l10n.birthday),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.birthdayHint),
          const SizedBox(height: DesignTokens.spacingL),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<int>(
                  initialValue: _month,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.month),
                  items: [
                    for (var m = 1; m <= 12; m++)
                      DropdownMenuItem(
                          value: m, child: Text(months.format(DateTime(2000, m)))),
                  ],
                  onChanged: (v) => setState(() => _month = v ?? _month),
                ),
              ),
              const SizedBox(width: DesignTokens.spacingM),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int>(
                  initialValue: _day,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.day),
                  items: [
                    for (var d = 1; d <= _daysInMonth; d++)
                      DropdownMenuItem(value: d, child: Text('$d')),
                  ],
                  onChanged: (v) => setState(() => _day = v ?? _day),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (widget.current != null)
          TextButton(
            onPressed: () =>
                Navigator.pop(context, const BirthdayChoice(null)),
            child: Text(l10n.remove),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, BirthdayChoice(DateTime(1904, _month, _day))),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

// ===== Username =====

/// Changes the username after checking it is free. Returns the new name,
/// or null when nothing changed.
Future<String?> showChangeUsernameDialog({
  required BuildContext context,
  required String currentUsername,
  required DiscourseProfileProxy proxy,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) =>
        _UsernameDialog(currentUsername: currentUsername, proxy: proxy),
  );
}

class _UsernameDialog extends StatefulWidget {
  const _UsernameDialog({required this.currentUsername, required this.proxy});
  final String currentUsername;
  final DiscourseProfileProxy proxy;

  @override
  State<_UsernameDialog> createState() => _UsernameDialogState();
}

class _UsernameDialogState extends State<_UsernameDialog> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  bool _checking = false;
  bool _saving = false;
  String? _problem;
  bool _available = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.currentUsername;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _changed(String text) {
    _debounce?.cancel();
    setState(() {
      _available = false;
      _problem = null;
      _checking = text.trim().isNotEmpty &&
          text.trim().toLowerCase() != widget.currentUsername.toLowerCase();
    });
    if (!_checking) return;
    _debounce = Timer(const Duration(milliseconds: 400), () => _check(text.trim()));
  }

  Future<void> _check(String name) async {
    try {
      final problem = await widget.proxy.checkUsername(name);
      if (!mounted || _controller.text.trim() != name) return;
      setState(() {
        _checking = false;
        _problem = problem;
        _available = problem == null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _problem = describeError(e);
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final name = await widget.proxy.changeUsername(_controller.text.trim());
      if (mounted) context.popOwnRoute(name);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _problem = describeError(e);
        _available = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.changeUsername),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.changeUsernameExplanation(widget.currentUsername),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: DesignTokens.spacingL),
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !_saving,
            autocorrect: false,
            onChanged: _changed,
            decoration: InputDecoration(
              labelText: l10n.newUsername,
              prefixText: '@',
              errorText: _problem,
              errorMaxLines: 3,
              helperText: _available ? l10n.usernameAvailable : null,
              suffixIcon: _checking
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : (_available
                      ? Icon(Icons.check, color: colorScheme.primary)
                      : null),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => context.popOwnRoute(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _available && !_saving ? _save : null,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.changeUsername),
        ),
      ],
    );
  }
}
