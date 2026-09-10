import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption { light, dark, system }

class ThemeProvider with ChangeNotifier {
  ThemeModeOption _themeModeOption = ThemeModeOption.system;

  ThemeModeOption get themeModeOption => _themeModeOption;

  ThemeMode get currentThemeMode {
    switch (_themeModeOption) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString('kc_theme_mode') ?? 'system';
    if (modeStr == 'light') _themeModeOption = ThemeModeOption.light;
    if (modeStr == 'dark') _themeModeOption = ThemeModeOption.dark;
    if (modeStr == 'system') _themeModeOption = ThemeModeOption.system;
    notifyListeners();
  }

  void setThemeMode(ThemeModeOption option) async {
    _themeModeOption = option;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kc_theme_mode', option.name);
  }
}
