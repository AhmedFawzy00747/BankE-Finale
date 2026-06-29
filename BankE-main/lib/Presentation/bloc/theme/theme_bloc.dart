import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AccentColorType {
  blue,
  indigo,
  purple,
  green,
  emerald,
  orange,
  red,
  teal,
  pink
}

extension AccentColorTypeExtension on AccentColorType {
  Color get color {
    switch (this) {
      case AccentColorType.blue: return Colors.blue;
      case AccentColorType.indigo: return Colors.indigo;
      case AccentColorType.purple: return Colors.purple;
      case AccentColorType.green: return Colors.green;
      case AccentColorType.emerald: return const Color(0xFF10B981);
      case AccentColorType.orange: return Colors.orange;
      case AccentColorType.red: return Colors.red;
      case AccentColorType.teal: return Colors.teal;
      case AccentColorType.pink: return Colors.pink;
    }
  }

  String get name {
    switch (this) {
      case AccentColorType.blue: return 'Blue';
      case AccentColorType.indigo: return 'Indigo';
      case AccentColorType.purple: return 'Purple';
      case AccentColorType.green: return 'Green';
      case AccentColorType.emerald: return 'Emerald';
      case AccentColorType.orange: return 'Orange';
      case AccentColorType.red: return 'Red';
      case AccentColorType.teal: return 'Teal';
      case AccentColorType.pink: return 'Pink';
    }
  }
}

// Events
abstract class ThemeEvent {}
class LoadThemeEvent extends ThemeEvent {}

class ChangeThemeEvent extends ThemeEvent {
  final ThemeMode themeMode;
  ChangeThemeEvent(this.themeMode);
}

class ChangeAccentColorEvent extends ThemeEvent {
  final AccentColorType accentColor;
  ChangeAccentColorEvent(this.accentColor);
}

// State
class ThemeState {
  final ThemeMode themeMode;
  final AccentColorType accentColor;
  const ThemeState(this.themeMode, this.accentColor);
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_preference';
  static const String _accentKey = 'accent_color_preference';

  ThemeBloc() : super(const ThemeState(ThemeMode.system, AccentColorType.indigo)) {
    on<LoadThemeEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      final accentIndex = prefs.getInt(_accentKey) ?? AccentColorType.indigo.index;
      emit(ThemeState(
        ThemeMode.values[themeIndex],
        AccentColorType.values[accentIndex],
      ));
    });

    on<ChangeThemeEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, event.themeMode.index);
      emit(ThemeState(event.themeMode, state.accentColor));
    });

    on<ChangeAccentColorEvent>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_accentKey, event.accentColor.index);
      emit(ThemeState(state.themeMode, event.accentColor));
    });
  }
}
