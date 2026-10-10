/// The forum refused an action the app asked for (delete, close, pin…);
/// [message] is its reason, shown as it is.
///
/// Thrown where a proxy's result:false used to be ignored, so the screen
/// reported success for something the server had turned down.
class ActionRefused implements Exception {
  const ActionRefused(this.message);
  final String message;

  @override
  String toString() => message;
}
