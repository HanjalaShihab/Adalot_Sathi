import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../storage/token_storage.dart';

/// Configured Dio instance for the Adalot Sathi API.
///
/// Attaches the Sanctum bearer token to every request and normalizes error
/// responses into typed [AppException]s, including the API's
/// `case_limit_reached` 403 payload.
class ApiClient {
  ApiClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  final TokenStorage _tokenStorage;

  Dio get dio => _dio;

  /// Convenience method that unwraps DioErrors into typed exceptions.
  static AppException mapError(Object error) {
    if (error is DioException) {
      final response = error.response;
      final status = response?.statusCode;
      final data = response?.data;

      if (data is Map<String, dynamic>) {
        final errorCode = data['error'] as String?;
        final message = (data['message'] as String?) ?? error.message ?? 'Something went wrong.';

        // Free-tier active case limit reached (403).
        if (status == 403 && errorCode == 'case_limit_reached') {
          return CaseLimitReachedException(
            message: message,
            limit: (data['limit'] as num?)?.toInt() ?? 5,
          );
        }

        // Unauthorized / session expired.
        if (status == 401) {
          return UnauthorizedException(message: message);
        }

        // Validation errors (422).
        if (status == 422) {
          final errors = data['errors'] as Map<String, dynamic>? ?? const {};
          final firstKey = errors.keys.isNotEmpty ? errors.keys.first : null;
          var firstMsg = message;
          if (firstKey != null) {
            final list = errors[firstKey];
            if (list is List && list.isNotEmpty) {
              firstMsg = list.first.toString();
            } else if (list is String) {
              firstMsg = list;
            }
          }
          return AppException(
            code: 'validation_error',
            message: firstMsg,
            statusCode: status,
            details: errors,
          );
        }
      }

      // Network-level failures.
      if (response == null) {
        return NetworkException(message: 'Could not reach the server. Check your connection.');
      }

      return AppException(
        code: 'http_${status ?? 'error'}',
        message: data is Map<String, dynamic>
            ? (data['message'] as String?) ?? 'Request failed.'
            : 'Request failed.',
        statusCode: status,
      );
    }

    return AppException(code: 'unknown', message: error.toString());
  }
}


