import 'dart:async';

import 'package:discourse_core/discourse_core.dart' show DiscourseUserApiKey;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../core/logging/app_logger.dart';
import '../services/discourse_login_service.dart';
import '../services/notification_key_service.dart';
import '../services/notification_permission.dart';
import '../theme/design_tokens.dart';
import 'discourse_login_webview_page.dart';
import '../l10n/generated/app_localizations.dart';

/// Asks the user to grant a notifications-only User API Key, shown once after
/// a successful sign-in — and again from Settings, if they declined.
///
/// Why a screen rather than launching the webview straight away: a second
/// permission prompt appearing seconds after signing in reads as something
/// having gone wrong. This says what is about to be asked and why, before
/// anything is asked.
///
/// Two independent things have to be true for notifications to arrive, and
/// conflating them is how a user ends up granting the forum permission and
/// still hearing nothing:
///
///   1. the OS lets this app show notifications — asked here, by the same
///      button, the first time it comes up; shown as a banner if it was
///      refused, with the only way back (the system settings);
///   2. the forum lets us read this user's notifications — the grant below.
///
/// This whole flow is a stand-in for the forum-wide push relay. Once an owner
/// adds a push URL to `allowed_user_api_push_urls`, Discourse posts
/// notifications directly and no per-user key is needed — hence the closing
/// line.
class EnableNotificationsPage extends StatefulWidget {
  final SiteContext siteContext;

  const EnableNotificationsPage({super.key, required this.siteContext});

  @override
  State<EnableNotificationsPage> createState() =>
      _EnableNotificationsPageState();
}

