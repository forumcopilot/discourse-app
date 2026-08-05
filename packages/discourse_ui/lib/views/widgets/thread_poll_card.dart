import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscoursePostProxy, DiscoursePollVoter;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_poll.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/design_tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import 'user_avatar.dart';

/// Twitter/X-style poll card shown at the top of a thread when the thread has a poll.
class ThreadPollCard extends StatefulWidget {
  final FCPoll poll;
  final String topicId;
  final SiteContext siteContext;
  final void Function(FCPoll updatedPoll) onVoteSuccess;

  const ThreadPollCard({
    super.key,
    required this.poll,
    required this.topicId,
    required this.siteContext,
    required this.onVoteSuccess,
  });

  @override
  State<ThreadPollCard> createState() => _ThreadPollCardState();
}

class _ThreadPollCardState extends State<ThreadPollCard> {
  /// Selected response IDs for submission. For single-choice maxVotes==1, at most one; for multi, up to maxVotes.
  final Set<String> _selectedIds = {};
  bool _isSubmitting = false;
  bool _isRemovingVote = false;

  /// Id of the post hosting the poll (Discourse's `/polls/*` endpoints are
  /// keyed on post_id + poll_name, not topic id). Resolved lazily from the
  /// topic's first post and cached for the widget's lifetime.
  int? _hostPostId;

  Future<int?> _resolveHostPostId() async {
    if (_hostPostId != null) return _hostPostId;
    try {
      final thread = await SiteProxyService.getPostProxy()
          .getThreadAsync(widget.topicId, 1, 1, true);
      if (thread.result && thread.posts.isNotEmpty) {
        final first = thread.posts.firstWhere(
          (p) => p.postNumber == 1,
          orElse: () => thread.posts.first,
        );
        _hostPostId = int.tryParse(first.id);
      }
    } catch (_) {}
    return _hostPostId;
  }

  int get _maxSelections => widget.poll.maxVotes == 0 ? widget.poll.responses.length : widget.poll.maxVotes;

  void _toggleOption(String responseId) {
    if (!widget.poll.canVote || widget.poll.hasVoted || _isSubmitting) return;
    setState(() {
      if (_selectedIds.contains(responseId)) {
        _selectedIds.remove(responseId);
      } else {
        if (_maxSelections == 1) {
          _selectedIds.clear();
          _selectedIds.add(responseId);
        } else if (_selectedIds.length < _maxSelections) {
          _selectedIds.add(responseId);
        }
      }
    });
  }

