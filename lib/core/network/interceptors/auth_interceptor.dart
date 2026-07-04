import 'package:dio/dio.dart';

import '../auth_token_provider.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenProvider);
  final AuthTokenProvider _tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra['skipAuth'] == true) {
      handler.next(options);
      return;
    }
    final token = await _tokenProvider.getToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
