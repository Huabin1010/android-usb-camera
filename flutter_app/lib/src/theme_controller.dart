import 'package:flutter/material.dart';

import 'user_prefs.dart';

/// 外观：跟随系统 / 浅色 / 暗色。
class AppThemes {
  static const ids = <String>['system', 'light', 'dark'];

  static ThemeMode parse(String? code) {
    return switch (code) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String codeOf(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) : _mode = AppThemes.parse(_prefs.themeMode);

  final UserPrefs _prefs;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  String get code => AppThemes.codeOf(_mode);

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) {
      return;
    }
    _mode = mode;
    await _prefs.setThemeMode(AppThemes.codeOf(mode));
    notifyListeners();
  }

  Future<void> setCode(String id) => setMode(AppThemes.parse(id));
}