  Future<void> _submitVote() async {
    if (_selectedIds.isEmpty || !widget.poll.canVote || widget.poll.hasVoted || _isSubmitting) return;
    if (widget.poll.maxVotes > 0 && _selectedIds.length > widget.poll.maxVotes) return;

    setState(() => _isSubmitting = true);
    try {
      final postProxy = SiteProxyService.getPostProxy();
      final updated = await postProxy.votePollAsync(widget.topicId, _selectedIds.toList());
      if (updated != null && mounted) {
        widget.onVoteSuccess(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.vote,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            behavior: SnackBarBehavior.floating,
            margin: DesignTokens.paddingS,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        _showError('Vote failed. Please try again.');
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Retract the viewer's vote(s). Only offered while the poll is open and
  /// the viewer has voted; swaps in the poll echoed by the server (viewer
  /// votes cleared) on success.
  Future<void> _removeVote() async {
    if (_isRemovingVote || _isSubmitting) return;
    final proxy = SiteProxyService.getPostProxy();
    if (proxy is! DiscoursePostProxy) return;

    setState(() => _isRemovingVote = true);
    try {
      final postId = await _resolveHostPostId();
      final updated = postId == null
          ? null
          : await proxy.removePollVoteAsync(
              postId,
              widget.poll.pollId,
              topicId: widget.topicId,
            );
      if (!mounted) return;
      if (updated != null) {
        widget.onVoteSuccess(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vote removed',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            behavior: SnackBarBehavior.floating,
            margin: DesignTokens.paddingS,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showError('Could not remove your vote. Please try again.');
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isRemovingVote = false);
    }
  }

  /// Open the per-option voters sheet (public polls only).
  Future<void> _showVoters() async {
    final proxy = SiteProxyService.getPostProxy();
    if (proxy is! DiscoursePostProxy) return;
    final postId = await _resolveHostPostId();
    if (!mounted) return;
    if (postId == null) {
      _showError('Could not load voters.');
      return;
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _PollVotersSheet(
        proxy: proxy,
        postId: postId,
        poll: widget.poll,
        siteContext: widget.siteContext,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        margin: DesignTokens.paddingS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusS),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final showResults = widget.poll.canViewResults &&
        widget.poll.voterCount != null &&
        widget.poll.voterCount! > 0;
    final canVote = widget.poll.canVote && !widget.poll.hasVoted;
    final voterCount = widget.poll.voterCount;
    // Discourse-native poll extras: retracting a vote and listing voters
    // both hit the poll plugin's endpoints via DiscoursePostProxy.
    final isDiscoursePolls =
        SiteProxyService.getPostProxy() is DiscoursePostProxy;
    final showRemoveVote =
        isDiscoursePolls && widget.poll.hasVoted && !widget.poll.isClosed;
    // Voters are only visible for PUBLIC polls; the server 400s otherwise.
    final showVoters =
        isDiscoursePolls && showResults && widget.poll.publicVotes;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingL,
        vertical: DesignTokens.spacingS,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: DesignTokens.opacityLow),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: DesignTokens.opacityMediumLow),
          width: DesignTokens.borderWidthThin,
        ),
      ),
      child: Padding(
        padding: DesignTokens.paddingCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.poll.question,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: DesignTokens.fontWeightSemiBold,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: DesignTokens.spacingM),
            ...widget.poll.responses.map((r) => _buildOptionRow(
                  context,
                  r,
                  showResults: showResults,
                  canVote: canVote,
                  voterCount: voterCount,
                )),
            SizedBox(height: DesignTokens.spacingM),
            if (canVote) ...[
              FilledButton(
                onPressed: (_selectedIds.isNotEmpty && !_isSubmitting) ? _submitVote : null,
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(l10n.vote),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  ),
                ),
              ),
              SizedBox(height: DesignTokens.spacingS),
            ],
            if (showRemoveVote || showVoters)
              Row(
                children: [
                  if (showRemoveVote)
                    TextButton.icon(
                      onPressed: _isRemovingVote ? null : _removeVote,
                      icon: _isRemovingVote
                          ? SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            )
                          : Icon(Icons.undo, size: DesignTokens.iconSizeS),
                      label: const Text('Remove vote'),
                    ),
                  if (showRemoveVote && showVoters)
                    SizedBox(width: DesignTokens.spacingS),
                  if (showVoters)
                    TextButton.icon(
                      onPressed: _showVoters,
                      icon: Icon(Icons.people_outline,
                          size: DesignTokens.iconSizeS),
                      label: const Text('Show voters'),
                    ),
                ],
              ),
            _buildFooter(l10n, colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(
    BuildContext context,
    FCPollResponse r, {
    required bool showResults,
    required bool canVote,
    int? voterCount,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isSelected = _selectedIds.contains(r.id) || r.viewerVotedFor;
    double fraction = 0.0;
    if (showResults && voterCount != null && voterCount > 0 && r.voteCount != null) {
      fraction = (r.voteCount! / voterCount).clamp(0.0, 1.0);
    }
    final showBar = showResults && voterCount != null && voterCount > 0;
    final percent = showBar && r.voteCount != null ? (fraction * 100).round() : null;

    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.spacingS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canVote ? () => _toggleOption(r.id) : null,
          borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingM,
              vertical: DesignTokens.spacingS + DesignTokens.spacingXS,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: DesignTokens.opacityMediumLow)
                  : null,
              border: isSelected
                  ? Border.all(
                      color: colorScheme.primary.withValues(alpha: DesignTokens.opacityMediumLow),
                      width: DesignTokens.borderWidthThin,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBar) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        r.viewerVotedFor ? colorScheme.primary : colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(height: DesignTokens.spacingXS),
                ],
                Row(
                  children: [
                    if (canVote && !widget.poll.hasVoted)
                      Padding(
                        padding: EdgeInsets.only(right: DesignTokens.spacingS),
                        child: Icon(
                          widget.poll.maxVotes <= 1
                              ? (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked)
                              : (isSelected ? Icons.check_box : Icons.check_box_outlined),
                          size: DesignTokens.iconSizeM,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        r.text,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: r.viewerVotedFor ? DesignTokens.fontWeightSemiBold : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (percent != null)
                      Text(
                        '$percent%',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n, ColorScheme colorScheme, TextTheme textTheme) {
    String footer = '';
    if (widget.poll.isClosed) {
      footer = l10n.pollClosed;
    } else if (widget.poll.closeDate > 0) {
      final date = DateTime.fromMillisecondsSinceEpoch(widget.poll.closeDate);
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      footer = l10n.pollEndsOn(dateStr);
    }
    if (widget.poll.voterCount != null) {
      footer = footer.isEmpty ? l10n.votesCount(widget.poll.voterCount!) : '$footer · ${l10n.votesCount(widget.poll.voterCount!)}';
    }
    if (footer.isEmpty && !widget.poll.canViewResults && !widget.poll.hasVoted) {
      footer = l10n.voteToSeeResults;
    }
    if (footer.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: DesignTokens.spacingXS),
      child: Text(
        footer,
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Bottom sheet listing who voted for what in a PUBLIC poll, grouped by
/// option, with per-option paging (Discourse serves 25 voters per option
/// per page; "Show more" fetches the next page for that option only).
/// Number-type polls return one ungrouped list (the `''` key).
class _PollVotersSheet extends StatefulWidget {
  final DiscoursePostProxy proxy;
  final int postId;
  final FCPoll poll;
  final SiteContext siteContext;

  const _PollVotersSheet({
    required this.proxy,
    required this.postId,
    required this.poll,
    required this.siteContext,
  });

  @override
  State<_PollVotersSheet> createState() => _PollVotersSheetState();
}

class _PollVotersSheetState extends State<_PollVotersSheet> {
  static const int _votersPerPage = 25;

  final Map<String, List<DiscoursePollVoter>> _votersByOption = {};
  final Map<String, int> _pageByOption = {};
  final Map<String, bool> _hasMoreByOption = {};
  final Set<String> _loadingMore = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final result = await widget.proxy.getPollVotersAsync(
      widget.postId,
      widget.poll.pollId,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (!result.result) {
        // Private poll (or plugin missing): the server refuses the voter
        // list. The affordance is gated on publicVotes, so this is rare.
        _error = result.resultText.isNotEmpty
            ? result.resultText
            : 'Voters are not visible for this poll.';
        return;
      }
      result.votersByOption.forEach((optionId, voters) {
        _votersByOption[optionId] = List.of(voters);
        _pageByOption[optionId] = 1;
        _hasMoreByOption[optionId] = voters.length >= _votersPerPage;
      });
    });
  }

  Future<void> _loadMore(String optionId) async {
    if (_loadingMore.contains(optionId)) return;
    setState(() => _loadingMore.add(optionId));
    final nextPage = (_pageByOption[optionId] ?? 1) + 1;
    final result = await widget.proxy.getPollVotersAsync(
      widget.postId,
      widget.poll.pollId,
      optionId: optionId.isEmpty ? null : optionId,
      page: nextPage,
    );
    if (!mounted) return;
    setState(() {
      _loadingMore.remove(optionId);
      if (!result.result) {
        _hasMoreByOption[optionId] = false;
        return;
      }
      final appended = result.votersByOption[optionId] ?? const [];
      _votersByOption.putIfAbsent(optionId, () => []).addAll(appended);
      _pageByOption[optionId] = nextPage;
      _hasMoreByOption[optionId] = appended.length >= _votersPerPage;
    });
  }

  String? _avatarUrl(DiscoursePollVoter voter) {
    final tpl = voter.avatarTemplate;
    if (tpl == null || tpl.isEmpty) return null;
    final filled = tpl.replaceAll('{size}', '90');
    if (filled.startsWith('http://') || filled.startsWith('https://')) {
      return filled;
    }
    final base = widget.siteContext.site.url;
    return filled.startsWith('/') ? '$base$filled' : '$base/$filled';
  }

  String _optionText(String optionId) {
    for (final r in widget.poll.responses) {
      if (r.id == optionId) return r.text;
    }
    return 'Voters';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Keep option ordering consistent with the poll card; append any
    // digests the poll doesn't know about (defensive) plus the ''
    // number-poll bucket at the end.
    final orderedIds = <String>[
      for (final r in widget.poll.responses)
        if (_votersByOption.containsKey(r.id)) r.id,
      for (final id in _votersByOption.keys)
        if (!widget.poll.responses.any((r) => r.id == id)) id,
    ];

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.spacingL,
                DesignTokens.spacingM,
                DesignTokens.spacingL,
                DesignTokens.spacingS,
              ),
              child: Text(
                'Voters',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(DesignTokens.spacingXL),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingL),
                child: Text(
                  _error!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else if (orderedIds.isEmpty)
              Padding(
                padding: const EdgeInsets.all(DesignTokens.spacingL),
                child: Text(
                  'No votes yet.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final optionId in orderedIds) ...[
                      if (optionId.isNotEmpty ||
                          orderedIds.length > 1)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            DesignTokens.spacingL,
                            DesignTokens.spacingM,
                            DesignTokens.spacingL,
                            DesignTokens.spacingXS,
                          ),
                          child: Text(
                            _optionText(optionId),
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      for (final voter in _votersByOption[optionId]!)
                        ListTile(
                          dense: true,
                          leading: UserAvatar(
                            username: voter.username,
                            iconUrl: _avatarUrl(voter),
                            radius: 16,
                          ),
                          title: Text(
                            voter.name?.isNotEmpty == true
                                ? voter.name!
                                : voter.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: voter.name?.isNotEmpty == true
                              ? Text(
                                  '@${voter.username}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                )
                              : null,
                        ),
                      if (_hasMoreByOption[optionId] == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spacingL,
                          ),
                          child: _loadingMore.contains(optionId)
                              ? const Padding(
                                  padding:
                                      EdgeInsets.all(DesignTokens.spacingS),
                                  child: Center(
                                    child: SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                )
                              : TextButton(
                                  onPressed: () => _loadMore(optionId),
                                  child: const Text('Show more'),
                                ),
                        ),
                    ],
                    const SizedBox(height: DesignTokens.spacingS),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
