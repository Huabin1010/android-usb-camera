/// Formats a recording timer as `mm:ss`.
String formatElapsed(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = (safe ~/ 60).toString().padLeft(2, '0');
  final rest = (safe % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}

/// Returns the capture mode to apply, or null when the request should be ignored.
String? switchMode({
  required String current,
  required bool recording,
  required String next,
}) {
  if (recording || current == next) {
    return null;
  }
  if (next != 'photo' && next != 'video' && next != 'audio') {
    return null;
  }
  return next;
}

const workspaceModeIds = <String>['watch', 'capture', 'tune'];

/// 录像中不允许离开拍摄台，避免收起快门后没法停。
String? switchWorkspace({
  required String current,
  required bool recording,
  required String next,
}) {
  if (current == next) {
    return null;
  }
  if (recording && next != 'capture') {
    return null;
  }
  if (!workspaceModeIds.contains(next)) {
    return null;
  }
  return next;
}

const rotateOptionIds = <String>[
  'ANGLE_0',
  'ANGLE_90',
  'ANGLE_180',
  'ANGLE_270',
  'FLIP_UP_DOWN',
  'FLIP_LEFT_RIGHT',
];

const segmentOptions = <int>[0, 1, 5, 10, 30];

/// 快门和模式条占用的高度。面板停在这条线上面，不再把它们挤出屏幕。
const captureBarReserve = 196.0;

/// 侧栏浮层宽度。右侧留出帧率，宽屏不超过 300。
double overlayPanelWidth(double previewWidth) {
  const gutter = 104.0;
  final room = previewWidth - gutter;
  if (room < 180) {
    return (previewWidth * 0.62).clamp(0, 300);
  }
  return room.clamp(180, 300);
}

String formatPreviewLabel({
  required int width,
  required int height,
  required String format,
  required int fps,
}) {
  final fmt = format.toUpperCase();
  return '$width×$height · $fmt · ${fps}fps';
}
