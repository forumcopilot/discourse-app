import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/models/search/fc_search_filters.dart';

import '../../theme/design_tokens.dart';
import 'sheet_title.dart';
import 'package:forum_kit/l10n/kit_l10n.dart';

/// Bottom sheet that lets the user toggle Discourse-native search filters
/// (status, personal, sort, tags) on top of a free-text query. Returns
/// the new [FCSearchFilters] when the user taps Apply, or null
/// when they back out.
class SearchFiltersSheet extends StatefulWidget {
  final FCSearchFilters initial;
  final bool loggedIn;

  const SearchFiltersSheet({
    super.key,
    required this.initial,
    this.loggedIn = false,
  });

  static Future<FCSearchFilters?> show({
    required BuildContext context,
    required FCSearchFilters initial,
    bool loggedIn = false,
  }) {
    return showModalBottomSheet<FCSearchFilters>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return SearchFiltersSheet(
              initial: initial,
              loggedIn: loggedIn,
            );
          },
        );
      },
    );
  }

  @override
  State<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends State<SearchFiltersSheet> {
  late Set<FCSearchStatus> _status;
  late Set<FCSearchPersonal> _personal;
  late bool _firstPostsOnly;
  late bool _titleOnly;
  late FCSearchSort? _sort;
  late TextEditingController _tagController;

  @override
  void initState() {
    super.initState();
    _status = {...widget.initial.status};
    _personal = {...widget.initial.personal};
    _firstPostsOnly = widget.initial.firstPostsOnly;
    _titleOnly = widget.initial.titleOnly;
    _sort = widget.initial.sort;
    _tagController =
        TextEditingController(text: widget.initial.tags.join(' '));
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  FCSearchFilters _buildResult() {
    final tags = _tagController.text
        .trim()
        .split(RegExp(r'[\s,]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    return FCSearchFilters(
      status: _status,
      personal: _personal,
      firstPostsOnly: _firstPostsOnly,
      titleOnly: _titleOnly,
      tags: tags,
      sort: _sort,
    );
  }

  void _apply() {
    Navigator.of(context).pop(_buildResult());
  }

  void _reset() {
    setState(() {
      _status = {};
      _personal = {};
      _firstPostsOnly = false;
      _titleOnly = false;
      _sort = null;
      _tagController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = kitL10n(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetTitle(
            l10n.searchFilters,
            trailing: TextButton(onPressed: _reset, child: Text(l10n.reset)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingL,
                vertical: DesignTokens.spacingS,
              ),
              children: [
                _section(l10n.searchFilterStatusSection, textTheme, colorScheme),
                _wrap([
                  for (final s in FCSearchStatus.values)
                    FilterChip(
                      label: Text(_statusLabel(l10n, s)),
                      selected: _status.contains(s),
                      onSelected: (sel) {
                        setState(() {
                          if (sel) {
                            _status.add(s);
                          } else {
                            _status.remove(s);
                          }
                        });
                      },
                    ),
                ]),
                if (widget.loggedIn) ...[
                  const SizedBox(height: DesignTokens.spacingM),
                  _section(l10n.searchFilterMyActivitySection, textTheme, colorScheme),
                  _wrap([
                    for (final p in FCSearchPersonal.values)
                      FilterChip(
                        label: Text(_personalLabel(l10n, p)),
                        selected: _personal.contains(p),
                        onSelected: (sel) {
                          setState(() {
                            if (sel) {
                              _personal.add(p);
                            } else {
                              _personal.remove(p);
                            }
                          });
                        },
                      ),
                  ]),
                ],
                const SizedBox(height: DesignTokens.spacingM),
                _section(l10n.searchFilterMatchTypeSection, textTheme, colorScheme),
                _wrap([
                  FilterChip(
                    label: Text(l10n.titleOnly),
                    selected: _titleOnly,
                    onSelected: (v) => setState(() => _titleOnly = v),
                  ),
                  FilterChip(
                    label: Text(l10n.firstPostsOnly),
                    selected: _firstPostsOnly,
                    onSelected: (v) => setState(() => _firstPostsOnly = v),
                  ),
                ]),
                const SizedBox(height: DesignTokens.spacingM),
                _section(l10n.tags, textTheme, colorScheme),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      // Example tag names, not words to translate.
                      hintText: 'foo bar baz',
                      helperText: l10n.searchTagsFilterHelper,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingM),
                _section(l10n.searchSortBy, textTheme, colorScheme),
                _wrap([
                  ChoiceChip(
                    label: Text(l10n.relevance),
                    selected: _sort == null,
                    onSelected: (v) {
                      if (v) setState(() => _sort = null);
                    },
                  ),
                  for (final s in FCSearchSort.values)
                    ChoiceChip(
                      label: Text(_sortLabel(l10n, s)),
                      selected: _sort == s,
                      onSelected: (v) {
                        setState(() => _sort = v ? s : null);
                      },
                    ),
                ]),
                const SizedBox(height: DesignTokens.spacingXL),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL,
              DesignTokens.spacingS,
              DesignTokens.spacingL,
              DesignTokens.spacingM,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingM),
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    child: Text(l10n.apply),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // The SDK's enums carry English labels; the chips use the app's strings,
  // in Discourse's advanced-search wording where it has one.
  static String _statusLabel(KitLocalizations l10n, FCSearchStatus s) =>
      switch (s) {
        FCSearchStatus.open => l10n.searchStatusOpen,
        FCSearchStatus.closed => l10n.closedLabel,
        FCSearchStatus.archived => l10n.searchStatusArchived,
        FCSearchStatus.noReplies => l10n.searchStatusNoReplies,
        FCSearchStatus.publicOnly => l10n.searchStatusPublicOnly,
        FCSearchStatus.solved => l10n.solved,
        FCSearchStatus.unsolved => l10n.searchStatusUnsolved,
      };

  static String _personalLabel(KitLocalizations l10n, FCSearchPersonal p) =>
      switch (p) {
        FCSearchPersonal.bookmarks => l10n.searchInBookmarked,
        FCSearchPersonal.messages => l10n.searchInMyMessages,
        FCSearchPersonal.liked => l10n.searchInLiked,
        FCSearchPersonal.posted => l10n.searchInPosted,
        FCSearchPersonal.watching => l10n.searchInWatching,
        FCSearchPersonal.tracking => l10n.searchInTracking,
        FCSearchPersonal.seen => l10n.searchInSeen,
        FCSearchPersonal.unseen => l10n.searchInUnseen,
      };

  static String _sortLabel(KitLocalizations l10n, FCSearchSort s) =>
      switch (s) {
        FCSearchSort.latest => l10n.searchSortLatestPost,
        FCSearchSort.likes => l10n.searchSortMostLiked,
        FCSearchSort.views => l10n.searchSortMostViewed,
        FCSearchSort.latestTopic => l10n.searchSortLatestTopic,
      };

  Widget _section(String title, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
      child: Text(
        title,
        style: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _wrap(List<Widget> children) {
    return Wrap(
      spacing: DesignTokens.spacingS,
      runSpacing: DesignTokens.spacingS,
      children: children,
    );
  }
}
