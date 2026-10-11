import 'package:discourse_core/discourse_core.dart' show DiscoursePostSignature;
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/settings_context.dart';
import 'package:discourse_ui/views/widgets/post_signature_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A member who turns the "Sent from" line off must stay off: on every
/// forum, from the next post on, and after the app restarts (the saved
/// value is read first thing in SettingsContext.loadFromDevice).
void main() {
  Widget host() => const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PostSignatureSwitch()),
      );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  tearDown(() {
    DiscoursePostSignature.current = null;
    DiscoursePostSignature.enabled = true;
    SettingsContext.instance.postSignature.value = true;
  });

  testWidgets('nothing to switch when the host adds no line', (tester) async {
    await tester.pumpWidget(host());
    expect(find.byType(SwitchListTile), findsNothing);
  });

  testWidgets('turning it off stops the line and is remembered',
      (tester) async {
    DiscoursePostSignature.current = const DiscoursePostSignature(
        appName: 'ABDA', homepage: 'https://betterdiscourse.app');
    await tester.pumpWidget(host());
    expect(find.text('Add “Sent from ABDA” to my posts'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(DiscoursePostSignature.enabled, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('post_signature'), isFalse);
  });
}
