import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment.dart';
import '../errors/failure.dart';
import '../errors/result.dart';
import '../logging/app_logger.dart';
import 'auth_token_provider.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/token_refresh_interceptor.dart';
import 'network_exceptions.dart';

/// The app's single HTTP client. Not currently called by any feature — v1
/// has no custom backend — this exists as the ready seam for whenever a
/// real REST API is introduced.
class ApiClient {
  ApiClient(this._dio);
  final Dio _dio;

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parse,
  }) => _request(() => _dio.get(path, queryParameters: queryParameters), parse);

  Future<Result<T>> post<T>(
    String path, {
    Object? data,
    required T Function(dynamic json) parse,
  }) => _request(() => _dio.post(path, data: data), parse);

  Future<Result<T>> delete<T>(
    String path, {
    required T Function(dynamic json) parse,
  }) => _request(() => _dio.delete(path), parse);

  Future<Result<T>> _request<T>(
    Future<Response<dynamic>> Function() request,
    T Function(dynamic json) parse,
  ) async {
    try {
      final response = await request();
      return Success(parse(response.data));
    } on DioException catch (e) {
      return Failed(mapDioException(e));
    } catch (e) {
      return Failed(UnexpectedFailure(e.toString()));
    }
  }
}

final _dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: Environment.current.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final tokenProvider = ref.watch(authTokenProviderProvider);

  dio.interceptors.addAll([
    AuthInterceptor(tokenProvider),
    RetryInterceptor(dio: dio),
    TokenRefreshInterceptor(dio: dio, tokenProvider: tokenProvider),
    LoggingInterceptor(AppLogger.instance),
  ]);

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(_dioProvider)));
