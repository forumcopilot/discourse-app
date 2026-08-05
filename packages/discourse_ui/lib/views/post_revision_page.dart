import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscoursePostProxy, DiscoursePostRevision;

import '../theme/design_tokens.dart';
import '../utils/time_utils.dart';
import 'widgets/rich_text_content.dart';
import 'widgets/user_avatar.dart';

/// Discourse-native edit-history viewer. Shows one revision at a time —
/// the server-rendered inline diff (`body_changes.inline`, with
/// `<ins>`/`<del>` markup) plus who edited, when, and why — with
/// prev/next arrows walking `previous_revision` / `next_revision`.
///
/// Backed by `DiscoursePostProxy.getPostRevisionAsync`; revisions are
/// numbered from 2 (revision N = the edit that produced version N), and
/// an unedited post simply has no revisions — the proxy surfaces that as
/// a clean `result: false` which this page shows as a friendly message.
class PostRevisionPage extends StatefulWidget {
  final SiteContext siteContext;
  final int postId;

  const PostRevisionPage({
    super.key,
    required this.siteContext,
    required this.postId,
  });

  @override
  State<PostRevisionPage> createState() => _PostRevisionPageState();
}

class _PostRevisionPageState extends State<PostRevisionPage> {
  DiscoursePostRevision? _revision;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(); // null revision = latest
  }

  Future<void> _load({int? revision}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final postProxy = SiteProxyFactory.getPostProxy();
    if (postProxy is! DiscoursePostProxy) {
      setState(() {
        _isLoading = false;
        _error = 'Edit history is not available on this forum.';
      });
      return;
    }
    final result =
        await postProxy.getPostRevisionAsync(widget.postId, revision: revision);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.result && result.revision != null) {
        _revision = result.revision;
      } else {
        // Keep the last loaded revision visible (if any) so a failed
        // prev/next hop doesn't blank the page; only first-load failures
        // show the full-page message.
        _error = result.resultText.trim().isNotEmpty
            ? result.resultText.trim()
            : 'Failed to load edit history.';
      }
    });
    if (_error != null && _revision != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error!),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(DesignTokens.spacingS),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit History',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: DesignTokens.fontWeightMedium,
          ),
        ),
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: _buildBody(colorScheme, textTheme),
      bottomNavigationBar:
          _revision != null ? _buildRevisionNavBar(colorScheme, textTheme) : null,
    );
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoading && _revision == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_revision == null) {
      // First load failed — friendly full-page message (covers "no edit
      // history" 404s and "not visible" 403s from the proxy).
      return Center(
        child: Padding(
          padding: DesignTokens.paddingL,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: colorScheme.onSurfaceVariant
                    .withValues(alpha: DesignTokens.opacityLow),
              ),
              const SizedBox(height: DesignTokens.spacingM),
              Text(
                _error ?? 'Failed to load edit history.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final rev = _revision!;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: DesignTokens.paddingL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRevisionHeader(rev, colorScheme, textTheme),
              const SizedBox(height: DesignTokens.spacingL),
              if (rev.titleInlineHtml != null &&
                  rev.titleInlineHtml!.isNotEmpty) ...[
                Text(
                  'Title',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: DesignTokens.fontWeightMedium,
                  ),
                ),
                RichTextContent(
                  siteContext: widget.siteContext,
                  content: rev.titleInlineHtml!,
                ),
                const SizedBox(height: DesignTokens.spacingM),
              ],
              _buildRevisionBody(rev, colorScheme, textTheme),
            ],
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildRevisionHeader(
      DiscoursePostRevision rev, ColorScheme colorScheme, TextTheme textTheme) {
    final editorName = rev.displayUsername?.trim().isNotEmpty == true
        ? rev.displayUsername!
        : rev.username;
    return Container(
      padding: DesignTokens.paddingM,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant
            .withValues(alpha: DesignTokens.opacityLow),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(alpha: DesignTokens.opacityLow),
          width: DesignTokens.borderWidthThin,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            username: rev.username,
            iconUrl: rev.avatarUrl(widget.siteContext.site.url),
            radius: DesignTokens.avatarRadiusM,
          ),
          const SizedBox(width: DesignTokens.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editorName,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: DesignTokens.fontWeightMedium,
                  ),
                ),
                if (rev.createdAt != null)
                  Text(
                    'Edited ${formatTimeAgo(rev.createdAt!, context)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (rev.editReason?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: DesignTokens.spacingXS),
                  Text(
                    'Reason: ${rev.editReason!.trim()}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevisionBody(
      DiscoursePostRevision rev, ColorScheme colorScheme, TextTheme textTheme) {
    // The server flags diffs it considers too complex to render
    // (`diff_error`); the diff fields are usually null then — show a
    // notice and fall back to whatever content did come through.
    final fallbackHtml = rev.bodyInlineHtml ?? rev.bodySideBySideHtml;
    if (rev.diffError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: DesignTokens.paddingM,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer
                  .withValues(alpha: DesignTokens.opacityLow),
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: DesignTokens.iconSizeM,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: DesignTokens.spacingS),
                Expanded(
                  child: Text(
                    'This diff is too large to display.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (fallbackHtml != null && fallbackHtml.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.spacingM),
            RichTextContent(
              siteContext: widget.siteContext,
              content: fallbackHtml,
            ),
          ] else if (rev.bodySideBySideMarkdown?.isNotEmpty == true) ...[
            const SizedBox(height: DesignTokens.spacingM),
            Text(
              rev.bodySideBySideMarkdown!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ],
      );
    }
    if (fallbackHtml == null || fallbackHtml.isEmpty) {
      return Text(
        'No content changes in this revision.',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }
    // Inline diff: server-rendered cooked HTML with <ins>/<del> markup —
    // the same widget the post list uses for cooked content renders it.
    return RichTextContent(
      siteContext: widget.siteContext,
      content: fallbackHtml,
    );
  }

  Widget _buildRevisionNavBar(ColorScheme colorScheme, TextTheme textTheme) {
    final rev = _revision!;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow
                .withValues(alpha: DesignTokens.opacityLow * 0.33),
            offset: const Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingL,
            vertical: DesignTokens.spacingXS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Previous revision',
                onPressed: (_isLoading || rev.previousRevision == null)
                    ? null
                    : () => _load(revision: rev.previousRevision),
              ),
              Text(
                'Revision ${rev.currentVersion} of ${rev.versionCount}',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: DesignTokens.fontWeightMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Next revision',
                onPressed: (_isLoading || rev.nextRevision == null)
                    ? null
                    : () => _load(revision: rev.nextRevision),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
