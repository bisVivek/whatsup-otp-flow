import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Called when the server rejects the stored token.
typedef UnauthorizedHandler = Future<void> Function();

/// Thin wrapper over Dio: adds the bearer token, maps errors to
/// [ApiException] and reports expired sessions.
class ApiClient {
  ApiClient(
    this._dio, {
    required TokenStorage tokens,
    required UnauthorizedHandler onUnauthorized,
  }) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokens.read();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final hadToken =
              error.requestOptions.headers.containsKey('Authorization');
          if (error.response?.statusCode == 401 && hadToken) {
            await onUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;

  Future<Map<String, dynamic>> get(String path) =>
      _send(() => _dio.get<Map<String, dynamic>>(path));

  Future<Map<String, dynamic>> post(String path, [Object? body]) =>
      _send(() => _dio.post<Map<String, dynamic>>(path, data: body));

  Future<Map<String, dynamic>> delete(String path) =>
      _send(() => _dio.delete<Map<String, dynamic>>(path));

  Future<Map<String, dynamic>> _send(
    Future<Response<Map<String, dynamic>>> Function() call,
  ) async {
    try {
      final response = await call();
      return response.data ?? const {};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

/// Set by the auth layer so the client can end a dead session
/// without the network layer depending on auth.
final unauthorizedHandlerProvider = Provider<UnauthorizedHandler>(
  (ref) => () async {},
);

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    ref.watch(dioProvider),
    tokens: ref.watch(tokenStorageProvider),
    onUnauthorized: () => ref.read(unauthorizedHandlerProvider)(),
  );
});
