import 'package:discourse_core/discourse_core.dart'
    show DiscourseChatMessageReaction;
import 'package:flutter/material.dart';

import '../../../theme/design_tokens.dart';

/// Discourse's default chat reaction set (site setting
/// `default_emoji_reactions` ships as heart / +1 / laughing / … ) —
/// offered by the long-press picker.
const List<String> kChatDefaultReactions = [
  'heart',
  '+1',
  'laughing',
  'open_mouth',
  'clap',
  'confetti_ball',
  'hugs',
];

/// Discourse emoji name (no colons) → unicode for the common set.
/// Anything not listed renders as `:name:`, mirroring how an uncooked
/// emoji shortcode looks on the web.
const Map<String, String> _emojiUnicode = {
  'heart': '❤️',
  '+1': '👍',
  '-1': '👎',
  'thumbsup': '👍',
  'thumbsdown': '👎',
  'laughing': '😆',
  'open_mouth': '😮',
  'clap': '👏',
  'confetti_ball': '🎊',
  'hugs': '🤗',
  'tada': '🎉',
  'smile': '😄',
  'smiley': '😃',
  'grin': '😁',
  'grinning': '😀',
  'joy': '😂',
  'wink': '😉',
  'cry': '😢',
  'sob': '😭',
  'angry': '😠',
  'rage': '😡',
  'thinking': '🤔',
  'fire': '🔥',
  'eyes': '👀',
  'rocket': '🚀',
  'heart_eyes': '😍',
  'sunglasses': '😎',
  'ok_hand': '👌',
  'wave': '👋',
  'raised_hands': '🙌',
  'pray': '🙏',
  'muscle': '💪',
  '100': '💯',
  'star': '⭐',
  'white_check_mark': '✅',
  'heavy_check_mark': '✔️',
  'x': '❌',
};

/// Display label for a Discourse emoji name: unicode when known,
/// `:name:` otherwise.
String chatEmojiLabel(String name) => _emojiUnicode[name] ?? ':$name:';

/// The row of reaction chips under a chat message.
///
/// [reactions] is the proxy's side-table snapshot for this message
/// (re-read by the parent on every poll tick / toggle). Tapping a chip
/// toggles the current user's reaction with an optimistic override
/// held locally: on success the side-table already reflects the change
/// so the override is redundant; on failure dropping the override
/// reverts the chip (the parent surfaces the error).
class ChatReactionChips extends StatefulWidget {
  const ChatReactionChips({
    super.key,
    required this.reactions,
    required this.onToggle,
  });

  final List<DiscourseChatMessageReaction> reactions;

  /// Performs the toggle; resolves false on failure (revert). Null
  /// renders the chips read-only (guests).
  final Future<bool> Function(String emoji, {required bool add})? onToggle;

  @override
  State<ChatReactionChips> createState() => _ChatReactionChipsState();
}

class _ChatReactionChipsState extends State<ChatReactionChips> {
  /// Optimistic overrides: emoji → desired `reacted` state, cleared
  /// when the toggle round-trip completes (either way).
  final Map<String, bool> _pending = {};
  final Set<String> _busy = {};

  Future<void> _toggle(String emoji, bool currentlyReacted) async {
    final onToggle = widget.onToggle;
    if (onToggle == null || _busy.contains(emoji)) return;
    final add = !currentlyReacted;
    setState(() {
      _busy.add(emoji);
      _pending[emoji] = add;
    });
    await onToggle(emoji, add: add);
    if (!mounted) return;
    setState(() {
      _busy.remove(emoji);
      _pending.remove(emoji);
    });
  }

  /// Side-table reactions with the optimistic overrides applied.
  List<(String, int, bool, List<String>)> _effective() {
    final out = <(String, int, bool, List<String>)>[];
    final seen = <String>{};
    for (final r in widget.reactions) {
      seen.add(r.emoji);
      final pending = _pending[r.emoji];
      if (pending == null || pending == r.reacted) {
        out.add((r.emoji, r.count, r.reacted, r.usernames));
      } else if (pending) {
        out.add((r.emoji, r.count + 1, true, r.usernames));
      } else if (r.count > 1) {
        out.add((r.emoji, r.count - 1, false, r.usernames));
      }
      // else: removing the last reaction — drop the chip entirely.
    }
    for (final entry in _pending.entries) {
      if (entry.value && !seen.contains(entry.key)) {
        out.add((entry.key, 1, true, const []));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final chips = _effective();
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: DesignTokens.spacingXS),
      child: Wrap(
        spacing: DesignTokens.spacingXS,
        runSpacing: DesignTokens.spacingXS,
        children: [
          for (final (emoji, count, reacted, usernames) in chips)
            _chip(context, emoji, count, reacted, usernames),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String emoji, int count, bool reacted,
      List<String> usernames) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final chip = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: widget.onToggle == null ? null : () => _toggle(emoji, reacted),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: reacted
              ? colorScheme.primary.withValues(alpha: 0.15)
              : colorScheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: reacted ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          '${chatEmojiLabel(emoji)} $count',
          style: textTheme.labelSmall?.copyWith(
            fontWeight: reacted ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
    if (usernames.isEmpty) return chip;
    return Tooltip(message: usernames.join(', '), child: chip);
  }
}
