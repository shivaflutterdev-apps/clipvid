import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final AppThemeColors colors;

  const ThemeState({
    required this.themeMode,
    required this.colors,
  });

  factory ThemeState.dark() {
    return const ThemeState(
      themeMode: ThemeMode.dark,
      colors: DarkThemeColors(),
    );
  }

  factory ThemeState.light() {
    return const ThemeState(
      themeMode: ThemeMode.light,
      colors: LightThemeColors(),
    );
  }

  bool get isDark => themeMode == ThemeMode.dark;

  @override
  List<Object> get props => [themeMode, colors];
}
