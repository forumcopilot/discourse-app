import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/entities/fc_custom_field.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseUserProxy,
        DiscourseSummaryUser,
        DiscourseUserSummary,
        DiscourseSiteContextExtension;

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../theme/style_builders.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/utils/avatar_cache_utils.dart';
import 'package:discourse_ui/utils/file_picker_utils.dart';
import 'package:discourse_ui/utils/signature_processor.dart';

import 'full_screen_image_viewer.dart';
import 'trust_level_sheet.dart';
import 'user_avatar.dart';
import 'user_badges_row.dart';
import 'user_activity_tabs.dart';
import '../bookmarks_page.dart';
import '../drafts_list_page.dart';
import '../edit_profile_page.dart';
import '../messages_page.dart';
import '../settings_page.dart';
import '../user_profile_page.dart';
import '../private_messaging/conversation/pages/new_conversation_page.dart';

/// The one shared profile experience ("subtraction model").
///
/// Renders the FULL profile — avatar block (with camera-upload badge in
/// self mode), username + BANNED chip, display text, trust-level chip,
/// badges row, action row (self: Edit profile + Settings; other:
/// Follow/Unfollow + Send Message), nav rows (self only: Messages /
/// Bookmarks / Drafts), the info card, the summary stats section, and
/// the Replies/Topics activity tabs.
///
/// Used by BOTH profile surfaces:
///  - `ProfileTab` (bottom-nav tab, always self) — the host keeps the
///    logged-out `NotSignedInView`, the tab reset/auth-listener wiring
///    and the userInfo fetch.
///  - `UserProfilePage` (avatar-tap page, self or other) — the host
///    keeps the app bar + moderation overflow menu, the userInfo fetch
///    and the pull-to-refresh wrapper.
///
/// The host always owns the `userInfo` fetch; this widget owns the
/// summary fetch (self-loading `_UserSummarySection`) and the avatar
/// upload / follow-toggle interactions.
class ProfileView extends StatefulWidget {
  final SiteContext siteContext;
  final FCUserInfoResult userInfo;

  /// Whether the profile being shown belongs to the logged-in viewer.
  final bool isSelf;

  /// Fallback avatar URL used when `userInfo.iconUrl` is empty (the
  /// avatar-tap page passes the URL it was opened with).
  final String? fallbackAvatarUrl;

  /// Self mode: called after `EditProfilePage` pops with a successful
  /// save. The host must null out its cached userInfo AND reset its
  /// has-loaded flag, then refetch — see the ProfileTab comment about
  /// the section vanishing after an edit when only one was reset.
  final VoidCallback? onEdited;

  /// Self mode: called after a successful avatar upload (the new
  /// iconUrl has already been written into `siteContext.loginDataOutput`
  /// and persisted). The host should refetch userInfo.
  final VoidCallback? onAvatarUploaded;

  /// Passed through to `UserActivityTabs.repliesKey` so the page host
  /// can keep driving load-more from its outer scroll controller.
  final Key? repliesKey;

  /// Bump to force the summary section to remount and refetch (the
  /// page host increments this on pull-to-refresh).
  final int refreshToken;

