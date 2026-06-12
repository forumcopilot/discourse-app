import 'package:discourse_core/discourse_core.dart'
    show DiscourseUserApiHandshakeRequest;
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:get/get.dart';
import 'package:forumcopilot_flutter/controllers/global_loader_controller.dart';
import 'package:forumcopilot_flutter/controllers/site_controller.dart';
import 'package:forumcopilot_flutter/services/discourse_login_service.dart';
import 'package:forumcopilot_flutter/views/discourse_login_webview_page.dart';
import 'package:forumcopilot_flutter/views/site_home_page.dart';

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
/// The legacy `LoginController.handleLogin` / `handlePasskeyLogin`
/// entry points still exist on the controller for now — they are
/// not invoked from this page anymore. A future cleanup phase will
/// delete them from the controller once we confirm nothing else
/// reaches into them.
class LoginPage extends StatefulWidget {
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
        SnackBar(content: Text('Could not start sign-in: $e')),
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
        const SnackBar(
          content: Text('Sign-in cancelled — no payload returned'),
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
        SnackBar(content: Text('Sign-in failed: $e')),
      );
      _popBack();
      return;
    }

    if (!mounted) return;
    if (Get.isRegistered<GlobalLoaderController>()) {
      GlobalLoaderController.to.forceHide();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        if (Get.isRegistered<GlobalLoaderController>()) {
          GlobalLoaderController.to.forceHide();
        }
        final siteController = Get.find<SiteController>();
        final isSiteInitialized = siteController.isInitialized.value;
        final navigator = Navigator.of(context, rootNavigator: true);
        final canPop = navigator.canPop();

        if (isSiteInitialized && canPop) {
          navigator.pop(true);
        } else {
          Get.offAll(() => const SiteHomePage());
        }
      } catch (_) {
        if (Get.isRegistered<GlobalLoaderController>()) {
          GlobalLoaderController.to.forceHide();
        }
        Get.offAll(() => const SiteHomePage());
      }
    });
  }

  /// Pop this page back to the caller, returning `false` so anything
  /// awaiting the route knows the user didn't sign in.
  void _popBack() {
    if (!mounted) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop(false);
    } else {
      // Nothing to pop to — drop the user onto the home page so the
      // app doesn't end up with a blank stack.
      Get.offAll(() => const SiteHomePage());
    }
  }

  /// Extract the host portion of the forum URL for the webview's
  /// AppBar title. Falls back to "this forum" when the URL is
  /// missing or unparseable.
  String _getSiteDomain() {
    final siteController = Get.put(SiteController());
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
          onPressed: () => _popBack(),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
