import 'package:flutter/material.dart';

/// Parses a Discourse colour setting into a [Color].
///
/// Discourse stores whatever the admin typed, so 3-char shorthand is
/// common — `tech` on try.discourse.org is "444". Expand it rather than
/// dropping the colour, which is what made that category fall back to a
/// hashed tile.
///
/// Returns null for anything that is not a 3- or 6-digit hex value, so
/// callers can fall back deliberately rather than rendering black.
Color? parseDiscourseHex(String hex) {
  var clean = hex.replaceAll('#', '').trim();
  if (clean.length == 3) {
    clean = clean.split('').map((ch) => '$ch$ch').join();
  }
  if (clean.length != 6) return null;
  final v = int.tryParse(clean, radix: 16);
  if (v == null) return null;
  return Color(0xFF000000 | v);
}
