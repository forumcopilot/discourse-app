import 'package:discourse_core/discourse_core.dart'
    show DiscourseUserApiHandshakeRequest;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:get/get.dart';
import 'package:discourse_ui/config/app_forum_config.dart';
import 'package:discourse_ui/controllers/global_loader_controller.dart';
import 'package:discourse_ui/controllers/site_controller.dart';
import 'package:discourse_ui/services/discourse_login_service.dart';
import 'package:discourse_ui/views/discourse_login_webview_page.dart';
import 'package:discourse_ui/views/enable_notifications_page.dart';
import 'package:discourse_ui/views/site_home_page.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:discourse_ui/utils/app_navigation.dart';

/// Phase 5.20a — the login page on Discourse is a single
/// "Sign in with {domain}" CTA that launches the User API Key
/// handshake webview. The legacy username/password form + passkey
/// outlined button were dead — the form fields were captured but
/// ignored by `_handleLogin` (handshake goes to webview), and the
/// passkey button's underlying proxy methods returned STUB-FAIL on
/// Discourse since passkey login is handled inside the same webview
/// (the user picks "passkey" on Discourse's own login screen, not
/// here). Both removed.
///
/// Follow-up: the intermediate explainer screen ("Sign in to
/// continue. You'll be taken to …") was removed too — the CTA was
/// the only useful action on it, and Discourse's own login webview
/// already makes the destination obvious. This page now auto-launches
/// the handshake on first build and shows only a spinner while it
/// runs. If the user backs out of the webview, this page pops itself
/// so they return to wherever they triggered the login from instead
/// of getting stranded on an empty loading screen.
///
/// `DiscourseLoginController.handlePasskeyLogin` had no callers left
/// once this page stopped driving login and has been deleted; the
/// passkey machinery survives only behind `attemptAutomaticLogin`.
/// `DiscourseLoginController.handleLogin` is not invoked from this
/// page anymore either, but `RegisterPage` still calls it to sign the
/// user in right after account creation.
class LoginPage extends StatefulWidget {
  /// The name sign-in opens under, which `Get.currentRoute` reports while it
  /// is on top.
  static const routeName = '/LoginPage';

  /// Opens sign-in for [siteContext] over the current page, unless it is
  /// already on top, so two prompts never stack. Completes with whether the
  /// user signed in (null when sign-in was already open).
  static Future<dynamic> open(SiteContext siteContext) {
    if (Get.currentRoute == routeName) return Future<dynamic>.value();
    return AppNavigation.pushGlobal<dynamic>(
        LoginPage(siteContext: siteContext),
        name: routeName);
  }

  final SiteContext siteContext;
  const LoginPage({Key? key, required this.siteContext}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _handshakeStarted = false;

  @override
  void initState() {
    super.initState();
    // Kick off the handshake on the next frame so `context` is fully
    // mounted (the webview push needs a valid Navigator).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _handshakeStarted) return;
      _handshakeStarted = true;
      _handleLogin();
    });
  }

  /// Discourse mobile login: User API Key handshake. The user lands
  /// on Discourse's own login UI inside the webview, which handles
  /// email + password, 2FA, passkeys, and SSO — every login method
  /// the forum's site settings allow. We just receive the redirect
  /// payload and exchange it for a long-lived `User-Api-Key`.
  Future<void> _handleLogin() async {
    final loginService = DiscourseLoginService(widget.siteContext);

    DiscourseUserApiHandshakeRequest handshake;
    try {
      handshake = await loginService.beginLogin();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotStartSignIn(e.toString()))),
      );
      _popBack();
      return;
    }
    if (!mounted) return;

    final redirectUrl = await Navigator.of(context).push<Uri?>(
      MaterialPageRoute<Uri?>(
        builder: (_) => DiscourseLoginWebViewPage(
          url: handshake.url,
          redirectMatcher: loginService.isAuthCallback,
          title: 'Sign in to ${_getSiteDomain()}',
        ),
      ),
    );
    if (!mounted) return;

    if (redirectUrl == null) {
      // User backed out of the webview — pop this page too so they
      // return to wherever they triggered login from instead of
      // staring at an empty spinner.
      _popBack();
      return;
    }
    final payload = loginService.extractPayload(redirectUrl);
    if (payload == null || payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.signInCancelledNoPayload),
        ),
      );
      _popBack();
      return;
    }

    try {
      await loginService.finishLogin(payload);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.signInFailed(e.toString()))),
      );
      _popBack();
      return;
    }

    if (!mounted) return;
    if (Get.isRegistered<DiscourseGlobalLoaderController>()) {
      DiscourseGlobalLoaderController.to.forceHide();
    }

    // Second handshake — a notifications-only key our backend can poll on the
    // user's behalf. It has to be a separate grant: Discourse issues one key
    // per authorization, and this one leaves the device, so it must not be the
    // session credential. Awaited (not fire-and-forget) so it runs while the
    // sign-in is still on screen; declining just falls through to the forum.
    await _promptEnableNotifications();
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<DiscourseGlobalLoaderController>()) {
        DiscourseGlobalLoaderController.to.forceHide();
      }
      _close(true);
    });
  }

  /// Offers the notifications grant — only when this build has a backend to
  /// hand the key to, and only once per forum: a completed grant is
  /// remembered, so a user signing in again is not asked to approve what
  /// they already approved. Never rethrows: the user is signed in either
  /// way, and a failure here must not strand them on the login page.
  Future<void> _promptEnableNotifications() async {
    if (!AppForumConfig.isNotificationsGrantEnabled) return;
    try {
      final alreadyGranted = await DiscourseLoginService(widget.siteContext)
          .hasNotificationsGrant();
      if (alreadyGranted || !mounted) return;
      await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) =>
              EnableNotificationsPage(siteContext: widget.siteContext),
        ),
      );
    } catch (_) {
      // Swallowed deliberately — see above.
    }
  }

  /// Pop this page back to the caller, returning `false` so anything
  /// awaiting the route knows the user didn't sign in.
  void _popBack() => _close(false);

  /// Closes this page, and only this page, with [signedIn]. Whoever opened
  /// it (a forum starting up, a list, a prompt) waits for the answer and
  /// carries on from there.
  ///
  /// Signing in while a forum was still starting used to replace the whole
  /// stack with a fresh home (`Get.offAll`): the forum's own start-up page
  /// and its colours went, and in a multi-forum host the host's forum list
  /// too, so Back closed the app.
  void _close(bool signedIn) {
    if (!mounted) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;
    if (route.isFirst) {
      // Nothing under it to return to: the forum's home.
      Get.offAll(() => const SiteHomePage());
    } else if (route.isCurrent) {
      Navigator.of(context).pop(signedIn);
    } else {
      Navigator.of(context).removeRoute(route, signedIn);
    }
  }

  /// Extract the host portion of the forum URL for the webview's
  /// AppBar title. Falls back to "this forum" when the URL is
  /// missing or unparseable.
  String _getSiteDomain() {
    final siteController = Get.put(DiscourseSiteController());
    final siteUrl = siteController.currentSite.value?.url;
    if (siteUrl == null || siteUrl.isEmpty) return 'this forum';
    try {
      final uri = Uri.parse(siteUrl);
      return uri.host.isNotEmpty ? uri.host : 'this forum';
    } catch (_) {
      return 'this forum';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => _popBack(),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
