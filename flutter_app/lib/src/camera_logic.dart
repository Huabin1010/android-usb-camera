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

const workspaceLabels = <String, String>{
  'watch': '观看',
  'capture': '拍摄',
  'tune': '调节',
};

const workspaceHints = <String, String>{
  'watch': '只看画面。需要时再打开设备列表切换摄像头。',
  'capture': '拍照、录像、录音，底部快门可用。',
  'tune': '画面、视频、效果、音频和分段设置。',
};

String workspaceLabel(String? id) => workspaceLabels[id] ?? workspaceLabels['watch']!;

String workspaceHint(String? id) => workspaceHints[id] ?? workspaceHints['watch']!;

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

const imageLabels = <String, String>{
  'brightness': '亮度',
  'contrast': '对比度',
  'saturation': '饱和度',
  'hue': '色调',
  'gain': '增益',
  'gamma': '伽马',
  'sharpness': '锐度',
  'zoom': '变焦',
};

const rotateOptions = <String, String>{
  'ANGLE_0': '0°',
  'ANGLE_90': '90°',
  'ANGLE_180': '180°',
  'ANGLE_270': '270°',
  'FLIP_UP_DOWN': '上下翻转',
  'FLIP_LEFT_RIGHT': '左右翻转',
};

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
