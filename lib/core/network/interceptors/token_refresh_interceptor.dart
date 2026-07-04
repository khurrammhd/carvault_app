import 'package:dio/dio.dart';

import '../auth_token_provider.dart';

class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({required this.dio, required this.tokenProvider});

  final Dio dio;
  final AuthTokenProvider tokenProvider;
  static const _retriedKey = 'tokenRefreshRetried';
  Future<String?>? _refreshInFlight;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final alreadyRetried = options.extra[_retriedKey] == true;

    if (err.response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    _refreshInFlight ??= tokenProvider.getToken(forceRefresh: true).whenComplete(() {
      _refreshInFlight = null;
    });
    final newToken = await _refreshInFlight;

    if (newToken == null) {
      handler.next(err);
      return;
    }

    options.extra[_retriedKey] = true;
    options.headers['Authorization'] = 'Bearer $newToken';

    try {
      handler.resolve(await dio.fetch(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
