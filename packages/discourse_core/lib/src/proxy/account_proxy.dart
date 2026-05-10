import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_account_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_account_result.dart';
import 'package:forumcopilot_sdk/models/registration/fc_registration_requirements.dart';
import 'package:forumcopilot_sdk/models/settings/fc_settings_category.dart';
import 'package:forumcopilot_sdk/models/settings/fc_user_setting.dart';
import 'package:forumcopilot_sdk/models/settings/fc_user_settings_result.dart';
import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCAccountProxy].
///
/// Endpoint mapping vs the XF-flavored SDK contract:
///
///   * `forgetPassword`     → `POST /session/forgot_password.json`
///   * `prefetchAccount`    → `GET /about.json` (just to read site flags;
///                            mobile registration is web-only on Discourse)
///   * `register`           → reported failure with a link to the web
///                            signup page. Discourse's signup has
///                            CAPTCHA + ToS + custom field validation
///                            that's not worth replicating in v1.
///   * `updateEmail`        → `PUT /u/{username}/preferences/email.json`
///   * `updatePassword`     → `POST /u/{username}/preferences/password.json`
///                            (Discourse triggers a password-reset email
///                            rather than accepting an inline password
///                            change.)
///   * `updateProfile`      → `PUT /u/{username}.json`
///   * `signinLogin*`       → not used; 2FA / passkey flows on Discourse
///                            go through the User API Key handshake.
///   * `getUserSettings*`   → empty results (Discourse exposes preferences
///                            as a flat structure under user_option, not
///                            as XF-style categories).
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
    try {
      final response = await apiGet('/about.json');
      final about = (response['about'] as Map<String, dynamic>?) ?? const {};
      // SiteSetting `allow_new_registrations` ungated here would require
      // admin scope. /about.json doesn't surface it, so we just report
      // canRegisterViaAPI=false unconditionally and let the UI redirect.
      return FCPrefetchAccountResult(
        result: true,
        resultText: '',
        accountExists: false,
        username: null,
        email: null,
        registrationOpen: true,
        canRegisterViaAPI: false,
        registerViaWebUrl: webUrl,
        registrationRequirements: null,
      );
    } catch (_) {
      // Fall back to the web URL even when /about.json is unreachable
      // — better than crashing the register page.
      return FCPrefetchAccountResult(
        result: true,
        resultText: '',
        accountExists: false,
        registrationOpen: true,
        canRegisterViaAPI: false,
        registerViaWebUrl: webUrl,
        registrationRequirements: null,
      );
    }
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
    // email", reachable via POST /u/{username}/preferences/password.json.
    // Inline password change requires a webview to /my/preferences/account.
    final username = siteContext.currentUsername;
    if (username == null || username.isEmpty) {
      return FCUpdatePasswordResult(
          result: false, resultText: 'Not logged in');
    }
    try {
      await apiPost(
        '/u/${Uri.encodeComponent(username)}/preferences/password.json',
      );
      return FCUpdatePasswordResult(
        result: true,
        resultText: 'A password-reset email has been sent.',
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
  // The XF SDK exposes settings as XF-style categories; Discourse exposes
  // preferences as a flat structure on `/u/{username}.json#user_option`.
  // For v1 we surface an empty category list so the settings page
  // renders cleanly without crashing. Phase 2.x can wire a curated
  // Discourse-preferences screen when there's UI demand.

  Future<FCUserSettingsCategoriesResult> getUserSettingsCategories() async {
    return FCUserSettingsCategoriesResult(
      result: true,
      resultText: '',
      categories: const <FCSettingsCategory>[],
    );
  }

  Future<FCUserSettingsResult> getUserSettings(String category) async {
    return FCUserSettingsResult(
      result: true,
      resultText: '',
      category: category,
      enabled: false,
      settings: const <FCUserSetting>[],
    );
  }

  Future<FCUserSettingsResult> updateUserSettings(
    String category,
    Map<String, dynamic> settings,
  ) async {
    return FCUserSettingsResult(
      result: true,
      resultText: '',
      category: category,
      enabled: false,
      settings: const <FCUserSetting>[],
    );
  }
}

// `FCRegistrationRequirements` parsing helpers were removed alongside
// the in-app registration path. If the SDK ever grows a Discourse-shaped
// signup contract, they can be reintroduced here.
