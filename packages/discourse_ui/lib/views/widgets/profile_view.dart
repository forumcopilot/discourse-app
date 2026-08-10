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
        DiscourseChatProxy,
        DiscourseUserProxy,
        DiscourseSummaryUser,
        DiscourseSummaryLink,
        DiscourseUserSummary;

import '../../l10n/generated/app_localizations.dart';
import 'profile_section.dart';
import '../../theme/design_tokens.dart';
import '../../theme/style_builders.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/utils/avatar_cache_utils.dart';
import 'package:discourse_ui/utils/error_message.dart';
import 'package:discourse_ui/utils/file_picker_utils.dart';
import 'package:discourse_ui/utils/time_utils.dart';
import 'package:discourse_ui/views/post_page.dart';
import 'package:get/get.dart';

import 'full_screen_image_viewer.dart';
import 'trust_level_sheet.dart';
import 'user_avatar.dart';
import '../chat/chat_channel_view.dart';
import 'user_badges_row.dart';
import 'user_activity_tabs.dart';
import '../edit_profile_page.dart';
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
  bool _isStartingChat = false;

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
    final wasFollowing = _userInfo.isFollowing;
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
        // The personal nav card (Messages / Bookmarks / Drafts) is gone.
        // Messages is a bottom-nav tab in its own right, so the row was a
        // second door to the same room; Bookmarks and Drafts moved to the
        // drawer's Account section, where the rest of "your stuff" lives.
        // Leaving one of the three behind would have been a card with a
        // single row in it.
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
                  isOnline: _userInfo.isOnline,
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

  /// Opens (or reuses) a direct-message chat channel with this user.
  ///
  /// `upsert: true` because the intent is "talk to this person", not
  /// "create a channel" — if one already exists, reuse it rather than
  /// failing or making a duplicate.
  Future<void> _handleStartChat() async {
    if (_isStartingChat) return;
    setState(() => _isStartingChat = true);
    try {
      // Discourse-only: creating a DM channel is not on IFCChatProxy,
      // because the SDK's XenForo-shaped contract has no equivalent.
      final proxy = SiteProxyService.getChatProxy() as DiscourseChatProxy;
      final result = await proxy
          .createDirectMessageChannelAsync([_userInfo.username], upsert: true);
      if (!mounted) return;
      final channel = result.channel;
      if (!result.result || channel == null) {
        // The server refuses for real reasons — DMs disabled, this user
        // does not accept them — so show what it said rather than a
        // generic failure.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Could not open a chat with this user.'),
        ));
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(_userInfo.username)),
            body: ChatChannelView(
              siteContext: widget.siteContext,
              channelId: channel.id,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isStartingChat = false);
    }
  }

  Widget _buildOtherActionRow(
      BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Follow / Unfollow toggle (Discourse 3.x). acceptsFollowers
        // is wired off `can_follow` — we only show the button when
        // the target permits follows.
        if (_userInfo.acceptsFollowers) ...[
          OutlinedButton.icon(
            onPressed: _isTogglingFollow ? null : _handleToggleFollow,
            icon: Icon(
              _userInfo.isFollowing
                  ? Icons.person_remove
                  : Icons.person_add,
              size: DesignTokens.iconSizeM,
            ),
            label: Text(
              _userInfo.isFollowing ? 'Unfollow' : 'Follow',
            ),
          ),
        ],
        if (_userInfo.acceptsPM) ...[
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
          // Web offers Message *and* Chat on a profile. Gated on the
          // server's `can_chat_user`, not on whether the chat plugin is
          // installed: those are different questions, and only the server
          // knows whether this viewer may chat with this person.
          if (_userInfo.canChatUser) ...[
            SizedBox(width: DesignTokens.spacingM),
            OutlinedButton.icon(
              onPressed: _isStartingChat ? null : _handleStartChat,
              icon: Icon(Icons.forum_outlined, size: DesignTokens.iconSizeM),
              label: Text(AppLocalizations.of(context)?.chatWithUser ?? 'Chat'),
            ),
          ],
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
          if (_userInfo.postCount != 0)
            _buildInfoTile(
              context,
              icon: Icons.post_add,
              title: AppLocalizations.of(context)?.posts ?? 'Posts',
              subtitle: NumberFormat.decimalPattern(
                      Localizations.localeOf(context).toString())
                  .format(_userInfo.postCount),
            ),
          // Web's profile header carries these two and the app's did not.
          // Both come from the same /u/{name}.json the page already fetches.
          if (_userInfo.lastSeenAt != null)
            _buildInfoTile(
              context,
              // Not an eye: Views sits directly below with one, and two
              // eyes side by side read as the same statistic twice. Seen
              // is a timestamp, so it takes a clock.
              icon: Icons.schedule,
              title: AppLocalizations.of(context)?.lastSeen ?? 'Seen',
              subtitle: DateFormat.yMMMMd(
                      Localizations.localeOf(context).toString())
                  .add_jm()
                  .format(_userInfo.lastSeenAt!.toLocal()),
            ),
          if (_userInfo.profileViewCount != 0)
            _buildInfoTile(
              context,
              icon: Icons.visibility_outlined,
              title: AppLocalizations.of(context)?.profileViews ?? 'Views',
              subtitle: NumberFormat.decimalPattern(
                      Localizations.localeOf(context).toString())
                  .format(_userInfo.profileViewCount),
            ),
          if (_userInfo.badgeCount != 0)
            _buildInfoTile(
              context,
              icon: Icons.military_tech_outlined,
              title: AppLocalizations.of(context)?.badges ?? 'Badges',
              subtitle: _userInfo.badgeCount.toString(),
            ),
          if (_userInfo.followingCount != 0)
            _buildInfoTile(
              context,
              icon: Icons.people_outline,
              title: AppLocalizations.of(context)?.following ?? 'Following',
              subtitle: _userInfo.followingCount.toString(),
            ),
          if (_userInfo.followerCount != 0)
            _buildInfoTile(
              context,
              icon: Icons.people,
              title: AppLocalizations.of(context)?.followers ?? 'Followers',
              subtitle: _userInfo.followerCount.toString(),
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
          // Additional Information Section (Expandable)
          if (_userInfo.customFieldsList != null &&
              _userInfo.customFieldsList!.isNotEmpty &&
              _userInfo.customFieldsList!.any((f) =>
                  f.value.trim().isNotEmpty &&
                  f.value != "0" &&
                  f.name.toLowerCase() != 'birthday' &&
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

}
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
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await DiscourseUserProxy(widget.siteContext)
          .getUserSummaryAsync(widget.username);
      if (!mounted) return;
      setState(() {
        _summary = result.result ? result.summary : null;
        _error = result.result
            ? null
            : (result.resultText.isNotEmpty
                ? result.resultText
                : 'Could not load stats.');
        _loading = false;
      });
    } catch (e) {
      AppLogger.debug('Error fetching user summary: $e');
      if (!mounted) return;
      setState(() {
        _error = describeError(e, fallback: 'Could not load stats.');
        _loading = false;
      });
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
    // A failed summary used to render nothing at all, which is
    // indistinguishable from "this user has no stats" — and because a
    // rate-limited app fails exactly here, the profile appeared to lose
    // its whole lower half with no explanation. Say so, and offer a retry.
    if (_loading) return const SizedBox.shrink();
    if (summary == null) {
      if (_error == null) return const SizedBox.shrink();
      return _SummaryUnavailable(message: _error!, onRetry: _load);
    }

    final showStats = summary.canSeeSummaryStats;
    final likedBy = summary.mostLikedByUsers;
    final topTopics = summary.topTopics;
    final topReplies = summary.topReplies;
    final topLinks = summary.topLinks;
    final mostLiked = summary.mostLikedUsers;
    final mostRepliedTo = summary.mostRepliedToUsers;
    if (!showStats &&
        likedBy.isEmpty &&
        mostLiked.isEmpty &&
        topTopics.isEmpty &&
        topReplies.isEmpty &&
        topLinks.isEmpty &&
        mostRepliedTo.isEmpty) {
      return const SizedBox.shrink();
    }

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
      // Discourse web shows these two alongside the rest; without them
      // the app's grid read as a truncated version of the same block.
      (
        value: numberFormat.format(summary.topicCount),
        label: 'Topics created',
      ),
      (
        value: numberFormat.format(summary.postCount),
        label: 'Posts created',
      ),
    ];

    // Stats stay in a card (mirroring the info card above); the two lists
    // below are full-width sections in the same shape as "Recent Posts",
    // because that is how this app presents a list of topics.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statsCard(context, colorScheme, textTheme, stats, showStats),
        if (topReplies.isNotEmpty)
          _SummaryTopicSection(
            title: 'Top Replies',
            rows: [
              for (final r in topReplies.take(5))
                _SummaryTopicRowData(
                  title: r.topicTitle,
                  likeCount: r.likeCount,
                  // The topic title is the same for every reply in a topic,
                  // so without the date three rows read identically.
                  createdAt: r.createdAt,
                  // Opens the topic, not the exact post: the summary gives a
                  // post_number, while anchoring needs a post id, and
                  // `gotoPage` is a page index — not the same thing.
                  onTap: () => Get.to(() => PostPage(
                        siteContext: widget.siteContext,
                        topicId: r.topicId.toString(),
                        title: r.topicTitle,
                      )),
                ),
            ],
          ),
        if (topTopics.isNotEmpty)
          _SummaryTopicSection(
            title: 'Top Topics',
            rows: [
              for (final t in topTopics.take(5))
                _SummaryTopicRowData(
                  title: t.title,
                  likeCount: t.likeCount,
                  createdAt: t.createdAt,
                  replyCount:
                      t.postsCount == null ? null : (t.postsCount! - 1),
                  onTap: () => Get.to(() => PostPage(
                        siteContext: widget.siteContext,
                        topicId: t.id.toString(),
                        title: t.title,
                      )),
                ),
            ],
          ),
        // Top Links and Most Replied To complete web's summary. Both were
        // already parsed off /u/{name}/summary.json — only the rendering
        // was missing, so neither costs a request.
        if (likedBy.isNotEmpty)
          _SummaryPeopleStrip(
            title: 'Most Liked By',
            people: likedBy,
            countLabel: (n) => n == 1 ? '1 like' : '$n likes',
            siteContext: widget.siteContext,
          ),
        // Web shows this third people list too. It was already parsed off
        // the same payload and simply never rendered, so it costs nothing.
        if (mostLiked.isNotEmpty)
          _SummaryPeopleStrip(
            title: 'Most Liked',
            people: mostLiked,
            countLabel: (n) => n == 1 ? '1 like' : '$n likes',
            siteContext: widget.siteContext,
          ),
        if (mostRepliedTo.isNotEmpty)
          _SummaryPeopleStrip(
            title: 'Most Replied To',
            people: mostRepliedTo.take(5).toList(),
            countLabel: (n) => n == 1 ? '1 reply' : '$n replies',
            siteContext: widget.siteContext,
          ),
        if (topLinks.isNotEmpty)
          _SummaryLinksSection(links: topLinks.take(5).toList()),
      ],
    );
  }

  Widget _statsCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<({String value, String label})> stats,
    bool showStats,
  ) {
    if (!showStats) return const SizedBox.shrink();
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
          ],
        ),
      ),
    );
  }
}

