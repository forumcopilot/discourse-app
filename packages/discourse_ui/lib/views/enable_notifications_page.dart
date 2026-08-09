import 'dart:async';
import 'dart:io';

import 'package:discourse_core/discourse_core.dart' show DiscourseUserApiKey;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/services/forumcopilot_api_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/logging/app_logger.dart';
import '../services/discourse_login_service.dart';
import '../theme/design_tokens.dart';
import 'discourse_login_webview_page.dart';

/// Asks the user to grant a notifications-only User API Key, shown once after
/// a successful sign-in.
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
///   1. the OS lets this app show notifications  — surfaced here when it does not;
///   2. the forum lets us read this user's notifications — the grant below.
///
/// This whole flow is a stand-in for the forum-wide push relay. Once an owner
/// adds our push URL to `allowed_user_api_push_urls`, Discourse posts
/// notifications to us directly and no per-user key is needed — hence the
/// closing line.
class EnableNotificationsPage extends StatefulWidget {
  final SiteContext siteContext;

  const EnableNotificationsPage({super.key, required this.siteContext});

  @override
  State<EnableNotificationsPage> createState() =>
      _EnableNotificationsPageState();
}

class _EnableNotificationsPageState extends State<EnableNotificationsPage> {
  /// null while the first check is in flight, so the banner does not flash in
  /// and out on a permission that was already granted.
  PermissionStatus? _osPermission;
  bool _granting = false;

  @override
  void initState() {
    super.initState();
    _refreshOsPermission();
  }

  Future<void> _refreshOsPermission() async {
    // iOS reports notification permission through its own channel; permission_handler's
    // Permission.notification is the Android 13+ POST_NOTIFICATIONS runtime grant.
    if (!Platform.isAndroid) {
      if (mounted) setState(() => _osPermission = PermissionStatus.granted);
      return;
    }
    final status = await Permission.notification.status;
    if (mounted) setState(() => _osPermission = status);
  }

  Future<void> _requestOsPermission() async {
    // Once permanently denied, requesting again silently no-ops — the OS will
    // not re-prompt, so the only route left is app settings.
    if (_osPermission?.isPermanentlyDenied ?? false) {
      await openAppSettings();
      // They may flip it and come back; re-check when the page resumes focus.
      await _refreshOsPermission();
      return;
    }
    final status = await Permission.notification.request();
    if (mounted) setState(() => _osPermission = status);
  }

  /// Runs the second handshake and returns the key for upload.
  Future<void> _grantNotificationsAccess() async {
    setState(() => _granting = true);
    final loginService = DiscourseLoginService(widget.siteContext);

    try {
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

      // On a first sign-in, FCM is often still initializing at this point, so the
      // upload above carried no device token and nothing could be delivered to this
      // grant. Attach it as soon as the token exists — unawaited, so the user is not
      // held on a spinner waiting for Firebase.
      if (uploaded) {
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
          const SnackBar(
            content: Text(
                'Approved, but we could not reach ForumCopilot to finish setting '
                'up. Try again later from Settings.'),
          ),
        );
      }
    } catch (e) {
      AppLogger.debug('🔔 [ENABLE_NOTIFICATIONS] grant failed: $e');
      if (!mounted) return;
      setState(() => _granting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not enable notifications: $e')),
      );
    }
  }

  /// Send the key to ForumCopilot's backend, along with the FCM token to deliver
  /// to and who the key belongs to.
  ///
  /// The forum user id comes from the signed-in session (handshake #1), not from
  /// this key — a `notifications`-scoped key cannot call `/session/current.json`.
  /// The server can also read it off the notifications themselves, so sending it
  /// is a convenience, not a requirement.
  Future<bool> _uploadKey(DiscourseUserApiKey key) async {
    final site = widget.siteContext.site;
    final siteId = site.id;
    if (siteId == null) {
      AppLogger.debug('🔔 [ENABLE_NOTIFICATIONS] no site id — cannot upload');
      return false;
    }

    return ForumCopilotApiService.registerDiscourseNotificationKey(
      siteId: siteId,
      siteUrl: site.url,
      clientId: key.clientId,
      userApiKey: key.key,
      discourseUserId: int.tryParse(widget.siteContext.currentUserId ?? ''),
      discourseUsername: widget.siteContext.currentUsername,
      deviceToken: await _currentFcmToken(),
      devicePlatform: Platform.isIOS ? 'ios' : 'android',
    );
  }

  /// The device's FCM token, read from FirebaseMessaging rather than this package's
  /// NotificationService.
  ///
  /// The multi-forum host app ships its OWN NotificationService, so the singleton in
  /// this package is never initialized there and its `fcmToken` is always null — which
  /// is why the first grants we captured stored no device token at all. FirebaseMessaging
  /// is the one source of truth in both apps.
  ///
  /// Returns null when FCM has not finished initializing; the grant is uploaded anyway
  /// and [DiscourseLoginService.syncNotificationDeviceTokenWhenReady] attaches the token
  /// as soon as it appears.
  Future<String?> _currentFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      AppLogger.debug('🔔 [ENABLE_NOTIFICATIONS] could not read FCM token: $e');
      return null;
    }
  }

  String get _forumName =>
      widget.siteContext.site.name.isNotEmpty
          ? widget.siteContext.site.name
          : 'this forum';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final osBlocked = _osPermission != null && !_osPermission!.isGranted;

    return Scaffold(
      appBar: AppBar(title: const Text('Turn on notifications')),
      body: SafeArea(
        child: Padding(
          padding: DesignTokens.paddingL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notifications_active_outlined,
                  size: 48, color: colorScheme.primary),
              const SizedBox(height: DesignTokens.spacingL),

              // Step 1 — only shown when the OS is actually blocking us, so a
              // user who already allowed notifications never sees a warning
              // about a problem they do not have.
              if (osBlocked) ...[
                Container(
                  padding: DesignTokens.paddingM,
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer
                        .withValues(alpha: DesignTokens.opacityLow),
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusM),
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
                              'Notifications are turned off for this app',
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
                        _osPermission!.isPermanentlyDenied
                            ? 'Your device will not show alerts until you allow '
                                'notifications in Settings.'
                            : 'Your device will not show alerts until you allow them.',
                        style: textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: DesignTokens.spacingS),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonal(
                          onPressed: _requestOsPermission,
                          child: Text(_osPermission!.isPermanentlyDenied
                              ? 'Open Settings'
                              : 'Allow'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingL),
              ],

              // Step 2 — what the next screen will ask, in plain terms.
              Text(
                'Next, $_forumName will ask you to approve “Notifications”.',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingS),
              Text(
                'Approving lets us check your notifications for you and send '
                'them to this device. This permission cannot post, reply, or '
                'read your messages.',
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
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ),
              const SizedBox(height: DesignTokens.spacingS),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed:
                      _granting ? null : () => Navigator.of(context).pop(false),
                  child: const Text('Not now'),
                ),
              ),

              const SizedBox(height: DesignTokens.spacingM),
              Text(
                'If this forum’s owner sets up notifications for the app, '
                'this step won’t be needed.',
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
