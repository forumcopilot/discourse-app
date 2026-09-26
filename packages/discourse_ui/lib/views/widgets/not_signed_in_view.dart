import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/views/login_page.dart';
import 'empty_state_view.dart';
import 'package:discourse_ui/utils/url_utils.dart';

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
          Get.to(() => LoginPage(siteContext: siteContext));
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
            Get.to(() => LoginPage(siteContext: siteContext));
          },
          child: Text(AppLocalizations.of(context)!.loginTitle),
        ),
        OutlinedButton(
          onPressed: () {
            UrlUtils.openUrl('${siteContext.site.url}/signup');
          },
          child: Text(AppLocalizations.of(context)?.register ?? 'Register'),
        ),
      ],
    );
  }
}
