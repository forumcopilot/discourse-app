import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseSiteCapabilities,
        DiscourseSiteContextExtension,
        DiscourseTopicTracking;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/site_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/forum_identity.dart';
import '../../utils/forum_legal_links.dart';
import '../badges_directory_page.dart';
import '../forum_topics_page.dart';
import '../groups_list_page.dart';
import '../in_app_web_view_page.dart';
import '../login_page.dart';
import '../moderation/reviewables_page.dart';
import '../site_home_tab.dart';
import '../tag_topics_page.dart';
import '../tags_page.dart';
import '../my_posts_page.dart';
import '../users_directory_page.dart';
import 'category_badge.dart' show categoryForum;
import 'category_tile_mark.dart';
import 'drawer_introduction.dart' show DrawerIntroduction;
import 'forum_icon_tile.dart';
import 'remote_circle_avatar.dart';

/// The forum's map, as Discourse's sidebar is on its website: who you are
/// here, then Community, your categories and your tags, each a section that
/// folds and stays folded. A few settings sit folded at the end.
///
/// The categories and tags are the reader's own sidebar on the forum (what
/// they chose on the website), else the forum's defaults for new members,
/// else its top-level categories and most used tags.
class SiteDrawer extends StatelessWidget {
  final SiteContext siteContext;

  /// Whether the Home tab is showing, so Topics is marked as the current
  /// destination.
  final bool homeIsCurrent;

  /// Whether the drawer opened by itself to introduce itself
  /// ([DrawerIntroduction]): a line under the header says what it holds and
  /// how to open it again.
  final bool introduction;

  const SiteDrawer({
    super.key,
    required this.siteContext,
    this.homeIsCurrent = false,
    this.introduction = false,
  });

  /// How many categories and tags the drawer lists before "All …".
  static const _maxCategories = 8;
  static const _maxTags = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final signedIn = siteContext.isLoggedIn;
    final canModerate =
        signedIn && (siteContext.loginDataOutput?.user?.canModerate ?? false);
    final username = siteContext.currentUsername;

