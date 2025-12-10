import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF2563EB); // Modern blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color secondary = Color(0xFFF59E0B); // Warm amber
  static const Color secondaryDark = Color(0xFFD97706);
  static const Color secondaryLight = Color(0xFFFCD34D);

  // Neutral Colors (light)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color cardBackgroundLight = Color(0xFFFFFFFF);

  // Neutral Colors (dark)
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceVariantDark = Color(0xFF1F2937);
  static const Color cardBackgroundDark = Color(0xFF0F172A);

  // Text Colors (light)
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Text Colors (dark)
  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);

  // Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Divider
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF1F2937);

  // Dynamic getters
  static Color get background =>
      Get.isDarkMode ? backgroundDark : backgroundLight;
  static Color get surface => Get.isDarkMode ? surfaceDark : surfaceLight;
  static Color get surfaceVariant =>
      Get.isDarkMode ? surfaceVariantDark : surfaceVariantLight;
  static Color get cardBackground =>
      Get.isDarkMode ? cardBackgroundDark : cardBackgroundLight;

  static Color get textPrimary =>
      Get.isDarkMode ? textPrimaryDark : textPrimaryLight;
  static Color get textSecondary =>
      Get.isDarkMode ? textSecondaryDark : textSecondaryLight;
  static Color get textTertiary =>
      Get.isDarkMode ? textTertiaryDark : textTertiaryLight;
  static Color get divider => Get.isDarkMode ? dividerDark : dividerLight;

  // Kost Type Colors (Modern palette)
  static const Color singleFanColor = Color(0xFF10B981); // Emerald
  static const Color singleACColor = Color(0xFF3B82F6); // Blue
  static const Color deluxeColor = Color(0xFF8B5CF6); // Violet

  // Service Colors
  static const Color serviceColor = Color(0xFFF59E0B); // Amber
  static const Color laundryColor = Color(0xFF06B6D4); // Cyan
  static const Color trashColor = Color(0xFF84CC16); // Lime
  static const Color cleaningColor = Color(0xFFF97316); // Orange

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get surfaceGradient => LinearGradient(
        colors: [surface, background],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}
