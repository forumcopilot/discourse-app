
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseChatProxy,
        DiscourseUserProxy,
        DiscourseUserStatus,
        DiscourseSummaryUser,
        DiscourseSummaryLink,
        DiscourseUserProfileExtras,
        DiscourseUserSummary;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/generated/app_localizations.dart';
import 'profile_section.dart';
import '../../theme/design_tokens.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/utils/emoji_shortcodes.dart';
import 'package:discourse_ui/utils/error_message.dart';
import 'package:discourse_ui/utils/time_utils.dart';
import 'package:discourse_ui/views/post_page.dart';

import '../../utils/local_dates.dart' show timeZoneNamed;
import '../../utils/number_utils.dart';
import '../../utils/snackbar_helper.dart';
import '../profile/profile_common.dart';
import '../profile/status_sheet.dart';
import 'cached_redirect_image.dart';
import 'rich_text_content.dart';
import 'category_badge.dart';
import 'full_screen_image_viewer.dart';
import 'profile_stats_strip.dart';
import 'reaction_glyph.dart';
import 'trust_level_sheet.dart';
import 'user_avatar.dart';
import '../chat/chat_channel_view.dart';
import 'user_badges_section.dart';
import 'user_activity_tabs.dart';
import '../edit_profile_page.dart';
import '../user_profile_page.dart';
import '../private_messaging/conversation/pages/new_conversation_page.dart';
import 'package:discourse_ui/utils/app_navigation.dart';

/// A website address as Discourse's profile shows it (UserSerializer
/// #website_name): host without "www." plus the path, no scheme.
@visibleForTesting
String websiteDisplayName(String website) {
  final uri = Uri.tryParse(website.contains('://') ? website : 'https://$website');
  if (uri == null || uri.host.isEmpty) return website;
  final host = uri.host.replaceFirst(RegExp(r'^www\.'), '');
  final path = uri.path == '/' ? '' : uri.path;
  return '$host$path';
}

/// A person's profile — web's user page — for anyone, the reader's own
/// included ("View profile" on the Profile tab shows it exactly as others
/// see it, with Edit profile in place of Message).
///
/// * A header: their background (profile or card background, else a soft
///   tint) with the avatar over its edge, their name, @username and title,
///   status, bio, location with their local time, website, and one line
///   for when they joined and were last seen.
/// * Message, Chat and Follow where the server allows each.
/// * Their numbers, as the Profile tab and the topic summary draw them.
/// * Pinned tabs: Activity (the shared activity rows), Summary (featured
///   topic, top replies and topics, the people lists, top categories, top
///   links, then details: trust level, groups, views, followers, custom
///   fields) and Badges.
///
/// It used to be a centred avatar over a XenForo-style info card (Member
/// Since, Last Activity, Posts, Seen — two of them the same timestamp —
/// Birthday that could never render), the reader's own editing tools on
/// their own page, and the summary and activity stacked below.
///
/// The host (`UserProfilePage`) owns the user fetch, the app bar and its
/// menu; this widget loads the summary.
class ProfileView extends StatefulWidget {
  final SiteContext siteContext;
  final FCUserInfoResult userInfo;

  /// Whether the profile being shown belongs to the logged-in viewer.
  final bool isSelf;

  /// Fallback avatar URL used when `userInfo.iconUrl` is empty (the
  /// avatar-tap page passes the URL it was opened with).
  final String? fallbackAvatarUrl;

  /// Called after `EditProfilePage` pops with a successful save; the host
  /// refetches.
  final VoidCallback? onEdited;

  /// Kept for hosts that still pass it; avatars are changed on the
  /// Profile tab now.
  final VoidCallback? onAvatarUploaded;

  /// Passed through to the Replies feed so the host can force a refresh.
  final Key? repliesKey;

  /// Bump to refetch the summary (the host does on pull-to-refresh).
  final int refreshToken;

