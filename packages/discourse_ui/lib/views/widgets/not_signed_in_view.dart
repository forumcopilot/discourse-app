import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/views/login_page.dart';
import 'empty_state_view.dart';

class NotSignedInView extends StatelessWidget {
  final SiteContext siteContext;
  final String title;
  final String message;
  final IconData icon;
  final bool autoShowLogin;

  const NotSignedInView({
    super.key,
    required this.siteContext,
    required this.title,
    required this.message,
    this.icon = Icons.lock_outline_rounded,
    this.autoShowLogin = false,
  });

  @override
  Widget build(BuildContext context) {
    if (autoShowLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute != '/LoginPage') {
          LoginPage.open(siteContext);
        }
      });
    }

    // The app's one empty-state recipe, with Sign in and Register as its
    // actions.
    return EmptyStateView(
      icon: icon,
      message: title,
      hint: message,
      actions: [
        FilledButton(
          onPressed: () {
            LoginPage.open(siteContext);
          },
          child: Text(AppLocalizations.of(context)!.loginTitle),
        ),
        OutlinedButton(
          // Sign-up is on the forum's sign-in page: the same sheet, so the
          // new account comes back signed in (see DiscourseAuthSession).
          onPressed: () {
            LoginPage.open(siteContext);
          },
          child: Text(AppLocalizations.of(context)?.register ?? 'Register'),
        ),
      ],
    );
  }
}
