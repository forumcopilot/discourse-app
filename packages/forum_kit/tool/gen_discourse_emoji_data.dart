// Regenerates lib/utils/discourse_emoji_data.dart from the `discourse-emojis`
// gem that Discourse itself ships its shortcode table in.
//
//   dart run tool/gen_discourse_emoji_data.dart <path to discourse-emojis>/dist
//
// Locate the gem with `bundle show discourse-emojis` inside a Discourse
// checkout. The script is deliberately a plain Dart program (no Flutter
// imports) so it runs with `dart run` from this package directory.
//
// The `emojis` pub package is used only to pick the fully-qualified form of
// each character: Discourse stores `warning` as bare `26a0`, but text
// rendering wants `26a0 fe0f` so the glyph comes out as the colour emoji
// rather than the monochrome dingbat. Where the package knows `code + FE0F`
// but not the bare code, the selector is appended.
import 'dart:convert';
import 'dart:io';

import 'package:emojis/emoji.dart';

/// Fitzpatrick modifiers for Discourse's `:tN:` suffix, t2..t6 in order.
/// Mirrors `Emoji::FITZPATRICK_SCALE` in app/models/emoji.rb.
const _fitzpatrick = [0x1f3fb, 0x1f3fc, 0x1f3fd, 0x1f3fe, 0x1f3ff];

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('usage: dart run tool/gen_discourse_emoji_data.dart '
        '<discourse-emojis gem>/dist');
    exit(64);
  }
  final dist = Directory(args.single);
  final emojis = _json(dist, 'emojis.json') as List;
  final aliases = (_json(dist, 'aliases.json') as Map).cast<String, List>();
  final tonable = (_json(dist, 'tonable_emojis.json') as List).cast<String>();
  final version = _gemVersion(dist);

  final known = Emoji.all().map((e) => e.char).toSet();
  String qualify(String char) {
    if (known.contains(char)) return char;
    final withSelector = '$char️';
    if (known.contains(withSelector)) return withSelector;
    return char;
  }

  // name -> character, canonical names first, then aliases. Discourse's own
  // `Emoji.lookup_unicode` skips "tm" and drops aliases whose target is
  // unknown; the same rules apply here.
  final byName = <String, String>{};
  for (final entry in emojis.cast<Map>()) {
    final name = entry['name'] as String;
    if (name == 'tm') continue;
    final code = entry['code'] as String;
    final char = String.fromCharCodes(
        code.split('-').map((hex) => int.parse(hex, radix: 16)));
    byName[name] = qualify(char);
  }
  final tonableNames = <String>{};
  for (final name in tonable) {
    if (byName.containsKey(name)) tonableNames.add(name);
  }
  var droppedAliases = 0;
  for (final alias in aliases.entries) {
    final char = byName[alias.key];
    if (char == null) {
      droppedAliases += alias.value.length;
      continue;
    }
    for (final name in alias.value.cast<String>()) {
      byName.putIfAbsent(name, () => char);
      if (tonableNames.contains(alias.key)) tonableNames.add(name);
    }
  }

  final out = StringBuffer()
    ..writeln('// GENERATED FILE - DO NOT EDIT BY HAND.')
    ..writeln('//')
    ..writeln('// Source: discourse-emojis gem $version, dist/emojis.json +')
    ..writeln('// dist/aliases.json + dist/tonable_emojis.json.')
    ..writeln('// Regenerate with tool/gen_discourse_emoji_data.dart.')
    ..writeln()
    ..writeln('/// Discourse shortcode name (canonical or alias) to the '
        'character it stands for.')
    ..writeln('const Map<String, String> discourseEmojiByName = {');
  for (final entry in byName.entries) {
    out.writeln("  '${entry.key}': '${_escape(entry.value)}',");
  }
  out
    ..writeln('};')
    ..writeln()
    ..writeln('/// Names (canonical and alias) that accept a `:tN:` skin-tone '
        'suffix.')
    ..writeln('const Set<String> discourseTonableEmoji = {');
  for (final name in tonableNames) {
    out.writeln("  '$name',");
  }
  out
    ..writeln('};')
    ..writeln()
    ..writeln('/// Fitzpatrick modifiers for `:t2:` .. `:t6:`, in that order.')
    ..writeln('const List<int> discourseFitzpatrickScale = ['
        '${_fitzpatrick.map((r) => '0x${_hex(r)}').join(', ')}];');

  final target = File('lib/utils/discourse_emoji_data.dart');
  target.writeAsStringSync(out.toString());
  stdout.writeln('wrote ${target.path}: ${byName.length} names '
      '(${tonableNames.length} tonable), dropped $droppedAliases aliases '
      'with no target');
}

Object? _json(Directory dist, String file) =>
    jsonDecode(File('${dist.path}/$file').readAsStringSync());

String _gemVersion(Directory dist) {
  final m = RegExp(r'discourse-emojis-([\d.]+)').firstMatch(dist.path);
  return m?.group(1) ?? '(unknown version)';
}

String _escape(String char) => char.runes.map(_hex).map((h) => '\\u{$h}').join();

String _hex(int rune) => rune.toRadixString(16);