  /// The host's scroll controller. ProfileView is the scrollable itself —
  /// a pinned sliver only pins inside the viewport that owns it.
  final ScrollController? scrollController;

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
    this.scrollController,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

enum _ProfileTab { activity, summary, badges }

class _ProfileViewState extends State<ProfileView> {
  bool _isTogglingFollow = false;
  bool _isStartingChat = false;
  _ProfileTab _tab = _ProfileTab.activity;

  /// Which Activity feed is showing. Lives here because the chip bar is a
  /// pinned sliver and the feed a separate one.
  ActivityTab _activityTab = ActivityTab.replies;

  DiscourseUserSummary? _summary;
  String? _summaryError;
  bool _summaryLoading = true;

  FCUserInfoResult get _userInfo => widget.userInfo;

  DiscourseUserProfileExtras? get _extras => DiscourseUserProfileExtras.forUser(
      widget.siteContext.site.url, _userInfo.username);

  String? get _avatarUrl {
    final iconUrl = _userInfo.iconUrl;
    if (iconUrl != null && iconUrl.isNotEmpty) return iconUrl;
    final fallback = widget.fallbackAvatarUrl;
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  @override
  void didUpdateWidget(covariant ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userInfo.username != widget.userInfo.username ||
        oldWidget.refreshToken != widget.refreshToken) {
      _loadSummary();
    }
  }

  Future<void> _loadSummary() async {
    setState(() {
      _summaryLoading = true;
      _summaryError = null;
    });
    try {
      final registered = SiteProxyService.getUserProxy();
      final proxy = registered is DiscourseUserProxy
          ? registered
          : DiscourseUserProxy(widget.siteContext);
      final result = await proxy.getUserSummaryAsync(_userInfo.username);
      if (!mounted) return;
      setState(() {
        _summary = result.result ? result.summary : null;
        _summaryError = result.result
            ? null
            : (result.resultText.isNotEmpty
                ? result.resultText
                : AppLocalizations.of(context)!.profileStatsLoadFailed);
        _summaryLoading = false;
      });
    } catch (e) {
      AppLogger.debug('Error fetching user summary: $e');
      if (!mounted) return;
      setState(() {
        _summaryError = describeError(e,
            fallback: AppLocalizations.of(context)!.profileStatsLoadFailed);
        _summaryLoading = false;
      });
    }
  }

