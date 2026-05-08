import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_config_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_config_result.dart';

import '../base_discourse_proxy.dart';

/// Discourse implementation of [IFCConfigProxy].
///
/// Hits `/site.json` (https://docs.discourse.org/#tag/Site/operation/getSite)
/// and maps a small set of fields onto the XenForo-shaped [FCConfigResult].
/// The SDK's `FCConfigResult` was modeled on the XenForo plugin's
/// `getConfig` response and carries ~100 capability flags that don't have a
/// 1:1 in Discourse — for those we return sensible defaults (Discourse's REST
/// API supports the operation, so the flag is `true`).
class DiscourseConfigProxy extends BaseDiscourseProxy implements IFCConfigProxy {
  DiscourseConfigProxy(SiteContext context) : super(context);

  @override
  Future<FCConfigResult> getConfig(String url, {bool forceRefresh = false}) async {
    // /site.json is the canonical capability dump but doesn't expose the
    // Discourse version or read-only state. /about.json gives us both.
    String version = 'discourse';
    bool isOpen = true;
    try {
      final about = await apiGet('/about.json');
      final aboutInner = (about['about'] as Map<String, dynamic>?) ?? const {};
      final v = aboutInner['version'] as String?;
      if (v != null && v.isNotEmpty) version = v;
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [DISCOURSE_CONFIG] /about.json failed (continuing): $e');
    }
    try {
      final site = await apiGet('/site.json');
      isOpen = !(site['is_readonly'] as bool? ?? false);
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ [DISCOURSE_CONFIG] /site.json failed (continuing): $e');
    }
    return _buildResult(url, version: version, isOpen: isOpen);
  }

  FCConfigResult _buildResult(
    String url, {
    required String version,
    required bool isOpen,
  }) {
    return FCConfigResult(
      jsonSupport: true,
      systemVersion: version,
      version: version,
      hookVersion: '1.0',
      apiLevel: '4',
      releaseTimestamp: DateTime.now().millisecondsSinceEpoch.toString(),
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
      pmLoad: true,
      subscribeLoad: true,
      // Discourse uses `notification_level` (Watching/Tracking/Normal/Muted),
      // not the XF-style email/notification toggle. The 'level' literal is
      // a v1 placeholder; Phase 2 wires real notification-level controls
      // through a Discourse-specific extension to IFCSubscriptionProxy.
      subscribeTopicMode: 'level',
      subscribeForumMode: 'level',
      minSearchLength: 3,
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
