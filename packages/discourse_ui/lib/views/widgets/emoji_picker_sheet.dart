import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../theme/design_tokens.dart';
import '../../utils/discourse_emoji_data.dart';
import 'sheet_title.dart';

/// A grid of Discourse's emoji with a search, as a bottom sheet. Returns the
/// chosen shortcode (`heart`, `+1`), or null. [first] are listed before the
/// rest (a status's usual emoji, the reader's reactions); names the table
/// lacks are left out.
///
/// Shared by the user status, chat reactions and the chat composer.
Future<String?> showEmojiPickerSheet(BuildContext context, {List<String> first = const []}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.75,
      child: EmojiPicker(first: first),
    ),
  );
}

class EmojiPicker extends StatefulWidget {
  const EmojiPicker({super.key, this.first = const []});

  final List<String> first;

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  String _query = '';

  /// One name per character: the table lists aliases too.
  static final List<String> _all = () {
    final seen = <String>{};
    return [
      for (final e in discourseEmojiByName.entries)
        if (seen.add(e.value)) e.key,
    ];
  }();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final q = _query.trim().toLowerCase().replaceAll(' ', '_');
    final first = widget.first.where(discourseEmojiByName.containsKey).toList();
    final names = q.isEmpty
        ? [
            ...first,
            ..._all.where((n) => !first.contains(n)),
          ]
        : discourseEmojiByName.keys.where((n) => n.contains(q)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l10n.chooseEmoji),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DesignTokens.spacingL, 0, DesignTokens.spacingL, DesignTokens.spacingS),
          child: SearchBar(
            hintText: l10n.searchEmoji,
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(0),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingS),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 52,
            ),
            itemCount: names.length,
            itemBuilder: (context, i) {
              final name = names[i];
              return Tooltip(
                message: ':$name:',
                child: InkWell(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                  onTap: () => Navigator.pop(context, name),
                  child: Center(
                    child: Text(discourseEmojiByName[name] ?? '',
                        style: const TextStyle(fontSize: 28)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