  /// Toggle the viewer's follow relationship (discourse-follow). Flips
  /// optimistically; reverts on failure.
  Future<void> _handleToggleFollow() async {
    if (_isTogglingFollow) return;
    if (!widget.siteContext.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseLogInToFollowUsers)),
      );
      return;
    }
    final proxy = SiteProxyService.getSocialProxy();
    final wasFollowing = _userInfo.isFollowing;
    setState(() {
      _isTogglingFollow = true;
      _userInfo.isFollowing = !wasFollowing;
    });
    final l10n = AppLocalizations.of(context)!;
    String? errorText;
    try {
      final result = wasFollowing
          ? await proxy.unfollowAsync(_userInfo.username)
          : await proxy.followAsync(_userInfo.username);
      if (!result.result) {
        errorText = result.resultText?.isNotEmpty == true
            ? result.resultText
            : (wasFollowing
                ? l10n.profileUnfollowFailed
                : l10n.profileFollowFailed);
      }
    } catch (e) {
      errorText = l10n.error('$e');
    }
    if (!mounted) return;
    setState(() {
      _isTogglingFollow = false;
      if (errorText != null) _userInfo.isFollowing = wasFollowing;
    });
    if (errorText != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorText)));
    }
  }

  Future<void> _handleStartChat() async {
    if (_isStartingChat) return;
    setState(() => _isStartingChat = true);
    try {
      // Discourse-only: creating a DM channel is not on IFCChatProxy.
      final proxy = SiteProxyService.getChatProxy() as DiscourseChatProxy;
      final result = await proxy
          .createDirectMessageChannelAsync([_userInfo.username], upsert: true);
      if (!mounted) return;
      final channel = result.channel;
      if (!result.result || channel == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : AppLocalizations.of(context)!.profileChatOpenFailed),
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

  /// Edit profile saves each change as it is made, so the profile is
  /// refetched whenever the reader comes back from it.
  Future<void> _openEdit() async {
    await AppNavigation.push<void>(
      context,
      EditProfilePage(siteContext: widget.siteContext, userInfo: _userInfo),
    );
    if (mounted) widget.onEdited?.call();
  }

  /// Your status, from where your profile shows it. Saved by the sheet;
  /// the host refetches so the profile shows the new one.
  Future<void> _editStatus() async {
    final l10n = AppLocalizations.of(context)!;
    final extras = _extras;
    final current = (extras?.hasStatus ?? false)
        ? DiscourseUserStatus(
            description: extras!.statusDescription!,
            emoji: extras.statusEmoji,
            endsAt: extras.statusEndsAt,
          )
        : null;
    final changed = await showStatusSheet(
        context: context, siteContext: widget.siteContext, current: current);
    if (!changed || !mounted) return;
    SnackbarHelper.showInfo(context, l10n.statusUpdated);
    widget.onEdited?.call();
  }

  void _viewAvatar() {
    final url = _avatarUrl;
    if (url == null || url.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FullScreenImageViewer(
        imageUrls: [url],
        initialIndex: 0,
        heroTag: 'profile_picture_${_userInfo.username}',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scaler = MediaQuery.textScalerOf(context);
    return CustomScrollView(
      controller: widget.scrollController,
      // Pull-to-refresh works even when the profile is short.
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _ProfileTabsDelegate(
            labels: [l10n.activity, l10n.profileTabSummary, l10n.badges],
            selected: _tab.index,
            onSelected: (i) => setState(() => _tab = _ProfileTab.values[i]),
            textScaler: scaler,
          ),
        ),
        if (_tab == _ProfileTab.activity) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: ActivityChipBarDelegate(
              selected: _activityTab,
              onSelected: (t) => setState(() => _activityTab = t),
              textScaler: scaler,
            ),
          ),
          SliverToBoxAdapter(
            child: ActivityFeed(
              siteContext: widget.siteContext,
              tab: _activityTab,
              userId: _userInfo.id,
              userName: _userInfo.username,
              repliesKey: widget.repliesKey,
            ),
          ),
        ],
        if (_tab == _ProfileTab.summary)
          SliverToBoxAdapter(
            child: _SummaryTab(
              siteContext: widget.siteContext,
              userInfo: _userInfo,
              extras: _extras,
              summary: _summary,
              loading: _summaryLoading,
              error: _summaryError,
              onRetry: _loadSummary,
            ),
          ),
        if (_tab == _ProfileTab.badges)
          SliverToBoxAdapter(
            child: UserBadgesSection(
              username: _userInfo.username,
              maxToShow: 1000,
              showHeading: false,
            ),
          ),
        const SliverToBoxAdapter(
            child: SizedBox(height: DesignTokens.spacingXL)),
      ],
    );
  }

  /// The band behind the picture: a strip of colour, or taller when it is
  /// the person's cover photo, so the photo can be seen.
  static const double _bandHeight = 88;
  static const double _coverHeight = 132;
  static const double _avatarRadius = 40;
  static const double _ring = 4;

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final extras = _extras;
    final name = (_userInfo.displayText ?? '').trim();
    final title = extras?.title;
    final subline = [
      if (name.isNotEmpty) '@${_userInfo.username}',
      if (title != null) title,
    ].join(' · ');
    final bio = (extras?.bioText ?? _userInfo.bio ?? '').trim();
    final avatarBox = (_avatarRadius + _ring) * 2;
    final summary = _summary;
    final band = extras?.backgroundUrl != null ? _coverHeight : _bandHeight;
    final cookedBio = extras?.bioCooked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: band + avatarBox / 2,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: band,
                child: extras?.backgroundUrl != null
                    ? CachedRedirectImage(
                        imageUrl: extras!.backgroundUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            ColoredBox(color: colorScheme.surfaceContainerHigh),
                        errorWidget: (_, __, ___) =>
                            ColoredBox(color: colorScheme.surfaceContainerHigh),
                      )
                    : ColoredBox(color: colorScheme.surfaceContainerHigh),
              ),
              Positioned(
                left: DesignTokens.spacingL - _ring,
                top: band - avatarBox / 2,
                child: GestureDetector(
                  onTap: _viewAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(_ring),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        UserAvatar(
                          username: _userInfo.username,
                          iconUrl: _avatarUrl,
                          radius: _avatarRadius,
                        ),
                        // The flair of the group they chose, as web draws it
                        // on their picture.
                        if (extras?.hasFlair ?? false)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: UserFlairBadge(
                              flairUrl: extras!.flairUrl!,
                              bgHex: extras.flairBgColor,
                              fgHex: extras.flairColor,
                              size: 28,
                              ringColor: colorScheme.surface,
                              semanticLabel: extras.flairName,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
              DesignTokens.spacingS, DesignTokens.spacingL, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: DesignTokens.spacingS,
                children: [
                  Text(
                    name.isNotEmpty ? name : _userInfo.username,
                    style: textTheme.headlineSmall,
                  ),
                  if (_userInfo.isBanned)
                    Chip(
                      avatar: Icon(Icons.block,
                          size: DesignTokens.iconSizeS,
                          color: colorScheme.onErrorContainer),
                      label: Text(l10n.profileSuspended),
                      backgroundColor: colorScheme.errorContainer,
                      labelStyle: textTheme.labelMedium
                          ?.copyWith(color: colorScheme.onErrorContainer),
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              if (subline.isNotEmpty)
                Text(
                  subline,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              if (extras?.hasStatus ?? false) ...[
                const SizedBox(height: DesignTokens.spacingS),
                InkWell(
                  // Your own status is changed where it is shown.
                  onTap: widget.isSelf ? _editStatus : null,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  child: Row(
                    children: [
                      if (extras!.statusEmoji != null) ...[
                        ReactionGlyph(
                          reactionId: extras.statusEmoji!,
                          size: DesignTokens.iconSizeM,
                          siteContext: widget.siteContext,
                        ),
                        const SizedBox(width: DesignTokens.spacingS),
                      ],
                      Expanded(
                        child: Text(extras.statusDescription!,
                            style: textTheme.bodyMedium),
                      ),
                      if (widget.isSelf)
                        Icon(Icons.edit_outlined,
                            size: DesignTokens.iconSizeS,
                            color: colorScheme.onSurfaceVariant,
                            semanticLabel: l10n.setStatus),
                    ],
                  ),
                ),
              ] else if (widget.isSelf &&
                  forumHasUserStatus(widget.siteContext)) ...[
                const SizedBox(height: DesignTokens.spacingXS),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spacingS)),
                    onPressed: _editStatus,
                    icon: const Icon(Icons.add_reaction_outlined,
                        size: DesignTokens.iconSizeM),
                    label: Text(l10n.setAStatus),
                  ),
                ),
              ],
              if (bio.isNotEmpty) ...[
                const SizedBox(height: DesignTokens.spacingS),
                // With links, the bio as the forum cooked it, so they can
                // be tapped; otherwise plain text, cut at six lines.
                if (cookedBio != null && cookedBio.contains('<a '))
                  RichTextContent(
                    siteContext: widget.siteContext,
                    content: cookedBio,
                    baseFontSize: textTheme.bodyMedium?.fontSize,
                  )
                else
                  Text(bio,
                      style: textTheme.bodyMedium,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis),
              ],
              if (extras != null && extras.fields.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: DesignTokens.spacingS),
                  child: Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      for (final f in extras.fields)
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                                end: DesignTokens.spacingM,
                                bottom: DesignTokens.spacingXS),
                            child: Text(f.name,
                                style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: DesignTokens.spacingXS),
                            child: Text(f.value, style: textTheme.bodyMedium),
                          ),
                        ]),
                    ],
                  ),
                ),
              _buildMetaLine(context, extras),
              _buildDatesLine(context),
              const SizedBox(height: DesignTokens.spacingM),
              _buildActions(context),
            ],
          ),
        ),
        if (summary != null && summary.canSeeSummaryStats)
          ProfileStatsStrip(summary: summary)
        else
          const SizedBox(height: DesignTokens.spacingM),
      ],
    );
  }

  /// Location with their local time, and website.
  Widget _buildMetaLine(
      BuildContext context, DiscourseUserProfileExtras? extras) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final muted = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: colorScheme.onSurfaceVariant);
    final location = (_userInfo.location ?? '').trim();
    final website = (_userInfo.website ?? '').trim();
    final zone = timeZoneNamed(extras?.timezone);
    final localTime = zone == null
        ? null
        : DateFormat.jm(Localizations.localeOf(context).toString())
            .format(tz.TZDateTime.now(zone));
    if (location.isEmpty && website.isEmpty && localTime == null) {
      return const SizedBox.shrink();
    }
    Widget item(IconData icon, String text, {VoidCallback? onTap, Color? color}) {
      final row = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: DesignTokens.iconSizeS, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: DesignTokens.spacingXS),
          Flexible(
            child: Text(text,
                style: color == null ? muted : muted?.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
      return onTap == null ? row : InkWell(onTap: onTap, child: row);
    }

    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacingS),
      child: Wrap(
        spacing: DesignTokens.spacingM,
        runSpacing: DesignTokens.spacingXS,
        children: [
          if (location.isNotEmpty) item(Icons.place_outlined, location),
          if (localTime != null)
            item(Icons.schedule, l10n.profileLocalTime(localTime)),
          if (website.isNotEmpty)
            item(
              Icons.link,
              websiteDisplayName(website),
              color: colorScheme.primary,
              onTap: () {
                final uri = Uri.tryParse(
                    website.contains('://') ? website : 'https://$website');
                if (uri != null) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
    );
  }

  /// "Joined Mar 2024 · Seen 2 hours ago" — one line where the info card
  /// had Member Since, Last Activity and Seen (the last two the same time).
  Widget _buildDatesLine(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final joined = _userInfo.registrationTime;
    final seen = _userInfo.lastSeenAt ?? _userInfo.lastActivityTime;
    final parts = [
      if (joined != null)
        l10n.profileJoined(
            DateFormat.yMMM(Localizations.localeOf(context).toString())
                .format(joined.toLocal())),
      if (seen != null) l10n.profileSeen(formatTimeAgo(seen, context)),
    ];
    if (parts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacingXS),
      child: Text(
        parts.join(' · '),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  /// Message, Chat and Follow where the server allows each; on the
  /// reader's own profile, Edit profile.
  Widget _buildActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.isSelf) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: OutlinedButton.icon(
          onPressed: _openEdit,
          icon: const Icon(Icons.edit_outlined, size: DesignTokens.iconSizeM),
          label: Text(l10n.editProfile),
        ),
      );
    }
    final buttons = <Widget>[
      if (_userInfo.acceptsPM)
        FilledButton.tonalIcon(
          onPressed: () => NewConversationPage.open(
            context,
            siteContext: widget.siteContext,
            initialRecipient: _userInfo.username,
            initialRecipientIconUrl: _avatarUrl,
          ),
          icon: const Icon(Icons.mail_outline, size: DesignTokens.iconSizeM),
          label: Text(l10n.sendMessage),
        ),
      if (_userInfo.canChatUser)
        OutlinedButton.icon(
          onPressed: _isStartingChat ? null : _handleStartChat,
          icon: const Icon(Icons.chat_bubble_outline, size: DesignTokens.iconSizeM),
          label: Text(l10n.chatWithUser),
        ),
      if (_userInfo.acceptsFollowers)
        OutlinedButton.icon(
          onPressed: _isTogglingFollow ? null : _handleToggleFollow,
          icon: Icon(
              _userInfo.isFollowing
                  ? Icons.person_remove_outlined
                  : Icons.person_add_outlined,
              size: DesignTokens.iconSizeM),
          label: Text(_userInfo.isFollowing ? l10n.unfollowUser : l10n.followUser),
        ),
    ];
    if (buttons.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: DesignTokens.spacingS,
      runSpacing: DesignTokens.spacingS,
      children: buttons,
    );
  }
}

