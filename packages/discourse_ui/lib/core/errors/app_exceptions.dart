/// Custom exceptions for the Forum Copilot app
///
/// This file defines all custom exceptions used throughout the application
/// to provide better error handling and user experience.
///
/// An [AppException.message] is shown to the user (`ErrorHandler`), so the
/// factories below word it in the app's language.
library;

import '../../l10n/app_l10n.dart';

/// Base exception class for all app-specific exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';

  static UnknownException unknown(e, [StackTrace? stackTrace]) {
    return UnknownException(
      message: appL10n().unexpectedErrorTryAgain,
      code: 'UNKNOWN_ERROR',
      originalError: e,
      stackTrace: stackTrace,
    );
  }
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  /// No internet connection
  static NetworkException noConnection() {
    return NetworkException(
      message: appL10n().errorNoInternetConnection,
      code: 'NO_CONNECTION',
    );
  }

  /// Request timeout
  static NetworkException timeout() {
    return NetworkException(
      message: appL10n().errorRequestTimedOut,
      code: 'TIMEOUT',
    );
  }

  /// Server error
  static NetworkException serverError(int statusCode, String? message) {
    return NetworkException(
      message: message ?? appL10n().errorServerTryLater,
      code: 'SERVER_ERROR_$statusCode',
    );
  }
}

/// Authentication-related exceptions
class AuthenticationException extends AppException {
  const AuthenticationException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  /// Invalid credentials
  static AuthenticationException invalidCredentials() {
    return AuthenticationException(
      message: appL10n().errorInvalidCredentials,
      code: 'INVALID_CREDENTIALS',
    );
  }

  /// Session expired
  static AuthenticationException sessionExpired() {
    return AuthenticationException(
      message: appL10n().errorSessionExpired,
      code: 'SESSION_EXPIRED',
    );
  }

  /// Account suspended (Discourse's word for it; the code keeps its name)
  static AuthenticationException accountLocked() {
    return AuthenticationException(
      message: appL10n().errorAccountSuspended,
      code: 'ACCOUNT_LOCKED',
    );
  }
}

/// Forum-specific exceptions
class ForumException extends AppException {
  const ForumException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  /// Forum not found
  static ForumException notFound() {
    return ForumException(
      message: appL10n().errorForumNotFound,
      code: 'FORUM_NOT_FOUND',
    );
  }

  /// Access denied
  static ForumException accessDenied() {
    return ForumException(
      message: appL10n().errorForumAccessDenied,
      code: 'ACCESS_DENIED',
    );
  }

  /// Forum unavailable
  static ForumException unavailable() {
    return ForumException(
      message: appL10n().errorForumUnavailable,
      code: 'FORUM_UNAVAILABLE',
    );
  }
}

/// Data-related exceptions
class DataException extends AppException {
  const DataException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  /// Data not found
  static DataException notFound() {
    return DataException(
      message: appL10n().errorDataNotFound,
      code: 'DATA_NOT_FOUND',
    );
  }

  /// Data corruption
  static DataException corrupted() {
    return DataException(
      message: appL10n().errorDataCorrupted,
      code: 'DATA_CORRUPTED',
    );
  }

  /// Cache error
  static DataException cacheError() {
    return DataException(
      message: appL10n().errorCacheLoadFailed,
      code: 'CACHE_ERROR',
    );
  }
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  /// Invalid input
  static ValidationException invalidInput(String field) {
    return ValidationException(
      message: appL10n().errorInvalidField(field),
      code: 'INVALID_INPUT',
    );
  }

  /// Required field missing
  static ValidationException requiredField(String field) {
    return ValidationException(
      message: appL10n().errorFieldRequired(field),
      code: 'REQUIRED_FIELD',
    );
  }
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  /// Permission denied
  static PermissionException denied(String action) {
    return PermissionException(
      message: appL10n().errorPermissionDeniedFor(action),
      code: 'PERMISSION_DENIED',
    );
  }

  /// Feature not available
  static PermissionException featureNotAvailable(String feature) {
    return PermissionException(
      message: appL10n().errorFeatureNotAvailable(feature),
      code: 'FEATURE_NOT_AVAILABLE',
    );
  }
}

/// Storage-related exceptions
class StorageException extends AppException {
  const StorageException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  /// Storage full
  static StorageException full() {
    return StorageException(
      message: appL10n().errorStorageFull,
      code: 'STORAGE_FULL',
    );
  }

  /// Storage access denied
  static StorageException accessDenied() {
    return StorageException(
      message: appL10n().errorStorageAccessDenied,
      code: 'STORAGE_ACCESS_DENIED',
    );
  }
}

/// Unknown or unexpected exceptions
class UnknownException extends AppException {
  const UnknownException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  /// Create from any error
  static UnknownException fromError(dynamic error, [StackTrace? stackTrace]) {
    return UnknownException(
      // The raw error is kept in `originalError` for logging; it must not
      // be pasted into `message`, which is shown to the user.
      message: appL10n().unexpectedErrorTryAgain,
      code: 'UNKNOWN_ERROR',
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
