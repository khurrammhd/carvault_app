/// Design-token constants shared across the app, transcribed directly
/// from the CarVault design spec's "Spacing & Radius" and accessibility
/// sections.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double listGap = 10;
  static const double rowGap = 12;
  static const double md = 14;
  static const double lg = 16;
  static const double screenHPadding = 20;
  static const double sectionGap = 18;
  static const double xl = 24;
  static const double heroPadding = 20;
  static const double loginPadding = 28;
}

class AppRadius {
  AppRadius._();

  static const double input = 12;
  static const double card = 14;
  static const double large = 16;
  static const double fab = 18;
  static const double headerBand = 24;
  static const double pill = 100;
}

class AppDurations {
  AppDurations._();

  static const Duration searchDebounce = Duration(milliseconds: 200);
}

class AppSizes {
  AppSizes._();

  /// Minimum tap target per the design spec's accessibility notes.
  static const double minTapTarget = 44;

  /// Minimum text size anywhere in the app (badges/nav labels only).
  static const double minFontSize = 11;
}
