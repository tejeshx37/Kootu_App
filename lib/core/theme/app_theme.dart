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
        elevation: isDark ? 2 : 6,
        shadowColor: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : const Color(0xFF1A1A2E).withValues(alpha: 0.10),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
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
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.45),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle:
              bodyFont(fontSize: 15, fontWeight: FontWeight.w700),
        ).copyWith(
          // Subtle press feedback: shrink the shadow and lighten on tap.
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 1;
            return 4;
          }),
          overlayColor:
              const WidgetStatePropertyAll(Color(0x1FFFFFFF)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: bodyFont(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: isDark
            ? AppColors.primary.withValues(alpha: 0.22)
            : AppColors.primarySoft,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
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
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightTextPrimary,
        contentTextStyle: bodyFont(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkMuted : AppColors.lightMuted,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        labelStyle: bodyFont(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
