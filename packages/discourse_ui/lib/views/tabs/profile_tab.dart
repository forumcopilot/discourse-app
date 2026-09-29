import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteContextExtension, DiscourseUserProxy, DiscourseUserSummary;
import 'package:discourse_ui/controllers/login_controller.dart';
import 'package:discourse_ui/core/logging/app_logger.dart';
import 'package:discourse_ui/views/widgets/resettable_widget.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/results/fc_forum_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import 'package:get/get.dart';

import '../../host/discourse_host.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/site_proxy_service.dart';
import '../../settings_context.dart';
import '../../theme/design_tokens.dart';
import '../../theme/forum_identity.dart';
import '../../utils/error_message.dart';
import '../../utils/forum_legal_links.dart';
import '../../utils/number_utils.dart';
import '../bookmarks_page.dart';
import '../drafts_list_page.dart';
import '../edit_profile_page.dart';
import '../in_app_web_view_page.dart';
import '../invites_page.dart';
import '../login_page.dart';
import '../my_posts_page.dart';
import '../settings/notification_settings_page.dart';
import '../settings_page.dart';
import '../user_profile_page.dart';
import '../widgets/appearance_sheet.dart';
import '../widgets/editable_profile_avatar.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/forum_icon_tile.dart';
import '../widgets/forum_masthead.dart';
import '../widgets/user_badges_section.dart';

/// The Profile tab: the reader's account on this forum.
///
/// Signed in, it is a hub rather than a public profile — who you are here
/// (avatar, name, trust level, with View profile for how others see you and
/// Edit profile), a strip of your numbers, then your stuff (My posts,
/// Drafts, Bookmarks, Badges, Invites) and the settings that are yours
/// (notifications, do not disturb, appearance, account and privacy, sign
/// out). It used to be the same page everyone else's profile is, which put
/// a public business card where your own things belong and scattered those
/// things over the drawer, a Settings button and an app-bar sign-out icon.
///
/// Signed out, it is where joining happens: the forum, what an account
/// gets you here, and Sign in / Create account — where it used to be an
/// empty "sign in to view profile" page.
class ProfileTab extends StatefulWidget {
  final SiteContext siteContext;
  final bool isActive;
  final bool autoShowLogin;

  /// The forum's member and topic counts, for the guest's welcome.
  final FCBoardStatResult? boardStats;

  const ProfileTab({
    super.key,
    required this.siteContext,
    required this.isActive,
    this.autoShowLogin = false,
    this.boardStats,
  });

  @override
  ProfileTabState createState() => ProfileTabState();
}

