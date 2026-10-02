import 'dart:async';

import 'package:discourse_core/discourse_core.dart' show DiscourseUserApiKey, DiscourseSiteContextExtension;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';

import '../core/logging/app_logger.dart';
import '../services/discourse_login_service.dart';
import '../services/notification_installation.dart';
import '../services/notification_grant_cleanup.dart';
import '../services/notification_key_service.dart';
import '../services/notification_permission.dart';
import '../theme/design_tokens.dart';
import '../theme/forum_identity.dart';
import '../utils/error_message.dart';
import 'widgets/forum_icon_tile.dart';
import '../services/discourse_auth_session.dart';
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
/// The page leads with what the user gets — two sample notifications with the
/// forum's own icon — and then the two steps above, numbered, so the system
/// prompt and the forum's approval page that follow are both expected.
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
    final session = widget.siteContext.configurationSession;

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

      // In the same browser sheet as sign-in, which is still signed in to
      // the forum: only Authorize is asked.
      final redirectUrl = await DiscourseAuthSession.authorize(
        context,
        url: handshake.url,
        isCallback: loginService.isAuthCallback,
        title: AppLocalizations.of(context)!.allowNotificationsSheetTitle,
      );
      if (!mounted) return;

      // Backed out of the grant page — not an error, just leave them be.
      if (redirectUrl == null) {
        setState(() => _granting = false);
        return;
      }

      final payload = loginService.extractPayload(redirectUrl);
      if (payload == null || payload.isEmpty) {
        // An Exception, not a StateError: its text is shown below, and
        // describeError drops "Exception: " but not "Bad state: ".
        throw Exception(
            AppLocalizations.of(context)!.notificationsGrantNoPayload);
      }

      final key = await loginService.finishNotificationsGrant(payload);
      AppLogger.debug(
          '🔔 [ENABLE_NOTIFICATIONS] granted, client_id=${key.clientId}');

      // File this phone with the backend first — its FCM token and whether
      // the OS lets it show notifications — so the grant below is registered
      // under an installation that can already be reached.
      await NotificationInstallation.report(force: true);

      // The key is deliberately not persisted on the device — it is not this
      // session's credential, and its whole purpose is to live on the server.
      if (!identical(session, widget.siteContext.configurationSession) ||
          await loginService.notificationsClientId() != key.clientId) {
        return;
      }
      final registration = await _uploadKey(key);
      if (!identical(session, widget.siteContext.configurationSession) ||
          await loginService.notificationsClientId() != key.clientId) {
        // Logout can race the upload. Retire this exact grant, never the new
        // session's grant, even if the upload timed out after reaching relay.
        await NotificationGrantCleanup.enqueue(widget.siteContext.site.url, key.clientId);
        unawaited(NotificationGrantCleanup.instance.retryPending());
        return;
      }
      final uploaded = registration.ok;

      if (uploaded) {
        // Remembered per forum, so the next sign-in does not ask again and the
        // settings row and the token sync know there is a grant to serve.
        await NotificationInstallation.markRegistered();
        final remembered = await loginService.markNotificationsGranted(
          installBound: true, expectedSession: session, expectedClientId: key.clientId);
        if (!remembered) {
          await NotificationGrantCleanup.enqueue(widget.siteContext.site.url, key.clientId);
          unawaited(NotificationGrantCleanup.instance.retryPending());
          return;
        }

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
      final l10n = AppLocalizations.of(context)!;
      final forumName = _forumName;
      Navigator.of(context).pop(uploaded);
      if (!uploaded) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.approvedButRelayUnreachable)),
        );
      } else if (!registration.reachable) {
        // Stored, but something in front of the forum (usually a Cloudflare
        // rule against datacenter addresses) refuses our server. Say so now
        // rather than let the user wait for notifications that never come.
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.forumBlocksNotificationServer(forumName)),
            duration: const Duration(seconds: 8),
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
                .couldNotEnableNotifications(
                    describeError(e, context: context)))),
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
  Future<NotificationKeyRegistration> _uploadKey(
      DiscourseUserApiKey key) async {
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
      : AppLocalizations.of(context)!.thisForumFallback;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final forumIcon = ForumIdentity.of(context, widget.siteContext.site).icon;
    // Only a refusal earns a banner. "Not asked yet" is handled by the button
    // below, so a first-time user sees no warning about a problem they do
    // not have.
    final osBlocked = _permission == NotificationPermissionState.denied;
    final osAllowed = _permission == NotificationPermissionState.granted;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.turnOnNotifications)),
      // The explanation scrolls and the buttons stay at the bottom, so a large
      // text size or a short phone never overflows.
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(DesignTokens.spacingXL,
                    DesignTokens.spacingS, DesignTokens.spacingXL, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // What arrives, shown rather than described: two
                    // notifications as they will look, under this forum's icon.
                    _NotificationPreview(
                      forumName: _forumName,
                      forumIcon: forumIcon,
                      samples: [
                        (
                          l10n.notificationPreviewNow,
                          l10n.notificationPreviewReply
                        ),
                        (
                          l10n.notificationPreviewEarlier,
                          l10n.notificationPreviewMessage
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spacingXL),
                    Text(
                      l10n.neverMissAReplyOn(_forumName),
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: DesignTokens.fontWeightSemiBold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingS),
                    // Polled, not pushed by the forum: set the expectation
                    // before the first one arrives a few minutes late.
                    Text(
                      l10n.notificationsPitch,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingXL),

                    if (osBlocked) ...[
                      _OsBlockedBanner(l10n: l10n),
                      const SizedBox(height: DesignTokens.spacingL),
                    ],

                    // The two things the button is about to ask for, in order:
                    // the system prompt, then the forum's approval page.
                    _Step(
                      number: 1,
                      done: osAllowed,
                      label: osAllowed
                          ? l10n.notificationsStepAllowed
                          : l10n.notificationsStepAllow,
                    ),
                    const SizedBox(height: DesignTokens.spacingM),
                    _Step(
                      number: 2,
                      label: l10n.notificationsStepApprove(_forumName),
                    ),
                    const SizedBox(height: DesignTokens.spacingXL),

                    // What the forum's page will ask to approve, answered
                    // before it is asked: the key is notifications-only.
                    Row(
                      children: [
                        Icon(Icons.lock_outline,
                            size: DesignTokens.iconSizeSMedium,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: DesignTokens.spacingS),
                        Expanded(
                          child: Text(
                            l10n.notificationsReadOnlyNote,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.spacingL),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  DesignTokens.spacingXL,
                  DesignTokens.spacingS,
                  DesignTokens.spacingXL,
                  DesignTokens.spacingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      textStyle: textTheme.titleMedium,
                    ),
                    onPressed: _granting ? null : _grantNotificationsAccess,
                    child: _granting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.turnOnNotifications),
                  ),
                  const SizedBox(height: DesignTokens.spacingXS),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      textStyle: textTheme.titleMedium,
                    ),
                    onPressed: _granting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text(l10n.notNow),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two sample notifications on a panel in the forum's accent, the newer one
/// in full and the older one faded, as a lock screen stacks them.
class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview({
    required this.forumName,
    required this.forumIcon,
    required this.samples,
  });

  final String forumName;
  final String? forumIcon;

  /// (when, text) for each card, newest first.
  final List<(String, String)> samples;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    // White cards in light mode, as notifications are; raised grey in dark.
    final card = theme.brightness == Brightness.light
        ? colorScheme.surfaceContainerLowest
        : colorScheme.surfaceContainerHighest;

    return ExcludeSemantics(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingM, vertical: DesignTokens.spacingL),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            for (final (index, (age, text)) in samples.indexed) ...[
              if (index > 0) const SizedBox(height: DesignTokens.spacingS + 2),
              Opacity(
                opacity: index == 0 ? 1 : 0.7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacingM + 2,
                      vertical: DesignTokens.spacingM),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ForumIconTile(name: forumName, url: forumIcon, size: 36),
                      const SizedBox(width: DesignTokens.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$forumName · $age',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One numbered step; a check replaces the number once it is already done.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.label, this.done = false});

  final int number;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? colorScheme.primary : colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: done
              ? Icon(Icons.check, size: 18, color: colorScheme.onPrimary)
              : Text(
                  '$number',
                  textScaler: TextScaler.noScaling,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: DesignTokens.fontWeightSemiBold,
                  ),
                ),
        ),
        const SizedBox(width: DesignTokens.spacingM),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }
}

/// The system has refused this app notifications: say so, and give the only
/// way back.
class _OsBlockedBanner extends StatelessWidget {
  const _OsBlockedBanner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
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
              Icon(Icons.error_outline, color: colorScheme.error, size: 20),
              const SizedBox(width: DesignTokens.spacingS),
              Expanded(
                child: Text(
                  l10n.notificationsAreTurnedOffForThisApp,
                  style: textTheme.titleSmall
                      ?.copyWith(color: colorScheme.onSurface),
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
            FilledButton.tonal(
              onPressed: NotificationPermission.openSettings,
              child: Text(l10n.openSettings),
            ),
          ],
        ],
      ),
    );
  }
}
