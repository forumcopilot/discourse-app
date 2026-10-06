import 'package:discourse_ui/controllers/site_controller.dart';
import 'package:discourse_ui/l10n/generated/app_localizations.dart';
import 'package:discourse_ui/views/site_home_page.dart';
import 'package:discourse_ui/views/site_home_tab.dart';
import 'package:discourse_ui/views/tabs/profile_tab.dart';
import 'package:discourse_ui/services/notification_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_account_switch_test.dart' show account;

class ReadySiteController extends DiscourseSiteController {
  // Initialization is supplied by this harness, without launching network work.
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  testWidgets('logout replacement is shared by Profile login and push routing',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = Get.put<DiscourseSiteController>(ReadySiteController());
    final original = account(id: null);
    controller.currentSite.value = original.site;
    controller.currentSiteContext.value = original;
    controller.isInitialized.value = true;
    await tester.pumpWidget(GetMaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SiteHomePage(
          siteVerified: true, initialTab: SiteHomeTab.profile),
    ));
    await tester.pump();
    final oldState = tester.state(find.byType(ProfileTab));
    controller.isInitialized.value = false;
    final replacement = account(id: null);
    controller.currentSiteContext.value = replacement;
    controller.isInitialized.value = true;
    await tester.pump();
    final profile = tester.widget<ProfileTab>(find.byType(ProfileTab));
    expect(profile.siteContext, same(replacement));
    expect(tester.state(find.byType(ProfileTab)), isNot(same(oldState)));
    // Profile passes this object to LoginPage. Its login must be visible to
    // the object used by notification routing without an app restart.
    profile.siteContext.setLoginData(FCLoginResult(
      result: true,
      resultText: '',
      user: FCUser(id: '4', username: 'petercroft'),
    ));
    final route = DiscourseNotificationRoute.from({
      'site_url': replacement.site.url,
      'recipient_user_id': '4',
      'notification_type': 6,
      'topic_id': 42,
    });
    expect(route.permits(controller.currentSiteContext.value!), isTrue);
    expect(original.isLoggedIn, isFalse);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 31));
    Get.reset();
  });
}
