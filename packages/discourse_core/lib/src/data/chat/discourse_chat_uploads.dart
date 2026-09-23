import 'package:forumcopilot_sdk/models/entities/fc_attachment.dart';

/// A chat message's uploads — images and files, which Discourse sends in the
/// message's `uploads` array (UploadSerializer), not in its cooked HTML.
/// FCChatMessage has no field for them, so they live here, keyed by forum and
/// message, filled whenever DiscourseChatProxy parses a message.
///
/// Two things need them: the bubble, which drew an upload-only message as an
/// empty bubble, and an edit, which must send the ids back —
/// Chat::UpdateMessage#modify_message treats a missing `upload_ids` as "no
/// uploads" and detaches them.
class DiscourseChatUploads {
  DiscourseChatUploads._();

  static final Map<String, List<FCAttachment>> _byMessage = {};

  static String _key(String siteUrl, int messageId) => '$siteUrl|$messageId';

  /// Record [uploads] for [messageId]; an empty list clears it (an edit can
  /// remove uploads).
  static void store(String siteUrl, int messageId, List<FCAttachment> uploads) {
    final key = _key(siteUrl, messageId);
    if (uploads.isEmpty) {
      _byMessage.remove(key);
    } else {
      _byMessage[key] = List.unmodifiable(uploads);
    }
  }

  static List<FCAttachment> forMessage(String siteUrl, int messageId) =>
      _byMessage[_key(siteUrl, messageId)] ?? const [];

  /// The upload ids an edit of [messageId] must send to keep its files.
  static List<int> idsFor(String siteUrl, int messageId) => [
        for (final u in forMessage(siteUrl, messageId))
          if (int.tryParse(u.id) case final id?) id,
      ];

  /// A chat upload from Discourse's UploadSerializer JSON — a message's
  /// `uploads` entry, or the `/uploads.json` answer to a chat-composer upload.
  static FCAttachment fromJson(String siteUrl, Map<String, dynamic> u) {
    String? abs(Object? url) {
      final s = url?.toString();
      if (s == null || s.isEmpty) return null;
      if (s.startsWith('http')) return s;
      // Protocol-relative (Discourse's `url` for an original): take the
      // forum's own scheme, as a browser would. Forcing https broke images on
      // a forum served over http.
      if (s.startsWith('//')) return '${Uri.parse(siteUrl).scheme}:$s';
      return '$siteUrl$s';
    }

    final url = abs(u['url']) ?? '';
    final ext = (u['extension'] ?? '').toString().toLowerCase();
    final isImage = u['width'] != null ||
        const {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'avif', 'svg'}
            .contains(ext);
    final thumb = (u['thumbnail'] as Map?)?['url'];
    return FCAttachment(
      id: (u['id'] ?? '').toString(),
      filename: (u['original_filename'] ?? 'file${ext.isEmpty ? '' : '.$ext'}').toString(),
      contentType: isImage ? 'image/${ext.isEmpty ? 'jpeg' : ext}' : null,
      fileSize: (u['filesize'] as num?)?.toInt() ?? 0,
      url: url,
      thumbnailUrl: isImage ? (abs(thumb) ?? url) : null,
      isImage: isImage,
      // The attachment widgets draw a lock and refuse the tap unless these
      // are set; a chat upload is always viewable by whoever sees the message.
      canViewUrl: true,
      canViewThumbnailUrl: true,
    );
  }

  /// Files uploaded from the chat composer, by upload id, until the message
  /// carrying them is sent. The create call answers with only the new
  /// message's id, so without these the sender's own copy of an image-only
  /// message is an empty bubble until the server's copy arrives.
  static final Map<String, FCAttachment> _awaitingMessage = {};

  static void rememberUpload(String siteUrl, FCAttachment upload) {
    _awaitingMessage[_key(siteUrl, int.tryParse(upload.id) ?? -1)] = upload;
  }

  /// The remembered uploads among [uploadIds], forgotten as they are taken.
  static List<FCAttachment> takeUploads(String siteUrl, List<int> uploadIds) => [
        for (final id in uploadIds)
          if (_awaitingMessage.remove(_key(siteUrl, id)) case final u?) u,
      ];

  /// Only for tests and sign-out.
  static void clear() {
    _byMessage.clear();
    _awaitingMessage.clear();
  }
}
