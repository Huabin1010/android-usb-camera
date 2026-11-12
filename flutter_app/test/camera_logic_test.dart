import 'package:ausbc_flutter/src/camera_logic.dart';
import 'package:ausbc_flutter/src/camera_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats the recording timer', () {
    expect(formatElapsed(0), '00:00');
    expect(formatElapsed(65), '01:05');
    expect(formatElapsed(-3), '00:00');
  });

  test('expands the side panel across the remaining width', () {
    expect(overlayPanelWidth(339), 339);
    expect(overlayPanelWidth(800), 800);
    expect(overlayPanelWidth(0), 0);
    expect(overlayPanelWidth(100, rightGutter: 12), 88);
    expect(captureBarReserve, greaterThanOrEqualTo(180));
  });

  test('keeps the current mode while recording', () {
    expect(switchMode(current: 'video', recording: true, next: 'photo'), isNull);
    expect(switchMode(current: 'photo', recording: false, next: 'photo'), isNull);
    expect(switchMode(current: 'photo', recording: false, next: 'video'), 'video');
    expect(switchMode(current: 'photo', recording: false, next: 'other'), isNull);
  });

  test('switches workspace modes and locks them while recording', () {
    expect(switchWorkspace(current: 'watch', recording: false, next: 'capture'), 'capture');
    expect(switchWorkspace(current: 'capture', recording: false, next: 'tune'), 'tune');
    expect(switchWorkspace(current: 'capture', recording: true, next: 'watch'), isNull);
    expect(switchWorkspace(current: 'watch', recording: false, next: 'watch'), isNull);
    expect(workspaceModeIds, contains('tune'));
  });

  test('formats the preview status label', () {
    expect(
      formatPreviewLabel(width: 1280, height: 720, format: 'mjpeg', fps: 30),
      '1280×720 · MJPEG · 30fps',
    );
  });

  test('keeps preview aspect ratio without stretching', () {
    expect(previewAspectRatio(width: 640, height: 480), closeTo(4 / 3, 0.0001));
    expect(previewAspectRatio(width: 1280, height: 720), closeTo(16 / 9, 0.0001));
    expect(previewAspectRatio(width: 0, height: 480), closeTo(4 / 3, 0.0001));
  });

  test('filters one-tap preview presets to device capabilities', () {
    final presets = availablePreviewPresets(
      resolutions: const [
        (width: 640, height: 480),
        (width: 1280, height: 720),
        (width: 1920, height: 1080),
      ],
      frameRates: const [15, 30],
    );
    expect(presets.map((preset) => preset.id), [
      '640x480@30',
      '1280x720@30',
      '1920x1080@30',
    ]);
    expect(
      availablePreviewPresets(resolutions: const [], frameRates: const [30]),
      isEmpty,
    );
  });

  test('round-trips custom preview presets', () {
    final custom = [
      const PreviewPreset(width: 800, height: 600, fps: 24),
      const PreviewPreset(width: 1280, height: 720, fps: 30),
    ];
    final decoded = decodePreviewPresets(encodePreviewPresets(custom));
    expect(decoded, custom);
    expect(decodePreviewPresets(null), defaultPreviewPresets);
    expect(decodePreviewPresets(<Object>[]), defaultPreviewPresets);
  });

  test('clamps preview gesture zoom between 1x and 8x', () {
    expect(clampPreviewZoom(0.5), previewZoomMin);
    expect(clampPreviewZoom(1), 1);
    expect(clampPreviewZoom(3.5), 3.5);
    expect(clampPreviewZoom(99), previewZoomMax);
  });

  test('reads a camera snapshot from the platform map', () {
    final snapshot = CameraSnapshot.fromMap({
      'connection': 'opened',
      'mode': 'video',
      'isRecording': true,
      'elapsedSeconds': 12,
      'frameRate': 30,
      'devices': [
        {'id': 7, 'name': 'HD Camera', 'summary': '/dev/bus/usb/001/002'},
      ],
      'resolutions': [
        {'width': 1280, 'height': 720},
      ],
      'frameRates': [15, 30, 60],
      'previewWidth': 1280,
      'previewHeight': 720,
      'previewFps': 30,
      'imageValues': {'brightness': 40},
      'imageSupported': ['brightness'],
      'snackbar': 'saved',
    });

    expect(snapshot.connection, 'opened');
    expect(snapshot.mode, 'video');
    expect(snapshot.isRecording, isTrue);
    expect(snapshot.devices.single.name, 'HD Camera');
    expect(snapshot.resolutions.single.label, '1280×720');
    expect(snapshot.frameRates, [15, 30, 60]);
    expect(snapshot.previewFps, 30);
    expect(snapshot.imageValues['brightness'], 40);
    expect(snapshot.snackbar, 'saved');
    expect(snapshot.textureId, -1);
  });

  test('reads flutter texture id from the platform map', () {
    final snapshot = CameraSnapshot.fromMap({'textureId': 7});
    expect(snapshot.textureId, 7);
  });

  test('keeps empty device names for l10n default display', () {
    final snapshot = CameraSnapshot.fromMap({
      'devices': [
        {'id': 1, 'summary': '/dev/bus/usb/001/001'},
      ],
    });
    expect(snapshot.devices.single.name, isEmpty);
  });
}
