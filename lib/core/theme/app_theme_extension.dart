import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme colors with no equivalent slot in Flutter's [ColorScheme] —
/// category badges and the Document Viewer's dark surfaces.
@immutable
class CarVaultColors extends ThemeExtension<CarVaultColors> {
  const CarVaultColors({
    required this.buyBadgeBg,
    required this.buyBadgeText,
    required this.sellBadgeBg,
    required this.sellBadgeText,
    required this.viewerBackground,
    required this.viewerSheet,
  });

  final Color buyBadgeBg;
  final Color buyBadgeText;
  final Color sellBadgeBg;
  final Color sellBadgeText;
  final Color viewerBackground;
  final Color viewerSheet;

  static const light = CarVaultColors(
    buyBadgeBg: AppColors.buyBadgeBg,
    buyBadgeText: AppColors.buyBadgeText,
    sellBadgeBg: AppColors.sellBadgeBg,
    sellBadgeText: AppColors.sellBadgeText,
    viewerBackground: AppColors.viewerBackground,
    viewerSheet: AppColors.viewerSheet,
  );

  @override
  CarVaultColors copyWith({
    Color? buyBadgeBg,
    Color? buyBadgeText,
    Color? sellBadgeBg,
    Color? sellBadgeText,
    Color? viewerBackground,
    Color? viewerSheet,
  }) {
    return CarVaultColors(
      buyBadgeBg: buyBadgeBg ?? this.buyBadgeBg,
      buyBadgeText: buyBadgeText ?? this.buyBadgeText,
      sellBadgeBg: sellBadgeBg ?? this.sellBadgeBg,
      sellBadgeText: sellBadgeText ?? this.sellBadgeText,
      viewerBackground: viewerBackground ?? this.viewerBackground,
      viewerSheet: viewerSheet ?? this.viewerSheet,
    );
  }

  @override
  CarVaultColors lerp(ThemeExtension<CarVaultColors>? other, double t) {
    if (other is! CarVaultColors) return this;
    return CarVaultColors(
      buyBadgeBg: Color.lerp(buyBadgeBg, other.buyBadgeBg, t)!,
      buyBadgeText: Color.lerp(buyBadgeText, other.buyBadgeText, t)!,
      sellBadgeBg: Color.lerp(sellBadgeBg, other.sellBadgeBg, t)!,
      sellBadgeText: Color.lerp(sellBadgeText, other.sellBadgeText, t)!,
      viewerBackground: Color.lerp(viewerBackground, other.viewerBackground, t)!,
      viewerSheet: Color.lerp(viewerSheet, other.viewerSheet, t)!,
    );
  }
}
