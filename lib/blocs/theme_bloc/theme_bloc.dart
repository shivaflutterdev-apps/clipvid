import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const _themePrefKey = 'is_dark_theme';

  ThemeBloc() : super(ThemeState.dark()) {
    on<ThemeToggleEvent>((event, emit) async {
      final isCurrentlyDark = state.isDark;
      if (isCurrentlyDark) {
        emit(ThemeState.light());
        await _saveThemePreference(false);
      } else {
        emit(ThemeState.dark());
        await _saveThemePreference(true);
      }
    });

    on<ThemeSetDarkEvent>((event, emit) async {
      emit(ThemeState.dark());
      await _saveThemePreference(true);
    });

    on<ThemeSetLightEvent>((event, emit) async {
      emit(ThemeState.light());
      await _saveThemePreference(false);
    });

    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themePrefKey) ?? true; // Default to dark
    if (isDark) {
      add(ThemeSetDarkEvent());
    } else {
      add(ThemeSetLightEvent());
    }
  }

  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, isDark);
  }
}