class ProfileTabState extends FCStatefulWidget<ProfileTab>
    with FCTabStatefulWidget<ProfileTab> {
  bool _hasLoaded = false;
  FCUserInfoResult? _userInfo;
  String? _userInfoError;
  DiscourseUserSummary? _summary;
  int? _draftCount;
  bool _didAttemptAutoLogin = false;
  late final VoidCallback _authStateListener;

  String? get _username => widget.siteContext.loginDataOutput?.user?.username;

  @override
  void initState() {
    super.initState();
    _fetch();
    _attemptAutoLoginIfNeeded();
    _authStateListener = () {
      if (widget.siteContext.isLoggedIn) {
        if (_userInfo == null || _userInfo!.username != _username) {
          _hasLoaded = false;
          _fetch();
        }
      } else if (mounted) {
        setState(() {
          _userInfo = null;
          _userInfoError = null;
          _summary = null;
          _draftCount = null;
          _hasLoaded = false;
        });
      }
    };
    widget.siteContext.isLoggedInNotifier.addListener(_authStateListener);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetch();
  }

  @override
  void dispose() {
    widget.siteContext.isLoggedInNotifier.removeListener(_authStateListener);
    super.dispose();
  }

  void _attemptAutoLoginIfNeeded() {
    if (_didAttemptAutoLogin) return;
    _didAttemptAutoLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || widget.siteContext.isLoggedIn) return;
      if (!Get.isRegistered<DiscourseLoginController>()) {
        Get.put(DiscourseLoginController());
      }
      final loginController = Get.find<DiscourseLoginController>();
      final loginResult =
          await loginController.attemptAutomaticLogin(widget.siteContext);
      if (!loginResult.success &&
          loginResult.hadCredentials &&
          Get.currentRoute != '/LoginPage') {
        await LoginPage.open(widget.siteContext);
      }
    });
  }

  @override
  void resetTab() {
    _hasLoaded = false;
    clearError();
    _fetch();
  }

  /// The profile, then — without holding it up — the numbers and the
  /// drafts count. The tab used to fetch the reader's replies too, and
  /// page more in on scroll, for a list it never showed.
  Future<void> _fetch() async {
    final username = _username;
    if (!widget.isActive || _hasLoaded || username == null) return;
    _hasLoaded = true;
    try {
      final info =
          await SiteProxyFactory.getUserProxy().getUserInfoAsync(username, null);
      if (!mounted) return;
      if (!info.result) {
        setState(() {
          _userInfoError = (info.resultText?.isNotEmpty ?? false)
              ? info.resultText
              : 'Could not load your profile.';
        });
        _hasLoaded = false;
        return;
      }
      setState(() {
        _userInfo = info;
        _userInfoError = null;
      });
    } catch (e) {
      AppLogger.debug('ProfileTab: profile fetch failed: $e');
      if (mounted) setState(() => _userInfoError = '$e');
      _hasLoaded = false;
      return;
    }
    _fetchSummary(username);
    _fetchDraftCount();
  }

  Future<void> _fetchSummary(String username) async {
    final proxy = SiteProxyFactory.getUserProxy();
    if (proxy is! DiscourseUserProxy) return;
    try {
      final result = await proxy.getUserSummaryAsync(username);
      if (mounted && result.result) setState(() => _summary = result.summary);
    } catch (e) {
      AppLogger.debug('ProfileTab: summary fetch failed: $e');
    }
  }

  Future<void> _fetchDraftCount() async {
    try {
      final result = await SiteProxyService.getDraftProxy().getMyDraftsAsync();
      if (mounted && result.result) {
        setState(() => _draftCount = result.items.length);
      }
    } catch (_) {
      // The count is a courtesy.
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _hasLoaded = false;
      _userInfoError = null;
    });
    clearError();
    await _fetch();
  }

  Future<void> _push(Widget page, {bool refreshAfter = false}) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (refreshAfter && mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.siteContext.isLoggedInNotifier,
      builder: (context, isLoggedIn, _) => isLoggedIn
          ? _buildHub(context)
          : _GuestProfile(
              siteContext: widget.siteContext, boardStats: widget.boardStats),
    );
  }

  Widget _buildHub(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final site = widget.siteContext;
    final user = site.loginDataOutput?.user;
    final username = _username ?? '';
    final info = _userInfo;

    if (info == null && _userInfoError != null) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: DesignTokens.spacingXXL),
              child: EmptyStateView.error(
                message: describeError(_userInfoError, context: context),
                onRetry: _refresh,
              ),
            ),
          ],
        ),
      );
    }

    final name = (info?.displayText ?? '').trim();
    final level = site.trustLevel;
    final subtitle = [
      if (name.isNotEmpty) '@$username',
      if (level != null) l10n.trustLevelN(level),
    ].join(' · ');
    final summary = _summary;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: DesignTokens.spacingXL),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingM),
            child: Row(
              children: [
                EditableProfileAvatar(
                  siteContext: site,
                  username: username,
                  avatarUrl: info?.iconUrl ?? user?.iconUrl,
                  onChanged: _refresh,
                ),
                const SizedBox(width: DesignTokens.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : username,
                        style: textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingL),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _push(
                        UserProfilePage(siteContext: site, userName: username)),
                    child: Text(l10n.viewProfile),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingS),
                Expanded(
                  child: OutlinedButton(
                    onPressed: info == null
                        ? null
                        : () async {
                            final saved = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => EditProfilePage(
                                    siteContext: site, userInfo: info),
                              ),
                            );
                            if (saved == true && mounted) _refresh();
                          },
                    child: Text(l10n.editProfile),
                  ),
                ),
              ],
            ),
          ),
          if (summary != null && summary.canSeeSummaryStats)
            _StatsStrip(
              summary: summary,
              onPosts: () => _push(MyPostsPage(siteContext: site)),
              onSolved: () => _push(MyPostsPage(
                  siteContext: site, initialFilter: MyPostsFilter.solved)),
            )
          else
            const SizedBox(height: DesignTokens.spacingL),
          const _Band(),
          _SectionHeading(l10n.yourStuff),
          _Row(
            icon: Icons.forum_outlined,
            label: l10n.myPosts,
            onTap: () => _push(MyPostsPage(siteContext: site)),
          ),
          _Row(
            icon: Icons.edit_note_outlined,
            label: l10n.drafts,
            count: _draftCount,
            onTap: () async {
              await _push(DraftsListPage(siteContext: site));
              if (mounted) _fetchDraftCount();
            },
          ),
          _Row(
            icon: Icons.bookmark_border,
            label: l10n.bookmarks,
            count: summary?.bookmarkCount,
            onTap: () => _push(BookmarksPage(siteContext: site)),
          ),
          _Row(
            icon: Icons.emoji_events_outlined,
            label: l10n.badges,
            // No count: the profile's badge_count and the badge list
            // disagree (2 against 3 listed for the same account).
            onTap: () => _push(_MyBadgesPage(username: username)),
          ),
          _Row(
            icon: Icons.person_add_alt_outlined,
            label: l10n.invites,
            onTap: () => _push(InvitesPage(siteContext: site)),
          ),
          const _Band(),
          _SectionHeading(l10n.settings),
          _Row(
            icon: Icons.notifications_none,
            label: l10n.notificationSettings,
            onTap: () => _push(const NotificationSettingsPage()),
          ),
          DoNotDisturbTile(siteContext: site),
          if (DiscourseHost.showAppearanceSetting)
            _Row(
              icon: Icons.brightness_6_outlined,
              label: l10n.appearance,
              trailing: Obx(() => Text(
                    appearanceLabel(
                        context, SettingsContext.instance.themeMode.value),
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  )),
              onTap: () => showAppearanceSheet(context),
            ),
          _Row(
            icon: Icons.shield_outlined,
            label: l10n.accountAndPrivacy,
            onTap: () => _push(ForumSettingsPage(siteContext: site)),
          ),
          _Row(
            icon: Icons.logout_rounded,
            label: l10n.signOut,
            color: colorScheme.error,
            onTap: () => _confirmSignOut(context),
          ),
          _LegalFooter(siteContext: site),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.areYouSureYouWantToLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final loginController = Get.isRegistered<DiscourseLoginController>()
        ? Get.find<DiscourseLoginController>()
        : Get.put(DiscourseLoginController());
    await loginController.handleLogout(widget.siteContext);
  }
}

