import 'package:discourse_core/discourse_core.dart' show DiscoursePostProxy;
import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_like.dart';

import 'package:discourse_ui/services/site_proxy_service.dart';

import '../../core/logging/app_logger.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../user_profile_page.dart';
import 'user_avatar.dart';

/// Bottom sheet listing the real users who reacted to a post.
///
/// Backed by `DiscoursePostProxy.getReactionUsersAsync`, which serves
/// the `discourse-reactions` actor list on plugin forums and falls back
/// to the stock `post_action_users` endpoint everywhere else. Nothing
/// here is derived from `FCPost.likesInfo` — that list is intentionally
/// empty; every row shown is a user the server actually reported.
///
/// Pass [reactionId] to scope the list to a single emoji (long-press on
/// a reaction chip); omit it for "everyone who reacted".
class ReactionUsersSheet extends StatefulWidget {
  final SiteContext siteContext;
  final String postId;

  /// Discourse reaction shortcode (e.g. `heart`, `+1`). Null lists all
  /// reactors regardless of which emoji they used.
  final String? reactionId;

  /// Optional header override. Defaults to the localized "Reacted by".
  final String? title;

  const ReactionUsersSheet({
    super.key,
    required this.siteContext,
    required this.postId,
    this.reactionId,
    this.title,
  });

  static const int pageSize = 30;

  static Future<void> show({
    required BuildContext context,
    required SiteContext siteContext,
    required String postId,
    String? reactionId,
    String? title,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusL)),
      ),
      builder: (sheetContext) => ReactionUsersSheet(
        siteContext: siteContext,
        postId: postId,
        reactionId: reactionId,
        title: title,
      ),
    );
  }

  @override
  State<ReactionUsersSheet> createState() => _ReactionUsersSheetState();
}

class _ReactionUsersSheetState extends State<ReactionUsersSheet> {
  final List<FCLike> _users = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _total = 0;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _hasMore => _users.length < _total;

  Future<void> _load({bool more = false}) async {
    if (more && (_loadingMore || !_hasMore)) return;
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
        _error = 'Reactions are not supported on this forum.';
      });
      return;
    }

    try {
      final result = await proxy.getReactionUsersAsync(
        widget.postId,
        reactionId: widget.reactionId,
        page: more ? _page + 1 : 0,
        limit: ReactionUsersSheet.pageSize,
      );
      if (!mounted) return;
      if (!result.result) {
        setState(() {
          _loading = false;
          _loadingMore = false;
          if (!more) {
            _error = result.resultText?.isNotEmpty == true
                ? result.resultText!
                : 'Could not load reactions.';
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
      AppLogger.error('ReactionUsersSheet load failed',
          error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (!more) _error = 'Could not load reactions.';
      });
    }
  }

  /// Convert a Discourse reaction shortcode to its Unicode glyph, or
  /// null when the forum uses a custom emoji we can't render natively
  /// (the header then falls back to the plain heart icon).
  String? _glyphFor(String? shortcode) {
    if (shortcode == null || shortcode.isEmpty) return null;
    final clean = shortcode.replaceAll(':', '').trim();
    final emoji = Emoji.byShortName(clean);
    if (emoji != null && emoji.char.isNotEmpty) return emoji.char;
    return null;
  }

  void _openProfile(FCLike user) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfilePage(
          siteContext: widget.siteContext,
          userId: user.userId,
          userName: user.username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final glyph = _glyphFor(widget.reactionId);
    final title = widget.title ??
        AppLocalizations.of(context)?.reactedBy ??
        'Reacted by';

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: DesignTokens.spacingL,
            horizontal: DesignTokens.spacingL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (glyph != null)
                    Text(glyph,
                        style:
                            const TextStyle(fontSize: DesignTokens.fontSizeL))
                  else
                    Icon(Icons.favorite, color: colorScheme.error),
                  SizedBox(width: DesignTokens.spacingS),
                  Expanded(
                    child: Text(title, style: textTheme.titleMedium),
                  ),
                  Semantics(
                    label: 'Close',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: DesignTokens.spacingM),
              Expanded(child: _buildBody(context, scrollController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ScrollController scrollController) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = _error;
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: colorScheme.error, size: DesignTokens.iconSizeL),
            SizedBox(height: DesignTokens.spacingM),
            Text(
              error,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            SizedBox(height: DesignTokens.spacingM),
            TextButton.icon(
              onPressed: () => _load(),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Text(
          'No reactions yet',
          style: textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: _users.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _users.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
            child: Center(
              child: _loadingMore
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: () => _load(more: true),
                      child: const Text('Load more'),
                    ),
            ),
          );
        }
        final user = _users[index];
        final userGlyph = user.reactionEmoji?.isNotEmpty == true
            ? user.reactionEmoji
            : _glyphFor(user.reactionName);
        return Semantics(
          label: 'View profile of ${user.username}',
          button: true,
          child: InkWell(
            onTap: () => _openProfile(user),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: DesignTokens.spacingS),
              child: Row(
                children: [
                  UserAvatar(
                    username: user.username,
                    iconUrl: user.avatarUrl.isNotEmpty ? user.avatarUrl : null,
                    radius: DesignTokens.avatarRadiusM,
                  ),
                  SizedBox(width: DesignTokens.spacingM),
                  Expanded(
                    child: Text(user.username, style: textTheme.bodyLarge),
                  ),
                  if (userGlyph != null) ...[
                    SizedBox(width: DesignTokens.spacingS),
                    Text(userGlyph,
                        style:
                            const TextStyle(fontSize: DesignTokens.fontSizeM)),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
