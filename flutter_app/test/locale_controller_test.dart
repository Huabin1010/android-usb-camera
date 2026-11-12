import 'package:ausbc_flutter/src/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses locale codes used by the language picker', () {
    expect(AppLocales.parse(null), isNull);
    expect(AppLocales.parse('system'), isNull);
    expect(AppLocales.parse('en'), const Locale('en'));
    expect(AppLocales.parse('zh'), const Locale('zh'));
    expect(
      AppLocales.parse('zh_Hant'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
    expect(AppLocales.codeOf(const Locale('ja')), 'ja');
    expect(
      AppLocales.codeOf(Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')),
      'zh_Hant',
    );
  });

  test('keeps Play-ready language coverage', () {
    final codes = AppLocales.supported.map(AppLocales.codeOf).toSet();
    expect(
      codes,
      containsAll([
        'en',
        'zh',
        'zh_Hant',
        'ja',
        'ko',
        'es',
        'pt',
        'de',
        'fr',
        'ru',
        'id',
        'hi',
        'ar',
      ]),
    );
  });
}
