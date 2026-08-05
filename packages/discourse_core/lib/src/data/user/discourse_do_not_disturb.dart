/// Result of a do-not-disturb call (`POST`/`DELETE /do-not-disturb.json`,
/// app/controllers/do_not_disturb_controller.rb) or a status check read
/// off `/session/current.json`'s `current_user.do_not_disturb_until`
/// (app/serializers/current_user_serializer.rb).
class DiscourseDoNotDisturbResult {
  final bool result;
  final String resultText;

  /// When the active do-not-disturb window ends, in UTC. Null when DND
  /// is off (or after a successful leave call).
  final DateTime? endsAt;

  DiscourseDoNotDisturbResult({
    required this.result,
    this.resultText = '',
    this.endsAt,
  });

  /// True when a do-not-disturb window is currently active.
  bool get isActive => endsAt != null && endsAt!.isAfter(DateTime.now().toUtc());
}
