/// Discourse Core - Discourse connector for ForumCopilot SDK
///
/// This package provides a complete Discourse forum connector that implements
/// the ForumCopilot SDK interfaces, enabling Flutter applications to interact
/// with Discourse forums using their REST API.

// Factory
export 'factory/discourse_proxy_factory.dart';

// Core proxies
export 'src/proxy/config_proxy.dart';
export 'src/proxy/account_proxy.dart';
export 'src/proxy/user_proxy.dart';
export 'src/proxy/forum_proxy.dart';
export 'src/proxy/topic_proxy.dart';
export 'src/proxy/post_proxy.dart';

// Discourse-only proxies
export 'src/proxy/bookmark_proxy.dart';
export 'src/proxy/chat_proxy.dart';
export 'src/proxy/group_proxy.dart';
export 'src/proxy/invite_proxy.dart';
export 'src/proxy/tag_proxy.dart';

// Remaining XF-shaped surface: `private_message_proxy` is the only real
// stub left (Discourse has no separate PM-inbox model — PMs are topics,
// served by `private_conversation_proxy`). The rest below are full REST
// implementations.
export 'src/proxy/attachment_proxy.dart';
export 'src/proxy/search_proxy.dart';
export 'src/proxy/social_proxy.dart';
export 'src/proxy/subscription_proxy.dart';
export 'src/proxy/moderation_proxy.dart';
export 'src/proxy/private_conversation_proxy.dart';
export 'src/proxy/private_message_proxy.dart';

// Network layer
export 'src/network/discourse_client.dart';
export 'src/network/discourse_auth_manager.dart';

// Context extensions
export 'src/context/discourse_site_context_extension.dart';

// Base proxy
export 'src/base_discourse_proxy.dart';

// Data models. The XenForo-era `dart_mappable` models that used to live
// under src/data/ (user, post, thread, node, conversation, poll, page,
// link_forum, thread_prefix, profile_post, alert, search, config,
// attachment, and the OAuth2 password-login request/response pair) were
// deleted: they parsed XF JSON keys stock Discourse never emits
// (`thread_id`, `post_date`, `message_parsed`, `node_id`, `prefix_id`)
// and were referenced by nothing. Proxies parse Discourse JSON straight
// into the FC models. What remains mirrors a real Discourse serializer.
export 'src/data/post/discourse_post_revision.dart';
export 'src/data/post/discourse_accepted_answer.dart';
export 'src/data/post/discourse_valid_reactions.dart';
export 'src/data/site/discourse_site_capabilities.dart';
export 'src/util/html_text.dart' show stripHtmlToText;
export 'src/data/post/discourse_suggested_topic.dart';
export 'src/data/moderation/discourse_reviewable.dart';
export 'src/data/user/discourse_do_not_disturb.dart';
export 'src/data/user/discourse_user_summary.dart';
export 'src/data/attachment/discourse_upload_limits.dart';

// Converter layer removed: the XF-shaped Discourse→FC converters had no
// callers — proxies parse Discourse JSON into FC models directly.
