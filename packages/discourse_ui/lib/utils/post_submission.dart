/// Discourse publishes positive numeric topic/post IDs. An HTTP success
/// without one (outside the explicit moderation queue path) leaves the
/// outcome unknown: preserve the editor and ask the reader to check the
/// forum before resubmitting. Never invent an ID or retry the POST here.
String confirmedPostId(String? value, String unconfirmedMessage) {
  final id = value?.trim();
  if (id == null || !RegExp(r'^[1-9][0-9]*$').hasMatch(id)) {
    throw Exception(unconfirmedMessage);
  }
  return id;
}
