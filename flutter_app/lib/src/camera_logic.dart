/// Formats a recording timer as `mm:ss`.
String formatElapsed(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final minutes = (safe ~/ 60).toString().padLeft(2, '0');
  final rest = (safe % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}

/// Returns the mode to apply, or null when the request should be ignored.
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
