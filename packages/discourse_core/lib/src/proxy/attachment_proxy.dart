import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:forumcopilot_sdk/context/site_context.dart';
import 'package:forumcopilot_sdk/interfaces/i_fc_attachment_proxy.dart';
import 'package:forumcopilot_sdk/models/results/fc_attachment_result.dart';
import 'package:forumcopilot_sdk/services/fc_http_client.dart';
import 'package:forumcopilot_sdk/services/fc_http_overrides.dart';

import '../base_discourse_proxy.dart';
import '../context/discourse_site_context_extension.dart';

/// Discourse implementation of [IFCAttachmentProxy].
///
/// Discourse stores all uploads (post images, avatars, etc.) through a
/// single endpoint:
///
///   `POST /uploads.json` (multipart/form-data)
///       file=<bytes>             — required
///       upload_type=<scope>      — composer | avatar | profile_background | …
///       for_private_message=true — set when the upload will be embedded in
///                                  a PM, so Discourse scopes the upload's
///                                  permissions to sender + recipient only.
///                                  Without this flag the upload is public
///                                  to anyone who knows the URL — a real
///                                  privacy leak for PM attachments.
///
/// The response is a JSON body with `id`, `url`, `short_url`,
/// `original_filename`, `filesize`, `width`, `height`, `extension`. The
/// short_url (`upload://<base62>.{ext}`) is what gets embedded in posts;
/// the absolute `url` is the CDN/local path.
class DiscourseAttachmentProxy extends BaseDiscourseProxy
    implements IFCAttachmentProxy {
  DiscourseAttachmentProxy(SiteContext context) : super(context);

  @override
  Future<FCAttachmentUploadResult> uploadAttachmentAsync(
    String type,
    String id,
    String groupId,
    String attachmentName,
    Uint8List attachmentBytes,
  ) =>
      // Phase 5.19 — translate the legacy XF-shaped `type` enum
      // ("post" / "pm" / etc.) into Discourse's two-dimensional
      // (upload_type, for_private_message) shape. For everything that
      // isn't a PM, the upload_type is "composer".
      _upload(
        attachmentName,
        attachmentBytes,
        uploadType: 'composer',
        forPrivateMessage: type == 'pm',
      );

  @override
  Future<FCAttachmentUploadResult> uploadAvatarAsync(
    String imageExtension,
    Uint8List attachmentBytes,
  ) async {
    final ext =
        imageExtension.startsWith('.') ? imageExtension.substring(1) : imageExtension;
    final filename = 'avatar.$ext';
    final upload = await _upload(filename, attachmentBytes, uploadType: 'avatar');
    if (!upload.result || upload.attachmentId == null) return upload;

    // Step 2: tell Discourse to use this upload as the user's avatar.
    final username = siteContext.currentUsername;
    if (username != null && username.isNotEmpty) {
      try {
        await apiPut('/u/$username/preferences/avatar/pick.json', body: {
          'upload_id': int.tryParse(upload.attachmentId!) ?? upload.attachmentId,
          'type': 'uploaded',
        });
      } catch (e) {
        return FCAttachmentUploadResult(
          result: false,
          resultText: 'Uploaded but could not set avatar: $e',
          attachmentId: upload.attachmentId,
          fileName: upload.fileName,
          groupId: upload.groupId,
          fileSize: upload.fileSize,
        );
      }
    }
    return upload;
  }

  @override
  Future<FCAttachmentRemoveResult> removeAttachmentAsync(
    String attachmentId,
    String forumId,
    String groupId,
    String postId,
  ) async {
    // Discourse doesn't have a "drop this upload" client endpoint — uploads
    // become orphaned when no post references them and a daily Sidekiq job
    // (`Jobs::CleanUpUploads`) garbage-collects them. From the client's
    // perspective the upload "removal" happens by editing the post raw to
    // strip the markdown image; that's a post edit, not an upload action.
    //
    // Report success so the UI can drop the upload from its compose state.
    return FCAttachmentRemoveResult(
      result: true,
      resultText: '',
      groupId: groupId,
    );
  }

  @override
  Future<FCTapatalkImageUploadResult> uploadTapatalkImageAsync(
    String attachmentName,
    Uint8List attachmentBytes,
  ) async {
    // Tapatalk-hosted media is XF/Tapatalk-only. On Discourse there is no
    // separate "Tapatalk image bucket" — all images live in /uploads. Map
    // through to the same endpoint and surface the resulting CDN URL.
    final upload = await _upload(attachmentName, attachmentBytes,
        uploadType: 'composer');
    if (!upload.result) {
      return FCTapatalkImageUploadResult(
        result: false,
        resultText: upload.resultText,
      );
    }
    return FCTapatalkImageUploadResult(
      result: true,
      resultText: '',
      imageId: upload.attachmentId,
      imageUrl: _resolveImageUrl(upload),
      thumbnailUrl: _resolveImageUrl(upload),
    );
  }

  // ===== Helpers =====

  Future<FCAttachmentUploadResult> _upload(
    String filename,
    Uint8List bytes, {
    required String uploadType,
    bool forPrivateMessage = false,
  }) async {
    try {
      await FCDioClient.instance.initialize();
      final base = Uri.parse(siteContext.site.url);
      final url = base.replace(path: _joinPath(base.path, '/uploads.json'));

      // `upload_type` is the current Discourse param name (3.4+);
      // legacy `type` still works but is deprecated. The `synchronous`
      // flag we used to send was a no-op — `/uploads.json` is always
      // synchronous from the client's perspective (Discourse processes
      // optimization async via Sidekiq but returns the upload row
      // immediately).
      final form = FormData.fromMap({
        'upload_type': uploadType,
        if (forPrivateMessage) 'for_private_message': 'true',
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final headers = <String, String>{
        'Accept': 'application/json',
        ...siteContext.userApiAuthHeaders(),
      };

      final response = await FCHttpClient.post<String>(
        url,
        headers: headers,
        body: form,
        responseType: ResponseType.plain,
      );

      final code = response.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        return FCAttachmentUploadResult(
          result: false,
          resultText: 'Upload failed: HTTP $code — ${response.data}',
        );
      }
      final data = response.data;
      final body = data is String
          ? jsonDecode(data) as Map<String, dynamic>
          : (data as Map<String, dynamic>?) ?? const <String, dynamic>{};
      return FCAttachmentUploadResult(
        result: true,
        resultText: '',
        attachmentId: body['id']?.toString(),
        fileName: body['original_filename']?.toString() ?? filename,
        // Discourse has no "group" concept on uploads — surface the
        // short_url so the caller can embed it in markdown.
        groupId: body['short_url']?.toString(),
        fileSize: (body['filesize'] as int?) ?? bytes.length,
      );
    } on DioException catch (e) {
      final body = e.response?.data;
      final reason = body is Map ? (body['errors']?.toString() ?? body.toString()) : '$body';
      return FCAttachmentUploadResult(
        result: false,
        resultText: 'Upload failed: $reason',
      );
    } catch (e) {
      return FCAttachmentUploadResult(
        result: false,
        resultText: 'Upload error: $e',
      );
    }
  }

  String? _resolveImageUrl(FCAttachmentUploadResult upload) {
    final short = upload.groupId; // we stashed short_url here
    if (short == null || short.isEmpty) return null;
    if (short.startsWith('http')) return short;
    if (short.startsWith('upload://')) {
      // The short_url won't render directly; the markdown post-render
      // resolves it. For preview UI we need the absolute URL — Discourse
      // doesn't return that from the upload response in older versions,
      // so we fall back to the short_url as-is. Phase 2.x can chase the
      // `url` field when present.
      return short;
    }
    return '${siteContext.site.url}$short';
  }

  String _joinPath(String basePath, String suffix) {
    if (basePath.isEmpty || basePath == '/') return suffix;
    final left = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    return suffix.startsWith('/') ? '$left$suffix' : '$left/$suffix';
  }
}