    return Drawer(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _Header(siteContext: siteContext),
            if (introduction) const _Introduction(),
            _Section(
              id: 'community',
              label: l10n.community,
              children: [
                _Item(
                  icon: Icons.forum_outlined,
                  label: l10n.home,
                  selected: homeIsCurrent,
                  onTap: () => _goHomeTab(context, SiteHomeTab.topics),
                ),
                if (signedIn && username != null)
                  _Item(
                    icon: Icons.person_outline,
                    label: l10n.myPosts,
                    // Its own screen, as web's sidebar link opens the
                    // activity stream; it used to open the whole profile.
                    onTap: () =>
                        _push(context, MyPostsPage(siteContext: siteContext)),
                  ),
                // Staff only (admin or moderator), as on the website.
                if (canModerate)
                  _Item(
                    icon: Icons.fact_check_outlined,
                    label: l10n.reviewQueue,
                    onTap: () => _push(
                        context, ReviewablesPage(siteContext: siteContext)),
                  ),
                // The forum's less used places, folded as web's sidebar
                // folds them under More. Bookmarks, Drafts, Invites and the
                // settings live on the Profile tab now, with the rest of
                // the reader's own things. A guest has only these, so they
                // show unfolded.
                _MoreItems(
                  label: l10n.drawerMore,
                  folds: signedIn,
                  children: [
                    _Item(
                      icon: Icons.people_outline,
                      label: l10n.users,
                      onTap: () => _push(context,
                          UsersDirectoryPage(siteContext: siteContext)),
                    ),
                    _Item(
                      icon: Icons.groups_outlined,
                      label: l10n.groups,
                      onTap: () => _push(
                          context, GroupsListPage(siteContext: siteContext)),
                    ),
                    _Item(
                      icon: Icons.emoji_events_outlined,
                      label: l10n.badges,
                      onTap: () => _push(context,
                          BadgesDirectoryPage(siteContext: siteContext)),
                    ),
                    _Item(
                      icon: Icons.info_outline,
                      label: l10n.about,
                      onTap: () => _push(
                        context,
                        InAppWebViewPage(
                          url: ForumLegalLinks.aboutUrl(siteContext),
                          title: siteContext.site.name,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _Section(
              id: 'categories',
              label: l10n.categoriesView,
              children: [
                for (final id in categoryIdsFor(siteContext))
                  _CategoryItem(
                    siteContext: siteContext,
                    categoryId: '$id',
                    onTap: () => _push(
                      context,
                      ForumTopicsPage(
                        siteContext: siteContext,
                        forum: categoryForum(siteContext, '$id'),
                      ),
                    ),
                  ),
                _Item(
                  icon: Icons.list,
                  label: l10n.allCategories,
                  onTap: () => _goHomeTab(context, SiteHomeTab.categories),
                ),
              ],
            ),
            _Section(
              id: 'tags',
              label: l10n.tags,
              children: [
                for (final tag in tagsFor(siteContext))
                  _Item(
                    icon: Icons.sell_outlined,
                    label: tag,
                    onTap: () => _push(context,
                        TagTopicsPage(siteContext: siteContext, tag: tag)),
                  ),
                _Item(
                  icon: Icons.list,
                  label: l10n.allTags,
                  onTap: () =>
                      _push(context, TagsPage(siteContext: siteContext)),
                ),
              ],
            ),
            // Terms and Privacy, small, as the web sidebar's footer has
            // them. Notification settings and Appearance moved to the
            // Profile tab.
            _LegalFooter(siteContext: siteContext),
          ],
        ),
      ),
    );
  }

  /// The categories to list: the reader's sidebar, else the forum's
  /// defaults, else its top-level categories in the forum's order; ones the
  /// forum does not describe, and Uncategorized, left out.
  static List<int> categoryIdsFor(SiteContext siteContext) {
    final caps = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl);
    final known = {
      for (final c in caps.categories)
        if (c['id'] is int) c['id'] as int: c,
    };
    List<int> usable(Iterable<int> ids) => ids
        .where((id) => known.containsKey(id) && !caps.isUncategorized('$id'))
        .take(_maxCategories)
        .toList();
    final own = siteContext.sidebarCategoryIds;
    if (own != null && own.isNotEmpty) return usable(own);
    if (caps.defaultSidebarCategoryIds.isNotEmpty) {
      return usable(caps.defaultSidebarCategoryIds);
    }
    final topLevel = caps.categories
        .where((c) => c['parent_category_id'] == null && c['id'] is int)
        .toList()
      ..sort((a, b) => ((a['position'] as num?) ?? 0)
          .compareTo((b['position'] as num?) ?? 0));
    return usable(topLevel.map((c) => c['id'] as int));
  }

  /// The tags to list: the reader's sidebar, else the forum's defaults,
  /// else its most used tags.
  static List<String> tagsFor(SiteContext siteContext) {
    final caps = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl);
    final own = siteContext.sidebarTags;
    final tags = (own != null && own.isNotEmpty)
        ? own
        : caps.defaultSidebarTags.isNotEmpty
            ? caps.defaultSidebarTags
            : caps.topTags;
    return tags.take(_maxTags).toList();
  }

  // Close the drawer first, so the new page arrives over the closed state.
  void _push(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  /// Switches the home to one of its tabs (or Home's Categories view).
  void _goHomeTab(BuildContext context, SiteHomeTab tab) {
    Navigator.of(context).pop();
    if (Get.isRegistered<DiscourseSiteController>()) {
      Get.find<DiscourseSiteController>().requestedHomeTab.value = tab;
    }
  }
}

/// What the drawer is and how to open it again, shown the one time it opens
/// by itself: beside ☰, so the button is recognised in the app bar.
class _Introduction extends StatelessWidget {
  const _Introduction();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Material(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
          child: Row(children: [
            Icon(Icons.menu, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.drawerIntroduction,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSecondaryContainer),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// The forum, small (its identity is already on the screen behind), then
/// the reader: an account card that opens their profile, or a way to sign
/// in.
class _Header extends StatelessWidget {
  const _Header({required this.siteContext});

  final SiteContext siteContext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final site = siteContext.site;
    final identity = ForumIdentity.of(context, site);
    final host = Uri.tryParse(site.url)?.host ?? site.url;
    final user = siteContext.loginDataOutput?.user;
    final signedIn = siteContext.isLoggedIn && user != null;
    final level = siteContext.trustLevel;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            ForumIconTile(name: site.name, url: identity.icon, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(site.name,
                      style: text.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  Text(host,
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Material(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: signedIn
                  ? () {
                      Navigator.of(context).pop();
                      if (Get.isRegistered<DiscourseSiteController>()) {
                        Get.find<DiscourseSiteController>()
                            .requestedHomeTab
                            .value = SiteHomeTab.profile;
                      }
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      RemoteCircleAvatar(
                        radius: 18,
                        backgroundColor: scheme.surfaceContainerHighest,
                        imageUrl: signedIn ? user.iconUrl : null,
                        fallback: Icon(Icons.person_outline,
                            size: 20, color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              signedIn ? user.username : l10n.notSignedIn,
                              style: text.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              signedIn
                                  ? [
                                      if (level != null)
                                        l10n.trustLevelN(level),
                                      l10n.goToYourProfile,
                                    ].join(' · ')
                                  : l10n.signInToPostAndGetNotifications,
                              style: text.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (signedIn)
                        Icon(Icons.chevron_right,
                            color: scheme.onSurfaceVariant),
                    ]),
                    if (!signedIn)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 4),
                        child: Row(children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                LoginPage.open(siteContext);
                              },
                              child: Text(l10n.signIn),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                LoginPage.open(siteContext);
                              },
                              child: Text(l10n.createAccount),
                            ),
                          ),
                        ]),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The community links the drawer folds under "More", as web's sidebar
/// does. Open or closed is remembered, like the sections. Unfolded, and
/// without the More row, when [folds] is off (a guest has nothing else).
class _MoreItems extends StatefulWidget {
  const _MoreItems({
    required this.label,
    required this.children,
    this.folds = true,
  });

  final String label;
  final List<Widget> children;
  final bool folds;

  @override
  State<_MoreItems> createState() => _MoreItemsState();
}

class _MoreItemsState extends State<_MoreItems> {
  static const _key = 'drawer_section_open_more';
  bool _open = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getBool(_key);
      if (saved != null && mounted && saved != _open) {
        setState(() => _open = saved);
      }
    });
  }

  void _toggle() {
    setState(() => _open = !_open);
    SharedPreferences.getInstance().then((p) => p.setBool(_key, _open));
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.folds) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children,
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          expanded: _open,
          child: _Item(
            icon: Icons.more_horiz,
            label: widget.label,
            trailing: Icon(_open ? Icons.expand_less : Icons.expand_more,
                size: 20, color: scheme.onSurfaceVariant),
            onTap: _toggle,
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topCenter,
          child: _open
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.children,
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Terms and Privacy, small, at the foot of the drawer.
class _LegalFooter extends StatelessWidget {
  const _LegalFooter({required this.siteContext});

  final SiteContext siteContext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 4),
          child: Divider(height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(children: [
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
          ]),
        ),
      ],
    );
  }
}

/// A drawer section with a label that folds it. Whether it is open is
/// remembered across launches (Discourse's sidebar does the same).
class _Section extends StatefulWidget {
  const _Section({
    required this.id,
    required this.label,
    required this.children,
  });

