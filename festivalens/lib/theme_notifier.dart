import 'package:flutter/material.dart';
// Notifies other pages when theme is changed from light/dark mode
class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
// End of Code