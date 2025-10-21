import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/app_shared_preferences.dart';
import '../../constants/app_constants.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeDataState(_getInitialTheme())) {
    on<ChangeThemeEvent>(_onChangeTheme);
  }

  static ThemeMode _getInitialTheme() {
    final savedTheme = AppPreferences().getData(AppConstants.themeKey);
    if (savedTheme == 'dark') return ThemeMode.dark;
    if (savedTheme == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      await AppPreferences()
          .setData(AppConstants.themeKey, event.themeMode.name);
      emit(ThemeDataState(event.themeMode));
    } catch (e) {
      // Handle error if needed, e.g., emit error state
      rethrow;
    }
  }
}