  final String id;
  final String label;
  final List<Widget> children;

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  bool _open = true;

  String get _key => 'drawer_section_open_${widget.id}';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getBool(_key);
      if (saved != null && mounted && saved != _open) {
        setState(() => _open = saved);
      }
    });
  }

  void _toggle() {
    setState(() => _open = !_open);
    SharedPreferences.getInstance().then((p) => p.setBool(_key, _open));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 4),
          child: Divider(height: 1),
        ),
        Semantics(
          header: true,
          expanded: _open,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 20, 8),
              child: Row(children: [
                Expanded(
                  child: Text(widget.label,
                      style: text.titleSmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ),
                Icon(_open ? Icons.expand_less : Icons.expand_more,
                    size: 20, color: scheme.onSurfaceVariant),
              ]),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topCenter,
          child: _open
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.children,
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// One destination, Material 3's navigation-drawer item: 48dp, a pill
/// behind the current one.
class _Item extends StatelessWidget {
  const _Item({
    required this.label,
    required this.onTap,
    this.icon,
    this.leading,
    this.trailing,
    this.selected = false,
  });

  final IconData? icon;
  final Widget? leading;
  final String label;
  final Widget? trailing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fg = selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                SizedBox(
                  width: 24,
                  child: Center(child: leading ?? Icon(icon, color: fg)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelLarge?.copyWith(
                        color: selected
                            ? scheme.onSecondaryContainer
                            : scheme.onSurface),
                  ),
                ),
                if (trailing != null) trailing!,
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// A category in the drawer: its own mark and name, and how many of its
/// topics are new or unread for the reader.
class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.siteContext,
    required this.categoryId,
    required this.onTap,
  });

  final SiteContext siteContext;
  final String categoryId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final caps = DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl);
    final style = caps.categoryStyleFor(categoryId);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    Widget counts() {
      if (!siteContext.isLoggedIn) return const SizedBox.shrink();
      final id = int.tryParse(categoryId);
      if (id == null) return const SizedBox.shrink();
      final tracking = DiscourseTopicTracking.forSite(siteContext);
      return ListenableBuilder(
        listenable: tracking,
        builder: (context, _) {
          final c =
              tracking.counts(categoryIds: caps.categoryWithDescendants(id));
          final n = (c?.newTopics ?? 0) + (c?.unreadTopics ?? 0);
          if (n == 0) return const SizedBox.shrink();
          return Text('$n',
              style: text.labelMedium?.copyWith(color: scheme.primary));
        },
      );
    }

    return _Item(
      leading: CategoryTileMark(style: style, size: 20),
      label: style?.name ?? '',
      trailing: counts(),
      onTap: onTap,
    );
  }
}
