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

  /// Only for tests and sign-out.
  static void clear() => _byMessage.clear();
}
