import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/appearance_sync.dart';
import 'package:discourse_ui/settings_context.dart';
import 'package:discourse_ui/theme/app_theme.dart';
import 'package:discourse_ui/views/widgets/appearance_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Appearance setting: System default / Light / Dark.
///
/// Flutter's `themeMode` alone only recolours Flutter's widgets, which
/// left forum pages in web views and native UI on the phone's setting.
/// So a choice must reach three places — the Flutter theme, the native
/// layer, and a `forced_color_mode` cookie on every forum origin (the
/// cookie Discourse reads server-side to pick its stylesheet) — and be
/// remembered across launches.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<(String, String)> cookies;
  late List<ThemeMode> native;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppTheme.themeMode.value = ThemeMode.system;
    AppearanceSync.reset();
    cookies = [];
    native = [];
    AppearanceSync.writeCookie = (origin, value, _) async {
      cookies.add((origin.toString(), value));
    };
    AppearanceSync.applyNative = (mode) async => native.add(mode);
  });

  group('AppearanceSync', () {
    test('uses the values Discourse reads from forced_color_mode', () {
      expect(AppearanceSync.cookieName, 'forced_color_mode');
      expect(AppearanceSync.cookieValue(ThemeMode.light), 'light');
      expect(AppearanceSync.cookieValue(ThemeMode.dark), 'dark');
      // "auto", not a deleted cookie: without one Discourse falls back to
      // the mode the user saved on the web, which may not be the device's.
      expect(AppearanceSync.cookieValue(ThemeMode.system), 'auto');
    });

    test('a registered forum gets the cookie on its origin, port kept',
        () async {
      await AppearanceSync.apply(ThemeMode.dark);
      await AppearanceSync.registerForum('http://127.0.0.1:4200/latest?x=1');
      expect(cookies.last, ('http://127.0.0.1:4200', 'dark'));
    });

    test('a change rewrites every registered forum and reaches native',
        () async {
      await AppearanceSync.registerForum('https://meta.discourse.org');
      await AppearanceSync.registerForum('https://try.discourse.org/');
      cookies.clear();

      await AppearanceSync.apply(ThemeMode.light);

      expect(native, [ThemeMode.light]);
      expect(cookies, [
        ('https://meta.discourse.org', 'light'),
        ('https://try.discourse.org', 'light'),
      ]);
    });

    test('prepare writes for a forum page, never for another site',
        () async {
      await AppearanceSync.registerForum('https://meta.discourse.org');
      await AppearanceSync.apply(ThemeMode.dark);
      cookies.clear();

      await AppearanceSync.prepare('https://meta.discourse.org/user-api-key/new');
      await AppearanceSync.prepare('https://example.com/some/page');

      expect(cookies, [('https://meta.discourse.org', 'dark')]);
    });

    test('rapid changes land in order', () async {
      await AppearanceSync.registerForum('https://meta.discourse.org');
      cookies.clear();

      AppearanceSync.apply(ThemeMode.light);
      AppearanceSync.apply(ThemeMode.dark);
      await AppearanceSync.apply(ThemeMode.system);

      expect(cookies.map((c) => c.$2), ['auto', 'auto', 'auto']);
      expect(native, [ThemeMode.light, ThemeMode.dark, ThemeMode.system]);
    });

    test('a failing write does not block later ones', () async {
      await AppearanceSync.registerForum('https://meta.discourse.org');
      AppearanceSync.applyNative = (_) async => throw StateError('boom');
      await AppearanceSync.apply(ThemeMode.dark);

      AppearanceSync.applyNative = (mode) async => native.add(mode);
      cookies.clear();
      await AppearanceSync.apply(ThemeMode.light);

      expect(native, [ThemeMode.light]);
      expect(cookies, [('https://meta.discourse.org', 'light')]);
    });
  });

  group('SettingsContext', () {
    test('themeMode and AppTheme.themeMode are one value', () {
      SettingsContext.instance.themeMode.value = ThemeMode.dark;
      expect(AppTheme.themeMode.value, ThemeMode.dark);
      expect(
          identical(SettingsContext.instance.themeMode, AppTheme.themeMode),
          isTrue);
    });

    test('setThemeMode applies, syncs and remembers', () async {
      await SettingsContext.instance.setThemeMode(ThemeMode.dark);
      await AppearanceSync.prepare('');

      expect(AppTheme.themeMode.value, ThemeMode.dark);
      expect(native, [ThemeMode.dark]);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'ThemeMode.dark');
    });

    // A widget test only because loadFromDevice also restores the locale
    // through GetX, which needs the test binding's frame scheduling.
    testWidgets('a saved choice comes back on launch and reaches native',
        (tester) async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'ThemeMode.light'});
      await tester.runAsync(SettingsContext.instance.loadFromDevice);
      await tester.runAsync(() => AppearanceSync.prepare(''));

      expect(AppTheme.themeMode.value, ThemeMode.light);
      expect(native, [ThemeMode.light]);
    });
  });

  testWidgets('picking Dark in the sheet turns the app dark at once',
      (tester) async {
    await tester.pumpWidget(Obx(() => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppTheme.themeMode.value,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showAppearanceSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        )));
    // The test binding reports a light platform, so System means light.
    expect(Theme.of(tester.element(find.text('open'))).brightness,
        Brightness.light);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsNothing, reason: 'sheet closes');
    expect(AppTheme.themeMode.value, ThemeMode.dark);
    expect(Theme.of(tester.element(find.text('open'))).brightness,
        Brightness.dark);
  });

  // How a host with its own settings screen (ABDA) shows the choice.
  testWidgets('embedded choices track the setting and apply a tap',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: AppearanceChoices()),
    ));
    bool checked(String label) => tester
        .widget<RadioListTile<ThemeMode>>(
            find.widgetWithText(RadioListTile<ThemeMode>, label))
        .selected;
    expect(checked('System default'), isTrue);

    await tester.tap(find.text('Light'));
    await tester.pump();
    expect(AppTheme.themeMode.value, ThemeMode.light);
    expect(checked('Light'), isTrue);

    // Changed elsewhere (another screen, a restore): the rows follow.
    AppTheme.themeMode.value = ThemeMode.dark;
    await tester.pump();
    expect(checked('Dark'), isTrue);
  });
}