class _EnableNotificationsPageState extends State<EnableNotificationsPage>
    with WidgetsBindingObserver {
  /// null while the first check is in flight, so the banner does not flash in
  /// and out on a permission that was already granted.
  NotificationPermissionState? _permission;
  bool _granting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Coming back from the system settings is a resume; re-read the
  /// permission so a banner the user just fixed goes away on its own.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    final status = await NotificationPermission.status();
    if (mounted) setState(() => _permission = status);
  }

  /// The one button: the system prompt first if it was never shown, then the
  /// forum's grant page, then the key to the backend.
  Future<void> _grantNotificationsAccess() async {
    setState(() => _granting = true);
    final loginService = DiscourseLoginService(widget.siteContext);

    try {
      // Ask the OS now, not at launch: the user has just read what the alerts
      // are for. A refusal is not a reason to skip the forum grant — the
      // banner says how to turn alerts on later, and the grant is the half
      // that cannot be redone from the system settings.
      if (_permission == NotificationPermissionState.notDetermined) {
        final status = await NotificationPermission.request();
        if (!mounted) return;
        setState(() => _permission = status);
      }

      final handshake = await loginService.beginNotificationsGrant();
      if (!mounted) return;

      final redirectUrl = await Navigator.of(context).push<Uri?>(
        MaterialPageRoute<Uri?>(
          builder: (_) => DiscourseLoginWebViewPage(
            url: handshake.url,
            redirectMatcher: loginService.isAuthCallback,
            title: 'Allow notifications',
          ),
        ),
      );
      if (!mounted) return;

      // Backed out of the grant page — not an error, just leave them be.
      if (redirectUrl == null) {
        setState(() => _granting = false);
        return;
      }

      final payload = loginService.extractPayload(redirectUrl);
      if (payload == null || payload.isEmpty) {
        throw StateError('No payload returned from the grant.');
      }

      final key = await loginService.finishNotificationsGrant(payload);
      AppLogger.debug(
          '🔔 [ENABLE_NOTIFICATIONS] granted, client_id=${key.clientId}');

      // The key is deliberately not persisted on the device — it is not this
      // session's credential, and its whole purpose is to live on the server.
      final uploaded = await _uploadKey(key);

      if (uploaded) {
        // Remembered per forum, so the next sign-in does not ask again and the
        // settings row and the token sync know there is a grant to serve.
        await loginService.markNotificationsGranted();

        // On a first sign-in, FCM is often still initializing at this point,
        // so the upload above carried no device token and nothing could be
        // delivered to this grant. Attach it as soon as the token exists —
        // unawaited, so the user is not held on a spinner waiting for
        // Firebase.
        unawaited(loginService.syncNotificationDeviceTokenWhenReady());
      }

      if (!mounted) return;

      // Whether or not our backend took the key, the user is done here: they
      // approved on the forum, and the grant is real. Holding them on this
      // screen strands them behind an outage they cannot do anything about,
      // and tapping Continue again only mints another key. Let them through
      // and report the partial result on the way out.
      //
      // The messenger is resolved BEFORE the pop — afterwards this context is
      // defunct and the message would go nowhere.
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop(uploaded);
      if (!uploaded) {
        messenger.showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.approvedButRelayUnreachable),
          ),
        );
      }
    } catch (e) {
      AppLogger.debug('🔔 [ENABLE_NOTIFICATIONS] grant failed: $e');
      if (!mounted) return;
      setState(() => _granting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .couldNotEnableNotifications(e.toString()))),
      );
    }
  }

  /// Send the key to the notifications backend, along with the FCM token to
  /// deliver to and who the key belongs to.
  ///
  /// The forum is named by URL: a host that opens forums by address has no
  /// directory id for it, and the backend keys on the URL. The forum user id
  /// comes from the signed-in session (handshake #1), not from this key — a
  /// `notifications`-scoped key cannot call `/session/current.json`. The
  /// backend can also read it off the notifications themselves, so sending it
  /// is a convenience, not a requirement.
  Future<bool> _uploadKey(DiscourseUserApiKey key) async {
    final site = widget.siteContext.site;
    return NotificationKeyService.register(
      siteUrl: site.url,
      siteId: site.id,
      clientId: key.clientId,
      userApiKey: key.key,
      discourseUserId: int.tryParse(widget.siteContext.currentUserId ?? ''),
      discourseUsername: widget.siteContext.currentUsername,
      deviceToken: await _currentFcmToken(),
      devicePlatform: NotificationKeyService.devicePlatform,
    );
  }

  /// The device's FCM token, read from FirebaseMessaging rather than this
  /// package's NotificationService.
  ///
  /// The multi-forum host app ships its OWN NotificationService, so the
  /// singleton in this package is never initialized there and its `fcmToken`
  /// is always null — which is why the first grants we captured stored no
  /// device token at all. FirebaseMessaging is the one source of truth in
  /// both apps.
  ///
  /// Returns null when FCM has not finished initializing; the grant is
  /// uploaded anyway and [DiscourseLoginService.syncNotificationDeviceTokenWhenReady]
  /// attaches the token as soon as it appears.
  Future<String?> _currentFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      AppLogger.debug('🔔 [ENABLE_NOTIFICATIONS] could not read FCM token: $e');
      return null;
    }
  }

  String get _forumName => widget.siteContext.site.name.isNotEmpty
      ? widget.siteContext.site.name
      : 'this forum';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    // Only a refusal earns a banner. "Not asked yet" is handled by the button
    // below, so a first-time user sees no warning about a problem they do
    // not have.
    final osBlocked = _permission == NotificationPermissionState.denied;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.turnOnNotifications)),
      body: SafeArea(
        child: Padding(
          padding: DesignTokens.paddingL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notifications_active_outlined,
                  size: 48, color: colorScheme.primary),
              const SizedBox(height: DesignTokens.spacingL),

              // Step 1 — only shown when the OS is actually blocking us.
              if (osBlocked) ...[
                Container(
                  padding: DesignTokens.paddingM,
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer
                        .withValues(alpha: DesignTokens.opacityLow),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: colorScheme.error, size: 20),
                          const SizedBox(width: DesignTokens.spacingS),
                          Expanded(
                            child: Text(
                              l10n.notificationsAreTurnedOffForThisApp,
                              style: textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: DesignTokens.fontWeightSemiBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DesignTokens.spacingXS),
                      Text(
                        l10n.deviceWillNotShowAlertsUntilAllowedInSettings,
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      if (NotificationPermission.canOpenSettings) ...[
                        const SizedBox(height: DesignTokens.spacingS),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonal(
                            onPressed: NotificationPermission.openSettings,
                            child: Text(l10n.openSettings),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingL),
              ],

              // Step 2 — what the next screen will ask, in plain terms.
              Text(
                l10n.forumWillAskToApproveNotifications(_forumName),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingS),
              Text(
                l10n.approveNotificationsExplanation,
                style: textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _granting ? null : _grantNotificationsAccess,
                  child: _granting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.continueButton),
                ),
              ),
              const SizedBox(height: DesignTokens.spacingS),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed:
                      _granting ? null : () => Navigator.of(context).pop(false),
                  child: Text(l10n.notNow),
                ),
              ),

              const SizedBox(height: DesignTokens.spacingM),
              Text(
                l10n.forumOwnerPushNote,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant
                      .withValues(alpha: DesignTokens.opacityMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
