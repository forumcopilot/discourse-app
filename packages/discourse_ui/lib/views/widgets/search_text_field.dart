import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../l10n/generated/app_localizations.dart';

/// A reusable search text field with clear button, auto-search, and debouncing.
class SearchTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  /// The placeholder; "Search…" in the reader's language when null.
  final String? hintText;
  final Function(String query) onSearch;
  final int? minLength;
  final Duration debounceDuration;
  final bool autoSearch;
  final VoidCallback? onClear;

  const SearchTextField({
    Key? key,
    required this.controller,
    this.focusNode,
    this.hintText,
    required this.onSearch,
    this.minLength,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.autoSearch = true,
    this.onClear,
  }) : super(key: key);

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    if (widget.autoSearch) {
      _debounceTimer?.cancel();
      final query = widget.controller.text.trim();
      
      if (widget.minLength == null || query.isEmpty || query.length >= widget.minLength!) {
        _debounceTimer = Timer(widget.debounceDuration, () {
          widget.onSearch(query);
        });
      }
    }
  }

  void _handleClear() {
    widget.controller.clear();
    widget.focusNode?.requestFocus();
    if (widget.onClear != null) {
      widget.onClear!();
    } else if (widget.autoSearch) {
      widget.onSearch('');
    }
  }

  void _handleSubmitted(String value) {
    _debounceTimer?.cancel();
    final query = value.trim();
    if (widget.minLength == null || query.length >= widget.minLength!) {
      widget.onSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.text,
      autocorrect: false,
      enableSuggestions: false,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        hintText:
            widget.hintText ?? AppLocalizations.of(context)!.searchFieldHint,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: _hasText
            ? IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: _handleClear,
              )
            : null,
        // Material 3 search bar: a filled pill, 56dp high, with no outline
        // in any state.
        border: _searchBarBorder,
        enabledBorder: _searchBarBorder,
        focusedBorder: _searchBarBorder,
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        contentPadding: DesignTokens.paddingInput,
      ),
      style: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: _handleSubmitted,
    );
  }
}

/// The Material 3 search bar's shape: a full pill, no outline.
const _searchBarBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(28)),
  borderSide: BorderSide.none,
);
