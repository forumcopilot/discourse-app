import 'package:discourse_core/discourse_core.dart'
    show DiscourseSiteCapabilities;
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:url_launcher/url_launcher.dart';

/// A forum's Terms of Service and Privacy Policy, where its settings put
/// them — the drawer's footer and the Profile tab both link to them.
class ForumLegalLinks {
  ForumLegalLinks._();

  static String _base(SiteContext siteContext) =>
      siteContext.site.url.replaceAll(RegExp(r'/+$'), '');

  /// A legal page's address from the site setting, which may be absolute
  /// (a hosted forum's company page) or site-relative, else the page every
  /// Discourse serves.
  static String _url(SiteContext siteContext, String? configured,
      String fallbackPath) {
    final base = _base(siteContext);
    final value = (configured ?? '').trim();
    if (value.isEmpty) return '$base$fallbackPath';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '$base${value.startsWith('/') ? '' : '/'}$value';
  }

  static String termsUrl(SiteContext siteContext) => _url(
      siteContext,
      DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl).tosUrl,
      '/tos');

  static String privacyUrl(SiteContext siteContext) => _url(
      siteContext,
      DiscourseSiteCapabilities.forSite(siteContext.site.pluginUrl)
          .privacyPolicyUrl,
      '/privacy');

  static String aboutUrl(SiteContext siteContext) =>
      '${_base(siteContext)}/about';

  static Future<void> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
