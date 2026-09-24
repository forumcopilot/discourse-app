import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/a11y-dark.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:highlight/highlight.dart' show highlight, Node;

import '../../l10n/generated/app_localizations.dart';
import '../../utils/html_colors.dart';

/// A code block as the web shows it: coloured by language (the `lang-*`
/// class Discourse cooks onto the `<code>`), scrolling sideways instead of
/// wrapping, with a copy button in the corner. The app showed plain
/// monospace text with nothing to copy it by.
///
/// Colours follow the theme: the a11y palettes (light/dark), with every
/// token then held to 4.5:1 contrast on the block's actual background —
/// stock palettes put comments and annotations in greys that fall under
/// 2.5:1 on a tinted block, which made code harder to read than plain text. `lang-auto` is detected (only for blocks short enough to detect
/// quickly); `lang-plaintext`, `lang-nohighlight` and unknown languages
/// stay plain.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.code,
    required this.textStyle,
    this.language,
  });

  final String code;
  final TextStyle textStyle;

  /// Discourse's language name (`python`, `yml`, `auto`, …), or null.
  final String? language;

  /// Detecting a language runs every grammar over the text; beyond this it
  /// costs more than colour is worth while scrolling a thread.
  static const int _autoDetectLimit = 3000;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final spans = highlightSpans(
        code, language, readableTheme(dark ? a11yDarkTheme : a11yLightTheme, colorScheme.surfaceContainerHighest));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // Room on the right so the last characters of the first lines
            // are not under the copy button.
            padding: const EdgeInsets.fromLTRB(12, 12, 44, 12),
            // Plain Text, not SelectableText: SelectableText claims
            // horizontal drags for text selection, which swallows the
            // scroll gesture. The copy button covers the selection use.
            child: Text.rich(
              TextSpan(
                style: textStyle.copyWith(color: textStyle.color ?? colorScheme.onSurface),
                children: spans,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: AppLocalizations.of(context)?.copy ?? 'Copy',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.copy_rounded, size: 18, color: colorScheme.onSurfaceVariant),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code));
                if (!context.mounted) return;
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)?.copied ?? 'Copied'),
                  duration: const Duration(seconds: 2),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }

  /// [code] as coloured spans; plain when the language is none, unknown or
  /// too long to detect.
  static List<InlineSpan> highlightSpans(String code, String? language, Map<String, TextStyle> theme) {
    final lang = language?.trim().toLowerCase();
    if (lang == null || lang.isEmpty || lang == 'plaintext' || lang == 'nohighlight' || lang == 'text') {
      return [TextSpan(text: code)];
    }
    List<Node>? nodes;
    try {
      if (lang == 'auto') {
        if (code.length <= _autoDetectLimit) {
          nodes = highlight.parse(code, autoDetection: true).nodes;
        }
      } else {
        nodes = highlight.parse(code, language: _aliases[lang] ?? lang).nodes;
      }
    } catch (_) {
      nodes = null;
    }
    if (nodes == null) return [TextSpan(text: code)];

    final out = <InlineSpan>[];
    void walk(Node node, List<InlineSpan> into) {
      final style = node.className == null ? null : theme[node.className!];
      if (node.value != null) {
        into.add(TextSpan(text: node.value, style: _noBackground(style)));
      } else if (node.children != null) {
        final children = <InlineSpan>[];
        for (final c in node.children!) {
          walk(c, children);
        }
        into.add(TextSpan(style: _noBackground(style), children: children));
      }
    }

    for (final n in nodes) {
      walk(n, out);
    }
    return out;
  }

  static final Map<(Map<String, TextStyle>, int), Map<String, TextStyle>> _readable = {};

  /// [theme] with every token colour adjusted, hue kept, to at least 4.5:1
  /// against [background]. Computed once per theme and background.
  static Map<String, TextStyle> readableTheme(Map<String, TextStyle> theme, Color background) =>
      _readable.putIfAbsent((theme, background.toARGB32()), () => {
            for (final e in theme.entries)
              e.key: e.value.color == null
                  ? e.value
                  : e.value.copyWith(color: readableOn(e.value.color!, background)),
          });

  /// Names Discourse accepts that the grammar set spells differently.
  static const Map<String, String> _aliases = {
    'yml': 'yaml',
    'jsonc': 'json',
    'sh': 'bash',
    'shell': 'bash',
    'console': 'bash',
    'js': 'javascript',
    'ts': 'typescript',
    'py': 'python',
    'rb': 'ruby',
    'kt': 'kotlin',
    'md': 'markdown',
    'html': 'xml',
  };

  // Token backgrounds (e.g. GitHub's diff lines) fight the block's own.
  static TextStyle? _noBackground(TextStyle? s) =>
      s?.copyWith(backgroundColor: Colors.transparent);
}
