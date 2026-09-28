import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const _key = 'darkMode';
  final SharedPreferences _prefs;

  ThemeProvider(this._prefs)
      : _themeMode =
            (_prefs.getBool(_key) ?? false) ? ThemeMode.dark : ThemeMode.light;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _prefs.setBool(_key, isOn);
    notifyListeners();
  }
}
