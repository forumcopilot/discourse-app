import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseModerationProxy,
        DiscourseReviewable,
        DiscourseReviewableAction;

import '../../theme/design_tokens.dart';
import '../../utils/time_utils.dart';
import '../post_page.dart';

/// Discourse-native moderator review queue (`/review.json`). Staff (and
/// reviewer-group members) see flagged posts, queued posts, and queued
/// users here, filterable by status and actionable with the same action
/// bundles Discourse's own review UI offers.
///
/// Everyone else gets a 403 from the server, shown as a friendly
/// "Moderator access required" state.
class ReviewablesPage extends StatefulWidget {
  const ReviewablesPage({super.key, required this.siteContext});

  final SiteContext siteContext;

  @override
  State<ReviewablesPage> createState() => _ReviewablesPageState();
}

class _ReviewablesPageState extends State<ReviewablesPage> {
  // `/review.json` pages 10 rows at a time (PER_PAGE in
  // reviewables_controller.rb).
  static const int _pageSize = 10;

  static const List<(String, String)> _statusFilters = [
    ('pending', 'Pending'),
    ('approved', 'Approved'),
    ('rejected', 'Rejected'),
    ('all', 'All'),
  ];

  final List<DiscourseReviewable> _reviewables = [];
  final ScrollController _scrollController = ScrollController();
  String _status = 'pending';
  int _offset = 0;
  int _total = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  /// Ids with a perform request in flight, to disable that card's buttons.
  final Set<int> _performing = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _load(reset: false);
    }
  }

  DiscourseModerationProxy? get _moderationProxy {
    final proxy = SiteProxyFactory.getModerationProxy();
    return proxy is DiscourseModerationProxy ? proxy : null;
  }

  /// True when the failure reads like the server's 403 for non-staff.
  bool _looksLikeAccessDenied(String message) {
    final lower = message.toLowerCase();
    return lower.contains('not authorized') ||
        lower.contains('not permitted') ||
        lower.contains('403');
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      _reviewables.clear();
      _offset = 0;
      _total = 0;
      _hasMore = true;
      _error = null;
    }
    final proxy = _moderationProxy;
    if (proxy == null) {
      setState(() {
        _error = 'Review queue is not available on this forum.';
        _hasMore = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    final result =
        await proxy.getReviewablesAsync(status: _status, offset: _offset);
    if (!mounted) return;
    if (!result.result) {
      setState(() {
        _error = result.resultText.trim().isNotEmpty
            ? result.resultText.trim()
            : 'Failed to load review queue';
        _isLoading = false;
        _hasMore = false;
      });
      return;
    }
    setState(() {
      _reviewables.addAll(result.reviewables);
      _total = result.total;
      _offset += _pageSize;
      _hasMore = result.reviewables.length >= _pageSize &&
          _reviewables.length < _total;
      _isLoading = false;
    });
  }

  Future<void> _refresh() => _load(reset: true);

  void _changeStatus(String status) {
    if (_status == status) return;
    setState(() => _status = status);
    _load(reset: true);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isError
                    ? colorScheme.onErrorContainer
                    : colorScheme.onInverseSurface,
              ),
        ),
        backgroundColor:
            isError ? colorScheme.errorContainer : colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(DesignTokens.spacingS),
      ),
    );
  }

  Future<void> _performAction(
      DiscourseReviewable reviewable, DiscourseReviewableAction action) async {
    final proxy = _moderationProxy;
    if (proxy == null) return;

    // Confirmation gate: the server's confirm_message when it has one,
    // and a reject-reason prompt when the action expects one. The perform
    // proxy has no reason parameter (and stock `/review/{id}/perform`
    // ignores extra params for most reviewables), so the typed reason is
    // collected purely as a deliberate-confirmation step and NOT sent —
    // extend DiscourseModerationProxy.performReviewableActionAsync first
    // if the reason should reach the server.
    if (action.requireRejectReason) {
      final reason = await _promptRejectReason(action);
      if (reason == null) return; // cancelled
    } else if (action.confirmMessage?.trim().isNotEmpty == true) {
      final confirmed = await _confirm(action);
      if (confirmed != true) return;
    }
    if (!mounted) return;

    setState(() => _performing.add(reviewable.id));
    final result = await proxy.performReviewableActionAsync(
      reviewable.id,
      action.id,
      version: reviewable.version,
    );
    if (!mounted) return;
    setState(() => _performing.remove(reviewable.id));

    if (result.conflict) {
      // Another moderator acted first — the queue row is stale, re-fetch.
      _showSnackBar(
          'This item was changed by another moderator. Refreshing…',
          isError: true);
      await _load(reset: true);
      return;
    }
    if (!result.result) {
      _showSnackBar(
        result.resultText.trim().isNotEmpty
            ? result.resultText.trim()
            : 'Failed to perform action',
        isError: true,
      );
      return;
    }
    setState(() {
      final removed = result.removeReviewableIds.isNotEmpty
          ? result.removeReviewableIds.toSet()
          : {reviewable.id};
      _reviewables.removeWhere((r) => removed.contains(r.id));
      if (_total > 0) _total = _total - removed.length;
    });
    _showSnackBar('${action.label ?? action.id} — done');
  }

  Future<bool?> _confirm(DiscourseReviewableAction action) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action.label ?? action.id),
        content: Text(action.confirmMessage!.trim()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  /// Reject-reason dialog. Returns the (possibly empty) reason on
  /// confirm, null on cancel. See the comment in [_performAction]: the
  /// reason is not transmitted because the perform API has no parameter
  /// for it.
  Future<String?> _promptRejectReason(DiscourseReviewableAction action) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action.label ?? action.id),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (action.confirmMessage?.trim().isNotEmpty == true) ...[
              Text(action.confirmMessage!.trim()),
              const SizedBox(height: DesignTokens.spacingM),
            ],
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'Why is this being rejected?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _openTopic(DiscourseReviewable reviewable) {
    final topicId = reviewable.topicId;
    if (topicId == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostPage(
          siteContext: widget.siteContext,
          topicId: topicId.toString(),
          title: reviewable.topicTitle ?? '',
        ),
      ),
    );
  }

  /// `ReviewableFlaggedPost` → `Flagged Post`, etc.
  String _readableType(String type) {
    final stripped = type.startsWith('Reviewable')
        ? type.substring('Reviewable'.length)
        : type;
    return stripped
        .replaceAllMapped(
            RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.flag_outlined, size: 20),
            SizedBox(width: 8),
            Text('Review Queue'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStatusFilterRow(colorScheme, textTheme),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _buildBody(colorScheme, textTheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterRow(ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingS,
      ),
      child: Row(
        children: [
          for (final (value, label) in _statusFilters) ...[
            FilterChip(
              label: Text(label),
              selected: _status == value,
              onSelected: (_) => _changeStatus(value),
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
              labelStyle: textTheme.bodyMedium?.copyWith(
                color: _status == value
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
              backgroundColor: colorScheme.surfaceVariant
                  .withValues(alpha: DesignTokens.opacityLow),
              side: BorderSide(
                color: _status == value
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
                width: _status == value
                    ? DesignTokens.borderWidthThinMedium
                    : DesignTokens.borderWidthThin,
              ),
            ),
            const SizedBox(width: DesignTokens.spacingS),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    if (_reviewables.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reviewables.isEmpty && _error != null) {
      final accessDenied = _looksLikeAccessDenied(_error!);
      return ListView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        children: [
          const SizedBox(height: DesignTokens.spacingXL),
          Icon(
            accessDenied ? Icons.shield_outlined : Icons.error_outline,
            size: 48,
            color: colorScheme.onSurfaceVariant
                .withValues(alpha: DesignTokens.opacityLow),
          ),
          const SizedBox(height: DesignTokens.spacingM),
          Center(
            child: Text(
              accessDenied ? 'Moderator access required' : _error!,
              style: textTheme.titleSmall?.copyWith(
                color: accessDenied
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (accessDenied)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: DesignTokens.spacingS),
                child: Text(
                  'Only staff and reviewers can see the review queue.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    }
    if (_reviewables.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(DesignTokens.spacingL),
        children: [
          Center(
            child: Text(
              'Nothing to review',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingL),
      itemCount: _reviewables.length + (_hasMore || _isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _reviewables.length) {
          return const Padding(
            padding: EdgeInsets.all(DesignTokens.spacingL),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildReviewableCard(
            _reviewables[index], colorScheme, textTheme);
      },
    );
  }

  Widget _buildReviewableCard(DiscourseReviewable reviewable,
      ColorScheme colorScheme, TextTheme textTheme) {
    final isBusy = _performing.contains(reviewable.id);
    final payloadRaw = reviewable.payload['raw']?.toString().trim();
    final isPending = reviewable.status == 0;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingS,
      ),
      child: Padding(
        padding: DesignTokens.paddingM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _readableType(reviewable.type),
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: DesignTokens.fontWeightMedium,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingS,
                    vertical: DesignTokens.spacingXS,
                  ),
                  decoration: BoxDecoration(
                    color: (isPending
                            ? colorScheme.tertiaryContainer
                            : colorScheme.surfaceVariant)
                        .withValues(alpha: DesignTokens.opacityMediumLow),
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusS),
                  ),
                  child: Text(
                    reviewable.statusName,
                    style: textTheme.labelSmall?.copyWith(
                      color: isPending
                          ? colorScheme.onTertiaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (reviewable.topicTitle?.trim().isNotEmpty == true) ...[
              const SizedBox(height: DesignTokens.spacingS),
              InkWell(
                onTap: reviewable.topicId != null
                    ? () => _openTopic(reviewable)
                    : null,
                child: Text(
                  reviewable.topicTitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: reviewable.topicId != null
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight: DesignTokens.fontWeightMedium,
                  ),
                ),
              ),
            ],
            if (payloadRaw != null && payloadRaw.isNotEmpty) ...[
              const SizedBox(height: DesignTokens.spacingS),
              Container(
                width: double.infinity,
                padding: DesignTokens.paddingS,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant
                      .withValues(alpha: DesignTokens.opacityLow),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                child: Text(
                  payloadRaw,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            const SizedBox(height: DesignTokens.spacingS),
            Wrap(
              spacing: DesignTokens.spacingM,
              runSpacing: DesignTokens.spacingXS,
              children: [
                if (reviewable.targetCreatedByUsername?.isNotEmpty ==
                    true)
                  _metaText('By ${reviewable.targetCreatedByUsername}',
                      textTheme, colorScheme),
                if (reviewable.createdByUsername?.isNotEmpty == true)
                  _metaText('Reported by ${reviewable.createdByUsername}',
                      textTheme, colorScheme),
                _metaText(
                    'Score ${reviewable.score.toStringAsFixed(1)}',
                    textTheme,
                    colorScheme),
                if (reviewable.createdAt != null)
                  _metaText(formatTimeAgo(reviewable.createdAt!, context),
                      textTheme, colorScheme),
              ],
            ),
            if (reviewable.actions.isNotEmpty) ...[
              const SizedBox(height: DesignTokens.spacingM),
              Wrap(
                spacing: DesignTokens.spacingS,
                runSpacing: DesignTokens.spacingS,
                children: [
                  for (final action in reviewable.actions)
                    FilledButton.tonal(
                      onPressed: isBusy
                          ? null
                          : () => _performAction(reviewable, action),
                      child: Text(action.label ?? action.id),
                    ),
                ],
              ),
            ],
            if (isBusy) ...[
              const SizedBox(height: DesignTokens.spacingS),
              const LinearProgressIndicator(minHeight: 2),
            ],
          ],
        ),
      ),
    );
  }

  Widget _metaText(
      String text, TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      text,
      style: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