/// Your numbers, each over its label as the topic summary draws them.
/// Posts and solutions open My posts on their own filter.
class _StatsStrip extends StatelessWidget {
  const _StatsStrip({
    required this.summary,
    required this.onPosts,
    required this.onSolved,
  });

  final DiscourseUserSummary summary;
  final VoidCallback onPosts;
  final VoidCallback onSolved;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Every post, the topics' opening posts included, as web's
    // "posts created" counts them.
    final posts = summary.postCount;
    final solved = summary.solvedCount;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingS, vertical: DesignTokens.spacingM),
      child: Row(
        children: [
          _Stat(value: posts, label: l10n.profileStatPosts(posts), onTap: onPosts),
          _Stat(
              value: summary.likesReceived,
              label: l10n.profileStatLikes(summary.likesReceived)),
          _Stat(
              value: summary.daysVisited,
              label: l10n.profileStatDays(summary.daysVisited)),
          // Only on forums running discourse-solved, which is also the
          // only way the summary carries the count.
          if (solved != null)
            _Stat(value: solved, label: l10n.profileStatSolved, onTap: onSolved),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.onTap});

  final int value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final number = formatNumber(context, value);
    return Expanded(
      // The number and its label read as one ("26 posts").
      child: MergeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
            child: Column(
              children: [
                Text(
                  number,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: DesignTokens.fontWeightMedium,
                    height: 1.2,
                  ),
                ),
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The band the topic page sets between sections.
class _Band extends StatelessWidget {
  const _Band();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: const SizedBox(height: DesignTokens.spacingS, width: double.infinity),
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
            DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingXS),
        child: Semantics(
          header: true,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
}

/// One destination on the tab: an icon, a label, and a count or value.
class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.count,
    this.trailing,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? count;
  final Widget? trailing;

  /// For Sign out.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(icon, color: color ?? colorScheme.onSurfaceVariant),
      title: Text(label,
          style: textTheme.bodyLarge?.copyWith(color: color ?? colorScheme.onSurface)),
      trailing: trailing ??
          ((count ?? 0) > 0
              ? Text(formatNumber(context, count!),
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant))
              : null),
      onTap: onTap,
    );
  }
}

