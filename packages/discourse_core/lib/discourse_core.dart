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

// Stub proxies
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

// Plugin API - No longer uses REST API layer (converted to plugin-only)

// Base proxy
export 'src/base_discourse_proxy.dart';

// Data models
export 'src/data/auth/oauth_token.dart';
export 'src/data/auth/auth_request.dart';
export 'src/data/auth/auth_response.dart';
export 'src/data/post/discourse_post_revision.dart';
export 'src/data/post/discourse_suggested_topic.dart';
export 'src/data/moderation/discourse_reviewable.dart';
export 'src/data/user/discourse_do_not_disturb.dart';
export 'src/data/user/discourse_user_summary.dart';
export 'src/data/attachment/discourse_upload_limits.dart';

// Converter layer removed: the XF-shaped Discourse→FC converters had no
// callers — proxies parse Discourse JSON into FC models directly.
