import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/interfaces.dart';

import '../src/proxy/config_proxy.dart';
import '../src/proxy/account_proxy.dart';
import '../src/proxy/user_proxy.dart';
import '../src/proxy/forum_proxy.dart';
import '../src/proxy/topic_proxy.dart';
import '../src/proxy/post_proxy.dart';
import '../src/proxy/attachment_proxy.dart';
import '../src/proxy/bookmark_proxy.dart';
import '../src/proxy/chat_proxy.dart';
import '../src/proxy/draft_proxy.dart';
import '../src/proxy/group_proxy.dart';
import '../src/proxy/search_proxy.dart';
import '../src/proxy/social_proxy.dart';
import '../src/proxy/subscription_proxy.dart';
import '../src/proxy/tag_proxy.dart';
import '../src/proxy/moderation_proxy.dart';
import '../src/proxy/private_conversation_proxy.dart';
import '../src/proxy/private_message_proxy.dart';
import '../src/proxy/device_proxy.dart';

/// Discourse proxy factory implementation
/// Creates Discourse-specific proxy instances for the ForumCopilot SDK
class DiscourseProxyFactory extends SiteProxyFactory {
  IFCConfigProxy createConfigProxy(SiteContext context) {
    return DiscourseConfigProxy(context);
  }

  IFCAccountProxy createAccountProxy(SiteContext context) {
    return DiscourseAccountProxy(context);
  }

  IFCUserProxy createUserProxy(SiteContext context) {
    return DiscourseUserProxy(context);
  }

  IFCForumProxy createForumProxy(SiteContext context) {
    return DiscourseForumProxy(context);
  }

  IFCTopicProxy createTopicProxy(SiteContext context) {
    return DiscourseTopicProxy(context);
  }

  IFCPostProxy createPostProxy(SiteContext context) {
    return DiscoursePostProxy(context);
  }

  IFCAttachmentProxy createAttachmentProxy(SiteContext context) {
    return DiscourseAttachmentProxy(context);
  }

  IFCSearchProxy createSearchProxy(SiteContext context) {
    return DiscourseSearchProxy(context);
  }

  IFCSocialProxy createSocialProxy(SiteContext context) {
    return DiscourseSocialProxy(context);
  }

  IFCSubscriptionProxy createSubscriptionProxy(SiteContext context) {
    return DiscourseSubscriptionProxy(context);
  }

  IFCModerationProxy createModerationProxy(SiteContext context) {
    return DiscourseModerationProxy(context);
  }

  IFCPrivateConversationProxy createPrivateConversationProxy(SiteContext context) {
    return DiscoursePrivateConversationProxy(context);
  }

  IFCPrivateMessageProxy createPrivateMessageProxy(SiteContext context) {
    return DiscoursePrivateMessageProxy(context);
  }

  IFCDeviceProxy createDeviceProxy(SiteContext context) {
    return DiscourseDeviceProxy(context);
  }

  IFCBookmarkProxy createBookmarkProxy(SiteContext context) {
    return DiscourseBookmarkProxy(context);
  }

  IFCDraftProxy createDraftProxy(SiteContext context) {
    return DiscourseDraftProxy(context);
  }

  IFCTagProxy createTagProxy(SiteContext context) {
    return DiscourseTagProxy(context);
  }

  IFCChatProxy createChatProxy(SiteContext context) {
    return DiscourseChatProxy(context);
  }

  IFCGroupProxy createGroupProxy(SiteContext context) {
    return DiscourseGroupProxy(context);
  }
}
