import 'package:forumcopilot_sdk/models/domain/site.dart';

/// Single-forum application configuration.
///
/// Developers only need to update values in this file to point the app to
/// their Discourse forum with the Forum Copilot add-on endpoint enabled.
class AppForumConfig {
  const AppForumConfig._();

  /// Stable local site identifier used by persistence layers.
  static const int siteId = 1;

  /// Human-readable forum name shown in app UI.
  static const String forumName = 'Discourse';

  /// Base forum URL (without trailing slash).
  /// Example: https://forum.example.com
  /// Local dev: http://localhost:3000 (Rails server from /Volumes/CRUCIAL/discourse).
  /// On-device dev: an ngrok tunnel pointing at the local Rails server, e.g.
  ///   https://<sub>.ngrok-free.dev — Discourse must be launched with
  ///   `RAILS_DEVELOPMENT_HOSTS=.ngrok-free.dev,localhost` so the Rails
  ///   `HostAuthorization` middleware lets the tunnel hostname through.
  static const String forumBaseUrl = 'https://try.discourse.org';

  /// Legacy plugin endpoint path. **Not used in v1** — Discourse
  /// authentication and data fetching go through stock REST endpoints.
  /// Kept on the [Site] object only because the SDK's persistence still
  /// keys on `pluginUrl` (= base + endpoint) for SharedPreferences.
  /// Treat any value here as a stable opaque identifier; do not serve a
  /// custom endpoint at this path.
  static const String pluginEndpoint = '';

  /// Display name shown to the user on Discourse's User API Key grant page
  /// (`/user-api-key/new`) — "`<name>` would like to access your account".
  /// Discourse stores it verbatim on the `UserApiKeyClient` row, so it is
  /// also what the user sees later under Preferences → Security → Apps.
  ///
  /// This is the one string on that page the user reads to decide whether
  /// to trust the request, so it should name the app they installed. A
  /// fork edits [defaultUserApiApplicationName]; a **host app** that mounts
  /// this package for many forums cannot use a compile-time value and calls
  /// [setUserApiApplicationName] once at startup instead. Read
  /// [userApiApplicationName] everywhere; it honours the override.
  static const String defaultUserApiApplicationName = 'Discourse Mobile';

  static String? _userApiApplicationNameOverride;

  /// Application name in effect: the host app's override when set,
  /// otherwise the compile-time [defaultUserApiApplicationName].
  static String get userApiApplicationName =>
      _userApiApplicationNameOverride ?? defaultUserApiApplicationName;

