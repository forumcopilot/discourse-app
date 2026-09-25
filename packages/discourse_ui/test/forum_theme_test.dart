import 'dart:convert';

import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/services/forum_theme.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/theme/forum_colors.dart';
import 'package:discourse_ui/theme/forum_palette.dart';
import 'package:discourse_ui/utils/html_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app wears the open forum's colours: its Discourse light and dark
/// schemes from /site.json, mapped onto Material's ColorScheme with the
/// colours a reader recognises the forum by pinned exactly — unless a
/// pinned colour would be illegible — and nothing forum-coloured outside
/// a forum.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // A teal forum with a warm off-white page, as an admin might set it.
  const tealLight = {
    'primary': '1d2b36',
    'secondary': 'fbf8f2',
    'tertiary': '0a7c86',
    'danger': 'b3261e',
    'selected': 'd8eef0',
    'success': '2e7d32',
    'love': 'e0245e',
  };
  const tealDark = {
    'primary': 'e6edf3',
    'secondary': '0d1117',
    'tertiary': '4fc1cb',
    'selected': '12343a',
  };

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ForumTheme.reset();
    AppForumConfig.setUseForumColors(null);
  });

  group('ForumPalette', () {
    test('reads /site.json hex, 3-digit included; gaps come from stock', () {
      final s = DiscourseScheme.fromHex({'primary': '222', 'tertiary': '0a7c86'});
      expect(s.primary, const Color(0xFF222222));
      expect(s.tertiary, const Color(0xFF0A7C86));
      expect(s.secondary, DiscourseScheme.light.secondary);
      expect(s.love, DiscourseScheme.light.love);
    });

    test('a scheme is dark when its text is brighter than its page', () {
      expect(DiscourseScheme.light.isDark, isFalse);
      expect(DiscourseScheme.dark.isDark, isTrue);
    });

    test('stock forum: Discourse Light in light mode, no dark scheme', () {
      const p = ForumPalette();
      expect(p.schemeFor(Brightness.light), DiscourseScheme.light);
      expect(p.schemeFor(Brightness.dark), isNull);
      expect(p.accent, DiscourseScheme.light.tertiary);
    });

    test('light and dark schemes go to their own mode', () {
      final p = ForumPalette.fromHex(light: tealLight, dark: tealDark);
      expect(p.schemeFor(Brightness.light)!.tertiary, const Color(0xFF0A7C86));
      expect(p.schemeFor(Brightness.dark)!.tertiary, const Color(0xFF4FC1CB));
    });

    test('a dark-only forum has no light scheme', () {
      // Its default ("light") scheme is a dark one and there is no other.
      final p = ForumPalette.fromHex(light: tealDark);
      expect(p.schemeFor(Brightness.light), isNull);
      expect(p.schemeFor(Brightness.dark)!.secondary, const Color(0xFF0D1117));
    });

    test('survives the device cache round trip', () {
      final p = ForumPalette.fromHex(light: tealLight, dark: tealDark);
      final back = ForumPalette.fromJson(jsonDecode(jsonEncode(p.toJson())));
      expect(back, p);
      expect(ForumPalette.fromJson(const ForumPalette().toJson()),
          const ForumPalette());
    });
  });

  group('colour scheme', () {
    final teal = ForumPalette.fromHex(light: tealLight, dark: tealDark);

    test('no forum: the app seed, exactly as before', () {
      expect(AppTheme.colorSchemeFor(Brightness.light, null),
          ColorScheme.fromSeed(seedColor: AppTheme.seedColor));
    });

    test('the colours a reader knows the forum by are its own', () {
      final cs = AppTheme.colorSchemeFor(Brightness.light, teal);
      expect(cs.brightness, Brightness.light);
      expect(cs.surface, const Color(0xFFFBF8F2)); // secondary: the page
      expect(cs.onSurface, const Color(0xFF1D2B36)); // primary: the text
      expect(cs.primary, const Color(0xFF0A7C86)); // tertiary: the accent
      expect(cs.onPrimary, const Color(0xFFFBF8F2)); // as on its buttons
      expect(cs.error, const Color(0xFFB3261E)); // danger
      expect(cs.secondaryContainer, const Color(0xFFD8EEF0)); // selected
      expect(cs.inverseSurface, cs.onSurface);
    });

    test('container greys are mixed from the forum page and text', () {
      final cs = AppTheme.colorSchemeFor(Brightness.light, teal);
      final page = cs.surface.computeLuminance();
      expect(cs.surfaceContainerLow.computeLuminance(), lessThan(page));
      expect(cs.surfaceContainerHighest.computeLuminance(),
          lessThan(cs.surfaceContainerLow.computeLuminance()));
      expect(contrastRatio(cs.onSurfaceVariant, cs.surface),
          greaterThanOrEqualTo(4.5));
    });

    test('dark mode uses the forum dark scheme', () {
      final cs = AppTheme.colorSchemeFor(Brightness.dark, teal);
      expect(cs.brightness, Brightness.dark);
      expect(cs.surface, const Color(0xFF0D1117));
      expect(cs.primary, const Color(0xFF4FC1CB));
    });

    test('a forum with no dark mode still gets one, in its accent', () {
      final lightOnly = ForumPalette.fromHex(light: tealLight);
      final cs = AppTheme.colorSchemeFor(Brightness.dark, lightOnly);
      expect(cs.brightness, Brightness.dark);
      expect(cs.surface.computeLuminance(), lessThan(0.1));
      // Seeded from the teal, not the app's blue.
      expect(HSLColor.fromColor(cs.primary).hue,
          closeTo(HSLColor.fromColor(const Color(0xFF0A7C86)).hue, 15));
    });

    test('an illegible accent is not pinned', () {
      // Pale yellow links on white: fine as a brand swatch, unreadable
      // as a button or link.
      final pale = ForumPalette.fromHex(
          light: {...tealLight, 'secondary': 'ffffff', 'tertiary': 'fff3a0'});
      final cs = AppTheme.colorSchemeFor(Brightness.light, pale);
      expect(cs.primary, isNot(const Color(0xFFFFF3A0)));
      expect(contrastRatio(cs.primary, cs.surface), greaterThanOrEqualTo(3));
    });

    test('button text falls back to black or white when the page colour fails',
        () {
      // A mid-grey page cannot carry text on a mid-blue button.
      final grey = ForumPalette.fromHex(light: {
        'primary': '000000',
        'secondary': 'bbbbbb',
        'tertiary': '1d4ed8',
      });
      final cs = AppTheme.colorSchemeFor(Brightness.light, grey);
      expect(cs.primary, const Color(0xFF1D4ED8));
      expect(cs.onPrimary, Colors.white);
    });

    test('unreadable page text leaves the page to the seeded scheme', () {
      final murky = ForumPalette.fromHex(
          light: {'primary': '777777', 'secondary': '888888', 'tertiary': '0a7c86'});
      final cs = AppTheme.colorSchemeFor(Brightness.light, murky);
      expect(cs.surface, isNot(const Color(0xFF888888)));
      expect(contrastRatio(cs.onSurface, cs.surface), greaterThan(4.5));
    });
  });

  group('forum colours extension', () {
    test('like and solved come from the forum, legible on its page', () {
      final theme = AppTheme.themeFor(Brightness.light,
          ForumPalette.fromHex(light: {...tealLight, 'success': 'a5d6a7'}));
      final fc = theme.extension<ForumColors>()!;
      expect(fc.love, const Color(0xFFE0245E));
      // The forum's pale green, darkened until "Solution" reads.
      expect(contrastRatio(fc.success, theme.colorScheme.surface),
          greaterThanOrEqualTo(4.5));
    });

    testWidgets('a theme without them gets Discourse stock', (tester) async {
      late ForumColors fc;
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Builder(builder: (context) {
          fc = ForumColors.of(context);
          return const SizedBox();
        }),
      ));
      expect(fc.love, DiscourseScheme.dark.love);
    });
  });

  group('ForumTheme', () {
    final teal = ForumPalette.fromHex(light: tealLight, dark: tealDark);
    final other = ForumPalette.fromHex(light: {...tealLight, 'tertiary': '8e24aa'});

    test('only an open forum colours the app', () async {
      await ForumTheme.update('https://a.example', teal);
      expect(AppTheme.palette.value, isNull, reason: 'not open yet');

      await ForumTheme.enter('https://a.example');
      expect(AppTheme.palette.value, teal);

      await ForumTheme.leave('https://a.example');
      expect(AppTheme.palette.value, isNull, reason: "back on the host's list");
    });

    // The single-forum app builds its forum page in runApp's attach,
    // outside any frame, so no scheduler phase says "mid-build"; the
    // app-wide change must never happen synchronously.
    test('the app-wide change never lands inside the call that asked',
        () async {
      await ForumTheme.update('https://a.example', teal);
      final done = ForumTheme.enter('https://a.example');
      expect(AppTheme.palette.value, isNull);
      await done;
      expect(AppTheme.palette.value, teal);
    });

    test('the innermost open forum wins; closing it reveals the one below',
        () async {
      await ForumTheme.update('https://a.example', teal);
      await ForumTheme.update('https://b.example', other);
      await ForumTheme.enter('https://a.example');
      await ForumTheme.enter('https://b.example');
      expect(AppTheme.palette.value, other);

      await ForumTheme.leave('https://b.example');
      expect(AppTheme.palette.value, teal);
    });

    test('a forum opened again starts in its remembered colours', () async {
      await ForumTheme.update('https://a.example', teal);
      ForumTheme.reset(); // a new launch: memory gone, the device keeps it

      await ForumTheme.loadRemembered();
      await ForumTheme.enter('https://a.example');
      expect(AppTheme.palette.value, teal);
      expect(ForumTheme.paletteFor('https://a.example'), teal);
    });

    test("the forum's /site.json replaces what was remembered", () async {
      await ForumTheme.update('https://c.example', other);
      await ForumTheme.enter('https://c.example');

      DiscourseSiteCapabilities.store('https://c.example', {
        'top_menu_items': ['latest'],
        'default_light_color_scheme': {
          'colors': [
            for (final e in tealLight.entries) {'name': e.key, 'hex': e.value},
          ],
        },
        'default_dark_color_scheme': {
          'colors': [
            for (final e in tealDark.entries) {'name': e.key, 'hex': e.value},
          ],
        },
      });
      await ForumTheme.updateFromCapabilities('https://c.example');
      expect(AppTheme.palette.value, teal);
    });

    test('a fork that turns forum colours off keeps its own', () async {
      AppForumConfig.setUseForumColors(false);
      await ForumTheme.update('https://a.example', teal);
      await ForumTheme.enter('https://a.example');
      expect(AppTheme.palette.value, isNull);
      expect(ForumTheme.paletteFor('https://a.example'), isNull);
    });
  });

  // How SingleForumBootstrapPage uses it: enter() from initState, while the
  // app shell's Obx (which reads AppTheme.palette) is an ancestor mid-build.
  testWidgets('a forum page entering mid-build does not break the frame',
      (tester) async {
    final teal = ForumPalette.fromHex(light: tealLight, dark: tealDark);
    await ForumTheme.update('https://a.example', teal);

    await tester.pumpWidget(Obx(() => MaterialApp(
          theme: AppTheme.lightTheme,
          home: const _EntersForum('https://a.example'),
        )));
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(AppTheme.palette.value, teal);
    final page = tester.element(find.byKey(const Key('forum-page')));
    expect(Theme.of(page).colorScheme.primary, const Color(0xFF0A7C86));
  });
}

class _EntersForum extends StatefulWidget {
  const _EntersForum(this.siteKey);
  final String siteKey;
  @override
  State<_EntersForum> createState() => _EntersForumState();
}

class _EntersForumState extends State<_EntersForum> {
  @override
  void initState() {
    super.initState();
    ForumTheme.enter(widget.siteKey);
  }

  @override
  void dispose() {
    ForumTheme.leave(widget.siteKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(key: Key('forum-page'));
}
