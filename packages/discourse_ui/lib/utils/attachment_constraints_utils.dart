import 'package:discourse_core/discourse_core.dart'
    show DiscourseUploadLimitsContext;
import 'package:forumcopilot_sdk/models/entities/fc_attachment_data.dart';
import 'package:forumcopilot_sdk/models/results/fc_user_result.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:get/get.dart';
import '../controllers/site_controller.dart';

/// Converts FCLoginResult to FCAttachmentConstraints
FCAttachmentConstraints? getAttachmentConstraintsFromLogin(FCLoginResult loginResult) {
  // Map maxAttachment to count (0 means unlimited, so use null)
  final count = loginResult.maxAttachment > 0 ? loginResult.maxAttachment : null;

  // Map maxAttachmentSize to size (0 means no limit, so use null)
  final size = loginResult.maxAttachmentSize > 0 ? loginResult.maxAttachmentSize : null;

  // Map allowedFileExtensions to extensions list
  List<String>? extensions;
  if (loginResult.allowedFileExtensions != null && loginResult.allowedFileExtensions!.isNotEmpty) {
    extensions = loginResult.allowedFileExtensions;
  } else if (loginResult.allowedExtensions != null && loginResult.allowedExtensions!.isNotEmpty) {
    // Fallback to comma-separated string
    extensions = loginResult.allowedExtensions!
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Map maxImageWidth and maxImageHeight (0 means no limit, so use null)
  final width = loginResult.maxImageWidth > 0 ? loginResult.maxImageWidth : null;
  final height = loginResult.maxImageHeight > 0 ? loginResult.maxImageHeight : null;

  return FCAttachmentConstraints(
    extensions: extensions,
    size: size,
    width: width,
    height: height,
    count: count,
  );
}

/// Gets attachment constraints from current SiteContext.
///
/// Prefers the Discourse-native upload limits cached on the context by
/// `DiscourseConfigProxy` (from `/site/settings.json`:
/// authorized_extensions / max_image_size_kb / max_attachment_size_kb);
/// falls back to the XF-era login-result fields when the fetch hasn't
/// happened, and returns null (no restrictions — fail open) when neither
/// source is available.
///
/// [isImage] selects which Discourse size cap applies: true →
/// max_image_size_kb, false/null → max_attachment_size_kb. Callers that
/// pick generic files should re-derive constraints once they know whether
/// the chosen file is an image.
FCAttachmentConstraints? getAttachmentConstraintsFromSiteContext(
  SiteContext? siteContext, {
  bool? isImage,
}) {
  if (siteContext == null) {
    return null;
  }

  final limits = siteContext.uploadLimits;
  if (limits != null) {
    final userType = siteContext.loginDataOutput?.user?.userType;
    final isStaff = userType == 'admin' || userType == 'moderator';
    final sizeKb =
        (isImage ?? false) ? limits.maxImageSizeKb : limits.maxAttachmentSizeKb;
    return FCAttachmentConstraints(
      // null when the wildcard '*' authorizes everything (fail open).
      extensions: limits.effectiveExtensions(staff: isStaff),
      size: sizeKb == null ? null : sizeKb * 1024,
      // Discourse's max_image_width/height are display dimensions, not
      // upload limits, and there is no per-post attachment cap — leave
      // width/height/count unset.
    );
  }

  final loginResult = siteContext.loginDataOutput;
  if (loginResult == null) {
    return null;
  }

  return getAttachmentConstraintsFromLogin(loginResult);
}

/// Helper to get current SiteContext
/// Uses Get.find<DiscourseSiteController>() pattern
SiteContext? getCurrentSiteContext() {
  try {
    if (Get.isRegistered<DiscourseSiteController>()) {
      final siteController = Get.find<DiscourseSiteController>();
      return siteController.currentSiteContext.value;
    }
  } catch (e) {
    // DiscourseSiteController not registered, return null
  }
  return null;
}