  /// Names this build on the grant page. Call before the first login:
  /// Discourse records the name when the key is minted and never updates
  /// it, so keys issued earlier keep whatever name was sent then.
  ///
  /// Pass null or an empty string to fall back to the compile-time default.
  static void setUserApiApplicationName(String? name) {
    final trimmed = name?.trim();
    _userApiApplicationNameOverride =
        (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// Redirect Discourse appends `?payload=<base64>` to after the user
  /// authorizes the User API Key request. The in-app webview intercepts
  /// this URL — it never reaches the OS, so no `Info.plist` /
  /// `AndroidManifest.xml` intent-filter is required.
  ///
  /// Set to `discourse://auth_redirect` — this is the universal scheme
  /// reserved for Discourse's official Hub app and ships in every
  /// Discourse instance's default `allowed_user_api_auth_redirects`
  /// site setting (alongside `https://api.discourse.org/api/auth_redirect`).
  /// Using it means our handshake works against any Discourse forum
  /// without the admin needing to allowlist a custom scheme. The
  /// authorize page still shows the requesting app as
  /// [userApiApplicationName], so the user sees they're authorizing
  /// our app — only the technical redirect target string is shared.
  ///
  /// To use a fork-specific scheme instead (e.g.
  /// `forumcopilot://auth-callback`), the forum admin must add the
  /// scheme to `allowed_user_api_auth_redirects` under
  /// Admin → Settings → Login.
  static const String userApiAuthRedirect = 'discourse://auth_redirect';

  /// Scopes requested during the User API Key handshake.
  /// See `app/models/user_api_key_scope.rb` in the Discourse source for
  /// the full list. `read,write,session_info,notifications,message_bus`
  /// covers a forum mobile client; add `push` once the push relay is wired.
  static const List<String> userApiRequestedScopes = <String>[
    'read',
    'write',
    'session_info',
    'notifications',
    'message_bus',
    'one_time_password',
  ];

  /// Scopes for the SECOND handshake — the key handed to the notifications
  /// backend ([notificationsApiBaseUrl]) so it can poll this user's
  /// notifications and deliver them as push.
  ///
  /// `notifications` alone, deliberately. It grants exactly four routes
  /// (notifications#index, #totals, #mark_read, and message_bus) — enough to
  /// see what arrived and mark it read, and nothing else. `read` would have
  /// been far worse: it matches every GET on the site, so a stored key would
  /// expose the user's private messages, drafts and preferences.
  ///
  /// There is no narrower option; Discourse's scopes are fixed named sets, so
  /// "just #totals" is not requestable — and totals alone returns counts with
  /// no content to build a notification from.
  static const List<String> userApiNotificationsScopes = <String>['notifications'];

  /// Suffix that derives this key's client id from the install's, keeping it
  /// distinct from the login key. Discourse destroys existing keys for the same
  /// (client_id, user) on each grant, so sharing an id would sign the user out.
  static const String userApiNotificationsClientIdSuffix = 'notify';

  /// Base URL of the notifications backend: the server this app hands the
  /// notifications-only key to, which polls the forum on the user's behalf
  /// and delivers what arrives as push. It must serve
  /// `POST /discourse/notification-key`,
  /// `POST /discourse/notification-key/device` and
  /// `DELETE /discourse/notification-key` — the bodies are documented on
  /// `NotificationKeyService`. Empty (the default) turns the whole flow off:
  /// no second handshake after sign-in, nothing uploaded anywhere.
  ///
  /// Deliberately separate from [pushApiBaseUrl]. That is the relay path: it
  /// makes the login handshake request the `push` scope and a `push_url`,
  /// which only delivers once the forum's owner has allowlisted the URL.
  /// This path needs nothing from the forum's admins, which is why a
  /// multi-forum host wants it and not the other.
  ///
  /// A fork edits [defaultNotificationsApiBaseUrl]; a **host app** calls
  /// [setNotificationsApiBaseUrl] once at startup, before the first login.
  /// Read [notificationsApiBaseUrl] everywhere; it honours the override.
  static const String defaultNotificationsApiBaseUrl = '';

  static String? _notificationsApiBaseUrlOverride;

  /// Notifications backend base URL in effect: the host app's override when
  /// set, otherwise the compile-time [defaultNotificationsApiBaseUrl].
  static String get notificationsApiBaseUrl =>
      _notificationsApiBaseUrlOverride ?? defaultNotificationsApiBaseUrl;

  /// Points the notifications grant at [baseUrl]. Pass null or an empty
  /// string to fall back to the compile-time default.
  static void setNotificationsApiBaseUrl(String? baseUrl) {
    final trimmed = baseUrl?.trim();
    _notificationsApiBaseUrlOverride =
        (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// True when a notifications backend is configured, so the app offers the
  /// second grant after sign-in and keeps its device token attached to it.
  static bool get isNotificationsGrantEnabled =>
      notificationsApiBaseUrl.trim().isNotEmpty;

  /// Optional branding metadata.
  static const String forumDescription =
      'Discourse demo forum — try.discourse.org';
  static const String? logoUrl = null;
  static const String? backgroundUrl = null;

  /// Push notification dispatch source. Identifies which mode this build of
  /// the app is registering against on the Discourse server. The server-side
  /// addon's `DispatchRouter` uses this to pick the right dispatcher.
  ///
  ///   - 'forumcopilot' — official Forum Copilot app build, OR any fork that
  ///                      uses the hosted ForumCopilot Push backend. Server
  ///                      dispatches via the hosted backend.
  ///   - 'direct'       — white-label / BYO Firebase build. Server dispatches
  ///                      via the customer's own Firebase project (the addon
  ///                      reads a service-account JSON path from its admin
  ///                      options and calls FCM HTTP v1 directly).
  ///                      Requires ForumCopilot discourse addon v1.3.4+.
  ///                      Set `pushApiBaseUrl = ''` for this mode.
  static const String pushSource = 'forumcopilot';

  /// Optional push backend base URL (leave empty to disable hosted push backend).
  ///
  /// You have two ways to enable push notifications:
  ///
  ///   1. **Run your own push backend.** Set this to your server's base URL
  ///      (e.g. `https://push.example.com/api`) and provide your own Firebase
  ///      project. Your backend stores FCM tokens registered by the app and
  ///      relays notification events from the Discourse `forumcopilot.php`
  ///      plugin to FCM/APNs.
  ///
  ///   2. **Use ForumCopilot Push (hosted).** A managed service that does the
  ///      above for you — you skip running a backend and managing your own
  ///      Firebase project. You provide your iOS bundle ID, Android package
  ///      name, and an APNs auth key (`.p8`); ForumCopilot issues the
  ///      `GoogleService-Info.plist` / `google-services.json` your build
  ///      needs. Set this URL to the endpoint shown in your ForumCopilot
  ///      dashboard. See https://forumcopilot.com for sign-up and pricing.
  ///
  /// A fork edits [defaultPushApiBaseUrl] below. A **host app** that embeds
  /// this package for several forums (the multi-tenant ForumCopilot app
  /// mounts `SingleForumBootstrapPage` per site) cannot use a compile-time
  /// value, because this package is shared with the open-source template —
  /// so it calls [setPushApiBaseUrl] once at startup instead. Read
  /// [pushApiBaseUrl] everywhere; it honours the override.
  static const String defaultPushApiBaseUrl = '';

  static String? _pushApiBaseUrlOverride;

  /// Push backend base URL in effect: the host app's override when set,
  /// otherwise the compile-time [defaultPushApiBaseUrl].
  static String get pushApiBaseUrl =>
      _pushApiBaseUrlOverride ?? defaultPushApiBaseUrl;

  /// Points this build's push registration at [baseUrl]. Call before the
  /// first login — the User API Key handshake bakes `push_url` and the
  /// `push` scope into the issued key, and Discourse treats both as
  /// immutable, so a key minted before this is set can never receive push.
  ///
  /// Pass null or an empty string to fall back to the compile-time default.
  static void setPushApiBaseUrl(String? baseUrl) {
    final trimmed = baseUrl?.trim();
    _pushApiBaseUrlOverride =
        (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// The `push_url` this app registers on its Discourse User API Key, or
  /// `null` when push is not configured ([pushApiBaseUrl] empty).
  ///
  /// **RELAY PATH CONTRACT — must match the relay backend.** Discourse POSTs
  /// notification payloads (JSON, see `HubPushNotificationPusher` in the
  /// Discourse source) to exactly this URL. We define the route as:
  ///
  ///     <pushApiBaseUrl>/discourse/push
  ///
  /// The relay must serve `POST /discourse/push` under its base URL and
  /// answer 200. Nothing in this repo enforces the path — if the relay
  /// exposes a different route, change this getter to match.
  ///
  /// **The URL is deliberately static — no per-device FCM token in the
  /// path.** Discourse validates `push_url` with *substring* matching
  /// against the `allowed_user_api_push_urls` site setting
  /// (`SiteSetting.allowed_user_api_push_urls.include?(push_url)` in
  /// `app/models/user_api_key.rb`, and `position(push_url IN ?)` in
  /// `push_clients_for`), so a unique per-device URL could never be
  /// allowlisted. Device identity instead travels as the `client_id` field
  /// Discourse merges into every notification it POSTs — the relay maps
  /// `client_id` → FCM token from the registration the app sends to
  /// `POST <pushApiBaseUrl>/devices/register` (see
  /// `PushNotificationService.registerDeviceForSite`, which includes
  /// `discourse_client_id`).
  ///
  /// Server-side prerequisites (forum admin):
  ///   * add this exact URL to `allowed_user_api_push_urls`;
  ///   * include `push` in `allow_user_api_key_scopes` (default: on).
  static String? get discoursePushUrl {
    if (!isPushBackendEnabled) return null;
    final base = pushApiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return '$base/discourse/push';
  }

  /// Scopes actually sent in the handshake: [userApiRequestedScopes], plus
  /// `push` when a push relay is configured ([discoursePushUrl] non-null).
  /// With no relay configured this is identical to [userApiRequestedScopes].
  static List<String> get userApiEffectiveScopes => <String>[
        ...userApiRequestedScopes,
        if (discoursePushUrl != null) 'push',
      ];

  /// Android package name used for passkey assetlinks validation.
  static const String androidPackageName = 'com.example.forumapp';

  /// SHA256 certificate fingerprint used for passkey validation.
  /// Leave empty until you configure your own signing certificate.
  static const String androidSha256CertFingerprint = '';

  static Site buildSite() {
    final trimmedName = forumName.trim();
    final trimmedBaseUrl = forumBaseUrl.trim();
    final trimmedEndpoint = pluginEndpoint.trim();

    if (trimmedName.isEmpty) {
      throw StateError('AppForumConfig.forumName must not be empty.');
    }
    if (trimmedBaseUrl.isEmpty) {
      throw StateError('AppForumConfig.forumBaseUrl must not be empty.');
    }

    final parsedBaseUrl = Uri.tryParse(trimmedBaseUrl);
    if (parsedBaseUrl == null ||
        !parsedBaseUrl.hasScheme ||
        parsedBaseUrl.host.isEmpty) {
      throw StateError(
        'AppForumConfig.forumBaseUrl is invalid. Expected absolute URL.',
      );
    }

    final normalizedBaseUrl = trimmedBaseUrl.endsWith('/')
        ? trimmedBaseUrl.substring(0, trimmedBaseUrl.length - 1)
        : trimmedBaseUrl;
    final normalizedEndpoint = trimmedEndpoint.startsWith('/')
        ? trimmedEndpoint.substring(1)
        : trimmedEndpoint;

    return Site(
      id: siteId,
      name: trimmedName,
      url: normalizedBaseUrl,
      description: forumDescription,
      logoUrl: logoUrl,
      backgroundUrl: backgroundUrl,
      endpoint: normalizedEndpoint,
      baseUrl: normalizedBaseUrl,
      siteType: 'discourse',
    );
  }

  static bool get isPushBackendEnabled => pushApiBaseUrl.trim().isNotEmpty;
}