/// A profile list section: heading plus full-bleed tappable rows, in the
/// shared [ProfileSection] chrome.
class _SummaryTopicSection extends StatelessWidget {
  final String title;
  final List<_SummaryTopicRowData> rows;

  const _SummaryTopicSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            // Rows are title-over-metadata with no card of their own, so
            // two consecutive ones ran together — worst where every reply
            // in a topic repeats the same topic title.
            if (i > 0) const ProfileRowDivider(),
            _SummaryTopicRow(data: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _SummaryTopicRowData {
  final String title;
  final int likeCount;
  final int? replyCount;
  final DateTime? createdAt;
  final VoidCallback onTap;

  const _SummaryTopicRowData({
    required this.title,
    required this.likeCount,
    this.replyCount,
    this.createdAt,
    required this.onTap,
  });
}

/// One topic row. Mirrors the "Recent Posts" item: Material + InkWell,
/// full-bleed, `spacingL` padding, title over a muted metadata line.
class _SummaryTopicRow extends StatelessWidget {
  final _SummaryTopicRowData data;

  const _SummaryTopicRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final meta = <String>[
      if (data.createdAt != null) formatTimeAgo(data.createdAt!, context),
      if (data.likeCount > 0)
        '${data.likeCount} ${data.likeCount == 1 ? 'like' : 'likes'}',
      if (data.replyCount != null && data.replyCount! > 0)
        '${data.replyCount} ${data.replyCount == 1 ? 'reply' : 'replies'}',
    ];
    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: data.onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingL,
            vertical: DesignTokens.spacingM,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (meta.isNotEmpty) ...[
                SizedBox(height: DesignTokens.spacingXS),
                Text(
                  meta.join(' · '),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when the summary fetch failed. The section used to disappear
/// silently, which made a transient failure — a 429 in particular — look
/// like the profile simply had no lower half.
class _SummaryUnavailable extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SummaryUnavailable({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
        child: Row(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: DesignTokens.iconSizeM,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context)?.tryAgain ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}


/// Web's "Top Links": the outbound links this user posted that were
/// clicked most. Tapping opens the link itself, not the post — the whole
/// point of the section is where the link went.
class _SummaryLinksSection extends StatelessWidget {
  const _SummaryLinksSection({required this.links});

  final List<DiscourseSummaryLink> links;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ProfileSection(
      title: 'Top Links',
      contentPadding:
          EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in links)
            InkWell(
              onTap: () async {
                final uri = Uri.tryParse(l.url);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Discourse leaves `title` null for a bare URL.
                      l.title.isNotEmpty ? l.title : l.url,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.primary),
                    ),
                    SizedBox(height: DesignTokens.spacingXS / 2),
                    Text(
                      l.clicks == 1 ? '1 click' : '${l.clicks} clicks',
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The people sections of web's summary — "Most Liked By", "Most Liked",
/// "Most Replied To" — as a swipeable strip of faces.
///
/// One shape for all three, because they are one kind of thing: a person
/// and a count. "Most Liked By" used to live inside the stats card as a
/// row of bare avatars under a `MOST LIKED BY` micro-label, which made a
/// list of people look like a statistic and gave no way to tell who they
/// were without long-pressing for a tooltip. The name is now on screen.
class _SummaryPeopleStrip extends StatelessWidget {
  const _SummaryPeopleStrip({
    required this.title,
    required this.people,
    required this.countLabel,
    required this.siteContext,
  });

  final String title;
  final List<DiscourseSummaryUser> people;

  /// Pluralised unit for the count, e.g. `(n) => n == 1 ? '1 like' : ...`.
  /// The counts mean different things per section and saying so is the
  /// only thing that distinguishes "Most Liked By" from "Most Replied To"
  /// once both are strips of faces.
  final String Function(int) countLabel;

  final SiteContext siteContext;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ProfileSection(
      title: title,
      child: SizedBox(
        height: 108,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
          itemCount: people.length,
          separatorBuilder: (_, __) =>
              SizedBox(width: DesignTokens.spacingS),
          itemBuilder: (context, index) {
            final u = people[index];
            return SizedBox(
              // Wide enough for a typical username at bodySmall; longer
              // ones ellipsize rather than reflowing the strip.
              width: 84,
              child: InkWell(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                onTap: () => Get.to(() => UserProfilePage(
                      siteContext: siteContext,
                      userId: u.id.toString(),
                      userName: u.username,
                      profilePictureUrl:
                          u.avatarUrl.isNotEmpty ? u.avatarUrl : null,
                    )),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: DesignTokens.spacingS,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserAvatar(
                        username: u.username,
                        iconUrl: u.avatarUrl.isNotEmpty ? u.avatarUrl : null,
                        radius: 22,
                      ),
                      SizedBox(height: DesignTokens.spacingXS),
                      Text(
                        u.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: DesignTokens.fontWeightSemiBold,
                        ),
                      ),
                      Text(
                        countLabel(u.count),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
