import 'package:flutter/material.dart';
import 'package:forumcopilot_flutter/services/site_proxy_service.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_draft.dart';

import '../theme/design_tokens.dart';
import '../utils/time_utils.dart';
import 'lists/posts_list.dart';
import 'new_topic_page.dart';
import 'post_page.dart';
import 'reply_page.dart';
import 'widgets/empty_state_view.dart';
import 'widgets/simple_list_app_bar.dart';

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
              : 'Failed to load drafts.';
        });
        return;
      }
      setState(() {
        _drafts = result.items;
        _loading = false;
        if (result.items.isEmpty) {
          _error = 'No saved drafts.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _drafts = const [];
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _delete(FCDraft draft) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Discard draft?'),
        content: const Text('This will permanently remove the saved draft.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard')),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await SiteProxyService.getDraftProxy()
        .deleteDraftAsync(draft.draftKey, sequence: draft.sequence);
    if (!mounted) return;
    if (result.result) {
      setState(() => _drafts?.removeWhere((d) => d.draftKey == draft.draftKey));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.resultText?.isNotEmpty == true
              ? result.resultText!
              : 'Failed to discard draft'),
        ),
      );
    }
  }

  void _resume(FCDraft draft) {
    // Reply drafts → ReplyPage anchored on the topic.
    // New-topic drafts → NewTopicPage in the saved category (or "" if
    //   the draft is uncategorised).
    // PM drafts (`new_private_message`) — open as a topic-less compose
    //   for now; deeper PM wiring is a follow-up.
    if (draft.draftKey.startsWith('topic_')) {
      final topicId = draft.draftKey.substring('topic_'.length);
      if (topicId.isEmpty) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReplyPage(
            siteContext: widget.siteContext,
            threadId: topicId,
            topicTitle: draft.title ?? '',
          ),
        ),
      );
      return;
    }
    if (draft.draftKey == 'new_topic') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NewTopicPage(
            siteContext: widget.siteContext,
            forumId: (draft.categoryId ?? '').toString(),
            forumName: '',
          ),
        ),
      );
      return;
    }
    // Topic-anchored drafts that we don't recognise — fall back to
    // opening the topic if we have an id.
    if (draft.topicId != null) {
      Navigator.of(context).push(
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final drafts = _drafts;

    return Scaffold(
      appBar: const SimpleListAppBar(title: 'Drafts'),
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
            return const EmptyStateView.scrollable(
              icon: Icons.edit_note_outlined,
              message: 'No drafts yet.',
              hint: 'Drafts auto-save as you type — start a reply or '
                  'topic and come back here to find it.',
            );
          }
          return ListView.separated(
            itemCount: drafts.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: colorScheme.outlineVariant
                  .withOpacity(DesignTokens.opacityDivider),
            ),
            itemBuilder: (_, i) {
              final d = drafts[i];
              final title = d.isNewTopic
                  ? (d.topicTitle?.isNotEmpty ?? false
                      ? d.topicTitle!
                      : '(untitled new topic)')
                  : (d.title?.isNotEmpty ?? false
                      ? d.title!
                      : 'Reply draft');
              final excerpt = d.reply.trim();
              return ListTile(
                onTap: () => _resume(d),
                leading: Icon(
                  d.isNewTopic ? Icons.fiber_new : Icons.reply,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                      fontWeight: DesignTokens.fontWeightSemiBold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: excerpt.isNotEmpty
                    ? Text(
                        excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (d.updatedAt != null)
                      Text(
                        formatTimeAgo(d.updatedAt!, context),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Discard',
                      color: colorScheme.onSurfaceVariant,
                      onPressed: () => _delete(d),
                    ),
                  ],
                ),
              );
            },
          );
        }(),
      ),
    );
  }
}