  const ProfileView({
    super.key,
    required this.siteContext,
    required this.userInfo,
    required this.isSelf,
    this.fallbackAvatarUrl,
    this.onEdited,
    this.onAvatarUploaded,
    this.repliesKey,
    this.refreshToken = 0,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  File? _selectedImageFile;
  bool _isUploading = false;
  bool _isTogglingFollow = false;

  FCUserInfoResult get _userInfo => widget.userInfo;

  String? get _avatarUrl {
    final iconUrl = _userInfo.iconUrl;
    if (iconUrl != null && iconUrl.isNotEmpty) return iconUrl;
    final fallback = widget.fallbackAvatarUrl;
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return null;
  }

  /// Discourse trust level label. 0–4 are the canonical
  /// levels; anything outside that range falls back to "TLn".
  String _trustLevelLabel(int level) {
    switch (level) {
      case 0:
        return 'TL0 · New';
      case 1:
        return 'TL1 · Basic';
      case 2:
        return 'TL2 · Member';
      case 3:
        return 'TL3 · Regular';
      case 4:
        return 'TL4 · Leader';
      default:
        return 'TL$level';
    }
  }

  // --- Avatar upload (self mode) -----------------------------------

  Future<void> _pickImage(BuildContext context) async {
    // Check permission before allowing image pick
    final canUploadAvatar =
        widget.siteContext.loginDataOutput?.canUploadAvatar ?? false;
    if (!canUploadAvatar) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You do not have permission to upload avatars',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      // Use FilePickerUtils for macOS compatibility, fallback to
      // image_picker for mobile
      XFile? image;
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        image =
            await FilePickerUtils.pickImage(imageQuality: ImageQuality.high);
      } else {
        final ImagePicker picker = ImagePicker();
        image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
      }

      if (image != null) {
        if (mounted) {
          setState(() {
            _selectedImageFile = File(image!.path);
            _isUploading = true;
          });
        }
        try {
          var attachmentProxy = SiteProxyFactory.getAttachmentProxy();
          var uploadAttachmentResult = await attachmentProxy.uploadAvatarAsync(
              "jpg", await image.readAsBytes());
          if (uploadAttachmentResult.result == true) {
            // After successful upload, refresh user info to get the
            // updated image URL into the login context.
            await _refreshLoginAvatar();

            if (mounted) {
              setState(() {
                _isUploading = false;
                _selectedImageFile = null;
              });
            }
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Avatar uploaded successfully',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onInverseSurface,
                        ),
                  ),
                  backgroundColor:
                      Theme.of(context).colorScheme.inverseSurface,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(8),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            throw Exception(uploadAttachmentResult.resultText);
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isUploading = false;
              _selectedImageFile = null;
            });
          }
          throw Exception('Failed to upload file: ${e.toString()}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _selectedImageFile = null;
        });
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image: $e',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _refreshLoginAvatar() async {
    try {
      final username = widget.siteContext.loginDataOutput?.user?.username;
      if (username == null) return;

      final proxy = SiteProxyFactory.getUserProxy();
      final userInfo = await proxy.getUserInfoAsync(username, null);

      // Update the login context with the new image URL
      if (widget.siteContext.loginDataOutput != null) {
        widget.siteContext.loginDataOutput!.user?.iconUrl =
            userInfo.iconUrl ?? '';
      }

      // Save the updated context to device
      await widget.siteContext.saveToDevice();

      // Notify the host so it refetches userInfo
      widget.onAvatarUploaded?.call();
    } catch (e) {
      AppLogger.debug('Error refreshing user info after avatar upload: $e');
    }
  }

  // --- Follow toggle (other mode) ----------------------------------

  /// Toggle the viewer's follow relationship with the displayed user.
  /// Optimistically flips state; reverts on failure. Routed through
  /// `IFCSocialProxy`; the richer `FCFollowResult` shape lets us
  /// surface the plugin-not-installed case explicitly.
  Future<void> _handleToggleFollow() async {
    if (_isTogglingFollow) return;
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to follow users')),
      );
      return;
    }
    final proxy = SiteProxyService.getSocialProxy();
    final wasFollowing = _userInfo.isFollowing ?? false;
    setState(() {
      _isTogglingFollow = true;
      _userInfo.isFollowing = !wasFollowing;
    });
    String? errorText;
    try {
      if (wasFollowing) {
        final result = await proxy.unfollowAsync(_userInfo.username);
        if (!result.result) {
          errorText = result.resultText?.isNotEmpty == true
              ? result.resultText
              : 'Failed to unfollow';
        }
      } else {
        final result = await proxy.followAsync(_userInfo.username);
        if (!result.result) {
          errorText = result.resultText?.isNotEmpty == true
              ? result.resultText
              : 'Failed to follow';
        }
      }
    } catch (e) {
      errorText = 'Error: $e';
    }
    if (!mounted) return;
    setState(() {
      _isTogglingFollow = false;
      if (errorText != null) {
        _userInfo.isFollowing = wasFollowing;
      }
    });
    if (errorText != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorText)),
      );
    }
  }

  // --- Build -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(height: DesignTokens.spacingL),
        _buildAvatarBlock(context, colorScheme),
        SizedBox(height: DesignTokens.spacingM),
        // Username with Banned Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _userInfo.username,
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
            if (_userInfo.isBanned) ...[
              SizedBox(width: DesignTokens.spacingS),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingM - DesignTokens.spacingXS,
                  vertical: DesignTokens.spacingXS / 2,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer
                      .withValues(alpha: DesignTokens.opacityHigh),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.block,
                      size: DesignTokens.iconSizeXS,
                      color: colorScheme.onErrorContainer,
                    ),
                    SizedBox(width: DesignTokens.spacingXS),
                    Text(
                      AppLocalizations.of(context)?.banned ?? 'BANNED',
                      style: StyleBuilders.badgeTextStyle(
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (_userInfo.displayText != null &&
            _userInfo.displayText!.isNotEmpty) ...[
          SizedBox(height: DesignTokens.spacingXS),
          Padding(
            padding: DesignTokens.paddingScreenHorizontal,
            child: Text(
              _userInfo.displayText!,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        // Discourse trust level badge (0–4). Hidden on
        // forums that don't expose trustLevel.
        if (_userInfo.trustLevel != null) ...[
          SizedBox(height: DesignTokens.spacingS),
          Center(
            // Tappable — opens the trust-level explainer sheet.
            child: Material(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              child: InkWell(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                onTap: () => TrustLevelSheet.show(
                  context: context,
                  currentLevel: _userInfo.trustLevel!,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    _trustLevelLabel(_userInfo.trustLevel!),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: DesignTokens.letterSpacingWide,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        // Discourse badges row (Bronze/Silver/Gold).
        // Hidden when the user has no granted badges.
        SizedBox(height: DesignTokens.spacingS),
        UserBadgesRow(username: _userInfo.username),
        SizedBox(height: DesignTokens.spacingM),
        // Action row — self: Edit profile + Settings;
        // other: Follow/Unfollow + Send Message.
        if (widget.isSelf)
          _buildSelfActionRow(context)
        else
          _buildOtherActionRow(context, colorScheme, textTheme),
        if (widget.isSelf) ...[
          SizedBox(height: DesignTokens.spacingL),
          // Discourse-native "Your stuff" section. Aggregates
          // Messages / Bookmarks / Drafts, matching how Discourse
          // web exposes them under the user menu.
          _ProfileActionsSection(siteContext: widget.siteContext),
        ],
        const SizedBox(height: DesignTokens.spacingL),
        _buildInfoCard(context, colorScheme, textTheme),
        // Discourse summary stats (`/u/{username}/summary.json`).
        // Loaded lazily by the section itself so the main profile
        // fetch stays a single request; renders nothing while
        // loading, on failure, or when the server hides the stats
        // from this viewer (`can_see_summary_stats`).
        _UserSummarySection(
          key: ValueKey(
              'summary_${_userInfo.username}_${widget.refreshToken}'),
          siteContext: widget.siteContext,
          username: _userInfo.username,
        ),
        SizedBox(height: DesignTokens.spacingS),
        // Replies / Topics tab strip. The selected tab loads lazily;
        // `repliesKey` still drives the page host's load-more path.
        UserActivityTabs(
          siteContext: widget.siteContext,
          userId: _userInfo.id,
          userName: _userInfo.username,
          repliesKey: widget.repliesKey,
        ),
        SizedBox(height: DesignTokens.spacingL),
      ],
    );
  }

  Widget _buildAvatarBlock(BuildContext context, ColorScheme colorScheme) {
    final canUploadAvatar = widget.isSelf &&
        (widget.siteContext.loginDataOutput?.canUploadAvatar ?? false);
    final avatarUrl = _avatarUrl;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (avatarUrl != null && avatarUrl.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImageViewer(
                    imageUrls: [avatarUrl],
                    initialIndex: 0,
                    heroTag: 'profile_picture_${_userInfo.username}',
                  ),
                ),
              );
            }
          },
          child: _selectedImageFile != null
              ? ClipOval(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.file(
                      _selectedImageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : UserAvatar(
                  username: _userInfo.username,
                  iconUrl: avatarUrl,
                  radius: 50,
                  showOnlineIndicator: true,
                  isOnline: _userInfo.isOnline ?? false,
                  cacheKey: () {
                    if (avatarUrl != null && avatarUrl.isNotEmpty) {
                      return AvatarCacheUtils.generateAvatarCacheKey(
                        userId: _userInfo.id,
                        username: _userInfo.username,
                        avatarUrl: avatarUrl,
                      );
                    }
                    return null;
                  }(),
                ),
        ),
        if (_isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: DesignTokens.iconSizeL,
                height: DesignTokens.iconSizeL,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ),
          ),
        // Only show camera icon on the viewer's own profile when the
        // forum allows avatar uploads.
        if (canUploadAvatar)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => _pickImage(context),
              child: Container(
                padding: DesignTokens.paddingS,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: DesignTokens.borderWidthThin,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: DesignTokens.iconSizeM,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Edit profile + Settings, side by side. The EditProfilePage pops
  /// with `true` on a successful save so the host re-fetches user
  /// info and surfaces the new values.
  Widget _buildSelfActionRow(BuildContext context) {
    return Padding(
      padding: DesignTokens.paddingScreenHorizontal,
      child: Row(
        children: [
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: () async {
                final saved = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(
                      siteContext: widget.siteContext,
                      userInfo: _userInfo,
                    ),
                  ),
                );
                if (saved == true && mounted) {
                  // The host must force a fresh fetch so name / bio /
                  // location / website re-render with the saved values
                  // (nulling its cached userInfo AND resetting its
                  // has-loaded flag — see ProfileTab).
                  widget.onEdited?.call();
                }
              },
              icon: Icon(Icons.edit_outlined, size: DesignTokens.iconSizeM),
              label: const Text('Edit profile'),
            ),
          ),
          SizedBox(width: DesignTokens.spacingS),
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForumSettingsPage(
                      siteContext: widget.siteContext,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.settings_outlined,
                  size: DesignTokens.iconSizeM),
              label: const Text('Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherActionRow(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Follow / Unfollow toggle (Discourse 3.x). acceptsFollowers
        // is wired off `can_follow` — we only show the button when
        // the target permits follows.
        if (_userInfo.acceptsFollowers ?? false) ...[
          OutlinedButton.icon(
            onPressed: _isTogglingFollow ? null : _handleToggleFollow,
            icon: Icon(
              (_userInfo.isFollowing ?? false)
                  ? Icons.person_remove
                  : Icons.person_add,
              size: DesignTokens.iconSizeM,
            ),
            label: Text(
              (_userInfo.isFollowing ?? false) ? 'Unfollow' : 'Follow',
            ),
          ),
        ],
        if (_userInfo.acceptsPM ?? false) ...[
          SizedBox(width: DesignTokens.spacingM),
          FilledButton.icon(
            onPressed: () {
              // Discourse PMs are always conversations.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewConversationPage(
                    siteContext: widget.siteContext,
                    initialRecipient: _userInfo.username,
                    initialRecipientIconUrl: _avatarUrl,
                  ),
                ),
              );
            },
            icon: Icon(Icons.message, size: DesignTokens.iconSizeM),
            label: Text(
              AppLocalizations.of(context)?.sendMessage ?? 'Send Message',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: DesignTokens.fontWeightBold,
              ),
            ),
            style: StyleBuilders.extendedFilledButtonStyle(
              colorScheme: colorScheme,
            ),
          ),
        ],
      ],
    );
  }

  // --- Info card (the ONE implementation) --------------------------

  Widget _buildInfoCard(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingXS,
      ),
      elevation: DesignTokens.elevationNone,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        side: BorderSide(
          color: colorScheme.outlineVariant
              .withValues(alpha: DesignTokens.opacityLow),
          width: DesignTokens.borderWidthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Core Information
          if (_userInfo.registrationTime != null)
            _buildInfoTile(
              context,
              icon: Icons.calendar_today,
              title: AppLocalizations.of(context)?.memberSince ??
                  'Member Since',
              subtitle: DateFormat.yMMMMd()
                  .format(_userInfo.registrationTime as DateTime),
            ),
          if (_userInfo.customFieldsList != null)
            ...(() {
              final birthdayField = _userInfo.customFieldsList!
                  .where((f) =>
                      f.name.toLowerCase() == 'birthday' &&
                      f.value.trim().isNotEmpty &&
                      f.value != '0')
                  .cast<FCCustomField?>()
                  .toList();
              if (birthdayField.isEmpty) return <Widget>[];
              final field = birthdayField.first;
              DateTime? birthdayDate;
              try {
                birthdayDate = DateFormat('d MMM yyyy').parse(field!.value);
              } catch (_) {}
              final now = DateTime.now();
              if (birthdayDate == null ||
                  birthdayDate.year < 1900 ||
                  birthdayDate.isAfter(now)) {
                return <Widget>[];
              }
              final locale = Localizations.localeOf(context).toString();
              final formatted = DateFormat.yMMMMd(locale).format(birthdayDate);
              return [
                _buildInfoTile(
                  context,
                  icon: Icons.cake,
                  title: AppLocalizations.of(context)?.birthday ?? 'Birthday',
                  subtitle: formatted,
                ),
              ];
            })(),
          if (_userInfo.lastActivityTime != null)
            _buildInfoTile(
              context,
              icon: Icons.access_time,
              title: AppLocalizations.of(context)?.lastActivity ??
                  'Last Activity',
              subtitle: DateFormat.yMMMd(
                      Localizations.localeOf(context).toString())
                  .add_jm()
                  .format(_userInfo.lastActivityTime!.toLocal()),
            ),
          if (_userInfo.postCount != null && _userInfo.postCount != 0)
            _buildInfoTile(
              context,
              icon: Icons.post_add,
              title: AppLocalizations.of(context)?.posts ?? 'Posts',
              subtitle: NumberFormat.decimalPattern(
                      Localizations.localeOf(context).toString())
                  .format(_userInfo.postCount),
            ),
          if (_userInfo.customFieldsList != null)
            ...(() {
              final likesReceivedField = _userInfo.customFieldsList!
                  .where((f) =>
                      (f.name.toLowerCase() == 'likes' ||
                          f.name.toLowerCase() == 'likes_received') &&
                      f.value.trim().isNotEmpty &&
                      f.value != '0')
                  .cast<FCCustomField?>()
                  .toList();
              final likesGivenField = _userInfo.customFieldsList!
                  .where((f) =>
                      f.name.toLowerCase() == 'liked' &&
                      f.value.trim().isNotEmpty &&
                      f.value != '0')
                  .cast<FCCustomField?>()
                  .toList();
              final List<Widget> fields = [];
              if (likesReceivedField.isNotEmpty) {
                fields.add(_buildInfoTile(
                  context,
                  icon: Icons.thumb_up,
                  title: AppLocalizations.of(context)?.likesReceived ??
                      'Likes Received',
                  subtitle: NumberFormat.decimalPattern(
                          Localizations.localeOf(context).toString())
                      .format(
                          int.tryParse(likesReceivedField.first!.value) ?? 0),
                ));
              }
              if (likesGivenField.isNotEmpty) {
                fields.add(_buildInfoTile(
                  context,
                  icon: Icons.thumb_up_outlined,
                  title: AppLocalizations.of(context)?.likesGiven ??
                      'Likes Given',
                  subtitle: NumberFormat.decimalPattern(
                          Localizations.localeOf(context).toString())
                      .format(int.tryParse(likesGivenField.first!.value) ?? 0),
                ));
              }
              return fields;
            })(),
          if (_userInfo.followingCount != null &&
              _userInfo.followingCount != 0)
            _buildInfoTile(
              context,
              icon: Icons.people_outline,
              title: AppLocalizations.of(context)?.following ?? 'Following',
              subtitle: _userInfo.followingCount.toString(),
            ),
          if (_userInfo.follower != null && _userInfo.follower != 0)
            _buildInfoTile(
              context,
              icon: Icons.people,
              title: AppLocalizations.of(context)?.followers ?? 'Followers',
              subtitle: _userInfo.follower.toString(),
            ),
          // About field (from direct API field)
          if (_userInfo.bio != null && _userInfo.bio!.isNotEmpty)
            _buildInfoTile(
              context,
              icon: Icons.person_outline,
              title: AppLocalizations.of(context)?.about ?? 'About',
              subtitle: _userInfo.bio!,
            ),
          // Location field (from direct API field)
          if (_userInfo.location != null && _userInfo.location!.isNotEmpty)
            _buildInfoTile(
              context,
              icon: Icons.location_on,
              title: AppLocalizations.of(context)?.location ?? 'Location',
              subtitle: _userInfo.location!,
            ),
          // Website field (clickable)
          if (_userInfo.website != null && _userInfo.website!.isNotEmpty)
            _buildInfoTile(
              context,
              icon: Icons.language,
              title: AppLocalizations.of(context)?.website ?? 'Website',
              subtitle: _userInfo.website!,
              onTap: () async {
                final url = _userInfo.website!;
                final uri = Uri.parse(
                    url.startsWith('http://') || url.startsWith('https://')
                        ? url
                        : 'https://$url');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          // Signature field (from direct API field)
          if (_userInfo.signature != null && _userInfo.signature!.isNotEmpty)
            _buildSignatureTile(
              context,
              icon: Icons.edit_note,
              title: AppLocalizations.of(context)?.signature ?? 'Signature',
              signature: _userInfo.signature!,
            ),
          // Location field from customFields (fallback for older data)
          if (_userInfo.location == null && _userInfo.customFieldsList != null)
            ...(() {
              final locationField = _userInfo.customFieldsList!
                  .where((f) =>
                      f.name.toLowerCase().contains('location') &&
                      f.value.trim().isNotEmpty &&
                      f.value != '0')
                  .toList();
              if (locationField.isEmpty) return <Widget>[];
              return [
                _buildInfoTile(
                  context,
                  icon: Icons.location_on,
                  title: locationField.first.name,
                  subtitle: locationField.first.value,
                ),
              ];
            })(),
          // Signature field from customFields (fallback for older data)
          if (_userInfo.signature == null &&
              _userInfo.customFieldsList != null)
            ...(() {
              final signatureField = _userInfo.customFieldsList!
                  .where((f) =>
                      f.name.toLowerCase() == 'signature' &&
                      f.value.trim().isNotEmpty &&
                      f.value != '0')
                  .toList();
              if (signatureField.isEmpty) return <Widget>[];
              return [
                _buildSignatureTile(
                  context,
                  icon: Icons.edit_note,
                  title:
                      AppLocalizations.of(context)?.signature ?? 'Signature',
                  signature: signatureField.first.value,
                ),
              ];
            })(),
          // Additional Information Section (Expandable)
          if (_userInfo.customFieldsList != null &&
              _userInfo.customFieldsList!.isNotEmpty &&
              _userInfo.customFieldsList!.any((f) =>
                  f.value.trim().isNotEmpty &&
                  f.value != "0" &&
                  f.name.toLowerCase() != 'birthday' &&
                  f.name.toLowerCase() != 'likes' &&
                  f.name.toLowerCase() != 'liked' &&
                  f.name.toLowerCase() != 'signature' &&
                  !f.name.toLowerCase().contains('location')))
            Theme(
              data: Theme.of(context)
                  .copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: false,
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                title: Text(
                  AppLocalizations.of(context)?.showMore ?? 'Show More',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: DesignTokens.fontWeightMedium,
                  ),
                ),
                children: [
                  ..._userInfo.customFieldsList!
                      .where((f) =>
                          f.value.trim().isNotEmpty &&
                          f.value != "0" &&
                          f.name.toLowerCase() != 'likes' &&
                          f.name.toLowerCase() != 'liked' &&
                          f.name.toLowerCase() != 'signature' &&
                          !f.name.toLowerCase().contains('location'))
                      .map((f) => _buildInfoTile(
                            context,
                            icon: Icons.info_outline,
                            title: f.name,
                            subtitle: f.value,
                          ))
                      .toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingXS,
      ),
      leading: Icon(
        icon,
        size: DesignTokens.iconSizeM,
        color: colorScheme.primary,
      ),
      title: Text(
        title,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodyMedium?.copyWith(
          color: onTap != null ? colorScheme.primary : colorScheme.onSurface,
          decoration: onTap != null ? TextDecoration.underline : null,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSignatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String signature,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final spans = SignatureProcessor.processSignature(signature, context);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingXS,
      ),
      leading: Icon(
        icon,
        size: DesignTokens.iconSizeM,
        color: colorScheme.primary,
      ),
      title: Text(
        title,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: RichText(
        text: TextSpan(children: spans),
      ),
    );
  }
}

/// Compact list of links to the current user's stuff — Messages,
/// Bookmarks, Drafts. Each row navigates to a dedicated page. Pre-
/// Phase-5.17d the Messages slot lived as a top-level bottom-nav tab;
/// the badge moved into Profile so the bottom nav can stay at 5 items
/// (Home / Categories / Tags / Notifications / Profile).
class _ProfileActionsSection extends StatelessWidget {
  final SiteContext siteContext;
  const _ProfileActionsSection({required this.siteContext});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Phase 5.18a — Messages lives in the bottom nav when Chat isn't
    // enabled (we took its slot). To avoid surfacing Messages twice,
    // hide the Profile row in that case. When Chat is enabled, the
    // bottom-nav slot is Chat and Messages needs this row as its
    // entry point (Discourse web nests PMs under the user menu the
    // same way).
    final showMessagesRow = siteContext.chatEnabled;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          border: Border.all(
            color: colorScheme.outlineVariant
                .withValues(alpha: DesignTokens.opacityMediumLow),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            if (showMessagesRow) ...[
              _ActionRow(
                icon: Icons.mail_outline,
                title: 'Messages',
                subtitle: 'Private messages and conversations',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MessagesPage(siteContext: siteContext),
                  ),
                ),
              ),
              Divider(
                height: 1,
                indent: 56,
                color: colorScheme.outlineVariant
                    .withValues(alpha: DesignTokens.opacityDivider),
              ),
            ],
            _ActionRow(
              icon: Icons.bookmark_outline,
              title: 'Bookmarks',
              subtitle: "Posts you've saved for later",
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BookmarksPage(siteContext: siteContext),
                ),
              ),
            ),
            Divider(
              height: 1,
              indent: 56,
              color: colorScheme.outlineVariant
                  .withValues(alpha: DesignTokens.opacityDivider),
            ),
            _ActionRow(
              icon: Icons.edit_note_outlined,
              title: 'Drafts',
              subtitle: 'Unfinished topics and replies',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DraftsListPage(siteContext: siteContext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL,
          vertical: DesignTokens.spacingM,
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                        fontWeight: DesignTokens.fontWeightSemiBold),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 20, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Summary stats block fed by Discourse's
/// `GET /u/{username}/summary.json` (via
/// `DiscourseUserProxy.getUserSummaryAsync`). Self-loading so the
/// profile's main fetch is unaffected; the section stays invisible
/// while loading, on failure, and when the server withheld the
/// numeric stats from this viewer (`canSeeSummaryStats` false — the
/// numbers all come back 0 in that case, so rendering them would be
/// worse than hiding). Below the stats, a "Most liked by" avatar row
/// appears when the summary carries any such users.
class _UserSummarySection extends StatefulWidget {
  final SiteContext siteContext;
  final String username;

  const _UserSummarySection({
    super.key,
    required this.siteContext,
    required this.username,
  });

  @override
  State<_UserSummarySection> createState() => _UserSummarySectionState();
}

class _UserSummarySectionState extends State<_UserSummarySection> {
  DiscourseUserSummary? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await DiscourseUserProxy(widget.siteContext)
          .getUserSummaryAsync(widget.username);
      if (!mounted) return;
      setState(() {
        _summary = result.result ? result.summary : null;
      });
    } catch (e) {
      AppLogger.debug('Error fetching user summary: $e');
      // Section simply stays hidden — the summary is enrichment, not
      // load-bearing profile data.
    }
  }

  /// "3d 4h" / "2h 15m" / "45m" / "< 1m" from a seconds count.
  String _humanizeDuration(int seconds) {
    if (seconds < 60) return '< 1m';
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;
    if (days > 0) {
      final remHours = hours % 24;
      return remHours > 0 ? '${days}d ${remHours}h' : '${days}d';
    }
    if (hours > 0) {
      final remMinutes = minutes % 60;
      return remMinutes > 0 ? '${hours}h ${remMinutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    if (summary == null) return const SizedBox.shrink();

    final showStats = summary.canSeeSummaryStats;
    final likedBy = summary.mostLikedByUsers;
    if (!showStats && likedBy.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final numberFormat = NumberFormat.decimalPattern(
        Localizations.localeOf(context).toString());

    final stats = <({String value, String label})>[
      (
        value: numberFormat.format(summary.daysVisited),
        label: 'Days visited',
      ),
      (
        value: _humanizeDuration(summary.timeRead),
        label: 'Time read',
      ),
      (
        value: numberFormat.format(summary.topicsEntered),
        label: 'Topics entered',
      ),
      (
        value: numberFormat.format(summary.postsReadCount),
        label: 'Posts read',
      ),
      (
        value: numberFormat.format(summary.likesGiven),
        label: 'Likes given',
      ),
      (
        value: numberFormat.format(summary.likesReceived),
        label: 'Likes received',
      ),
    ];

    // Mirrors the profile info card above (margin / border / surface).
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingXS,
      ),
      elevation: DesignTokens.elevationNone,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        side: BorderSide(
          color: colorScheme.outlineVariant
              .withValues(alpha: DesignTokens.opacityLow),
          width: DesignTokens.borderWidthThin,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingL,
          vertical: DesignTokens.spacingM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showStats) ...[
              Text(
                'STATS',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: DesignTokens.letterSpacingWide,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                ),
              ),
              SizedBox(height: DesignTokens.spacingS),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cellWidth =
                      (constraints.maxWidth - 2 * DesignTokens.spacingS) / 3;
                  return Wrap(
                    spacing: DesignTokens.spacingS,
                    runSpacing: DesignTokens.spacingM,
                    children: stats
                        .map(
                          (s) => SizedBox(
                            width: cellWidth,
                            child: Column(
                              children: [
                                Text(
                                  s.value,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: DesignTokens.fontWeightBold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: DesignTokens.spacingXS / 2),
                                Text(
                                  s.label,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
            if (likedBy.isNotEmpty) ...[
              if (showStats) SizedBox(height: DesignTokens.spacingL),
              Text(
                'MOST LIKED BY',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: DesignTokens.letterSpacingWide,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                ),
              ),
              SizedBox(height: DesignTokens.spacingS),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: likedBy.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: DesignTokens.spacingS),
                  itemBuilder: (context, index) {
                    final DiscourseSummaryUser user = likedBy[index];
                    return Tooltip(
                      message: '${user.username} · ${user.count}',
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserProfilePage(
                                siteContext: widget.siteContext,
                                userId: user.id.toString(),
                                userName: user.username,
                                profilePictureUrl: user.avatarUrl.isNotEmpty
                                    ? user.avatarUrl
                                    : null,
                              ),
                            ),
                          );
                        },
                        child: UserAvatar(
                          username: user.username,
                          iconUrl: user.avatarUrl.isNotEmpty
                              ? user.avatarUrl
                              : null,
                          radius: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
