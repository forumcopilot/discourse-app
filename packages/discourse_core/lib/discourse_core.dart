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
export 'src/data/post/discourse_bookmark.dart';

// Converters
export 'src/converter/discourse_user_converter.dart';
export 'src/converter/discourse_forum_converter.dart';
export 'src/converter/discourse_thread_converter.dart';
export 'src/converter/discourse_post_converter.dart';
export 'src/converter/discourse_attachment_converter.dart';
