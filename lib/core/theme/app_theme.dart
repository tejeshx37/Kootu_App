import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface:
          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      surfaceContainerHighest:
          isDark ? AppColors.darkMuted : AppColors.lightMuted,
      outline: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );

    final headingFont = GoogleFonts.nunito;
    final bodyFont = GoogleFonts.plusJakartaSans;

    final textTheme = TextTheme(
      displaySmall: headingFont(
          fontSize: 22, fontWeight: FontWeight.w800, height: 1.3),
      headlineSmall: headingFont(
          fontSize: 18, fontWeight: FontWeight.w700, height: 1.3),
      titleLarge: headingFont(
          fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
      titleMedium: headingFont(
          fontSize: 15, fontWeight: FontWeight.w700, height: 1.3),
      titleSmall: bodyFont(
          fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge:
          bodyFont(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4),
      bodyMedium:
          bodyFont(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
      bodySmall:
          bodyFont(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge:
          bodyFont(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2),
      labelMedium:
          bodyFont(fontSize: 12, fontWeight: FontWeight.w500, height: 1.2),
      labelSmall:
          bodyFont(fontSize: 10, fontWeight: FontWeight.w500, height: 1.2),
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: headingFont(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? AppColors.darkMuted : AppColors.lightInputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.xs),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.xs),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.xs),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: bodyFont(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle:
              bodyFont(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: AppColors.primarySoft,
        labelTextStyle: WidgetStatePropertyAll(
          bodyFont(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active
                ? AppColors.primary
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
            size: 22,
          );
        }),
        height: 64,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primarySoft
              : (isDark
                  ? AppColors.darkMuted
                  : const Color(0xFFCBCED4)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
