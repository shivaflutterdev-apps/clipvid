import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

/// The dark cinematic theme for ClipVid.
ThemeData buildAppTheme() {
  final base = ThemeData.dark();

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: const ColorScheme.dark(
      primary:    AppColors.accent,
      secondary:  AppColors.accentViolet,
      surface:    AppColors.bgCard,
      error:      AppColors.error,
      onPrimary:  Colors.white,
      onSurface:  AppColors.textPrimary,
    ),

    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 56, fontWeight: FontWeight.w800,
        color: AppColors.textPrimary, letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 40, fontWeight: FontWeight.w800,
        color: AppColors.textPrimary, letterSpacing: -1.0,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, letterSpacing: 0.2,
      ),
    ),

    cardTheme: CardThemeData(
      color:        AppColors.bgCard,
      elevation:    0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled:      true,
      fillColor:   AppColors.bgCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      hintStyle: GoogleFonts.inter(
        color: AppColors.textMuted, fontSize: 16,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation:       0,
        padding:  const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600,
        ),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgDark,
      elevation:       0,
      centerTitle:     false,
      titleTextStyle:  GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color:             AppColors.accent,
      linearTrackColor:  AppColors.border,
    ),
  );
}
