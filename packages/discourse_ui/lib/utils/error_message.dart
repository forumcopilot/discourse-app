import 'package:discourse_core/discourse_core.dart' show DiscourseApiException;

/// Turns a caught error into something worth showing a person.
///
/// UI code used to interpolate the exception directly (`'$e'`), which for a
/// [DiscourseApiException] meant rendering its `toString()` — method, path,
/// status code and the **entire response body**. When a CDN or reverse proxy
/// answered with an HTML error page, that whole document appeared on screen.
///
/// Every user-facing error string should go through here. Keep raw `$e` for
/// `AppLogger`, where the detail is the point.
String describeError(Object? error, {String? fallback}) {
  if (error == null) {
    return fallback ?? 'Something went wrong. Please try again.';
  }
  if (error is DiscourseApiException) return error.userMessage;

  // Dart prepends "Exception: " to the message of a bare Exception; it means
  // nothing to a reader.
  final text = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  if (text.isEmpty) {
    return fallback ?? 'Something went wrong. Please try again.';
  }
  // Anything long or markup-shaped is a machine detail that escaped; prefer
  // the caller's wording over dumping it.
  if (text.length > 200 || text.contains('<html') || text.contains('<!DOCTYPE')) {
    return fallback ?? 'Something went wrong. Please try again.';
  }
  return text;
}

/// True when the error is worth offering an immediate "Try again" for —
/// throttling and transport failures, as opposed to a 404 or a permission
/// error where retrying changes nothing.
bool isRetryableError(Object? error) {
  if (error is DiscourseApiException) {
    return error.isRateLimited ||
        error.statusCode == 0 ||
        error.statusCode >= 500;
  }
  return error != null;
}
