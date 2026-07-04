/// Which build flavor is currently running. Set once at startup by
/// `bootstrap.dart` and read everywhere else via [Environment.current].
enum Environment {
  development,
  production;

  static Environment current = Environment.development;

  bool get isProduction => this == Environment.production;

  bool get reportCrashes => isProduction;

  String get appNameSuffix {
    switch (this) {
      case Environment.development:
        return ' (Dev)';
      case Environment.production:
        return '';
    }
  }

  /// Placeholder — no backend exists yet. See core/network/ for the
  /// (currently unused) HTTP client this would back.
  String get apiBaseUrl {
    switch (this) {
      case Environment.development:
        return 'https://api-dev.carvault.app';
      case Environment.production:
        return 'https://api.carvault.app';
    }
  }
}
