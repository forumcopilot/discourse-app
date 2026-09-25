import 'dart:typed_data';

import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/theme/forum_brand_style.dart';
import 'package:discourse_ui/theme/forum_palette.dart';
import 'package:discourse_ui/utils/html_colors.dart';
import 'package:discourse_ui/utils/logo_tone.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The forum's identity card: a gradient in the forum's own colour, and a
/// logo that stays visible on it. Logos are transparent artwork drawn for
/// the forum's own header, so on another colour a black wordmark can vanish
/// into a dark card — Asana's did, which is why its card used to stay white
/// in dark mode.
void main() {
  group('LogoTone', () {
    // A 10×1 strip: [n] opaque pixels of [rgb], the rest transparent.
    Uint8List strip(int n, List<int> rgb) {
      final out = Uint8List(40);
      for (var i = 0; i < n; i++) {
        out.setAll(i * 4, [...rgb, 255]);
      }
      return out;
    }

    // A 10-pixel strip of runs of colour, the rest transparent.
    Uint8List mix(List<(int, List<int>)> runs) {
      final out = Uint8List(40);
      var at = 0;
      for (final (n, rgb) in runs) {
        for (var i = 0; i < n; i++, at++) {
          out.setAll(at * 4, [...rgb, 255]);
        }
      }
      return out;
    }

    test('measures the visible pixels only', () {
      final tone = LogoTone.fromRgba(strip(3, [0, 0, 0]))!;
      expect(tone.coverage, closeTo(0.3, 0.001));
      expect(tone.lostOn(Colors.black), closeTo(1, 0.001));
      expect(tone.lostOn(Colors.white), 0);
      expect(LogoTone.fromRgba(strip(0, [0, 0, 0])), isNull);
    });

    test('a black wordmark on a dark card is inverted; on white it is left',
        () {
      // Asana's: black text with coral dots.
      final asana = LogoTone.fromRgba(mix([(6, [17, 17, 17]), (2, [240, 106, 106])]))!;
      expect(asana.fixOn(const Color(0xFF3B1F6B), designedFor: Colors.white),
          LogoFix.invert);
      expect(asana.fixOn(const Color(0xFF1A1A1A), designedFor: Colors.white),
          LogoFix.invert);
      expect(asana.fixOn(Colors.white, designedFor: Colors.white), LogoFix.none);
    });

    test('a white wordmark on a light card is inverted', () {
      // Docker's: white, drawn for its navy header.
      const navy = Color(0xFF051D2F);
      final wordmark = LogoTone.fromRgba(strip(3, [250, 250, 250]))!;
      expect(wordmark.fixOn(const Color(0xFFF8F8F8), designedFor: navy),
          LogoFix.invert);
      expect(wordmark.fixOn(navy, designedFor: navy), LogoFix.none);
    });

    test('a light-and-dark logo gets a backing, not an invert', () {
      // Python's: grey wordmark, blue and yellow snakes, drawn for white.
      // Inverting would turn the yellow snake dark, so it keeps its
      // colours on a backing of white.
      final python = LogoTone.fromRgba(mix([
        (4, [100, 100, 100]),
        (2, [55, 118, 171]),
        (3, [255, 212, 59]),
      ]))!;
      const deepBlue = Color(0xFF1E3A55);
      expect(python.lostOn(deepBlue), greaterThanOrEqualTo(0.3));
      expect(python.fixOn(deepBlue, designedFor: Colors.white), LogoFix.plate);
      // On white the yellow snake is faint too — as designed; left alone.
      expect(python.lostOn(Colors.white), greaterThanOrEqualTo(0.3));
      expect(python.fixOn(Colors.white, designedFor: Colors.white), LogoFix.none);
    });

    test('artwork with its own background reads anywhere', () {
      final badge = LogoTone.fromRgba(strip(10, [20, 20, 20]))!;
      expect(badge.coverage, 1);
      expect(badge.fixOn(Colors.black, designedFor: Colors.white), LogoFix.none);
    });

    test('the fix flips light and dark but keeps hue', () {
      Color apply(Color c) {
        final m = [
          0.574, -1.430, -0.144, 0, 255, //
          -0.426, -0.430, -0.144, 0, 255, //
          -0.426, -1.430, 0.856, 0, 255, //
        ];
        int ch(int row) => (m[row * 5] * (c.r * 255) +
                m[row * 5 + 1] * (c.g * 255) +
                m[row * 5 + 2] * (c.b * 255) +
                m[row * 5 + 4])
            .round()
            .clamp(0, 255);
        return Color.fromARGB(255, ch(0), ch(1), ch(2));
      }

      expect(LogoTone.invertLightness, const ColorFilter.matrix(<double>[
        0.574, -1.430, -0.144, 0, 255, //
        -0.426, -0.430, -0.144, 0, 255, //
        -0.426, -1.430, 0.856, 0, 255, //
        0, 0, 0, 1, 0, //
      ]));
      expect(apply(Colors.black), Colors.white);
      expect(apply(Colors.white), Colors.black);
      // Asana's coral dot stays coral-ish rather than turning teal, as a
      // plain invert would.
      final coral = apply(const Color(0xFFF06A6A));
      expect(HSLColor.fromColor(coral).hue,
          closeTo(HSLColor.fromColor(const Color(0xFFF06A6A)).hue, 20));
    });
  });

  group('ForumBrandStyle', () {
    Future<ForumBrandStyle> brandIn(WidgetTester tester, ThemeData theme) async {
      late ForumBrandStyle brand;
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Builder(builder: (context) {
          brand = ForumBrandStyle.of(context);
          return const SizedBox();
        }),
      ));
      return brand;
    }

    void expectReadable(ForumBrandStyle b) {
      for (final c in b.colors) {
        expect(contrastRatio(b.foreground, c), greaterThanOrEqualTo(4.5));
      }
    }

    testWidgets('a forum with a branded header wears its header colour',
        (tester) async {
      // forums.docker.com: navy header over a near-white page.
      final docker = ForumPalette.fromHex(light: {
        'primary': '222222',
        'secondary': 'f8f8f8',
        'tertiary': '06759a',
        'header_background': '051d2f',
        'header_primary': 'e1f7ff',
      });
      final b = await brandIn(tester, AppTheme.themeFor(Brightness.light, docker));
      expect(b.base, const Color(0xFF051D2F));
      expect(b.foreground, const Color(0xFFE1F7FF));
      expect(b.isDark, isTrue);
      expectReadable(b);
    });

    testWidgets('a page-coloured header gives way to the accent',
        (tester) async {
      // forum.asana.com: white header on a white page, purple accent.
      final asana = ForumPalette.fromHex(light: {
        'primary': '111111',
        'secondary': 'ffffff',
        'tertiary': '6a0085',
        'header_background': 'ffffff',
        'header_primary': '1b2432',
      });
      final theme = AppTheme.themeFor(Brightness.light, asana);
      final b = await brandIn(tester, theme);
      expect(b.base, theme.colorScheme.primaryContainer);
      expectReadable(b);
    });

    testWidgets('no dark scheme: dark mode is the accent, not a white card',
        (tester) async {
      final asana = ForumPalette.fromHex(light: {
        'primary': '111111',
        'secondary': 'ffffff',
        'tertiary': '6a0085',
        'header_background': 'ffffff',
      });
      final theme = AppTheme.themeFor(Brightness.dark, asana);
      final b = await brandIn(tester, theme);
      expect(b.base, theme.colorScheme.primaryContainer);
      expect(b.base.computeLuminance(), lessThan(0.3));
      expectReadable(b);
    });

    testWidgets('the gradient is one colour, lighter to darker',
        (tester) async {
      final b = await brandIn(tester, AppTheme.themeFor(Brightness.light, null));
      expect(b.colors.first.computeLuminance(),
          greaterThan(b.base.computeLuminance()));
      expect(b.colors.last.computeLuminance(),
          lessThan(b.base.computeLuminance()));
      expectReadable(b);
    });

    testWidgets('a bright accent is deepened on a dark screen', (tester) async {
      // community.letsencrypt.org's dark scheme: cyan accent.
      final le = ForumPalette.fromHex(dark: {
        'primary': 'cccccc',
        'secondary': '111111',
        'tertiary': '009dd8',
        'header_background': '131418',
      });
      final theme = AppTheme.themeFor(Brightness.dark, le);
      final b = await brandIn(tester, theme);
      expect(b.isDark, isTrue);
      expect(HSLColor.fromColor(b.base).hue,
          closeTo(HSLColor.fromColor(theme.colorScheme.primaryContainer).hue, 1));
      expectReadable(b);
    });

    testWidgets('a forum not open looks as it will inside', (tester) async {
      final asana = ForumPalette.fromHex(light: {
        'primary': '111111',
        'secondary': 'ffffff',
        'tertiary': '6a0085',
        'header_background': 'ffffff',
      });
      for (final b in Brightness.values) {
        final inside = await brandIn(tester, AppTheme.themeFor(b, asana));
        final outside = ForumBrandStyle.forPalette(asana, b);
        expect(outside.colors, inside.colors, reason: '$b');
        expect(outside.foreground, inside.foreground, reason: '$b');
      }
    });
  });
}
