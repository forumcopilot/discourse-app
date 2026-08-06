import 'package:flutter/services.dart' show TextEditingValue, TextSelection;

/// Formatting-toolbar actions, expressed in the markup Discourse actually
/// cooks.
///
/// Discourse stores posts as Markdown (`posts.raw`) and renders them with
/// markdown-it. Its parser additionally understands a **subset** of BBCode,
/// registered as rules inside the same pipeline — inline `[b] [i] [u] [s]
/// [code] [url] [email] [img]` (see `bbcode-inline.js` in the Discourse
/// source) and block `[quote] [wrap] [excerpt] [code]`, plus `[spoiler]`
/// and `[details]` from bundled plugins. That subset exists mainly so
/// posts imported from phpBB/vBulletin/XenForo keep rendering.
///
/// Everything outside that subset — `[list]`, `[*]`, `[video]`, `[color]`,
/// `[size]`, `[center]`, `[attach]` — passes straight through as literal
/// text. So the toolbar emits Markdown wherever Markdown has the concept,
/// and reaches for BBCode only where it genuinely is the native spelling
/// (underline, quote, spoiler).
///
/// Both composers share this so they cannot drift apart again: the main
/// composer was migrated off XenForo BBCode in Phase 5.19, but the
/// new-conversation composer was missed and kept emitting `[LIST]`,
/// `[VIDEO]`, `[LEFT]` and `[CENTER]` — none of which Discourse parses.
class DiscourseMarkup {
  const DiscourseMarkup._();

  /// Toolbar action identifiers this class knows how to emit. A toolbar
  /// must not offer an action outside this set — [apply] returns the
  /// value untouched for anything else, which reads to the user as a
  /// dead button.
  static const Set<String> supportedActions = <String>{
    'B', 'I', 'U', 'S', 'URL', 'IMG', 'VIDEO', 'QUOTE', 'CODE', 'SPOILER',
    'LIST', 'LIST=1', '*',
  };

  /// Applies [tag] to [value], wrapping the selection when there is one
  /// and otherwise inserting empty markers with the cursor placed between
  /// them. Returns the value unchanged for an unrecognised tag.
  static TextEditingValue apply(TextEditingValue value, String tag) {
    final int start = value.selection.start;
    final int end = value.selection.end;
    final String selectedText =
        (start >= 0 && end > start) ? value.text.substring(start, end) : '';

    // Lists: Markdown has per-line markers, not wrapping tags — turn each
    // selected line into an item, or insert a starter item on its own line.
    if (tag == 'LIST' || tag == 'LIST=1' || tag == '*') {
      return _applyList(value, tag, selectedText);
    }

    final ({String prefix, String suffix})? markers =
        _markersFor(tag, selectedText);
    if (markers == null) return value;

    final String prefix = markers.prefix;
    final String suffix = markers.suffix;

    // start < 0 means there is no valid cursor position — append instead.
    if (start < 0) {
      final newText = '${value.text}$prefix$suffix';
      return TextEditingValue(
        text: newText,
        selection:
            TextSelection.collapsed(offset: newText.length - suffix.length),
      );
    }

    final String newText;
    final int cursorPosition;
    if (start == end) {
      newText = value.text.replaceRange(start, start, '$prefix$suffix');
      cursorPosition = start + prefix.length; // between the markers
    } else {
      newText = value.text.replaceRange(start, end, '$prefix$selectedText$suffix');
      cursorPosition = start + prefix.length + selectedText.length + suffix.length;
    }

    return TextEditingValue(
      text: newText,
      selection:
          TextSelection.collapsed(offset: cursorPosition.clamp(0, newText.length)),
    );
  }

  static ({String prefix, String suffix})? _markersFor(
      String tag, String selectedText) {
    switch (tag) {
      case 'B':
        return (prefix: '**', suffix: '**');
      case 'I':
        return (prefix: '*', suffix: '*');
      case 'U':
        // Markdown has no underline; Discourse parses [u] natively.
        return (prefix: '[u]', suffix: '[/u]');
      case 'S':
        return (prefix: '~~', suffix: '~~');
      case 'URL':
        return (prefix: '[', suffix: '](url)');
      case 'IMG':
        return (prefix: '![](', suffix: ')');
      case 'VIDEO':
        // Discourse has no [video] markup — a media URL alone on its own
        // line oneboxes into a player.
        return (prefix: '\n', suffix: '\n');
      case 'QUOTE':
        return (prefix: '[quote]\n', suffix: '\n[/quote]');
      case 'CODE':
        return selectedText.contains('\n')
            ? (prefix: '```\n', suffix: '\n```')
            : (prefix: '`', suffix: '`');
      case 'SPOILER':
        // spoiler-alert ships as a bundled Discourse plugin.
        return (prefix: '[spoiler]', suffix: '[/spoiler]');
      default:
        return null;
    }
  }

  static TextEditingValue _applyList(
      TextEditingValue value, String tag, String selectedText) {
    final bool numbered = tag == 'LIST=1';
    final int start = value.selection.start;
    final int end = value.selection.end;
    final int insertAt = start < 0 ? value.text.length : start;

    String replacement;
    if (selectedText.isNotEmpty) {
      final buffer = StringBuffer();
      var itemNo = 1;
      for (final line in selectedText.split('\n')) {
        if (line.trim().isEmpty) continue;
        buffer.writeln(numbered ? '${itemNo++}. ${line.trim()}' : '- ${line.trim()}');
      }
      replacement = buffer.toString();
    } else {
      replacement = numbered ? '1. ' : '- ';
    }

    // List items must start at the beginning of a line.
    if (insertAt > 0 && value.text[insertAt - 1] != '\n') {
      replacement = '\n$replacement';
    }

    final newText =
        value.text.replaceRange(insertAt, start < 0 ? insertAt : end, replacement);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: (insertAt + replacement.length).clamp(0, newText.length)),
    );
  }

  /// Builds the Discourse Markdown reference for an upload, from the
  /// upload's `short_url` (`upload://abc123.png`).
  ///
  /// Images embed inline; everything else renders as a download link.
  /// Discourse Markdown has no thumbnail-vs-full distinction — rendered
  /// size is governed by the site/category settings.
  static String attachmentRef(String shortUrl, {required bool isImage}) =>
      isImage ? '![image]($shortUrl)' : '[file|attachment]($shortUrl)';
}
