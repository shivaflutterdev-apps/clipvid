import 'package:flutter/material.dart';

/// App-wide color tokens and design constants.
class AppColors {
  // Primary gradient — electric blue to violet
  static const Color primaryStart = Color(0xFF2E90FA);
  static const Color primary   = Color(0xFF2E90FA);
  static const Color primaryEnd   = Color(0xFF9B8AFB);

  // Backgrounds (dark cinematic)
  static const Color bgDark       = Color(0xFF0A0B0F);
  static const Color bgCard       = Color(0xFF12141A);
  static const Color bgCardHover  = Color(0xFF1A1D28);
  static const Color bgSurface    = Color(0xFF181B24);

  // Text
  static const Color textPrimary   = Color(0xFFF2F4F8);
  static const Color textSecondary = Color(0xFF8B95A9);
  static const Color textMuted     = Color(0xFF4E5668);

  // Accent
  static const Color accent        = Color(0xFF2E90FA);
  static const Color accentViolet  = Color(0xFF9B8AFB);
  static const Color success       = Color(0xFF16BA48);
  static const Color warning       = Color(0xFFFF6B00);
  static const Color error         = Color(0xFFFF4747);

  // Border
  static const Color border        = Color(0xFF1F2433);
  static const Color borderHover   = Color(0xFF2E90FA);

  // Score colors
  static const Color scoreHigh   = Color(0xFF16BA48);  // 8-10
  static const Color scoreMid    = Color(0xFFFFA500);  // 5-7.9
  static const Color scoreLow    = Color(0xFFFF4747);  // <5
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