/// Terms and Privacy, small, at the end.
class _LegalFooter extends StatelessWidget {
  const _LegalFooter({required this.siteContext});

  final SiteContext siteContext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(DesignTokens.spacingS,
          DesignTokens.spacingM, DesignTokens.spacingS, 0),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          TextButton(
            onPressed: () =>
                ForumLegalLinks.open(ForumLegalLinks.termsUrl(siteContext)),
            child: Text(l10n.termsOfService, style: style),
          ),
          TextButton(
            onPressed: () =>
                ForumLegalLinks.open(ForumLegalLinks.privacyUrl(siteContext)),
            child: Text(l10n.privacyPolicy, style: style),
          ),
        ],
      ),
    );
  }
}

/// Your badges, on a page of their own.
class _MyBadgesPage extends StatelessWidget {
  const _MyBadgesPage({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.badges)),
        body: ListView(
          children: [
            UserBadgesSection(
                username: username, maxToShow: 1000, showHeading: false),
          ],
        ),
      );
}

/// The tab for a guest: the forum, what an account gets you here, and the
/// ways in. It used to be a bare "sign in to view profile" page.
class _GuestProfile extends StatelessWidget {
  const _GuestProfile({required this.siteContext, this.boardStats});

  final SiteContext siteContext;
  final FCBoardStatResult? boardStats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final site = siteContext.site;
    final identity = ForumIdentity.of(context, site);
    final stats = ForumMasthead.statsLine(context, boardStats);
    final benefits = <(IconData, String)>[
      (Icons.add_comment_outlined, l10n.guestBenefitPost),
      (Icons.notifications_none, l10n.guestBenefitNotify),
      (Icons.bookmark_border, l10n.guestBenefitSave),
      if (siteContext.chatEnabled)
        (Icons.chat_bubble_outline, l10n.guestBenefitChat),
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingXL),
      children: [
        const SizedBox(height: DesignTokens.spacingXL),
        Center(child: ForumIconTile(name: site.name, url: identity.icon, size: 64)),
        const SizedBox(height: DesignTokens.spacingM),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXL),
          child: Text(
            l10n.joinForum(site.name),
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        if (stats != null)
          Padding(
            padding: const EdgeInsets.only(top: DesignTokens.spacingXS),
            child: Text(
              stats,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: DesignTokens.spacingL),
        for (final (icon, text) in benefits)
          ListTile(
            dense: true,
            leading: Icon(icon, color: colorScheme.primary),
            title: Text(text, style: textTheme.bodyLarge),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
              DesignTokens.spacingL, DesignTokens.spacingL, DesignTokens.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: () => LoginPage.open(siteContext),
                child: Text(l10n.signIn),
              ),
              const SizedBox(height: DesignTokens.spacingS),
              OutlinedButton(
                onPressed: () => LoginPage.open(siteContext),
                child: Text(l10n.createAccount),
              ),
            ],
          ),
        ),
        const _Band(),
        _SectionHeading(l10n.settings),
        if (DiscourseHost.showAppearanceSetting)
          _Row(
            icon: Icons.brightness_6_outlined,
            label: l10n.appearance,
            trailing: Obx(() => Text(
                  appearanceLabel(
                      context, SettingsContext.instance.themeMode.value),
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                )),
            onTap: () => showAppearanceSheet(context),
          ),
        _Row(
          icon: Icons.info_outline,
          label: l10n.aboutThisForum,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => InAppWebViewPage(
              url: ForumLegalLinks.aboutUrl(siteContext),
              title: site.name,
            ),
          )),
        ),
        _LegalFooter(siteContext: siteContext),
      ],
    );
  }
}
