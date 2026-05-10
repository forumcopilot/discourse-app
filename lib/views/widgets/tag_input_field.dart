import 'dart:async';

import 'package:discourse_core/discourse_core.dart' show DiscourseTopicProxy;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';

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

  /// Label shown above the chips when the user hasn't entered any
  /// tags yet.
  final String label;

  const TagInputField({
    super.key,
    this.initial = const [],
    this.onChanged,
    this.maxTags = 5,
    this.label = 'Tags',
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
    final proxy = SiteProxyFactory.getTopicProxy();
    if (proxy is! DiscourseTopicProxy) {
      setState(() {
        _suggestions = const [];
        _searching = false;
      });
      return;
    }
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = const [];
        _searching = false;
      });
      return;
    }
    setState(() => _searching = true);
    final results = await proxy.searchTagsAsync(query);
    if (!mounted) return;
    setState(() {
      _suggestions = results
          .where((s) => !_tags.contains(s))
          .take(8)
          .toList(growable: false);
      _searching = false;
    });
  }

  void _commit(String raw) {
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
    final textTheme = Theme.of(context).textTheme;
    final cap = widget.maxTags;
    final atCap = cap != null && _tags.length >= cap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (cap != null) ...[
              const SizedBox(width: 8),
              Text(
                '${_tags.length}/$cap',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: DesignTokens.spacingS),
        Wrap(
          spacing: DesignTokens.spacingXS,
          runSpacing: DesignTokens.spacingXS,
          children: [
            for (final t in _tags)
              Chip(
                label: Text(t),
                onDeleted: () => _remove(t),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !atCap,
                decoration: InputDecoration(
                  hintText: atCap
                      ? 'Max tags reached'
                      : (_tags.isEmpty ? 'Add a tag…' : '+ tag'),
                  isDense: true,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: _commit,
              ),
            ),
          ],
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: DesignTokens.spacingS),
          Wrap(
            spacing: DesignTokens.spacingXS,
            runSpacing: DesignTokens.spacingXS,
            children: [
              for (final s in _suggestions)
                ActionChip(
                  label: Text(s),
                  onPressed: atCap ? null : () => _commit(s),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
