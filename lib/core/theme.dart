import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

/// The cinematic theme for ClipVid.
ThemeData buildAppTheme(AppThemeColors colors) {
  final base = ThemeData.dark(); // We still base it on dark for text contrast baselines, though text colors override it

  return base.copyWith(
    scaffoldBackgroundColor: colors.bgDark,
    colorScheme: ColorScheme.dark(
      primary:    colors.accent,
      secondary:  colors.accentViolet,
      surface:    colors.bgCard,
      error:      colors.error,
      onPrimary:  Colors.white,
      onSurface:  colors.textPrimary,
    ),

    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 56, fontWeight: FontWeight.w800,
        color: colors.textPrimary, letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 40, fontWeight: FontWeight.w800,
        color: colors.textPrimary, letterSpacing: -1.0,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24, fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: colors.textPrimary, letterSpacing: 0.2,
      ),
    ),

    cardTheme: CardThemeData(
      color:        colors.bgCard,
      elevation:    0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.border, width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled:      true,
      fillColor:   colors.bgCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        borderSide: BorderSide(color: colors.accent, width: 2),
      ),
      hintStyle: GoogleFonts.inter(
        color: colors.textMuted, fontSize: 16,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.accent,
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

    dividerTheme: DividerThemeData(
      color: colors.border,
      thickness: 1,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: colors.bgDark,
      elevation:       0,
      centerTitle:     false,
      titleTextStyle:  GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color:             colors.accent,
      linearTrackColor:  colors.border,
    ),
  );
}
