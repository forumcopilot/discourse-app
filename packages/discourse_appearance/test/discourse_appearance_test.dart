import 'package:discourse_appearance/discourse_appearance.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Dart half of the channel contract the three native handlers
/// (Android, iOS, macOS) implement: one `setMode` call carrying
/// `system`, `light` or `dark`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() =>
      messenger.setMockMethodCallHandler(DiscourseAppearance.channel, null));

  test('sends setMode with the mode name', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(DiscourseAppearance.channel,
        (call) async {
      calls.add(call);
      return null;
    });

    for (final mode in ThemeMode.values) {
      await DiscourseAppearance.apply(mode);
    }

    expect(calls.map((c) => c.method), everyElement('setMode'));
    expect(calls.map((c) => c.arguments), ['system', 'light', 'dark']);
  });

  test('a platform without the plugin is a no-op, not an error', () async {
    // No handler registered: invokeMethod throws MissingPluginException.
    await expectLater(DiscourseAppearance.apply(ThemeMode.dark), completes);
  });

  test('a native failure is swallowed', () async {
    messenger.setMockMethodCallHandler(DiscourseAppearance.channel,
        (call) async => throw PlatformException(code: 'boom'));
    await expectLater(DiscourseAppearance.apply(ThemeMode.light), completes);
  });
}
