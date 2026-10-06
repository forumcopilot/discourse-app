import 'package:flutter/material.dart';
import 'package:discourse_core/discourse_core.dart'
    show DiscoursePostProxy, DiscoursePollExtras, DiscoursePollVoter;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/models/entities/fc_poll.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';
import 'package:discourse_ui/theme/design_tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import 'cooked_inline_text.dart';
import 'post_body_extensions.dart';
import 'sheet_title.dart';
import 'user_avatar.dart';

/// Twitter/X-style poll card shown at the top of a thread when the thread has a poll.
///
/// On Discourse the poll's title and each option's text are cooked HTML
/// (emoji images, links, bold, code), drawn by [CookedInlineText].
///
/// A ranked-choice poll ([DiscoursePollExtras.isRankedChoice]) is voted by
/// tapping the options in order of preference: each tap gives the next rank,
/// a second tap takes it back, and an option left unranked is Abstain, as
/// the web's per-option rank menu has it. Its result is the runoff's winner
/// (or the tied options), marked on the options; the per-option counts of a
/// ranked-choice poll are all the voter count, so it has no bars.
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

  /// A ranked-choice ballot being filled in: the options in order of
  /// preference, first choice first. An option not here is Abstain.
  final List<String> _rankOrder = [];
  bool _isSubmitting = false;
  bool _isRemovingVote = false;

  /// Id of the post hosting the poll (Discourse's `/polls/*` endpoints
  /// are keyed on post_id + poll_name, not topic id). Carried on the
  /// parsed poll itself ([FCPoll.postId]); null means the backend didn't
  /// provide it and the vote-removal / voters affordances are hidden.
  int? get _hostPostId => int.tryParse(widget.poll.postId ?? '');

  /// Whether [proxy] talks to the forum this card's poll is on. The active
  /// forum can change under a card still on screen (a page left open across
  /// a forum switch); the `/polls/*` endpoints are addressed by post id and
  /// poll name only, so the other forum's proxy would act on whatever post
  /// has that id there.
  bool _servesThisForum(DiscoursePostProxy proxy) =>
      proxy.siteContext.site.pluginUrl == widget.siteContext.site.pluginUrl;

  DiscoursePollExtras? get _extras => DiscoursePollExtras.of(widget.poll);

  bool get _isRankedChoice => _extras?.isRankedChoice == true;

  int get _maxSelections => widget.poll.maxVotes == 0 ? widget.poll.responses.length : widget.poll.maxVotes;

  void _toggleOption(String responseId) {
    if (!widget.poll.canVote || widget.poll.hasVoted || _isSubmitting) return;
    setState(() {
      if (_isRankedChoice) {
        // The next rank, or back to Abstain; the ranks after it move up.
        if (!_rankOrder.remove(responseId)) _rankOrder.add(responseId);
        return;
      }
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
    final ranked = _isRankedChoice;
    if ((ranked ? _rankOrder.isEmpty : _selectedIds.isEmpty) ||
        !widget.poll.canVote ||
        widget.poll.hasVoted ||
        _isSubmitting) {
      return;
    }
    if (!ranked && widget.poll.maxVotes > 0 && _selectedIds.length > widget.poll.maxVotes) return;

    setState(() => _isSubmitting = true);
    try {
      final postProxy = SiteProxyService.getPostProxy();
      // Use the displayed poll's identity, and refuse to use a proxy for
      // another forum if navigation changed the active site.
      FCPoll? updated;
      if (postProxy is DiscoursePostProxy) {
        if (_servesThisForum(postProxy)) {
          updated = ranked
              ? await postProxy.voteRankedChoicePollAsync(
                  widget.topicId,
                  {for (final (i, id) in _rankOrder.indexed) id: i + 1},
                  poll: widget.poll)
              : await postProxy.votePollAsync(
                  widget.topicId, _selectedIds.toList(), poll: widget.poll);
        }
      } else {
        updated = await postProxy.votePollAsync(widget.topicId, _selectedIds.toList());
      }
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
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        _showError(AppLocalizations.of(context)!.pollVoteFailed);
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
    if (!_servesThisForum(proxy)) {
      _showError(AppLocalizations.of(context)!.pollRemoveVoteFailed);
      return;
    }

    setState(() => _isRemovingVote = true);
    try {
      final postId = _hostPostId;
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
              AppLocalizations.of(context)!.voteRemoved,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showError(AppLocalizations.of(context)!.pollRemoveVoteFailed);
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
    final postId = _hostPostId;
    if (postId == null || !_servesThisForum(proxy)) {
      _showError(AppLocalizations.of(context)!.pollVotersLoadFailed);
      return;
    }
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
    final extras = _extras;
    final ranked = extras?.isRankedChoice == true;
    // Bars and voters per option. A ranked-choice poll has neither: every
    // voter has a vote on every option (Abstain included), so each option's
    // count is the voter count and each option's voters are all of them.
    final showResults = !ranked &&
        widget.poll.canViewResults &&
        widget.poll.voterCount != null &&
        widget.poll.voterCount! > 0;
    final canVote = widget.poll.canVote && !widget.poll.hasVoted;
    final voterCount = widget.poll.voterCount;
    // The server sends the outcome whatever the poll's results setting.
    final outcome =
        ranked && widget.poll.canViewResults ? extras!.outcome : null;
    // Discourse-native poll extras: retracting a vote and listing voters
    // both hit the poll plugin's endpoints via DiscoursePostProxy.
    // Both affordances need the hosting post id (FCPoll.postId); a poll
    // without one can't address the plugin endpoints, so hide them.
    final isDiscoursePolls =
        SiteProxyService.getPostProxy() is DiscoursePostProxy &&
            _hostPostId != null;
    final showRemoveVote =
        isDiscoursePolls && widget.poll.hasVoted && !widget.poll.isClosed;
    // Voters are only visible for PUBLIC polls; the server 400s otherwise.
    final showVoters =
        isDiscoursePolls && showResults && widget.poll.publicVotes;

    // The one card recipe, at the post's own margin (no inset of its own);
    // the gap to the next block is the post body's.
    return EmbeddedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Discourse polls usually have no title; an empty question left
          // a blank band across the top of the card.
          if (widget.poll.question.trim().isNotEmpty) ...[
            CookedInlineText(
              widget.poll.question,
              siteContext: widget.siteContext,
              openLinks: true,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: DesignTokens.spacingM),
          ],
          if (ranked && canVote) ...[
            Text(
              l10n.pollRankedChoiceHint,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: DesignTokens.spacingS),
          ],
          ...widget.poll.responses.map((r) => _buildOptionRow(
                context,
                r,
                showResults: showResults,
                canVote: canVote,
                voterCount: voterCount,
                // The ballot being filled in, else the viewer's own.
                rank: !ranked
                    ? null
                    : canVote
                        ? _rankOrder.indexOf(r.id) + 1
                        : widget.poll.hasVoted
                            ? extras!.viewerRanks[r.id] ?? 0
                            : null,
                outcome: outcome == null
                    ? null
                    : outcome.winnerId == r.id
                        ? l10n.pollRankedChoiceWinner
                        : outcome.tiedIds.contains(r.id)
                            ? l10n.pollRankedChoiceTied
                            : null,
                isWinner: outcome?.winnerId == r.id,
              )),
          SizedBox(height: DesignTokens.spacingM),
          if (canVote) ...[
            // A standard FilledButton, across the card.
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: ((ranked ? _rankOrder.isNotEmpty : _selectedIds.isNotEmpty) &&
                        !_isSubmitting)
                    ? _submitVote
                    : null,
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
                            height: DesignTokens.iconSizeSMedium,
                            width: DesignTokens.iconSizeSMedium,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                        : Icon(Icons.undo, size: DesignTokens.iconSizeSMedium),
                    label: Text(AppLocalizations.of(context)!.removeVote),
                  ),
                if (showRemoveVote && showVoters)
                  SizedBox(width: DesignTokens.spacingS),
                if (showVoters)
                  TextButton.icon(
                    onPressed: _showVoters,
                    icon: Icon(Icons.people_outline,
                        size: DesignTokens.iconSizeSMedium),
                    label: Text(AppLocalizations.of(context)!.showVoters),
                  ),
              ],
            ),
          _buildFooter(l10n, colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildOptionRow(
    BuildContext context,
    FCPollResponse r, {
    required bool showResults,
    required bool canVote,
    int? voterCount,
    int? rank,
    String? outcome,
    bool isWinner = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isSelected = rank != null
        ? rank > 0
        : _selectedIds.contains(r.id) || r.viewerVotedFor;
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
            // A 48dp choice row however short its text.
            constraints: const BoxConstraints(minHeight: 48),
            alignment: AlignmentDirectional.centerStart,
            padding: EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingM,
              vertical: DesignTokens.spacingM,
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
                    if (rank != null)
                      Padding(
                        padding: EdgeInsets.only(right: DesignTokens.spacingS),
                        child: _rankBadge(rank, colorScheme, textTheme),
                      )
                    else if (canVote && !widget.poll.hasVoted)
                      Padding(
                        padding: EdgeInsets.only(right: DesignTokens.spacingS),
                        child: Icon(
                          widget.poll.maxVotes <= 1
                              ? (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked)
                              : (isSelected ? Icons.check_box : Icons.check_box_outline_blank),
                          size: DesignTokens.iconSizeM,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    // The whole option, wrapped: an option cut off cannot be
                    // chosen knowingly. While it can be chosen, a tap
                    // anywhere on it chooses it, a link in its text too.
                    Expanded(
                      child: CookedInlineText(
                        r.text,
                        siteContext: widget.siteContext,
                        openLinks: !canVote,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: r.viewerVotedFor ? DesignTokens.fontWeightMedium : null,
                        ),
                      ),
                    ),
                    if (percent != null)
                      Text(
                        '$percent%',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (outcome != null) ...[
                      SizedBox(width: DesignTokens.spacingS),
                      if (isWinner)
                        Padding(
                          padding: EdgeInsets.only(right: DesignTokens.spacingXS),
                          child: Icon(
                            Icons.emoji_events_outlined,
                            size: DesignTokens.iconSizeSMedium,
                            color: colorScheme.primary,
                          ),
                        ),
                      Text(
                        outcome,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A ranked-choice option's rank: the number in a filled circle, or an
  /// empty circle for Abstain.
  Widget _rankBadge(int rank, ColorScheme colorScheme, TextTheme textTheme) {
    final l10n = AppLocalizations.of(context)!;
    final size = DesignTokens.iconSizeM;
    return Semantics(
      label: rank > 0 ? l10n.pollRank(rank) : l10n.pollRankAbstain,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rank > 0 ? colorScheme.primary : null,
            border: rank > 0
                ? null
                : Border.all(
                    color: colorScheme.onSurfaceVariant,
                    width: DesignTokens.borderWidthMedium,
                  ),
          ),
          child: rank > 0
              ? Padding(
                  padding: const EdgeInsets.all(2),
                  child: FittedBox(
                    child: Text(
                      '$rank',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: DesignTokens.fontWeightBold,
                      ),
                    ),
                  ),
                )
              : null,
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
            : AppLocalizations.of(context)!.pollVotersNotVisible;
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

  /// The option's cooked text, for [CookedInlineText].
  String _optionText(String optionId) {
    for (final r in widget.poll.responses) {
      if (r.id == optionId) return r.text;
    }
    return AppLocalizations.of(context)!.voters;
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
            SheetTitle(AppLocalizations.of(context)!.voters),
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
                  AppLocalizations.of(context)!.noVotesYet,
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
                          child: CookedInlineText(
                            _optionText(optionId),
                            siteContext: widget.siteContext,
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
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
                                  child: Text(AppLocalizations.of(context)!.showMore),
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
