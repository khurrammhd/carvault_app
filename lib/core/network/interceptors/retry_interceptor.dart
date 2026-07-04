import 'dart:math';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, this.maxRetries = 2});

  final Dio dio;
  final int maxRetries;
  static const _retryCountKey = 'retryCount';

  bool _isTransient(DioException err) {
    final isNetworkFailure = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
    final status = err.response?.statusCode;
    final isServerError = status != null && status >= 500;
    return isNetworkFailure || isServerError;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final retryCount = (options.extra[_retryCountKey] as int?) ?? 0;

    if (!_isTransient(err) || retryCount >= maxRetries) {
      handler.next(err);
      return;
    }

    await Future.delayed(Duration(milliseconds: 300 * pow(2, retryCount).toInt()));
    options.extra[_retryCountKey] = retryCount + 1;

    try {
      handler.resolve(await dio.fetch(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
