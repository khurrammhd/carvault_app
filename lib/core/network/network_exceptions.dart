import 'package:dio/dio.dart';

import '../errors/failure.dart';

/// Translates Dio's exception types into the app's own [Failure]
/// vocabulary.
Failure mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkFailure('The request timed out. Please try again.');
    case DioExceptionType.connectionError:
      return const NetworkFailure('No internet connection. Please check your network and try again.');
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode ?? 0;
      if (status == 401) return const NetworkFailure('Your session has expired. Please log in again.');
      if (status == 403) return const NetworkFailure("You don't have permission to do that.");
      if (status == 404) return const NetworkFailure('That could not be found.');
      if (status >= 500) return const NetworkFailure('Something went wrong on our end. Please try again shortly.');
      return const NetworkFailure('The request could not be completed.');
    case DioExceptionType.cancel:
      return const NetworkFailure('The request was cancelled.');
    case DioExceptionType.badCertificate:
      return const NetworkFailure('Could not establish a secure connection.');
    case DioExceptionType.unknown:
    default:
      return const NetworkFailure('Something went wrong. Please try again.');
  }
}
