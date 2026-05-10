import 'package:forumcopilot_sdk/models/entities/fc_topic.dart';

/// Discourse-native tag attachment for [FCTopic] instances.
///
/// Tags are a first-class concept in Discourse but the cross-forum
/// `forumcopilot_sdk` doesn't model them on [FCTopic]. We attach them via
/// an [Expando] keyed on the FCTopic instance — populated by
/// [DiscourseTopicProxy] as it builds topics, read by the UI to render
/// tag chips.
///
/// **Lifetime caveat**: tags are bound to the in-memory [FCTopic]
/// instance. A topic refetched from the server gets a fresh FCTopic and
/// has its tags re-attached at proxy time; persistence (e.g. SiteContext
/// toJson/fromJson) doesn't carry tags across. Phase 5.x can move this
/// onto the SDK proper once the dart_mappable codegen is unblocked.
class DiscourseTopicTags {
  static final Expando<List<String>> _tags =
      Expando<List<String>>('discourse-topic-tags');

  /// Returns the tags attached to [topic], or `const []` if none.
  static List<String> of(FCTopic topic) => _tags[topic] ?? const [];

  /// Attach [tags] to [topic]. Pass `null` (or an empty list, semantically)
  /// to clear.
  static void set(FCTopic topic, List<String>? tags) {
    if (tags == null || tags.isEmpty) {
      _tags[topic] = null;
    } else {
      _tags[topic] = List<String>.unmodifiable(tags);
    }
  }
}
