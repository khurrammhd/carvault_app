import 'package:logger/logger.dart';

/// Thin wrapper around the `logger` package so call sites depend on this
/// class, not the third-party package directly.
class AppLogger {
  AppLogger._();

  static final Logger instance = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
  );
}
