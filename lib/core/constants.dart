import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/theme_bloc/theme_bloc.dart';
import '../blocs/theme_bloc/theme_state.dart';

/// App-wide color tokens and design constants.
abstract class AppThemeColors {
  const AppThemeColors();

  // Primary gradient
  Color get primaryStart;
  Color get primary;
  Color get primaryEnd;

  // Backgrounds
  Color get bgDark;
  Color get bgCard;
  Color get bgCardHover;
  Color get bgSurface;

  // Text
  Color get textPrimary;
  Color get textSecondary;
  Color get textMuted;

  // Accent
  Color get accent;
  Color get accentViolet;
  Color get success;
  Color get warning;
  Color get error;

  // Border
  Color get border;
  Color get borderHover;

  // Score colors
  Color get scoreHigh;
  Color get scoreMid;
  Color get scoreLow;
}

/// The exact same colors you currently have
class DarkThemeColors extends AppThemeColors {
  const DarkThemeColors();

  @override Color get primaryStart => const Color(0xFF2E90FA);
  @override Color get primary      => const Color(0xFF2E90FA);
  @override Color get primaryEnd   => const Color(0xFF9B8AFB);

  @override Color get bgDark       => const Color(0xFF0A0B0F);
  @override Color get bgCard       => const Color(0xFF12141A);
  @override Color get bgCardHover  => const Color(0xFF1A1D28);
  @override Color get bgSurface    => const Color(0xFF181B24);

  @override Color get textPrimary   => const Color(0xFFF2F4F8);
  @override Color get textSecondary => const Color(0xFF8B95A9);
  @override Color get textMuted     => const Color(0xFF4E5668);

  @override Color get accent        => const Color(0xFF2E90FA);
  @override Color get accentViolet  => const Color(0xFF9B8AFB);
  @override Color get success       => const Color(0xFF16BA48);
  @override Color get warning       => const Color(0xFFFF6B00);
  @override Color get error         => const Color(0xFFFF4747);

  @override Color get border        => const Color(0xFF1F2433);
  @override Color get borderHover   => const Color(0xFF2E90FA);

  @override Color get scoreHigh     => const Color(0xFF16BA48);
  @override Color get scoreMid      => const Color(0xFFFFA500);
  @override Color get scoreLow      => const Color(0xFFFF4747);
}

/// A beautiful light theme palette
class LightThemeColors extends AppThemeColors {
  const LightThemeColors();

  @override Color get primaryStart => const Color(0xFF0052CC); // Deeper blue
  @override Color get primary      => const Color(0xFF0052CC);
  @override Color get primaryEnd   => const Color(0xFF6554C0);

  @override Color get bgDark       => const Color(0xFFF4F5F7); // Light gray background
  @override Color get bgCard       => const Color(0xFFFFFFFF); // White cards
  @override Color get bgCardHover  => const Color(0xFFFAFBFC);
  @override Color get bgSurface    => const Color(0xFFFFFFFF);

  @override Color get textPrimary   => const Color(0xFF172B4D); // Dark slate
  @override Color get textSecondary => const Color(0xFF5E6C84);
  @override Color get textMuted     => const Color(0xFF8993A4);

  @override Color get accent        => const Color(0xFF0052CC);
  @override Color get accentViolet  => const Color(0xFF6554C0);
  @override Color get success       => const Color(0xFF00875A);
  @override Color get warning       => const Color(0xFFFF991F);
  @override Color get error         => const Color(0xFFDE350B);

  @override Color get border        => const Color(0xFFDFE1E6);
  @override Color get borderHover   => const Color(0xFF0052CC);

  @override Color get scoreHigh     => const Color(0xFF00875A);
  @override Color get scoreMid      => const Color(0xFFFF991F);
  @override Color get scoreLow      => const Color(0xFFDE350B);
}

extension ThemeColorsExt on BuildContext {
  AppThemeColors get colors => watch<ThemeBloc>().state.colors;
}

/// Spacing constants
class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}

/// Radius constants
class AppRadius {
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double xxl = 32;
}
