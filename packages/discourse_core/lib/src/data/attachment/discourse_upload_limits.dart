import 'package:forumcopilot_sdk/context/site_context.dart';

/// Upload limits a Discourse site exposes to clients.
///
/// Source of truth: `GET /site/settings.json` (`SiteController#settings`,
/// app/controllers/site_controller.rb) which returns every site setting
/// flagged `client: true` in config/site_settings.yml. The upload-relevant
/// ones are:
///
///   - `authorized_extensions`            pipe-separated, e.g. "jpg|png|gif";
///                                        may contain "*" meaning "all types"
///   - `authorized_extensions_for_staff`  extra extensions staff may upload
///                                        (additive to the list above)
///   - `max_image_size_kb`                max upload size for image files
///   - `max_attachment_size_kb`           max upload size for everything else
///
/// NOT exposed to clients (server-enforced only, no `client: true` flag):
/// `max_image_megapixels` (checked in lib/upload_creator.rb). Discourse's
/// `max_image_width`/`max_image_height` client settings are post-render
/// *display* dimensions, not upload constraints — Discourse happily accepts
/// larger images and thumbnails them — so they are deliberately not modeled
/// as limits here. Discourse also has no XenForo-style
/// "max attachments per post" setting.
///
/// Whether a file counts as an "image" (and therefore gets
/// `max_image_size_kb` instead of `max_attachment_size_kb`) follows the
/// server's own classification: `FileHelper.supported_images`
/// (lib/file_helper.rb) — see [imageExtensions].
class DiscourseUploadLimits {
  /// Extensions any user may upload, lowercase, without dots. May contain
  /// `*`, meaning every file type is allowed.
  final List<String> authorizedExtensions;

  /// Additional extensions staff (admins/moderators) may upload. May also
  /// contain `*`.
  final List<String> authorizedExtensionsForStaff;

  /// Maximum size for image uploads, in KB. Null/0 = unknown (fail open).
  final int? maxImageSizeKb;

  /// Maximum size for non-image uploads, in KB. Null/0 = unknown (fail open).
  final int? maxAttachmentSizeKb;

  const DiscourseUploadLimits({
    this.authorizedExtensions = const [],
    this.authorizedExtensionsForStaff = const [],
    this.maxImageSizeKb,
    this.maxAttachmentSizeKb,
  });

  /// Mirror of Discourse's `FileHelper.supported_images`
  /// (lib/file_helper.rb) — the set the server uses to decide whether the
  /// image or the attachment size limit applies.
  static const Set<String> imageExtensions = {
    'jpg', 'jpeg', 'png', 'gif', 'svg', 'ico',
    'webp', 'avif', 'heic', 'heif', 'jxl',
  };

  /// Parse the `/site/settings.json` payload.
  factory DiscourseUploadLimits.fromClientSettings(Map<String, dynamic> json) {
    List<String> parseExts(Object? raw) {
      final s = raw?.toString() ?? '';
      return s
          .split(RegExp(r'[|,]'))
          .map((e) => e.trim().toLowerCase().replaceFirst('.', ''))
          .where((e) => e.isNotEmpty)
          .toList();
    }

    int? parseKb(Object? raw) {
      final v = int.tryParse(raw?.toString() ?? '');
      return (v != null && v > 0) ? v : null;
    }

    return DiscourseUploadLimits(
      authorizedExtensions: parseExts(json['authorized_extensions']),
      authorizedExtensionsForStaff:
          parseExts(json['authorized_extensions_for_staff']),
      maxImageSizeKb: parseKb(json['max_image_size_kb']),
      maxAttachmentSizeKb: parseKb(json['max_attachment_size_kb']),
    );
  }

  static bool isImageFilename(String filename) =>
      imageExtensions.contains(extensionOf(filename));

  /// Lowercase extension of [filename] without the dot ('' when none).
  static String extensionOf(String filename) {
    final dot = filename.lastIndexOf('.');
    if (dot < 0 || dot == filename.length - 1) return '';
    return filename.substring(dot + 1).toLowerCase();
  }

  /// True when every extension is allowed for this user class.
  bool allowsAllExtensions({bool staff = false}) =>
      authorizedExtensions.contains('*') ||
      (staff && authorizedExtensionsForStaff.contains('*'));

  /// The effective allow-list for this user class, or null when all
  /// extensions are allowed (wildcard) or the list is unknown (fail open).
  List<String>? effectiveExtensions({bool staff = false}) {
    if (allowsAllExtensions(staff: staff)) return null;
    final merged = <String>[
      ...authorizedExtensions,
      if (staff) ...authorizedExtensionsForStaff,
    ];
    return merged.isEmpty ? null : merged;
  }

  /// Whether [filename]'s extension may be uploaded. Unknown limits fail
  /// open (return true).
  bool allowsFilename(String filename, {bool staff = false}) {
    final allowed = effectiveExtensions(staff: staff);
    if (allowed == null) return true;
    return allowed.contains(extensionOf(filename));
  }

  /// The applicable size cap in bytes for [filename] (image vs attachment),
  /// or null when unknown (fail open).
  int? maxSizeBytesFor(String filename) {
    final kb = isImageFilename(filename) ? maxImageSizeKb : maxAttachmentSizeKb;
    return kb == null ? null : kb * 1024;
  }

  /// Human-friendly size string for the applicable cap ("4 MB" style).
  static String formatKb(int kb) {
    if (kb >= 1024) {
      final mb = kb / 1024;
      final rounded = mb == mb.roundToDouble()
          ? mb.toStringAsFixed(0)
          : mb.toStringAsFixed(1);
      return '$rounded MB';
    }
    return '$kb KB';
  }
}

/// Per-site cache of [DiscourseUploadLimits], following the same
/// Expando-on-[SiteContext] pattern as the chat-probe cache in
/// `discourse_site_context_extension.dart`. Populated once per session by
/// `DiscourseConfigProxy.getConfig`; null until fetched (callers must fail
/// open when null).
extension DiscourseUploadLimitsContext on SiteContext {
  static final Expando<DiscourseUploadLimits> _limits =
      Expando('discourseUploadLimits');

  DiscourseUploadLimits? get uploadLimits => _limits[this];

  void setUploadLimits(DiscourseUploadLimits? limits) {
    _limits[this] = limits;
  }
}
