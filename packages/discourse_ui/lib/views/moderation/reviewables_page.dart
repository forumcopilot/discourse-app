import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseModerationProxy,
        DiscourseReviewable,
        DiscourseReviewableAction,
        DiscourseReviewableScore;

import '../../theme/design_tokens.dart';
import '../../utils/time_utils.dart';
import '../post_page.dart';
import '../../l10n/generated/app_localizations.dart';

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
    // and a reject-reason prompt when the action expects one (rejecting a
    // sign-up: Discourse emails the reason to the person).
    String? rejectReason;
    if (action.requireRejectReason) {
      rejectReason = await _promptRejectReason(action);
      if (rejectReason == null) return; // cancelled
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
      rejectReason: rejectReason,
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
    _showSnackBar(action.completedMessage?.trim().isNotEmpty == true
        ? action.completedMessage!.trim()
        : '${action.label ?? action.id} — done');
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
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  /// Reject-reason dialog. Returns the (possibly empty) reason on
  /// confirm, null on cancel.
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
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: Text(AppLocalizations.of(context)!.confirm),
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
          children: [
            Icon(Icons.flag_outlined, size: 20),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.reviewQueue),
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
              backgroundColor: colorScheme.surfaceContainerHighest
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
                  AppLocalizations.of(context)!.reviewQueueStaffOnly,
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
              AppLocalizations.of(context)!.nothingToReview,
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
    final payloadRaw = reviewable.raw?.trim();
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
                            : colorScheme.surfaceContainerHighest)
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
                  color: colorScheme.surfaceContainerHighest
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
            for (final score in reviewable.scores)
              _buildScoreRow(score, colorScheme, textTheme),
            const SizedBox(height: DesignTokens.spacingS),
            Wrap(
              spacing: DesignTokens.spacingM,
              runSpacing: DesignTokens.spacingXS,
              children: [
                if (reviewable.targetCreatedByUsername?.isNotEmpty ==
                    true)
                  _metaText(AppLocalizations.of(context)!.reviewableBy(reviewable.targetCreatedByUsername!),
                      textTheme, colorScheme),
                // Each flagger is on their reason's row above.
                if (reviewable.scores.isEmpty &&
                    reviewable.createdByUsername?.isNotEmpty == true)
                  _metaText(AppLocalizations.of(context)!.reportedBy(reviewable.createdByUsername!),
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
                  for (final bundle in _bundles(reviewable.actions))
                    _buildBundleButton(reviewable, bundle, isBusy),
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

  /// One flag or reason: "Spam", who raised it, and the forum's
  /// explanation when the system put the item here.
  Widget _buildScoreRow(DiscourseReviewableScore score,
      ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.flag_outlined,
                size: 14, color: colorScheme.error),
          ),
          const SizedBox(width: DesignTokens.spacingXS),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: score.type,
                  style: const TextStyle(
                      fontWeight: DesignTokens.fontWeightMedium),
                ),
                if (score.username?.isNotEmpty == true)
                  TextSpan(
                      text:
                          ' · ${AppLocalizations.of(context)!.reportedBy(score.username!)}'),
                if (score.reason?.trim().isNotEmpty == true)
                  TextSpan(text: '\n${score.reason!.trim()}'),
              ]),
              style: textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  /// Actions grouped by bundle, in the order Discourse sends them.
  List<List<DiscourseReviewableAction>> _bundles(
      List<DiscourseReviewableAction> actions) {
    final byBundle = <String, List<DiscourseReviewableAction>>{};
    for (final action in actions) {
      byBundle.putIfAbsent(action.bundleId, () => []).add(action);
    }
    return byBundle.values.toList();
  }

  /// A bundle as Discourse's queue shows it: one button when it holds a
  /// single action, otherwise a dropdown under the bundle's label ("Yes" /
  /// "No"). Flat buttons put "Keep post" twice on a flagged post, one
  /// agreeing with the flag and one disagreeing, with nothing to tell
  /// them apart.
  Widget _buildBundleButton(DiscourseReviewable reviewable,
      List<DiscourseReviewableAction> bundle, bool isBusy) {
    if (bundle.length == 1) {
      final action = bundle.single;
      return FilledButton.tonal(
        onPressed: isBusy ? null : () => _performAction(reviewable, action),
        child: Text(action.label ?? action.id),
      );
    }
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return MenuAnchor(
      menuChildren: [
        for (final action in bundle)
          MenuItemButton(
            onPressed: () => _performAction(reviewable, action),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: DesignTokens.spacingXS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(action.label ?? action.id),
                    if (action.description?.trim().isNotEmpty == true)
                      Text(
                        action.description!.trim(),
                        style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
      builder: (context, controller, _) => FilledButton.tonalIcon(
        onPressed: isBusy
            ? null
            : () => controller.isOpen ? controller.close() : controller.open(),
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.arrow_drop_down),
        label: Text(bundle.first.bundleLabel ?? bundle.first.label ?? ''),
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
