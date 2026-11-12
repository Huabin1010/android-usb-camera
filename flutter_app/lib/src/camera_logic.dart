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

/// 侧栏浮层宽度：占满抽屉右侧剩余空间，默认贴右边缘。
double overlayPanelWidth(double availableWidth, {double rightGutter = 0}) {
  if (availableWidth <= rightGutter) {
    return 0;
  }
  return availableWidth - rightGutter;
}

/// Preview box aspect (width / height). Falls back to 4:3 when sizes are invalid.
double previewAspectRatio({required int width, required int height}) {
  if (width <= 0 || height <= 0) {
    return 4 / 3;
  }
  return width / height;
}

/// 预览显示尺寸：优先横向铺满，高度按比例；若超出屏幕高度则整体缩小以完整显示。
({double width, double height}) previewFitSize({
  required double roomWidth,
  required double roomHeight,
  required double aspectRatio,
}) {
  final ratio = aspectRatio <= 0 ? 4 / 3 : aspectRatio;
  var width = roomWidth;
  var height = width / ratio;
  if (height > roomHeight) {
    height = roomHeight;
    width = height * ratio;
  }
  return (width: width, height: height);
}

/// Whether native preview buffers should be resized.
///
/// Repeated same-size `setDefaultBufferSize` / FBO reloads flash the Texture.
bool shouldResizePreviewSurface({
  required int currentWidth,
  required int currentHeight,
  required int nextWidth,
  required int nextHeight,
}) {
  if (nextWidth <= 0 || nextHeight <= 0) {
    return false;
  }
  return nextWidth != currentWidth || nextHeight != currentHeight;
}

/// Mirrors native `uvc_mjpeg_is_complete`: SOI at start and EOI before trailing zero padding.
bool isCompleteMjpegFrame(List<int> data) {
  if (data.length < 4) {
    return false;
  }
  if (data[0] != 0xFF || data[1] != 0xD8) {
    return false;
  }
  var i = data.length;
  while (i >= 2) {
    if (data[i - 2] == 0xFF && data[i - 1] == 0xD9) {
      return true;
    }
    if (data[i - 1] != 0x00) {
      break;
    }
    i--;
  }
  return false;
}

/// 一键预览预设：分辨率 + 帧率一起选，避免拆成两步。
class PreviewPreset {
  const PreviewPreset({required this.width, required this.height, required this.fps});

  final int width;
  final int height;
  final int fps;

  String get id => '${width}x$height@$fps';

  String get label => '$width×$height · ${fps}fps';

  Map<String, Object> toJson() => {
        'width': width,
        'height': height,
        'fps': fps,
      };

  static PreviewPreset? tryParse(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    final width = _asPositiveInt(raw['width']);
    final height = _asPositiveInt(raw['height']);
    final fps = _asPositiveInt(raw['fps']);
    if (width == null || height == null || fps == null) {
      return null;
    }
    return PreviewPreset(width: width, height: height, fps: fps);
  }

  @override
  bool operator ==(Object other) {
    return other is PreviewPreset &&
        other.width == width &&
        other.height == height &&
        other.fps == fps;
  }

  @override
  int get hashCode => Object.hash(width, height, fps);
}

const defaultPreviewPresets = <PreviewPreset>[
  PreviewPreset(width: 640, height: 480, fps: 30),
  PreviewPreset(width: 1280, height: 720, fps: 30),
  PreviewPreset(width: 1280, height: 720, fps: 60),
  PreviewPreset(width: 1920, height: 1080, fps: 30),
  PreviewPreset(width: 1920, height: 1080, fps: 60),
];

/// 从偏好/JSON 还原；无效或空时回落到默认列表。
List<PreviewPreset> decodePreviewPresets(Object? raw) {
  if (raw is! List) {
    return List<PreviewPreset>.of(defaultPreviewPresets);
  }
  final out = <PreviewPreset>[];
  final seen = <String>{};
  for (final item in raw) {
    final preset = PreviewPreset.tryParse(item);
    if (preset == null || !seen.add(preset.id)) {
      continue;
    }
    out.add(preset);
  }
  if (out.isEmpty) {
    return List<PreviewPreset>.of(defaultPreviewPresets);
  }
  return out;
}

List<Map<String, Object>> encodePreviewPresets(Iterable<PreviewPreset> presets) {
  return [for (final preset in presets) preset.toJson()];
}

/// 只保留设备实际支持的分辨率；帧率就近落到设备列表里。
List<PreviewPreset> availablePreviewPresets({
  required Iterable<({int width, int height})> resolutions,
  required Iterable<int> frameRates,
  List<PreviewPreset> catalog = defaultPreviewPresets,
}) {
  final sizes = {
    for (final size in resolutions) '${size.width}x${size.height}',
  };
  if (sizes.isEmpty) {
    return const [];
  }
  final rates = frameRates.where((fps) => fps > 0).toList()..sort();
  final out = <PreviewPreset>[];
  final seen = <String>{};
  for (final preset in catalog) {
    if (!sizes.contains('${preset.width}x${preset.height}')) {
      continue;
    }
    final fps = _nearestFrameRate(preset.fps, rates) ?? preset.fps;
    final next = PreviewPreset(width: preset.width, height: preset.height, fps: fps);
    if (seen.add(next.id)) {
      out.add(next);
    }
  }
  return out;
}

int? _asPositiveInt(Object? value) {
  if (value is int && value > 0) {
    return value;
  }
  if (value is num && value > 0) {
    return value.round();
  }
  return null;
}

int? _nearestFrameRate(int wanted, List<int> rates) {
  if (rates.isEmpty) {
    return null;
  }
  if (rates.contains(wanted)) {
    return wanted;
  }
  return rates.reduce((best, fps) {
    final dBest = (best - wanted).abs();
    final dFps = (fps - wanted).abs();
    return dFps < dBest ? fps : best;
  });
}

/// Preview gesture zoom limits (UI scale, not UVC digital zoom).
const previewZoomMin = 1.0;
const previewZoomMax = 8.0;

double clampPreviewZoom(double scale) {
  return scale.clamp(previewZoomMin, previewZoomMax).toDouble();
}

/// Keeps a pure formatter for unit tests; UI should prefer [AppLocalizations.previewStatus].
String formatPreviewLabel({
  required int width,
  required int height,
  required String format,
  required int fps,
}) {
  final fmt = format.toUpperCase();
  return '$width×$height · $fmt · ${fps}fps';
}
