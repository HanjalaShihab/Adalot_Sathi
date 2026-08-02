/// A machine-readable error surfaced from the API or the app layer.
class AppException implements Exception {
  final String code;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const AppException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// Thrown when a free-tier user attempts to create an active case beyond the
/// 5-case limit. Mirrors the API's `case_limit_reached` 403 payload.
class CaseLimitReachedException extends AppException {
  final int limit;

  const CaseLimitReachedException({
    required String message,
    required this.limit,
  }) : super(
          code: 'case_limit_reached',
          message: message,
          statusCode: 403,
        );
}

/// Thrown when the API returns 401 and the stored session is no longer valid.
class UnauthorizedException extends AppException {
  const UnauthorizedException({String message = 'Session expired. Please log in again.'})
      : super(code: 'unauthorized', message: message, statusCode: 401);
}

/// Thrown when a network/connectivity problem prevents the request.
class NetworkException extends AppException {
  const NetworkException({String message = 'No internet connection. Please try again.'})
      : super(code: 'network_error', message: message);
}

