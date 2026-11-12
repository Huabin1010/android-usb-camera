import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'camera_logic.dart';

class UserPrefs {
  UserPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _workspaceKey = 'workspace_mode';
  static const _localeKey = 'locale_code';
  static const _themeKey = 'theme_mode';
  static const _presetsKey = 'preview_presets';

  static Future<UserPrefs> load() async {
    return UserPrefs(await SharedPreferences.getInstance());
  }

  String get workspace {
    final value = _prefs.getString(_workspaceKey);
    if (value != null && workspaceModeIds.contains(value)) {
      return value;
    }
    return 'tune';
  }

  Future<void> setWorkspace(String id) async {
    if (!workspaceModeIds.contains(id)) {
      return;
    }
    await _prefs.setString(_workspaceKey, id);
  }

  /// `null` / missing means follow the system locale.
  String? get localeCode => _prefs.getString(_localeKey);

  Future<void> setLocaleCode(String? code) async {
    if (code == null || code.isEmpty || code == 'system') {
      await _prefs.remove(_localeKey);
      return;
    }
    await _prefs.setString(_localeKey, code);
  }

  /// `system` / `light` / `dark`；缺失时跟随系统。
  String get themeMode {
    final value = _prefs.getString(_themeKey);
    if (value == 'light' || value == 'dark' || value == 'system') {
      return value!;
    }
    return 'system';
  }

  Future<void> setThemeMode(String id) async {
    if (id != 'light' && id != 'dark' && id != 'system') {
      return;
    }
    await _prefs.setString(_themeKey, id);
  }

  /// 用户可编辑的预览预设目录；缺失时用默认五项。
  List<PreviewPreset> get previewPresets {
    final raw = _prefs.getString(_presetsKey);
    if (raw == null || raw.isEmpty) {
      return List<PreviewPreset>.of(defaultPreviewPresets);
    }
    try {
      return decodePreviewPresets(jsonDecode(raw));
    } catch (_) {
      return List<PreviewPreset>.of(defaultPreviewPresets);
    }
  }

  Future<void> setPreviewPresets(List<PreviewPreset> presets) async {
    final normalized = decodePreviewPresets(encodePreviewPresets(presets));
    await _prefs.setString(_presetsKey, jsonEncode(encodePreviewPresets(normalized)));
  }
}
