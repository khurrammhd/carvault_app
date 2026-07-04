import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles mirroring the design spec's type scale. `RobotoMono` styles
/// fall back to the platform's default monospace font in this build since
/// no font assets are bundled yet — swap in real Roboto/RobotoMono asset
/// files later (see NOTES.md) without touching any call site.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const TextStyle cardHeadline = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const TextStyle bodyPrimary = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textMedium,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 15,
    color: AppColors.text,
  );

  /// Registration numbers, filenames — monospace per the design spec.
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle monoLarge = TextStyle(
    fontFamily: 'monospace',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.02,
    color: AppColors.onPrimary,
  );
}
