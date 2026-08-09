import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_config_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_config_result.dart';

import '../base_discourse_proxy.dart';
import '../context/discourse_site_context_extension.dart';
import '../data/attachment/discourse_upload_limits.dart';

/// Discourse implementation of [IFCConfigProxy].
///
/// Hits `/about.json` and maps a small set of fields onto the
/// XenForo-shaped [FCConfigResult].
/// The SDK's `FCConfigResult` was modeled on the XenForo plugin's
/// `getConfig` response and carries ~100 capability flags that don't have a
/// 1:1 in Discourse — for those we return sensible defaults (Discourse's REST
/// API supports the operation, so the flag is `true`).
class DiscourseConfigProxy extends BaseDiscourseProxy implements IFCConfigProxy {
  DiscourseConfigProxy(SiteContext context) : super(context);

  @override
  Future<FCConfigResult> getConfig(String url, {bool forceRefresh = false}) async {
    String version = 'discourse';
    bool isOpen = true;
    try {
      final about = await apiGet('/about.json');
      final aboutInner = (about['about'] as Map<String, dynamic>?) ?? const {};
      final v = aboutInner['version'] as String?;
      if (v != null && v.isNotEmpty) version = v;
      // Read-only mode is not a /site.json or /about.json body field —
      // Discourse signals it with a `Discourse-Readonly: true` response
      // header on every request (lib/read_only_mixin.rb). Check the
      // response we just received.
      final headers =
          siteContext.lastCallResponse?.headers ?? const <String, String>{};
      isOpen = !headers.entries.any((h) =>
          h.key.toLowerCase() == 'discourse-readonly' &&
          h.value.toLowerCase() == 'true');
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [DISCOURSE_CONFIG] /about.json failed (continuing): $e');
    }
    // Phase 5.18a — probe the chat plugin via its `/chat/api/me/channels`
    // route. Discourse's `/site.json` doesn't expose `enabled_plugins`
    // for anonymous viewers, so a route-probe is the most portable
    // signal. We treat anything other than 404 (including 401/403 for
    // unauth'd requests against installed plugins) as "chat installed";
    // 404 means the chat plugin's routes aren't registered.
    //
    // Asked once per forum, not once per getConfig. A cold launch calls
    // getConfig three times in ~600ms (SiteInitializationService,
    // SiteController._performSiteInitialization, and SiteHomePage's
    // post-frame "is the site still up?" check). The other two reads here
    // answer 2xx and so collapse into DiscourseClient's read cache, but a
    // signed-out visitor gets 403 from this route, and that cache
    // deliberately stores only 2xx — pinning an error would outlive
    // whatever caused it. That left the probe as the one request in the
    // launch sequence that repeated per caller: three 403s spent against
    // the per-IP rate limit on a question whose answer cannot change.
    // Skipping the call is better than caching its failure, and the
    // answer is not session-dependent — 403 and 200 both mean "installed".
    if (!siteContext.chatProbeResolved) {
      try {
        await apiGet('/chat/api/me/channels');
        siteContext.setChatEnabled(true);
      } on DiscourseApiException catch (e) {
        if (e.statusCode == 404) {
          // Route not registered → chat plugin absent.
          siteContext.setChatEnabled(false);
        } else if (e.statusCode == 401 || e.statusCode == 403) {
          // The route exists and answered; it just refused us because we
          // are signed out. That is a positive signal → chat installed.
          siteContext.setChatEnabled(true);
        }
        // Everything else is the server failing to answer the question
        // rather than answering it: 0 (transport failure), 429 (rate
        // limited), 5xx. Those must stay unresolved. This used to say
        // "any status but 404 means installed", which was harmless while
        // the probe re-ran on every getConfig and could correct itself —
        // but now that one answer is kept, a 429 during a burst launch
        // would pin the wrong nav layout for the rest of the process.
      } catch (_) {
        // Network error or unknown — same reasoning: record nothing, so
        // this stays retryable rather than freezing a guess for the
        // lifetime of the process.
      }
    }
    // Upload limits — Discourse publishes every `client: true` site setting
    // at `/site/settings.json` (SiteController#settings →
    // SiteSetting.client_settings_json). That's where the upload caps live:
    // authorized_extensions / authorized_extensions_for_staff /
    // max_image_size_kb / max_attachment_size_kb. The XF-shaped
    // FCConfigResult has no fields for these, so they're cached on the
    // site context (same pattern as the chat probe above) and consumed by
    // DiscourseAttachmentProxy and the composer's pre-upload validation.
    // Fail soft: on any error the cache stays null and uploads fall back
    // to server-side validation only.
    int? minSearchLength;
    try {
      final settings = await apiGet('/site/settings.json');
      siteContext
          .setUploadLimits(DiscourseUploadLimits.fromClientSettings(settings));
      // `min_search_term_length` is `client: true`
      // (config/site_settings.yml:3465-3467, default 3, locale-dependent —
      // 1 for zh_CN/zh_TW), so the real value ships in this same payload.
      // Read it rather than hardcoding the English default.
      final raw = settings['min_search_term_length'];
      final parsed = raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
      if (parsed != null && parsed > 0) minSearchLength = parsed;
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [DISCOURSE_CONFIG] /site/settings.json failed '
          '(upload limits unavailable, uploads fail open): $e');
    }
    return _buildResult(
      url,
      version: version,
      isOpen: isOpen,
      minSearchLength: minSearchLength,
    );
  }

  FCConfigResult _buildResult(
    String url, {
    required String version,
    required bool isOpen,
    int? minSearchLength,
  }) {
    return FCConfigResult(
      jsonSupport: true,
      systemVersion: version,
      version: version,
      // hookVersion/apiLevel are XenForo-plugin protocol constants. There
      // is no Discourse analogue; they are OUR client-side protocol
      // markers, not anything the server reported.
      hookVersion: '1.0',
      apiLevel: '4',
      // Discourse publishes no build/release timestamp. `/about.json`
      // carries `version` only (which we map above). This used to be
      // `DateTime.now()`, i.e. a different "release date" on every call —
      // an empty string is the honest answer for "unknown". No consumer
      // reads it today.
      releaseTimestamp: '',
      pushSlug: 'discourse',
      smartBannerInfo: '',
      setForumInfo: true,
      isOpen: isOpen,
      guestOkay: true,
      reportPost: true,
      reportPm: true,
      gotoPost: true,
      gotoUnread: true,
      getTopicByIds: true,
      markRead: true,
      markForum: true,
      subscribeForum: true,
      disableSubscribeForum: false,
      disableSearch: false,
      getLatestTopic: true,
      getNewTopic: true,
      getIdByUrl: true,
      getUrlById: true,
      deleteReason: true,
      modApprove: true,
      modDelete: true,
      modReport: true,
      guestSearch: true,
      anonymous: false,
      guestWhosOnline: true,
      searchId: true,
      avatar: true,
      // Discourse has no traditional XF "PM inbox/sent" model; PMs are
      // always conversations. Signaling false makes the UI skip the
      // legacy PM tabs and use the conversation flow exclusively.
      pmLoad: false,
      subscribeLoad: true,
      // Discourse uses `notification_level` (Watching/Tracking/Normal/Muted),
      // not the XF-style email/notification toggle. 'level' tells the UI to
      // use the 4-level control; the real levels are driven through
      // `DiscourseSubscriptionProxy`'s Discourse-native methods (landed in
      // Phase 2 — this is no longer a placeholder).
      subscribeTopicMode: 'level',
      subscribeForumMode: 'level',
      // Real `min_search_term_length` when /site/settings.json answered;
      // otherwise Discourse's own default (3) as a stated fallback.
      minSearchLength: minSearchLength ?? 3,
      inboxStat: true,
      multiQuote: true,
      defaultSmilies: false,
      canUnread: true,
      announcement: true,
      emoji: true,
      supportMd5: false,
      supportSha1: false,
      passwordType: 'bcrypt',
      conversation: true,
      getForum: true,
      getTopicStatus: true,
      getParticipatedForum: true,
      getForumStatus: true,
      getSmilies: false,
      advancedHtml: false,
      idToUrlRedirect: true,
      updateProfile: true,
      getMemberList: true,
      mGetInactiveUsers: false,
      mApproveUser: true,
      pollOptionsMaxCount: true,
      advancedOnlineUsers: true,
      markPmUnread: true,
      markPmRead: true,
      advancedSearch: true,
      massSubscribe: false,
      userId: '',
      regUrl: '$url/signup',
      guestGroupId: '0',
      phpVersion: '',
      adsDisabledGroup: '',
      markTopicRead: true,
      advancedDelete: true,
      firstUnread: true,
      alert: true,
      getActivity: true,
      searchUser: true,
      userRecommended: false,
      ignoreUser: true,
      getIgnoredUsers: true,
      unban: true,
      banExpires: true,
      advancedMerge: false,
      advancedMove: true,
      advancedEdit: true,
      twoStep: true,
      searchStartedBy: true,
      bannerControl: true,
      allowTrending: true,
      pushType: 'fcm',
      // Client-side protocol constant, NOT a per-forum capability the
      // server reported. Whether push actually works depends on
      // `AppForumConfig.pushApiBaseUrl` + the forum's
      // `allowed_user_api_push_urls` / `allow_user_api_key_scopes`, which
      // this proxy cannot see. `SiteContext.userApiPushEnabled` (set
      // during the User API Key handshake) is the real signal.
      push: 'enabled',
      disableHtml: false,
      contentEncoding: 'gzip',
      contentType: 'application/json',
      signIn: true,
      setApiKey: true,
      loginWithEmail: true,
      syncUser: true,
      getContact: false,
      userSubscription: true,
      pushContentCheck: true,
      apiKey: '',
      mbqFrameVersion: '1.0',
      forumType: 'discourse',
    );
  }
}
