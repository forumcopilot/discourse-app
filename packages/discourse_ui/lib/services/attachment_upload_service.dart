import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:forumcopilot_sdk/factory/site_proxy_factory.dart';
import 'package:forumcopilot_sdk/models/entities/fc_attachment_data.dart';

import '../core/logging/app_logger.dart';
import '../settings_context.dart';
import '../utils/attachment_constraints_utils.dart';
import '../utils/attachment_validation_utils.dart';
import '../utils/file_utils.dart';
import '../utils/image_shrink.dart';
import '../views/widgets/oversized_image_sheet.dart';

/// What happened to one attachment.
///
/// [shortUrl] is Discourse's `upload://…` reference — the only thing that
/// can go in a post's raw. It is null on failure, with [errorMessage] set
/// to something worth showing the user.
class AttachmentUploadOutcome {
  const AttachmentUploadOutcome({
    this.shortUrl,
    this.errorMessage,
    this.fileName,
    this.fileSize,
    this.cancelled = false,
  });

  final String? shortUrl;
  final String? errorMessage;

  /// The name and size as actually uploaded — which may differ from what
  /// was picked, if the file had to be resized to fit.
  final String? fileName;
  final int? fileSize;

  /// True when the user declined (e.g. said no to resizing). Not an
  /// error: nothing should be shown for it.
  final bool cancelled;

  bool get succeeded => shortUrl != null && shortUrl!.isNotEmpty;
}

/// The one place an attachment goes from "picked" to "uploaded".
///
/// Six composer pages — reply, new topic, edit post, and the three
/// private-message equivalents — each carried their own copy of this,
/// ~960 lines that differed only in a debug tag. That is not a tidiness
/// complaint: the "convert every PNG to JPEG" bug had to be found and
/// fixed three separate times in one session because each copy had to be
/// fixed independently, and the copies had already drifted apart.
///
/// Everything specific to a page is a parameter; everything else lives
/// here exactly once.
class AttachmentUploadService {
  const AttachmentUploadService._();

  /// Validates, resizes if the user agrees, and uploads [file].
  ///
  /// [uploadType] and [targetId] are the SDK's `uploadAttachmentAsync`
  /// coordinates ("post" plus the forum/topic id). [groupId] threads
  /// Discourse's upload group through consecutive uploads in one
  /// composer session; pass what the previous call returned.
  static Future<AttachmentUploadOutcome> upload({
    required BuildContext context,
    required XFile file,
    required String uploadType,
    required String targetId,
    required String groupId,
    required int currentAttachmentCount,
  }) async {
    final siteContext = getCurrentSiteContext();
    final isImage = isImageFile(file.name);
    final constraints = getAttachmentConstraintsFromSiteContext(
      siteContext,
      isImage: isImage,
    );

    if (!canAddMoreAttachments(currentAttachmentCount, constraints)) {
      return AttachmentUploadOutcome(
        errorMessage:
            'Maximum of ${constraints?.count} attachment(s) allowed',
      );
    }

    var toUpload = file;
    if (constraints != null) {
      final validation = await validateFile(
        file,
        constraints,
        isImage,
        currentAttachmentCount: currentAttachmentCount,
      );
      if (!validation.isValid) {
        return AttachmentUploadOutcome(
          errorMessage: validation.errorMessage ?? 'File validation failed',
        );
      }

      if (isImage) {
        final prepared = await _prepareImage(context, file, constraints);
        if (prepared == null) {
          return const AttachmentUploadOutcome(cancelled: true);
        }
        toUpload = prepared;
      }
    }

    try {
      final bytes = await toUpload.readAsBytes();
      final result = await SiteProxyFactory.getAttachmentProxy()
          .uploadAttachmentAsync(
        uploadType,
        targetId,
        groupId,
        toUpload.name,
        bytes,
      );
      if (!result.result) {
        return AttachmentUploadOutcome(
          errorMessage: result.resultText ?? 'Failed to upload file',
        );
      }
      // Discourse's short_url arrives in `groupId` — the SDK slot is
      // XenForo-shaped and the numeric attachmentId is useless here.
      final shortUrl = result.groupId;
      if (shortUrl == null || shortUrl.isEmpty) {
        return const AttachmentUploadOutcome(
          errorMessage: 'Upload succeeded but the server returned no '
              'reference for the file.',
        );
      }
      return AttachmentUploadOutcome(
        shortUrl: shortUrl,
        fileName: toUpload.name,
        fileSize: bytes.length,
      );
    } catch (e) {
      AppLogger.debug('Attachment upload failed: $e');
      return AttachmentUploadOutcome(
        errorMessage: 'Failed to upload file: $e',
      );
    }
  }

  /// Returns the file to upload, or null when the user declined.
  ///
  /// Only touches a file that will not otherwise fit. The old shared
  /// path re-encoded on `needsOptimization`, which also fired for "this
  /// is a PNG and the forum allows JPEG" — so files well within the
  /// limit were converted anyway, losing transparency and turning any
  /// GIF into a still frame.
  static Future<XFile?> _prepareImage(
    BuildContext context,
    XFile image,
    FCAttachmentConstraints constraints,
  ) async {
    final maxBytes = constraints.size;
    final pickedBytes = await File(image.path).length();
    if (maxBytes == null || maxBytes <= 0 || pickedBytes <= maxBytes) {
      return image;
    }

    var proceed = SettingsContext.instance.alwaysResizeOversizedImages.value;
    if (!proceed && context.mounted) {
      final choice = await showOversizedImageSheet(
        context,
        fileName: image.name,
        fileBytes: pickedBytes,
        maxBytes: maxBytes,
      );
      proceed = choice == OversizedImageChoice.resize;
    }
    if (!proceed) return null;

    final shrunk =
        await shrinkImageToFit(File(image.path), maxBytes: maxBytes);
    if (shrunk == null) return null;
    // No `name:` override here — XFile ignores it on mobile. The shrink
    // writes the file under its original basename instead, so the name
    // survives to the server.
    AppLogger.debug(
      'prepared image: ${shrunk.file.path} (${shrunk.newBytes} bytes)',
    );
    return XFile(shrunk.file.path);
  }
}
