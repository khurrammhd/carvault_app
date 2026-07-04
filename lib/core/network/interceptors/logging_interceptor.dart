import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);
  final Logger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('→ ${options.method} ${options.uri} headers=${_redact(options.headers)}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.w('✕ ${err.requestOptions.method} ${err.requestOptions.uri} — ${err.type} ${err.response?.statusCode ?? ''}');
    handler.next(err);
  }

  Map<String, dynamic> _redact(Map<String, dynamic> headers) {
    if (!headers.containsKey('Authorization')) return headers;
    return {...headers, 'Authorization': 'Bearer [redacted]'};
  }
}
