import 'package:flutter/material.dart';

/// Color tokens translated 1:1 from src/styles/theme.css and
/// kootu-design-tokens.json. Hex values stay in this file only —
/// every widget should pull from Theme.of(context) or AppColors.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1D9E75);
  static const Color primarySoft = Color(0xFFE8F5E9);
  static const Color accent = Color(0xFFFF6B35);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Light surfaces
  static const Color lightBg = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightMuted = Color(0xFFECECEF);
  static const Color lightBorder = Color(0x1A000000);
  static const Color lightInputBg = Color(0xFFF3F3F5);

  // Dark surfaces (oklch(0.145 0 0) ≈ #252525; we go a little deeper
  // for app bg to match the prototype's #0f0f1a / #1a1a2e tones used
  // in className conditionals throughout the React source).
  static const Color darkBg = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB5B5B5);
  static const Color darkMuted = Color(0xFF2A2A3A);
  static const Color darkBorder = Color(0x14FFFFFF);
}

class AppRadii {
  AppRadii._();
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 24;
  static const double sheet = 28;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
