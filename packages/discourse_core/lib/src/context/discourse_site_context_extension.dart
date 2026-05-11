import 'dart:async';

import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Discourse-specific authentication state attached to a [SiteContext].
///
/// Discourse mobile clients authenticate via the User API Key handshake
/// (https://meta.discourse.org/t/-/32504): the app generates an RSA keypair,
/// asks the server for an authorization, and after the user grants permission
/// receives an RSA-encrypted payload containing a long-lived API key. The key
/// is then sent on every request via the `User-Api-Key` header (paired with the
/// app-generated `User-Api-Client-Id`).
///
/// Storage: in-memory (per-context [Expando]) plus an optional SharedPreferences
/// persistence layer keyed by `site.pluginUrl` so the credentials survive
/// process restarts.
extension DiscourseSiteContextExtension on SiteContext {
  static final Expando<Map<String, dynamic>> _store = Expando('discourseStore');

  Map<String, dynamic> _data() => _store[this] ??= <String, dynamic>{};

  /// The User API Key returned by Discourse after a successful handshake.
  String? get userApiKey => _data()['userApiKey'] as String?;

  /// The client id this app sent to Discourse during the handshake. Stable for
  /// the lifetime of the install (persisted with the key).
  String? get userApiClientId => _data()['userApiClientId'] as String?;

  /// True when the handshake requested the `push` scope and the server
  /// accepted; we expect Discourse to POST notifications to our push backend.
  bool get userApiPushEnabled => (_data()['userApiPushEnabled'] as bool?) ?? false;

  bool get hasUserApiKey =>
      (userApiKey?.isNotEmpty ?? false) && (userApiClientId?.isNotEmpty ?? false);

  /// Headers to attach to every authenticated Discourse REST request.
  Map<String, String> userApiAuthHeaders() {
    final key = userApiKey;
    final clientId = userApiClientId;
    if (key == null || key.isEmpty || clientId == null || clientId.isEmpty) {
      return const {};
    }
    return {
      'User-Api-Key': key,
      'User-Api-Client-Id': clientId,
    };
  }

  /// Persist the credentials produced by a successful handshake. Writes to
  /// memory and to SharedPreferences (keyed by [SiteContext.site.pluginUrl]).
  Future<void> setUserApiCredentials({
    required String userApiKey,
    required String userApiClientId,
    bool pushEnabled = false,
  }) async {
    final data = _data();
    data['userApiKey'] = userApiKey;
    data['userApiClientId'] = userApiClientId;
    data['userApiPushEnabled'] = pushEnabled;

    final prefs = await SharedPreferences.getInstance();
    final prefix = _prefsPrefix();
    await prefs.setString('${prefix}_user_api_key', userApiKey);
    await prefs.setString('${prefix}_user_api_client_id', userApiClientId);
    await prefs.setBool('${prefix}_user_api_push_enabled', pushEnabled);
  }

  /// Wipe credentials from memory and SharedPreferences.
  Future<void> clearUserApiCredentials() async {
    final data = _data();
    data.remove('userApiKey');
    data.remove('userApiClientId');
    data.remove('userApiPushEnabled');

    final prefs = await SharedPreferences.getInstance();
    final prefix = _prefsPrefix();
    await prefs.remove('${prefix}_user_api_key');
    await prefs.remove('${prefix}_user_api_client_id');
    await prefs.remove('${prefix}_user_api_push_enabled');
  }

  /// Hydrate in-memory credentials from SharedPreferences. Call once at app
  /// start (before issuing any authenticated request).
  Future<void> loadUserApiCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = _prefsPrefix();
    final data = _data();
    data['userApiKey'] = prefs.getString('${prefix}_user_api_key');
    data['userApiClientId'] = prefs.getString('${prefix}_user_api_client_id');
    data['userApiPushEnabled'] =
        prefs.getBool('${prefix}_user_api_push_enabled') ?? false;
  }

  // ===== Discourse plugin availability =====
  //
  // Discourse's `/site.json` payload doesn't expose `enabled_plugins` for
  // anonymous viewers, and the field shape varies by version, so we use a
  // route-probe pattern: hit a known plugin route and watch for 404
  // (plugin not installed → no Rails route) versus any other status code
  // (route exists → plugin installed; auth-required responses still
  // confirm the plugin is wired in). Results are cached on the context
  // for the lifetime of the session so the bottom-nav slot decision is
  // synchronous from `_enabledTabs`.

  /// Phase 5.18a — true when the `discourse-chat` plugin is installed and
  /// reachable. Drives the bottom-nav third slot (Chat when true, PMs
  /// when false). Defaults to false before the first probe so the
  /// fallback (Messages) renders during cold start.
  bool get chatEnabled => (_data()['chatEnabled'] as bool?) ?? false;

  /// Cache the result of a chat-route probe. Called by
  /// `DiscourseConfigProxy.getConfig` once per site init.
  void setChatEnabled(bool enabled) {
    _data()['chatEnabled'] = enabled;
  }

  String _prefsPrefix() => 'discourse:${site.pluginUrl}';
}
