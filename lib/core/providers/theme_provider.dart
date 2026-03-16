import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/dark_mode.dart';
import '../theme/light_mode.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setLight() => state = ThemeMode.light;
  void setDark() => state = ThemeMode.dark;
  void setSystem() => state = ThemeMode.system;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

// final colorSchemeProvider = Provider<ColorScheme>((ref) {
//   final themeMode = ref.watch(themeModeProvider);
//   final brightness =
//       WidgetsBinding.instance.platformDispatcher.platformBrightness;
//
//   final isDark = themeMode == ThemeMode.dark ||
//       (themeMode == ThemeMode.system && brightness == Brightness.dark);
//
//   return isDark ? darkMode.colorScheme : lightMode.colorScheme;
// });
