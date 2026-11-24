import 'package:dio/dio.dart';

/// One error type for the whole app, built from whatever Dio threw.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
    this.data = const {},
  });

  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  /// The raw JSON body, for endpoint specific fields like `retry_after`.
  final Map<String, dynamic> data;

  bool get isUnauthorized => statusCode == 401;
  bool get isRateLimited => statusCode == 429;

  String? firstErrorFor(String field) {
    final list = fieldErrors[field];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  factory ApiException.fromDio(DioException e) {
    final response = e.response;
    if (response == null) {
      return const ApiException(
        "Can't reach the server. Check your connection and try again",
      );
    }

    final body = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : const <String, dynamic>{};

    final errors = <String, List<String>>{};
    final raw = body['errors'];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is List) {
          errors['$key'] = value.map((v) => '$v').toList();
        }
      });
    }

    final message = body['message'] is String
        ? body['message'] as String
        : 'Something went wrong. Try again in a moment';

    return ApiException(
      message,
      statusCode: response.statusCode,
      fieldErrors: errors,
      data: body,
    );
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
