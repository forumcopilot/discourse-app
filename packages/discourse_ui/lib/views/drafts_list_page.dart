import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_draft.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_draft_proxy.dart';

import '../theme/design_tokens.dart';
import '../utils/emoji_shortcodes.dart';
import '../utils/draft_tags.dart';
import '../utils/markdown_preview.dart';
import '../utils/time_utils.dart';
import 'lists/posts_list.dart';
import 'new_topic_page.dart';
import 'post_page.dart';
import 'reply_page.dart';
import 'widgets/activity_row.dart' show QuotedExcerpt;
import 'widgets/empty_state_view.dart';
import 'widgets/topic_taxonomy_chips.dart';
import 'widgets/simple_list_app_bar.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/error_message.dart';
import 'private_messaging/conversation/pages/new_conversation_page.dart';
import 'package:discourse_ui/utils/app_navigation.dart';

/// Discourse-native drafts list (`/drafts.json`). Surfaces all of the
/// current user's saved drafts — new topics, replies, and PMs.
/// Tapping a row opens the matching composer pre-filled by the
/// existing draft-controller plumbing.
class DraftsListPage extends StatefulWidget {
  final SiteContext siteContext;

  const DraftsListPage({super.key, required this.siteContext});

  @override
  State<DraftsListPage> createState() => _DraftsListPageState();
}

