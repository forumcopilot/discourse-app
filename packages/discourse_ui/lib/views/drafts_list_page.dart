import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_draft.dart';

import '../theme/design_tokens.dart';
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
  List<FCDraft>? _drafts;
  bool _loading = false;
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
      final result =
          await SiteProxyService.getDraftProxy().getMyDraftsAsync();
      if (!mounted) return;
      if (!result.result) {
        setState(() {
          _drafts = const [];
          _loading = false;
          _error = result.resultText?.isNotEmpty == true
              ? result.resultText!
              : AppLocalizations.of(context)!.failedToLoadDrafts;
        });
        return;
      }
      setState(() {
        _drafts = result.items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _drafts = const [];
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
    if (index < 0) return;
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
      if (!mounted) return;
      final now = [...?_drafts];
      now.insert(index.clamp(0, now.length), draft);
      setState(() => _drafts = now);
    }

    controller.closed.then((reason) async {
      if (reason == SnackBarClosedReason.action) {
        restore();
        return;
      }
      final result = await SiteProxyService.getDraftProxy()
          .deleteDraftAsync(draft.draftKey, sequence: draft.sequence);
      if (!mounted || result.result) return;
      restore();
      messenger.showSnackBar(SnackBar(
        content: Text(result.resultText?.isNotEmpty == true
            ? result.resultText!
            : l10n.failedToDiscardDraft),
      ));
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
      body: RefreshIndicator(
        onRefresh: _load,
        child: () {
          if (_loading && drafts == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if ((drafts == null || drafts.isEmpty) && _error != null) {
            return EmptyStateView.scrollable(
              icon: Icons.edit_note_outlined,
              message: _error!,
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
            itemCount: rows.length,
            itemBuilder: (_, i) {
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
    final tags = ((draft.data['tags'] as List?) ?? const [])
        .map((t) => t.toString())
        .where((t) => t.isNotEmpty)
        .toList();
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
                            : title,
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
