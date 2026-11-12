import 'package:ausbc_flutter/src/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses theme mode codes', () {
    expect(AppThemes.parse(null), ThemeMode.system);
    expect(AppThemes.parse('system'), ThemeMode.system);
    expect(AppThemes.parse('light'), ThemeMode.light);
    expect(AppThemes.parse('dark'), ThemeMode.dark);
    expect(AppThemes.parse('nope'), ThemeMode.system);
  });

  test('maps ThemeMode back to codes', () {
    expect(AppThemes.codeOf(ThemeMode.system), 'system');
    expect(AppThemes.codeOf(ThemeMode.light), 'light');
    expect(AppThemes.codeOf(ThemeMode.dark), 'dark');
  });

  test('keeps the three appearance options', () {
    expect(AppThemes.ids, ['system', 'light', 'dark']);
  });
}