class _DraftsListPageState extends State<DraftsListPage> {
  // Keep requests (especially a delete after the Undo timeout) on the
  // forum that opened this page, even after the global forum changes.
  late final IFCDraftProxy _draftProxy = SiteProxyService.getDraftProxy();
  List<FCDraft>? _drafts;
  final _pendingDeletes = <String>{};
  bool _loading = false;
  bool _hasMore = false;
  bool _retryMore = false;
  int _nextPage = 0;
  int _loadGeneration = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_loading || !_hasMore)) return;
    final generation = ++_loadGeneration;
    final page = more ? _nextPage : 0;
    setState(() {
      _loading = true;
      _error = null;
      _retryMore = more;
    });
    try {
      final result = await _draftProxy.getMyDraftsAsync(page: page);
      if (!mounted || generation != _loadGeneration) return;
      if (!result.result) {
        throw Exception(result.resultText?.isNotEmpty == true
            ? result.resultText!
            : AppLocalizations.of(context)!.failedToLoadDrafts);
      }
      setState(() {
        // Offset pages can overlap when drafts are edited elsewhere. Also
        // keep a refreshed row hidden while its Undo/delete is pending.
        _drafts = {
          if (more)
            for (final draft in _drafts ?? <FCDraft>[])
              if (!_pendingDeletes.contains(draft.draftKey))
                draft.draftKey: draft,
          for (final draft in result.items)
            if (!_pendingDeletes.contains(draft.draftKey))
              draft.draftKey: draft,
        }.values.toList();
        // The Discourse proxy requests 50; total is this page's length,
        // not a grand total. A full page may have another page after it.
        _hasMore = result.items.length == 50;
        _nextPage = page + 1;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _loading = false;
        _error = describeError(e);
      });
    }
  }

  /// Discards at once and deletes on the server when the Undo snackbar
  /// closes without an Undo — in place of a confirm dialog before every
  /// discard. An undone discard comes back exactly as it was.
  void _delete(FCDraft draft) {
    final drafts = _drafts;
    if (drafts == null) return;
    final index = drafts.indexWhere((d) => d.draftKey == draft.draftKey);
    if (index < 0 || !_pendingDeletes.add(draft.draftKey)) return;
    setState(() => _drafts = [...drafts]..removeAt(index));
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    messenger.hideCurrentSnackBar();
    // Timed, not persistent: since Flutter 3.38 a snackbar with an action
    // stays up until tapped, and the delete waits for it to close.
    final controller = messenger.showSnackBar(SnackBar(
      content: Text(l10n.draftDiscarded),
      action: SnackBarAction(label: l10n.undo, onPressed: () {}),
      persist: false,
      duration: const Duration(seconds: 5),
    ));
    void restore() {
      _pendingDeletes.remove(draft.draftKey);
      if (!mounted) return;
      final now = [...?_drafts];
      if (now.any((d) => d.draftKey == draft.draftKey)) return;
      now.insert(index.clamp(0, now.length), draft);
      setState(() => _drafts = now);
    }

    controller.closed.then((reason) async {
      if (reason == SnackBarClosedReason.action) {
        restore();
        return;
      }
      try {
        final result = await _draftProxy.deleteDraftAsync(draft.draftKey,
            sequence: draft.sequence);
        if (!result.result) {
          throw Exception(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : l10n.failedToDiscardDraft);
        }
        _pendingDeletes.remove(draft.draftKey);
        // Deleting changes every later offset. Restart the listing so
        // Load more cannot skip a draft shifted into the previous page.
        if (mounted) await _load();
      } catch (error) {
        restore();
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(
          content: Text(describeError(error, context: context)),
        ));
      }
    });
  }

  /// A new topic's draft: `new_topic`, or `new_topic_<timestamp>` as the web
  /// keys them (one per topic being written). Only the first was recognised,
  /// so a draft started on the web showed as a reply and tapping did nothing.
  static bool _isNewTopicDraft(FCDraft draft) =>
      draft.draftKey == 'new_topic' || draft.draftKey.startsWith('new_topic_');

  /// Opens [draft] where it belongs, then reloads the list: a draft sent or
  /// discarded from there is gone, and one kept has moved to the top. The
  /// list used to stay as it was, so a sent draft stayed listed and tapping
  /// it opened an empty composer.
  Future<void> _resume(FCDraft draft) async {
    await _open(draft);
    if (mounted) await _load();
  }

  Future<void> _open(FCDraft draft) async {
    // Reply drafts → ReplyPage anchored on the topic.
    // New-topic drafts → NewTopicPage in the saved category (or "" if
    //   the draft is uncategorised).
    // New-message drafts → New Message, with the saved recipients.
    //   (A reply to a message is a `topic_<id>` draft like any reply.)
    if (NewConversationPage.isDraftKey(draft.draftKey)) {
      await NewConversationPage.open(context,
          siteContext: widget.siteContext, draftKey: draft.draftKey);
      return;
    }
    if (draft.draftKey.startsWith('topic_')) {
      final topicId = draft.draftKey.substring('topic_'.length);
      if (topicId.isEmpty) return;
      await Navigator.of(context).push(
        FormPageRoute(
          builder: (_) => ReplyPage(
            siteContext: widget.siteContext,
            threadId: topicId,
            topicTitle: draft.title ?? '',
          ),
        ),
      );
      return;
    }
    if (_isNewTopicDraft(draft)) {
      await Navigator.of(context).push(
        FormPageRoute(
          builder: (_) => NewTopicPage(
            siteContext: widget.siteContext,
            draftKey: draft.draftKey,
            forumId: (draft.categoryId ?? '').toString(),
            // Named, so the category chip does not come back blank.
            forumName: draft.categoryId == null
                ? ''
                : DiscourseSiteCapabilities.forSite(
                            widget.siteContext.site.pluginUrl)
                        .categoryNameFor(draft.categoryId.toString()) ??
                    '',
          ),
        ),
      );
      return;
    }
    // Topic-anchored drafts that we don't recognise — fall back to
    // opening the topic if we have an id.
    if (draft.topicId != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PostPage(
            siteContext: widget.siteContext,
            topicId: draft.topicId!.toString(),
            title: draft.title ?? '',
            mode: PostsListMode.normal,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final drafts = _drafts;

    return Scaffold(
      appBar: SimpleListAppBar(title: l10n.drafts),
      body: Column(
        children: [
          if (_error != null && !_retryMore && drafts?.isNotEmpty == true)
            MaterialBanner(
              content: Text(_error!),
              actions: [
                TextButton(onPressed: () => _load(), child: Text(l10n.retry)),
              ],
            ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: _load,
            child: () {
              if (_loading && drafts == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if ((drafts == null || drafts.isEmpty) && _error != null) {
                return EmptyStateView.error(
                  message: _error!,
                  scrollable: true,
                  onRetry: () => _load(),
                );
              }
              if (drafts == null || drafts.isEmpty) {
                return EmptyStateView.scrollable(
                  icon: Icons.edit_note_outlined,
                  message: l10n.draftsEmpty,
                  hint: l10n.draftsEmptyHint,
                );
              }
              // Today, then Earlier, set apart by the topic page's band.
              final rows = <Object>[];
              bool? todayGroup;
              for (final d in drafts) {
                final isToday = _isToday(d.updatedAt);
                if (isToday != todayGroup) {
                  rows.add(_Group(isToday, first: todayGroup == null));
                  todayGroup = isToday;
                }
                rows.add(d);
              }
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: rows.length +
                    ((_loading || (_error != null ? _retryMore : _hasMore))
                        ? 1
                        : 0),
                itemBuilder: (_, i) {
                  if (i == rows.length) {
                    return Padding(
                      padding: const EdgeInsets.all(DesignTokens.spacingL),
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                if (_error != null) Text(_error!),
                                TextButton(
                                  onPressed: () =>
                                      _load(more: _error == null || _retryMore),
                                  child: Text(_error == null
                                      ? l10n.loadMore
                                      : l10n.retry),
                                ),
                              ],
                            ),
                    );
                  }
                  final row = rows[i];
                  if (row is _Group) return _groupHeader(context, l10n, row);
                  final d = row as FCDraft;
                  final next = i + 1 < rows.length ? rows[i + 1] : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DraftTile(
                        key: ValueKey('draft-${d.draftKey}'),
                        siteContext: widget.siteContext,
                        draft: d,
                        kind: _kindOf(d),
                        onTap: () => _resume(d),
                        onDiscard: () => _delete(d),
                      ),
                      if (next is FCDraft)
                        Divider(
                          height: 1,
                          indent: 72,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                    ],
                  );
                },
              );
            }(),
          )),
        ],
      ),
    );
  }

  static bool _isToday(DateTime? t) {
    if (t == null) return false;
    final local = t.toLocal();
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  _DraftKind _kindOf(FCDraft d) {
    if (NewConversationPage.isDraftKey(d.draftKey)) return _DraftKind.message;
    if (_isNewTopicDraft(d)) return _DraftKind.newTopic;
    return _DraftKind.reply;
  }

  Widget _groupHeader(BuildContext context, AppLocalizations l10n, _Group g) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!g.first)
          ColoredBox(
            color: colorScheme.surfaceContainer,
            child: const SizedBox(height: DesignTokens.spacingS),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
              DesignTokens.spacingM, DesignTokens.spacingL, 0),
          child: Semantics(
            header: true,
            child: Text(
              g.today ? l10n.sectionToday : l10n.sectionEarlier,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}

class _Group {
  const _Group(this.today, {required this.first});
  final bool today;
  final bool first;
}

enum _DraftKind { reply, newTopic, message }

/// One draft: what kind it is (a badge), where it goes, and the words
/// written so far, quoted and freed of their Markdown.
class _DraftTile extends StatelessWidget {
  const _DraftTile({
    super.key,
    required this.siteContext,
    required this.draft,
    required this.kind,
    required this.onTap,
    required this.onDiscard,
  });

  final SiteContext siteContext;
  final FCDraft draft;
  final _DraftKind kind;
  final VoidCallback onTap;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (icon, bg, fg) = switch (kind) {
      _DraftKind.reply => (Icons.reply_rounded, colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer),
      _DraftKind.newTopic => (Icons.edit_outlined, colorScheme.tertiaryContainer,
          colorScheme.onTertiaryContainer),
      _DraftKind.message => (Icons.mail_outline, colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer),
    };
    final recipients = (draft.data['recipients'] ?? '')
        .toString()
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final what = switch (kind) {
      _DraftKind.reply => l10n.reply,
      _DraftKind.newTopic => l10n.draftKindNewTopic,
      _DraftKind.message => recipients.isEmpty
          ? l10n.newConversation
          : l10n.draftMessageTo(recipients.join(', ')),
    };
    final overline = [
      what,
      if (draft.updatedAt != null) formatTimeAgo(draft.updatedAt!, context),
    ].join(' · ');
    final title = switch (kind) {
      _DraftKind.reply => draft.title,
      _ => draft.topicTitle,
    };
    final untitled = title == null || title.trim().isEmpty;
    final tags = draftTagNames(draft.data['tags']);
    final categoryId = draft.categoryId?.toString() ?? '';
    final preview = markdownPreviewText(draft.reply);

    return Dismissible(
      key: ValueKey('dismiss-${draft.draftKey}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDiscard(),
      background: Container(
        color: colorScheme.errorContainer,
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXL),
        child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
      ),
      child: Material(
        color: colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(DesignTokens.spacingL,
                DesignTokens.spacingM, DesignTokens.spacingXS, DesignTokens.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: DesignTokens.avatarRadiusM,
                  backgroundColor: bg,
                  child: Icon(icon, color: fg),
                ),
                const SizedBox(width: DesignTokens.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overline,
                        style: textTheme.labelMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: DesignTokens.spacingXS),
                      Text(
                        untitled
                            ? (kind == _DraftKind.message
                                ? l10n.newConversation
                                : l10n.untitledTopic)
                            : withEmojiShortcodes(title),
                        style: textTheme.titleMedium?.copyWith(
                          fontStyle: untitled ? FontStyle.italic : null,
                          color: untitled ? colorScheme.onSurfaceVariant : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (kind == _DraftKind.newTopic &&
                          (categoryId.isNotEmpty || tags.isNotEmpty))
                        TopicTaxonomyChips(
                          siteContext: siteContext,
                          categoryId: categoryId,
                          tags: tags,
                          maxTags: 3,
                          padding:
                              const EdgeInsets.only(top: DesignTokens.spacingXS),
                        ),
                      if (preview.isNotEmpty)
                        QuotedExcerpt(text: preview, maxLines: 2),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.discard,
                  color: colorScheme.onSurfaceVariant,
                  onPressed: onDiscard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
