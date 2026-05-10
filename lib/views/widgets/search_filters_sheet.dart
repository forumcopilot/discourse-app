import 'package:discourse_core/discourse_core.dart'
    show
        DiscourseSearchFilters,
        DiscourseSearchPersonal,
        DiscourseSearchSort,
        DiscourseSearchStatus;
import 'package:flutter/material.dart';

import '../../theme/design_tokens.dart';

/// Bottom sheet that lets the user toggle Discourse-native search filters
/// (status, personal, sort, tags) on top of a free-text query. Returns
/// the new [DiscourseSearchFilters] when the user taps Apply, or null
/// when they back out.
class SearchFiltersSheet extends StatefulWidget {
  final DiscourseSearchFilters initial;
  final bool loggedIn;

  const SearchFiltersSheet({
    super.key,
    required this.initial,
    this.loggedIn = false,
  });

  static Future<DiscourseSearchFilters?> show({
    required BuildContext context,
    required DiscourseSearchFilters initial,
    bool loggedIn = false,
  }) {
    return showModalBottomSheet<DiscourseSearchFilters>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
  late Set<DiscourseSearchStatus> _status;
  late Set<DiscourseSearchPersonal> _personal;
  late bool _firstPostsOnly;
  late bool _titleOnly;
  late DiscourseSearchSort? _sort;
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

  DiscourseSearchFilters _buildResult() {
    final tags = _tagController.text
        .trim()
        .split(RegExp(r'[\s,]+'))
        .where((t) => t.isNotEmpty)
        .toList();
    return DiscourseSearchFilters(
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

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL,
              DesignTokens.spacingM,
              DesignTokens.spacingS,
              DesignTokens.spacingS,
            ),
            child: Row(
              children: [
                Text(
                  'Search filters',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton(onPressed: _reset, child: const Text('Reset')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spacingL,
                vertical: DesignTokens.spacingS,
              ),
              children: [
                _section('Status', textTheme, colorScheme),
                _wrap([
                  for (final s in DiscourseSearchStatus.values)
                    FilterChip(
                      label: Text(s.label),
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
                  _section('My activity', textTheme, colorScheme),
                  _wrap([
                    for (final p in DiscourseSearchPersonal.values)
                      FilterChip(
                        label: Text(p.label),
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
                _section('Match type', textTheme, colorScheme),
                _wrap([
                  FilterChip(
                    label: const Text('Title only'),
                    selected: _titleOnly,
                    onSelected: (v) => setState(() => _titleOnly = v),
                  ),
                  FilterChip(
                    label: const Text('First posts only'),
                    selected: _firstPostsOnly,
                    onSelected: (v) => setState(() => _firstPostsOnly = v),
                  ),
                ]),
                const SizedBox(height: DesignTokens.spacingM),
                _section('Tags', textTheme, colorScheme),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'foo bar baz',
                      isDense: true,
                      helperText:
                          'Space- or comma-separated. Each tag is required.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingM),
                _section('Sort', textTheme, colorScheme),
                _wrap([
                  ChoiceChip(
                    label: const Text('Relevance'),
                    selected: _sort == null,
                    onSelected: (v) {
                      if (v) setState(() => _sort = null);
                    },
                  ),
                  for (final s in DiscourseSearchSort.values)
                    ChoiceChip(
                      label: Text(s.label),
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
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: DesignTokens.spacingM),
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spacingS),
      child: Text(
        title,
        style: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
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
