import 'package:shared_preferences/shared_preferences.dart';

import 'camera_logic.dart';

class UserPrefs {
  UserPrefs(this._prefs);

  final SharedPreferences _prefs;

  static const _workspaceKey = 'workspace_mode';
  static const _localeKey = 'locale_code';

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
}
