import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/services/discourse_route_navigator.dart';
import 'package:discourse_ui/services/notification_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'notification_account_switch_test.dart' show account;

void main() {
  testWidgets('old account push stays on current page and explains why',
      (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: Text('Current account home')),
    ));
    await tester.pumpAndSettle();
    await DiscourseRouteNavigator.open(
        account(id: '8'),
        DiscourseNotificationRoute.from({
          'site_url': 'https://forum.example/sub',
          'recipient_user_id': '7',
          'notification_type': 6,
          'topic_id': 42,
          'content_id': 43,
        }));
    await tester.pumpAndSettle();
    expect(find.text('Current account home'), findsOneWidget);
    expect(
        find.text(
            'This notification cannot be opened with the current account. Open Notifications to see updates for this account.'),
        findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpWidget(const SizedBox());
    Get.reset();
  });
}
