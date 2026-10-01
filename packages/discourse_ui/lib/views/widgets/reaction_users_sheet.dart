import 'package:discourse_core/discourse_core.dart'
    show DiscoursePostProxy, DiscourseReactionUser;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_post_reaction.dart';

import 'package:discourse_ui/services/site_proxy_service.dart';

import '../../core/logging/app_logger.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../utils/post_reactions.dart';
import '../user_profile_page.dart';
import 'empty_state_view.dart';
import 'reaction_glyph.dart';
import 'user_avatar.dart';

/// Who reacted to a post, and with what.
///
/// Opened by a tap on the post's reactions summary. As the web's reactions
/// menu: a title with the number of people, a filter chip per emoji with
/// its count (when more than one emoji was used), and one row per person
/// with their display name, username and emoji. The reader's own reaction
/// comes first, marked "You". A button at the bottom opens the picker for a
/// reader who may react.
///
/// Backed by `DiscoursePostProxy.getReactionUsersAsync`, which serves the
/// `discourse-reactions` list on plugin forums and the stock like list
/// everywhere else. Every row is a person the server reported.
class ReactionUsersSheet extends StatefulWidget {
  final SiteContext siteContext;
  final String postId;

  /// The post's reactions: the counts for the title and the chips, and the
  /// reader's own.
  final List<FCPostReaction> reactions;

  /// The emoji to start filtered on; null for everyone.
  final String? initialReaction;

  /// Opens the reaction picker; null when the reader may not react, which
  /// hides the button.
  final VoidCallback? onReact;

  const ReactionUsersSheet({
    super.key,
    required this.siteContext,
    required this.postId,
    this.reactions = const [],
    this.initialReaction,
    this.onReact,
  });

  static const int pageSize = 30;

  static Future<void> show({
    required BuildContext context,
    required SiteContext siteContext,
    required String postId,
    List<FCPostReaction> reactions = const [],
    String? initialReaction,
    VoidCallback? onReact,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => ReactionUsersSheet(
        siteContext: siteContext,
        postId: postId,
        reactions: reactions,
        initialReaction: initialReaction,
        onReact: onReact,
      ),
    );
  }

  @override
  State<ReactionUsersSheet> createState() => _ReactionUsersSheetState();
}

class _ReactionUsersSheetState extends State<ReactionUsersSheet> {
  final List<DiscourseReactionUser> _users = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  String? _filter;

  /// Not a Discourse forum, so nothing lists who reacted. A flag rather
  /// than [_error]'s text: it is known from initState, before the sheet
  /// can look up its strings.
  bool _unsupported = false;
  int _total = 0;
  int _page = 0;

