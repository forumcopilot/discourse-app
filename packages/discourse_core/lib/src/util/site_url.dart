/// [url] as an absolute URL on the forum at [siteUrl].
///
/// Discourse hands out three shapes: absolute (`https://…`), site-relative
/// (`/uploads/…`, `/user_avatar/…`) and — for uploads kept on S3 or a CDN,
/// which is every forum Discourse hosts — protocol-relative
/// (`//cdck-file-uploads-us1.s3…/logo.png`). The last used to be glued onto
/// the forum's address as if it were a path (`https://forum.asana.com//cdck…`),
/// a 404, so category logos and backgrounds never showed on those forums.
/// A protocol-relative URL takes the forum's own scheme. Empty stays empty.
String absoluteSiteUrl(String siteUrl, String url) {
  final s = url.trim();
  if (s.isEmpty) return '';
  if (s.startsWith('//')) {
    final scheme = Uri.tryParse(siteUrl)?.scheme ?? '';
    return '${scheme.isEmpty ? 'https' : scheme}:$s';
  }
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  return '$siteUrl$s';
}
