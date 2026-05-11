import 'package:discourse_core/discourse_core.dart'
    show DiscourseUserApiHandshakeRequest;
import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:get/get.dart';
import 'package:forumcopilot_flutter/controllers/global_loader_controller.dart';
import 'package:forumcopilot_flutter/controllers/site_controller.dart';
import 'package:forumcopilot_flutter/services/discourse_login_service.dart';
import 'package:forumcopilot_flutter/views/discourse_login_webview_page.dart';
import 'package:forumcopilot_flutter/views/widgets/forum_header_widget.dart';
import 'package:forumcopilot_flutter/views/site_home_page.dart';
import 'forgot_password_page.dart';
import '../theme/design_tokens.dart';
import '../theme/style_builders.dart';

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

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isHandshakeRunning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  /// Discourse mobile login: User API Key handshake. The user lands
  /// on Discourse's own login UI inside the webview, which handles
  /// email + password, 2FA, passkeys, and SSO — every login method
  /// the forum's site settings allow. We just receive the redirect
  /// payload and exchange it for a long-lived `User-Api-Key`.
  Future<void> _handleLogin() async {
    if (_isHandshakeRunning) return;
    setState(() {
      _isHandshakeRunning = true;
    });
    try {
      final loginService = DiscourseLoginService(widget.siteContext);

      DiscourseUserApiHandshakeRequest handshake;
      try {
        handshake = await loginService.beginLogin();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start sign-in: $e')),
        );
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
        // User backed out of the webview — silent.
        return;
      }
      final payload = loginService.extractPayload(redirectUrl);
      if (payload == null || payload.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in cancelled — no payload returned'),
          ),
        );
        return;
      }

      try {
        await loginService.finishLogin(payload);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: $e')),
        );
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
    } finally {
      if (mounted) {
        setState(() {
          _isHandshakeRunning = false;
        });
      }
    }
  }

  /// Extract the host portion of the forum URL for the CTA label and
  /// the webview's AppBar title. Falls back to "this forum" when the
  /// URL is missing or unparseable.
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final domain = _getSiteDomain();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.loginTitle,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: DesignTokens.fontWeightBold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ForumHeaderWidget(
                boardStats: null,
                extendUnderAppBar: false,
              ),
              Padding(
                padding: DesignTokens.paddingScreen,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lead copy — sets expectation that the next tap
                    // opens Discourse's own login UI.
                    Text(
                      'Sign in to continue',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingS),
                    Text(
                      "You'll be taken to $domain to sign in. Email "
                      'and password, single sign-on, passkeys, and '
                      'two-factor are all handled there.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: DesignTokens.lineHeightRelaxed,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingXL),
                    FilledButton.icon(
                      onPressed:
                          _isHandshakeRunning ? null : _handleLogin,
                      icon: _isHandshakeRunning
                          ? SizedBox(
                              width: DesignTokens.iconSizeS,
                              height: DesignTokens.iconSizeS,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.lock_open_rounded),
                      label: Text(
                        _isHandshakeRunning
                            ? 'Opening sign-in…'
                            : 'Sign in with $domain',
                        style: StyleBuilders.titleTextStyle(
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          color: colorScheme.onPrimary,
                          fontWeight: DesignTokens.fontWeightBold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: DesignTokens.spacingL),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DesignTokens.radiusL),
                        ),
                        elevation: DesignTokens.elevationMedium,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingS),
                    // Forgot-password helper. Discourse exposes a
                    // first-class reset-password flow at
                    // /password-reset/{token}; the inline button posts
                    // to /session/forgot_password.json which works
                    // for stock Discourse installs (no plugin
                    // required).
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage(
                                siteContext: widget.siteContext,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          l10n.forgotPassword,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: DesignTokens.fontWeightMedium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingXL),
                    // Reassurance copy — credentials never reach this
                    // app's process; the webview talks to the forum
                    // directly and we only receive the User API Key.
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacingXS),
                      child: Text(
                        "Your password is never seen by this app — "
                        "you'll type it into $domain's own page inside "
                        'a secure browser view.',
                        style: StyleBuilders.smallTextStyle(
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ).copyWith(
                          fontSize: DesignTokens.fontSizeXS,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingL),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
