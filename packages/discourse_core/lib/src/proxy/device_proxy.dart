import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_device_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_device_result.dart';
import '../base_discourse_proxy.dart';
import '../context/discourse_site_context_extension.dart';

/// Discourse implementation of [IFCDeviceProxy].
///
/// **Stock Discourse has no device-registration endpoint.** The interface
/// was shaped by XenForo (where `registerDeviceAsync` writes an FCM token
/// row via the forum plugin); Discourse's push model is entirely different:
///
///   * The push registration happens ONCE, during the `/user-api-key/new`
///     handshake — the app sends `push_url` + the `push` scope, and Discourse
///     stores the URL on the User API Key (`user_api_keys.push_url`).
///   * Afterwards Discourse POSTs notification payloads to that `push_url`
///     (see `HubPushNotificationPusher` in the Discourse source), tagging
///     each with the key's `client_id`. The relay behind `push_url` maps
///     `client_id` → FCM token and forwards to FCM/APNs.
///   * The FCM-token side of that mapping is NOT Discourse's concern: the
///     app registers `(client_id, fcm_token)` with the relay backend itself
///     — that HTTP call lives in `PushNotificationService` (discourse_ui),
///     not here.
///
/// This proxy therefore only reports the truthful state of the Discourse
/// side of push, instead of inventing endpoints that don't exist:
///
///   * push not configured in this build → no-op success;
///   * configured, but the current User API Key predates the push grant
///     (no `push` scope / no `push_url` on it) → failure telling the caller
///     a re-login (fresh handshake) is required — scopes and `push_url` are
///     immutable on an existing key;
///   * configured and the key has push → success (nothing to do here).
class DiscourseDeviceProxy extends BaseDiscourseProxy
    implements IFCDeviceProxy {
  DiscourseDeviceProxy(SiteContext context) : super(context);

  bool get _pushConfigured => siteContext.isPushConfigured;

  /// True when the stored key was granted push: recorded by
  /// `DiscourseAuthManager.completeHandshake` only when the handshake sent
  /// `push` scope + `push_url` AND the server echoed `push: true`
  /// (`key.has_push?`, which also verifies `allowed_user_api_push_urls`).
  bool get _keyHasPush => siteContext.userApiPushEnabled;

  @override
  Future<FCDeviceResult> registerDeviceAsync({
    required String deviceId,
    required String fcmToken,
    required String platform,
    required String source,
    String? appVersion,
  }) async {
    if (!_pushConfigured) {
      // No relay configured (AppForumConfig.pushApiBaseUrl empty) — there is
      // nothing to register anywhere. Succeed so push bootstrap in main.dart
      // completes without surfacing a misleading error.
      return FCDeviceResult(
        result: true,
        resultText: 'Push is not configured in this build — nothing to register.',
        deviceId: deviceId,
      );
    }
    if (!_keyHasPush) {
      // The key was provisioned before push was configured (or the server
      // rejected the push_url — e.g. not in `allowed_user_api_push_urls`).
      // A User API Key's scopes and push_url cannot be amended in place;
      // only a fresh handshake (re-login) can grant them.
      return FCDeviceResult(
        result: false,
        resultText:
            'This login predates push support: the User API Key has no push '
            'grant. Log out and log in again to authorize push notifications.',
        deviceId: deviceId,
      );
    }
    // Discourse-side registration already happened at handshake time
    // (push_url is stored on the key); the relay-side (client_id → FCM
    // token) registration is PushNotificationService's job. Nothing to do.
    return FCDeviceResult(
      result: true,
      resultText:
          'Push is registered on the User API Key (push_url); Discourse will '
          'POST notifications to the relay tagged with this client_id.',
      deviceId: deviceId,
    );
  }

  @override
  Future<FCDeviceResult> updateDeviceTokenAsync({
    required String deviceId,
    required String fcmToken,
  }) async {
    // An FCM token rotation changes nothing on Discourse: the key's
    // push_url and client_id are stable. Only the relay's client_id → token
    // mapping must be refreshed, which PushNotificationService.updateDeviceToken
    // does. Report the truthful no-op.
    return FCDeviceResult(
      result: true,
      resultText: _pushConfigured
          ? 'No Discourse-side action for a token rotation — refresh the '
              'relay mapping via PushNotificationService.'
          : 'Push is not configured in this build — nothing to update.',
      deviceId: deviceId,
    );
  }

  @override
  Future<FCDeviceResult> unregisterDeviceAsync(String deviceId) async {
    // Stock Discourse offers no way to detach push from a live key: the only
    // mechanism that stops pushes is revoking the User API Key itself
    // (`POST /user-api-key/revoke` — `push_clients_for` filters on
    // `revoked_at IS NULL`). Logout already does that
    // (DiscourseUserProxy.logoutUserAsync), so this call is a deliberate no-op;
    // performing the revoke here would tear down the whole session, not just
    // push. (Relay-side cleanup is PushNotificationService's
    // unregisterDeviceFromSite.)
    return FCDeviceResult(
      result: true,
      resultText:
          'Discourse stops pushing only when the User API Key is revoked '
          '(done on logout); no separate unregister endpoint exists.',
    );
  }
}
