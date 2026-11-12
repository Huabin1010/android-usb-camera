import 'package:ausbc_flutter/src/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('maps platform message keys in English and Chinese', (tester) async {
    late AppLocalizations en;
    late AppLocalizations zh;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            en = context.l10n;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            zh = context.l10n;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(en.platformMessage('saved'), 'Saved');
    expect(en.platformMessage('save_failed'), 'Could not save');
    expect(en.platformMessage('no_device'), 'No USB camera found');
    expect(en.platformMessage('camera_error'), 'Camera error');
    expect(en.deviceDisplayName(''), 'USB camera');
    expect(en.previewStatusLabel(width: 1280, height: 720, format: 'mjpeg', fps: 30), '1280×720 · MJPEG · 30fps');

    expect(zh.platformMessage('saved'), '已保存');
    expect(zh.platformMessage('已保存'), '已保存');
    expect(zh.platformMessage('save_failed'), '保存失败');
    expect(zh.deviceDisplayName(''), 'USB 摄像头');
  });
}