/// Activity · Summary · Badges, pinned under the header.
class _ProfileTabsDelegate extends SliverPersistentHeaderDelegate {
  const _ProfileTabsDelegate({
    required this.labels,
    required this.selected,
    required this.onSelected,
    required this.textScaler,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;
  final TextScaler textScaler;

  double get _height => 16 + textScaler.scale(20) + 14;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: colorScheme.surface,
      elevation: overlapsContent ? DesignTokens.elevationLow : 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Semantics(
                  selected: i == selected,
                  button: true,
                  child: InkWell(
                    onTap: () => onSelected(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          labels[i],
                          style: textTheme.titleSmall?.copyWith(
                            color: i == selected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 11),
                        Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: i == selected
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ProfileTabsDelegate old) =>
      old.selected != selected ||
      old.labels.join() != labels.join() ||
      old.textScaler != textScaler;
}

/// The Summary tab: what the person is known for here, then the details
/// the old info card listed.
class _SummaryTab extends StatelessWidget {
  const _SummaryTab({
    required this.siteContext,
    required this.userInfo,
    required this.extras,
    required this.summary,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final SiteContext siteContext;
  final FCUserInfoResult userInfo;
  final DiscourseUserProfileExtras? extras;
  final DiscourseUserSummary? summary;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final s = summary;
    final featuredId = extras?.featuredTopicId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (loading && s == null)
          const Padding(
            padding: EdgeInsets.all(DesignTokens.spacingXL),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (s == null && error != null)
          _SummaryUnavailable(message: error!, onRetry: onRetry),
        if (featuredId != null)
          ProfileSection(
            title: l10n.featuredTopic,
            child: ListTile(
              leading: const Icon(Icons.push_pin_outlined),
              title: Text(withEmojiShortcodes(extras?.featuredTopicTitle ?? '')),
              onTap: () => AppNavigation.pushGlobal(PostPage(
                siteContext: siteContext,
                topicId: '$featuredId',
                title: extras?.featuredTopicTitle ?? '',
              )),
            ),
          ),
        if (s != null) ..._summaryLists(context, l10n, s),
        _details(context, l10n),
      ],
    );
  }

  List<Widget> _summaryLists(
      BuildContext context, AppLocalizations l10n, DiscourseUserSummary s) {
    return [
      if (s.topReplies.isNotEmpty)
        _SummaryTopicSection(
          title: l10n.summaryTopReplies,
          rows: [
            for (final r in s.topReplies.take(5))
              _SummaryTopicRowData(
                title: r.topicTitle,
                likeCount: r.likeCount,
                createdAt: r.createdAt,
                onTap: () => AppNavigation.pushGlobal(PostPage(
                  siteContext: siteContext,
                  topicId: r.topicId.toString(),
                  title: r.topicTitle,
                )),
              ),
          ],
        ),
      if (s.topTopics.isNotEmpty)
        _SummaryTopicSection(
          title: l10n.summaryTopTopics,
          rows: [
            for (final t in s.topTopics.take(5))
              _SummaryTopicRowData(
                title: t.title,
                likeCount: t.likeCount,
                createdAt: t.createdAt,
                replyCount: t.postsCount == null ? null : (t.postsCount! - 1),
                onTap: () => AppNavigation.pushGlobal(PostPage(
                  siteContext: siteContext,
                  topicId: t.id.toString(),
                  title: t.title,
                )),
              ),
          ],
        ),
      if (s.mostLikedByUsers.isNotEmpty)
        _SummaryPeopleStrip(
          title: l10n.summaryMostLikedBy,
          people: s.mostLikedByUsers,
          countLabel: l10n.summaryLikeCount,
          siteContext: siteContext,
        ),
      if (s.mostLikedUsers.isNotEmpty)
        _SummaryPeopleStrip(
          title: l10n.summaryMostLiked,
          people: s.mostLikedUsers,
          countLabel: l10n.summaryLikeCount,
          siteContext: siteContext,
        ),
      if (s.mostRepliedToUsers.isNotEmpty)
        _SummaryPeopleStrip(
          title: l10n.summaryMostRepliedTo,
          people: s.mostRepliedToUsers.take(5).toList(),
          countLabel: l10n.nReplies,
          siteContext: siteContext,
        ),
      if (s.topCategories.isNotEmpty)
        ProfileSection(
          title: l10n.summaryTopCategories,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final c in s.topCategories.take(5))
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.spacingXS),
                  child: Row(
                    children: [
                      Flexible(
                        child: CategoryBadge(
                          siteContext: siteContext,
                          categoryId: '${c.id}',
                          fallbackName: c.name,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacingS),
                      Text(
                        [
                          if (c.topicCount > 0)
                            l10n.countTopics(c.topicCount, '${c.topicCount}'),
                          if (c.postCount > 0)
                            '${c.postCount} ${l10n.profileStatPosts(c.postCount)}',
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      if (s.topLinks.isNotEmpty)
        _SummaryLinksSection(links: s.topLinks.take(5).toList()),
    ];
  }

  /// Trust level, groups, views, followers and custom fields: what the old
  /// info card had that is not already in the header.
  Widget _details(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final level = userInfo.trustLevel;
    final groups = userInfo.userGroups;
    final fields = userInfo.customFields
        .where((f) => f.name.isNotEmpty && f.value.trim().isNotEmpty)
        .toList();
    Widget row(IconData icon, String label, String? value, {VoidCallback? onTap}) =>
        ListTile(
          dense: true,
          leading: Icon(icon, color: colorScheme.onSurfaceVariant),
          title: Text(label, style: textTheme.bodyMedium),
          trailing: value != null
              ? Text(value,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant))
              : (onTap != null
                  ? Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant)
                  : null),
          onTap: onTap,
        );
    return ProfileSection(
      title: l10n.profileDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (level != null)
            // What the level means is one tap away, as before.
            row(Icons.verified_outlined, l10n.trustLevelN(level), null,
                onTap: () =>
                    TrustLevelSheet.show(context: context, currentLevel: level)),
          if (userInfo.profileViewCount > 0)
            row(Icons.visibility_outlined, l10n.profileViews,
                formatNumber(context, userInfo.profileViewCount)),
          if (userInfo.acceptsFollowers || userInfo.followerCount > 0) ...[
            row(Icons.people_outline, l10n.followers,
                formatNumber(context, userInfo.followerCount)),
            row(Icons.person_outline, l10n.following,
                formatNumber(context, userInfo.followingCount)),
          ],
          for (final f in fields) row(Icons.info_outline, f.name, f.value),
          if (groups.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                  DesignTokens.spacingS, DesignTokens.spacingL, 0),
              child: Wrap(
                spacing: DesignTokens.spacingS,
                runSpacing: DesignTokens.spacingS,
                children: [
                  for (final g in groups)
                    Chip(
                      avatar: const Icon(Icons.groups_outlined,
                          size: DesignTokens.iconSizeS),
                      label: Text(g),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
        ],
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
    final l10n = AppLocalizations.of(context)!;
    final meta = <String>[
      if (data.createdAt != null) formatTimeAgo(data.createdAt!, context),
      if (data.likeCount > 0) l10n.summaryLikeCount(data.likeCount),
      if (data.replyCount != null && data.replyCount! > 0)
        l10n.nReplies(data.replyCount!),
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
                withEmojiShortcodes(data.title),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
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
              child: Text(AppLocalizations.of(context)!.tryAgain),
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
      title: AppLocalizations.of(context)!.summaryTopLinks,
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
                      AppLocalizations.of(context)!.summaryLinkClicks(l.clicks),
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
                onTap: () => AppNavigation.pushGlobal(UserProfilePage(
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
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        countLabel(u.count),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
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
