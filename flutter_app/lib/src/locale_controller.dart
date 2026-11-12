import 'package:flutter/material.dart';

import 'user_prefs.dart';

/// Play 上架准备支持的语言；`null` 表示跟随系统。
class AppLocales {
  static const supported = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale('ja'),
    Locale('ko'),
    Locale('es'),
    Locale('pt'),
    Locale('de'),
    Locale('fr'),
    Locale('ru'),
    Locale('id'),
    Locale('hi'),
    Locale('ar'),
  ];

  static String codeOf(Locale locale) {
    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      return 'zh_Hant';
    }
    return locale.languageCode;
  }

  static Locale? parse(String? code) {
    if (code == null || code.isEmpty || code == 'system') {
      return null;
    }
    if (code == 'zh_Hant') {
      return Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');
    }
    return Locale(code);
  }

  static String displayName(Locale locale) {
    return switch (codeOf(locale)) {
      'en' => 'English',
      'zh' => '简体中文',
      'zh_Hant' => '繁體中文',
      'ja' => '日本語',
      'ko' => '한국어',
      'es' => 'Español',
      'pt' => 'Português',
      'de' => 'Deutsch',
      'fr' => 'Français',
      'ru' => 'Русский',
      'id' => 'Bahasa Indonesia',
      'hi' => 'हिन्दी',
      'ar' => 'العربية',
      _ => locale.toLanguageTag(),
    };
  }
}

class LocaleController extends ChangeNotifier {
  LocaleController(this._prefs) : _code = _prefs.localeCode;

  final UserPrefs _prefs;
  String? _code;

  /// `null` = follow system language.
  Locale? get locale => AppLocales.parse(_code);

  String? get code => _code;

  Future<void> setLocaleCode(String? code) async {
    final normalized = (code == null || code == 'system') ? null : code;
    if (normalized == _code) {
      return;
    }
    _code = normalized;
    await _prefs.setLocaleCode(normalized);
    notifyListeners();
  }
}