  /// Bumped on every new filter, so a slow answer for an old one is dropped.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialReaction;
    _load();
  }

  bool get _hasMore => _users.length < _total;

  String? get _viewer => widget.siteContext.currentUsername?.toLowerCase();

  void _select(String? reaction) {
    if (reaction == _filter) return;
    setState(() => _filter = reaction);
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_loadingMore || !_hasMore)) return;
    final generation = more ? _generation : ++_generation;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _error = null;
        _page = 0;
        _users.clear();
        _total = 0;
      }
    });

    final proxy = SiteProxyService.getPostProxy();
    if (proxy is! DiscoursePostProxy) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _unsupported = true;
      });
      return;
    }

    try {
      final result = await proxy.getReactionUsersAsync(
        widget.postId,
        reactionId: _filter,
        page: more ? _page + 1 : 0,
        limit: ReactionUsersSheet.pageSize,
      );
      if (!mounted || generation != _generation) return;
      if (!result.result) {
        setState(() {
          _loading = false;
          _loadingMore = false;
          if (!more) {
            _error = result.resultText.isNotEmpty
                ? result.resultText
                : AppLocalizations.of(context)!.reactionsLoadFailed;
          }
        });
        return;
      }
      setState(() {
        if (more) _page += 1;
        _users.addAll(result.users);
        _total = result.total > _users.length ? result.total : _users.length;
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } catch (e, st) {
      AppLogger.error('ReactionUsersSheet load failed', error: e, stackTrace: st);
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (!more) _error = AppLocalizations.of(context)!.reactionsLoadFailed;
      });
    }
  }

  void _openProfile({required String userId, required String username}) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfilePage(
          siteContext: widget.siteContext,
          userId: userId,
          userName: username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final total = reactionTotal(widget.reactions);
    final mine = viewerReactionOf(widget.reactions);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.spacingM),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      DesignTokens.spacingL, DesignTokens.spacingS, DesignTokens.spacingS, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          total > 0 ? l10n.reactionsTitle(total) : l10n.reactedBy,
                          style: textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: l10n.close,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                if (widget.reactions.length > 1) _buildFilters(context, total),
                Expanded(child: _buildBody(context, scrollController, mine)),
                if (widget.onReact != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        DesignTokens.spacingL, DesignTokens.spacingS, DesignTokens.spacingL, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          final onReact = widget.onReact!;
                          Navigator.pop(context);
                          onReact();
                        },
                        child: Text(mine != null ? l10n.changeYourReaction : l10n.react),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context, int total) {
    final l10n = AppLocalizations.of(context)!;
    final glyphSize = DesignTokens.iconSizeM;
    Widget chip({
      required String? reaction,
      required int count,
      required String semantics,
    }) {
      final selected = _filter == reaction;
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: DesignTokens.spacingS),
        child: Semantics(
          label: semantics,
          selected: selected,
          button: true,
          excludeSemantics: true,
          child: ChoiceChip(
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => _select(reaction),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (reaction == null)
                  Text(l10n.reactionsAll)
                else
                  ReactionGlyph(
                    reactionId: reaction,
                    size: glyphSize,
                    siteContext: widget.siteContext,
                  ),
                const SizedBox(width: DesignTokens.spacingXS),
                Text('$count'),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
          DesignTokens.spacingL, DesignTokens.spacingXS, DesignTokens.spacingL, DesignTokens.spacingS),
      child: Row(
        children: [
          chip(reaction: null, count: total, semantics: '${l10n.reactionsAll}, $total'),
          for (final r in widget.reactions)
            chip(
              reaction: r.id,
              count: r.count,
              semantics: l10n.reactionFilterSemantics(reactionDisplayName(r.id), r.count),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ScrollController scrollController,
    FCPostReaction? mine,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _unsupported ? l10n.reactionsNotSupported : _error;
    if (error != null) {
      return EmptyStateView.error(message: error, onRetry: () => _load());
    }

    // The reader's own row leads, whatever page the server puts it on.
    final viewer = _viewer;
    final showMe = mine != null &&
        viewer != null &&
        (_filter == null || _filter == mine.id);
    final others = viewer == null
        ? _users
        : _users.where((u) => u.username.toLowerCase() != viewer).toList();

    if (!showMe && others.isEmpty) {
      return EmptyStateView(
        icon: Icons.favorite_border,
        message: l10n.noReactionsYet,
      );
    }

    final rows = <Widget>[
      if (showMe)
        _UserRow(
          name: null,
          username: widget.siteContext.currentUsername!,
          avatarUrl: widget.siteContext.currentAvatarUrl ?? '',
          reaction: mine.id,
          isYou: true,
          siteContext: widget.siteContext,
          onTap: () => _openProfile(
            userId: widget.siteContext.currentUserId ?? '',
            username: widget.siteContext.currentUsername!,
          ),
        ),
      for (final u in others)
        _UserRow(
          name: u.name,
          username: u.username,
          avatarUrl: u.avatarUrl,
          reaction: u.reaction ?? _filter,
          isYou: false,
          siteContext: widget.siteContext,
          onTap: () => _openProfile(userId: u.userId, username: u.username),
        ),
    ];

    return ListView.builder(
      controller: scrollController,
      itemCount: rows.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < rows.length) return rows[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
          child: Center(
            child: _loadingMore
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: () => _load(more: true),
                    child: Text(l10n.loadMore),
                  ),
          ),
        );
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  final String? name;
  final String username;
  final String avatarUrl;
  final String? reaction;
  final bool isYou;
  final SiteContext siteContext;
  final VoidCallback onTap;

  const _UserRow({
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.reaction,
    required this.isYou,
    required this.siteContext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasName = name != null && name!.isNotEmpty && name != username;
    final reaction = this.reaction;
    return Semantics(
      label: l10n.viewProfileOfUser(username),
      button: true,
      child: Material(
        color: isYou ? colorScheme.primaryContainer.withValues(alpha: 0.45) : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingL, vertical: DesignTokens.spacingS),
            child: Row(
              children: [
                UserAvatar(
                  username: username,
                  iconUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
                  radius: DesignTokens.avatarRadiusM,
                ),
                const SizedBox(width: DesignTokens.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              hasName ? name! : username,
                              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isYou) ...[
                            const SizedBox(width: DesignTokens.spacingS),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                                border: Border.all(color: colorScheme.primary),
                              ),
                              child: Text(
                                l10n.reactionYou,
                                style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (hasName)
                        Text(
                          '@$username',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (reaction != null && reaction.isNotEmpty) ...[
                  const SizedBox(width: DesignTokens.spacingS),
                  ReactionGlyph(reactionId: reaction, size: 22, siteContext: siteContext),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
