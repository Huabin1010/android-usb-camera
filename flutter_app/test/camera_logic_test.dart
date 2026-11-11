import 'package:ausbc_flutter/src/camera_logic.dart';
import 'package:ausbc_flutter/src/camera_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats the recording timer', () {
    expect(formatElapsed(0), '00:00');
    expect(formatElapsed(65), '01:05');
    expect(formatElapsed(-3), '00:00');
  });

  test('keeps the current mode while recording', () {
    expect(switchMode(current: 'video', recording: true, next: 'photo'), isNull);
    expect(switchMode(current: 'photo', recording: false, next: 'photo'), isNull);
    expect(switchMode(current: 'photo', recording: false, next: 'video'), 'video');
    expect(switchMode(current: 'photo', recording: false, next: 'other'), isNull);
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
      'previewWidth': 1280,
      'previewHeight': 720,
      'imageValues': {'brightness': 40},
      'imageSupported': ['brightness'],
      'snackbar': '已保存',
    });

    expect(snapshot.connection, 'opened');
    expect(snapshot.mode, 'video');
    expect(snapshot.isRecording, isTrue);
    expect(snapshot.devices.single.name, 'HD Camera');
    expect(snapshot.resolutions.single.label, '1280×720');
    expect(snapshot.imageValues['brightness'], 40);
    expect(snapshot.snackbar, '已保存');
  });
}
