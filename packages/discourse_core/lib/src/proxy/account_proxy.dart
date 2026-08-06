import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_account_proxy.dart';
import 'package:forumcopilot_sdk/models/entities/fc_notification_prefs.dart';
import 'package:forumcopilot_sdk/models/results/fc_account_result.dart';
import 'package:forumcopilot_sdk/models/results/fc_notification_result.dart';
import 'package:forumcopilot_sdk/models/settings/fc_settings_category.dart';
import 'package:forumcopilot_sdk/models/settings/fc_user_setting.dart';
import 'package:forumcopilot_sdk/models/settings/fc_user_settings_result.dart';
import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCAccountProxy].
///
/// Endpoint mapping vs the XF-flavored SDK contract:
///
///   * `forgetPassword`     → `POST /session/forgot_password.json`
///   * `prefetchAccount`    → `GET /site/settings.json` for
///                            `allow_new_registrations`; mobile
///                            registration itself is web-only on Discourse
///   * `register`           → reported failure with a link to the web
///                            signup page. Discourse's signup has
///                            CAPTCHA + ToS + custom field validation
///                            that's not worth replicating in v1.
///   * `updateEmail`        → `PUT /u/{username}/preferences/email.json`
///   * `updatePassword`     → `POST /session/forgot_password.json`
///                            (Discourse triggers a password-reset email
///                            rather than accepting an inline password
///                            change.)
///   * `updateProfile`      → `PUT /u/{username}.json`
///   * `signinLogin*`       → not used; 2FA / passkey flows on Discourse
///                            go through the User API Key handshake.
///   * `getUserSettings*`   → honestly empty (Discourse exposes
///                            preferences as a flat structure under
///                            `user_option`, not as XF-style categories).
///                            `updateUserSettings` reports FAILURE — it
///                            writes nothing, and claiming success for a
///                            no-op write is worse than saying so.
class DiscourseAccountProxy extends BaseDiscourseProxy
    implements IFCAccountProxy {
  DiscourseAccountProxy(SiteContext context) : super(context);

  @override
  Future<FCForgetPasswordResult> forgetPassword(
      String username, String token, String code) async {
    // Discourse: POST /session/forgot_password.json { login: <email|username> }.
    // It accepts either an email or a username and always returns 200 to
    // avoid leaking account existence.
    if (username.trim().isEmpty) {
      return FCForgetPasswordResult(
        result: false,
        resultText: 'Username or email is required',
        verified: false,
      );
    }
    try {
      await apiPost('/session/forgot_password.json', body: {
        'login': username,
      });
      return FCForgetPasswordResult(
        result: true,
        resultText: 'If an account exists, a reset email has been sent.',
        verified: true,
      );
    } catch (e) {
      return FCForgetPasswordResult(
        result: false,
        resultText: 'Error requesting password reset: $e',
        verified: false,
      );
    }
  }

  @override
  Future<FCPrefetchAccountResult?> prefetchAccount() async {
    // Discourse-native mobile registration isn't supported in v1 — the
    // full signup flow (CAPTCHA, ToS, custom field validation, email
    // verification) is web-only. We probe /about.json so the register
    // page can route the user to the web signup form with a real URL.
    final webUrl = '${siteContext.site.url}/signup';
    // `allow_new_registrations` is a `client: true` site setting
    // (config/site_settings.yml:660-662, default true), so it ships in
    // /site/settings.json — the same payload DiscourseConfigProxy reads
    // for upload limits. /about.json carries no registration signal at
    // all, so the previous version fetched it, threw the body away, and
    // hardcoded registrationOpen: true.
    bool registrationOpen = true;
    try {
      final settings = await apiGet('/site/settings.json');
      final raw = settings['allow_new_registrations'];
      if (raw is bool) {
        registrationOpen = raw;
      } else if (raw is String) {
        registrationOpen = raw.toLowerCase() != 'false';
      }
    } catch (_) {
      // Unreachable settings endpoint: keep the server default (true) and
      // let the UI hand the user to the web signup form, which will show
      // the real "registrations closed" message if they are.
    }
    return FCPrefetchAccountResult(
      result: true,
      resultText: '',
      accountExists: false,
      username: null,
      email: null,
      registrationOpen: registrationOpen,
      canRegisterViaAPI: false,
      registerViaWebUrl: webUrl,
      registrationRequirements: null,
    );
  }

  @override
  Future<FCRegisterResult> register({
    required String username,
    required String email,
    required String password,
    String? passwordConfirm,
    String? timezone,
    String? dateOfBirth,
    String? location,
    bool? emailChoice,
    Map<String, dynamic>? customFields,
    String? captchaToken,
    bool? acceptTerms,
    bool? acceptPrivacy,
  }) async {
    // In-app registration intentionally not implemented. Discourse's
    // signup flow has too many moving parts (CAPTCHA, T&C, custom
    // fields, email verification) to round-trip from a mobile form.
    // The UI shows the web signup URL from prefetchAccount instead.
    return FCRegisterResult(
      result: false,
      resultText:
          'In-app registration is not supported. Please sign up on the web.',
    );
  }

  // ===== Signin flows — currently routed through the User API Key
  // handshake, so these XF-style methods aren't called on Discourse.

  @override
  Future<FCSigninResult> signinLogin(
          String token, String code, String? trustCode) async =>
      FCSigninResult(result: false, resultText: 'Not implemented');

  @override
  Future<FCSigninResult> signinLoginWithEmail(
          String token, String code, String email, String? trustCode) async =>
      FCSigninResult(result: false, resultText: 'Not implemented');

  @override
  Future<FCSigninResult> signinLoginWithUsername(String token, String code,
          String email, String username, String? trustCode) async =>
      FCSigninResult(result: false, resultText: 'Not implemented');

  @override
  Future<FCSigninResult> signinRegister(
          String token, String code, String email, String username,
          String password,
          {Map<String, dynamic>? customRegisterFields}) async =>
      FCSigninResult(result: false, resultText: 'Not implemented');

  // ===== Update email / password / profile =====

  @override
  Future<FCUpdateEmailResult> updateEmail(
      String password, String newEmail) async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCUpdateEmailResult(
          result: false, resultText: 'Not logged in');
    }
    try {
      await apiPut(
        '/u/${Uri.encodeComponent(username)}/preferences/email.json',
        body: {'email': newEmail},
      );
      // Discourse sends a confirmation email to the new address; the
      // change isn't live until the user clicks the link.
      return FCUpdateEmailResult(
        result: true,
        resultText:
            'A confirmation email has been sent to the new address.',
      );
    } catch (e) {
      return FCUpdateEmailResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCUpdatePasswordResult> updatePassword(
      String oldPassword, String newPassword) async {
    // Discourse's mobile-friendly password change is "send me a reset
    // email" via POST /session/forgot_password.json (the same endpoint
    // forgetPassword uses — /u/{username}/preferences/password.json is
    // not a route). Inline password change requires a webview to
    // /my/preferences/account.
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCUpdatePasswordResult(
          result: false, resultText: 'Not logged in');
    }
    try {
      await apiPost('/session/forgot_password.json', body: {
        'login': username,
      });
      return FCUpdatePasswordResult(
        result: true,
        resultText:
            'A password-reset email has been sent to the address on your '
            'account. Follow the link in it to set a new password.',
      );
    } catch (e) {
      return FCUpdatePasswordResult(result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCUpdatePasswordSSOResult> updatePasswordSSO(
          String newPassword, String token, String code) async =>
      FCUpdatePasswordSSOResult(
          result: false, resultText: 'Not supported on Discourse');

  @override
  Future<FCUpdateProfileResult> updateProfile(
      String userId, Map<String, dynamic> customFields) async {
    // Discourse: PUT /u/{username}.json accepts bio_raw, location,
    // website, name, custom_fields[<key>]. We forward keys verbatim;
    // unknown keys are silently dropped by the server.
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCUpdateProfileResult(
          result: false, resultText: 'Not logged in');
    }
    try {
      await apiPut(
        '/u/${Uri.encodeComponent(username)}.json',
        body: customFields,
      );
      return FCUpdateProfileResult(result: true, resultText: '');
    } catch (e) {
      return FCUpdateProfileResult(result: false, resultText: 'Error: $e');
    }
  }

  // ===== Settings categories =====
  //
  // The XF SDK exposes settings as XF-style categories; Discourse
  // exposes preferences as a flat structure on
  // `/u/{username}.json#user_option`. Phase 5.20d rebuilt the
  // consuming `ForumSettingsPage` as a curated Discourse-native
  // section list that bypasses these methods, but the IFC contract
  // still requires them — we keep them as no-op STUBs returning
  // empty data so any future caller that goes through the typed
  // interface gets a clean response rather than a crash.

  @override
  Future<FCUserSettingsCategoriesResult> getUserSettingsCategories() async {
    // Honestly empty: Discourse has no settings-category concept, so
    // there is nothing to enumerate. `result: true` + empty list is the
    // accurate answer, not a placeholder.
    return FCUserSettingsCategoriesResult(
      result: true,
      resultText: '',
      categories: const <FCSettingsCategory>[],
    );
  }

  @override
  Future<FCUserSettingsResult> getUserSettings(String category) async {
    return FCUserSettingsResult(
      result: true,
      resultText: '',
      category: category,
      enabled: false,
      settings: const <FCUserSetting>[],
    );
  }

  @override
  Future<FCUserSettingsResult> updateUserSettings(
    String category,
    Map<String, dynamic> settings,
  ) async {
    // This method has no Discourse implementation and writes NOTHING.
    // It used to return `result: true`, i.e. it reported a successful
    // save for a write that never happened. Fail loudly instead and
    // point callers at the real path.
    return FCUserSettingsResult(
      result: false,
      resultText: 'Discourse has no XF-style settings categories. Use '
          'updateNotificationPrefsAsync (user_option) or PUT '
          '/u/{username}.json via updateProfile.',
      category: category,
      enabled: false,
      settings: const <FCUserSetting>[],
    );
  }

  // ===== Discourse-native user notification preferences =====
  //
  // Phase 5.20b — read + write the subset of `user_option.*` fields
  // that are notification-relevant (email frequency, like aggregation,
  // mailing list mode, auto-watch on reply). The legacy XF-shaped
  // per-type toggles persisted only to SharedPreferences; these
  // methods round-trip to Discourse so changes stick across devices
  // and the user's email/notification cadence is actually under
  // their control.
  //
  // Endpoint:
  //   GET  /u/{username}.json       → user.user_option block
  //   PUT  /u/{username}.json       → top-level params (see
  //                                   UserUpdater::OPTION_ATTR for
  //                                   the accepted field list)

  @override
  Future<FCNotificationPrefsResult> getNotificationPrefsAsync() async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCNotificationPrefsResult(
        result: false,
        resultText: 'Not signed in',
      );
    }
    try {
      final response =
          await apiGet('/u/${Uri.encodeComponent(username)}.json');
      final user = (response['user'] as Map<String, dynamic>?) ?? const {};
      final userOption =
          (user['user_option'] as Map<String, dynamic>?) ?? const {};
      return FCNotificationPrefsResult(
        result: true,
        prefs: _prefsFromUserOption(userOption),
      );
    } on DiscourseApiException catch (e) {
      return FCNotificationPrefsResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCNotificationPrefsResult(
          result: false, resultText: 'Error: $e');
    }
  }

  @override
  Future<FCNotificationPrefsResult> updateNotificationPrefsAsync(
    FCNotificationPrefs prefs,
  ) async {
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCNotificationPrefsResult(
        result: false,
        resultText: 'Not signed in',
      );
    }
    try {
      final response = await apiPut(
        '/u/${Uri.encodeComponent(username)}.json',
        body: _prefsToUpdateBody(prefs),
      );
      // `UsersController#update` renders through `json_result(user,
      // serializer: UserSerializer)` (app/controllers/users_controller.rb:262-266
      // → app/controllers/application_controller.rb:671-683), so the
      // 200 body is `{ success: "OK", user: {... user_option ...} }`
      // carrying the server's POST-UPDATE state. Report that rather than
      // echoing the caller's own request back as if it were confirmed:
      // UserUpdater clamps/rejects values (e.g. digest_after_minutes must
      // be one of its allowed steps) and the caller would never know.
      final user = (response['user'] as Map<String, dynamic>?);
      final userOption = (user?['user_option'] as Map<String, dynamic>?);
      return FCNotificationPrefsResult(
        result: true,
        prefs: userOption == null ? prefs : _prefsFromUserOption(userOption),
      );
    } on DiscourseApiException catch (e) {
      return FCNotificationPrefsResult(
          result: false, resultText: e.userMessage);
    } catch (e) {
      return FCNotificationPrefsResult(
          result: false, resultText: 'Error: $e');
    }
  }

  FCNotificationPrefs _prefsFromUserOption(Map<String, dynamic> userOption) {
    int asInt(String key, int fallback) {
      final v = userOption[key];
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    bool asBool(String key, bool fallback) {
      final v = userOption[key];
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        if (v.toLowerCase() == 'true') return true;
        if (v.toLowerCase() == 'false') return false;
      }
      return fallback;
    }

    // The fallbacks below are Discourse's OWN defaults for each
    // `user_option` column, used only when the key is absent (which on
    // `/u/{username}.json` means the viewer isn't the account owner —
    // UserSerializer gates user_option on `can_edit`). They are NOT
    // reported preferences; FCNotificationPrefs has no per-field
    // "unknown", so a caller cannot tell the two apart. Callers that
    // care should only read prefs for the signed-in user.
    return FCNotificationPrefs(
      emailLevel: asInt('email_level', 1),
      emailMessagesLevel: asInt('email_messages_level', 1),
      emailDigests: asBool('email_digests', true),
      digestAfterMinutes: asInt('digest_after_minutes', 10080),
      mailingListMode: asBool('mailing_list_mode', false),
      likeNotificationFrequency: asInt('like_notification_frequency', 0),
      notificationLevelWhenReplying:
          asInt('notification_level_when_replying', 2),
    );
  }

  Map<String, dynamic> _prefsToUpdateBody(FCNotificationPrefs prefs) {
    return {
      'email_level': prefs.emailLevel,
      'email_messages_level': prefs.emailMessagesLevel,
      'email_digests': prefs.emailDigests,
      'digest_after_minutes': prefs.digestAfterMinutes,
      'mailing_list_mode': prefs.mailingListMode,
      'like_notification_frequency': prefs.likeNotificationFrequency,
      'notification_level_when_replying': prefs.notificationLevelWhenReplying,
    };
  }
}


