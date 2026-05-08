import 'package:forumcopilot_sdk/forumcopilot_sdk.dart';
import 'test_env.dart';

/// Builds a SiteContext configured for Discourse tests
SiteContext buildDiscourseSiteContext() {
  final baseUrl = TestEnv.baseUrl();
  final pluginUrl = TestEnv.pluginUrl();
  
  // Extract endpoint from pluginUrl if it's different from baseUrl
  String? endpoint;
  if (pluginUrl != baseUrl && pluginUrl.startsWith(baseUrl)) {
    endpoint = pluginUrl.substring(baseUrl.length);
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }
  }
  
  final site = Site(
    id: null,
    name: 'Discourse Test',
    url: baseUrl,
    description: 'Discourse test site',
    endpoint: endpoint,
    baseUrl: baseUrl,
    logoUrl: null,
    backgroundUrl: null,
    siteType: 'discourse',
  );

  final context = SiteContext(
    siteType: 'discourse',
    site: site,
  );

  return context;
}

