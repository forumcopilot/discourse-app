import 'dart:async';

import 'package:flutter/material.dart';
import 'package:discourse_ui/services/site_proxy_service.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';

/// A composer-friendly tag input: text field + chip row + autocomplete
/// menu backed by `/tags/filter/search.json`.
///
/// Usage:
///
/// ```dart
/// TagInputField(
///   initial: const ['flutter', 'mobile'],
///   onChanged: (tags) => _tags = tags,
/// )
/// ```
///
/// The widget keeps its own list internally; [onChanged] fires on every
/// add/remove. Submission semantics:
///   - Enter / Done on the soft-keyboard → commits the current text as a
///     new tag.
///   - Space inside the text field also commits (matches Discourse's
///     web composer behaviour).
///   - Tapping a suggestion commits that tag immediately.
class TagInputField extends StatefulWidget {
  final List<String> initial;
  final ValueChanged<List<String>>? onChanged;

  /// Optional cap on how many tags the forum allows on a topic. Stock
  /// Discourse defaults to 5; passing null disables the cap (server
  /// will reject if exceeded).
  final int? maxTags;

  /// Whether the user may invent tags that do not exist yet
  /// (`can_create_tag`). When false, only tags picked from the suggestion
  /// list commit — typing a new one and pressing Enter does nothing here
  /// rather than being accepted and then rejected by the server on submit,
  /// which loses the whole post's tags.
  final bool allowCreate;

  /// Label shown above the chips when the user hasn't entered any
  /// tags yet; null for "Tags".
  final String? label;

  const TagInputField({
    super.key,
    this.initial = const [],
    this.onChanged,
    this.maxTags = 5,
    this.label,
    this.allowCreate = true,
  });

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _tags = [];
  List<String> _suggestions = const [];
  Timer? _debounce;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _tags.addAll(widget.initial);
    _controller.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onInputChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final text = _controller.text;
    // Auto-commit on space (matches Discourse's web composer).
    if (text.endsWith(' ') || text.endsWith(',')) {
      _commit(text);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _search(text));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = const [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    final result = await SiteProxyService.getTagProxy().searchTagsAsync(query);
    if (!mounted) return;
    setState(() {
      _suggestions = result.names
          .where((s) => !_tags.contains(s))
          .take(8)
          .toList(growable: false);
      _searching = false;
    });
  }

  void _commit(String raw) {
    // Refuse to invent a tag the forum will not accept. Suggestions are
    // existing tags, so committing one of those is always fine.
    if (!widget.allowCreate) {
      final candidate = raw.trim().toLowerCase();
      final known = _suggestions.map((s) => s.toLowerCase()).toSet();
      if (candidate.isEmpty || !known.contains(candidate)) return;
    }
    final candidates = raw
        .split(RegExp(r'[\s,]+'))
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();
    if (candidates.isEmpty) {
      _controller.clear();
      return;
    }
    setState(() {
      for (final t in candidates) {
        if (_tags.contains(t)) continue;
        if (widget.maxTags != null && _tags.length >= widget.maxTags!) break;
        _tags.add(t);
      }
      _controller.clear();
      _suggestions = const [];
    });
    widget.onChanged?.call(List.unmodifiable(_tags));
  }

  void _remove(String tag) {
    setState(() => _tags.remove(tag));
    widget.onChanged?.call(List.unmodifiable(_tags));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final cap = widget.maxTags;
    final atCap = cap != null && _tags.length >= cap;

    // The composer's other fields' look: a full-width outlined field with
    // its label in it and the count as its counter, the tags as input chips
    // under it. It was a 200dp-wide dense box under a separate label.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: !atCap,
          decoration: InputDecoration(
            labelText: widget.label ?? l10n.tags,
            hintText: atCap
                ? l10n.tagInputMaxReached
                : (_tags.isEmpty ? l10n.tagInputAddTag : l10n.tagInputAddAnother),
            counterText: cap == null ? null : '${_tags.length}/$cap',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: _commit,
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: DesignTokens.spacingS),
          Wrap(
            spacing: DesignTokens.spacingS,
            runSpacing: DesignTokens.spacingS,
            children: [
              for (final t in _tags)
                InputChip(
                  label: Text(t),
                  onDeleted: () => _remove(t),
                ),
            ],
          ),
        ],
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: DesignTokens.spacingS),
          Wrap(
            spacing: DesignTokens.spacingS,
            runSpacing: DesignTokens.spacingS,
            children: [
              for (final s in _suggestions)
                ActionChip(
                  label: Text(s),
                  onPressed: atCap ? null : () => _commit(s),
                ),
            ],
          ),
        ] else if (_searching) ...[
          const SizedBox(height: DesignTokens.spacingS),
          SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}
