class UsbDeviceItem {
  const UsbDeviceItem({required this.id, required this.name, required this.summary});

  final int id;
  final String name;
  final String summary;
}

class ResolutionOption {
  const ResolutionOption({required this.width, required this.height});

  final int width;
  final int height;

  String get label => '$width×$height';
}

class CameraSnapshot {
  const CameraSnapshot({
    required this.connection,
    required this.deviceId,
    required this.message,
    required this.mode,
    required this.isRecording,
    required this.elapsedSeconds,
    required this.frameRate,
    required this.devices,
    required this.resolutions,
    required this.frameRates,
    required this.previewWidth,
    required this.previewHeight,
    required this.previewFps,
    required this.previewFormat,
    required this.audioSource,
    required this.rotate,
    required this.segmentMinutes,
    required this.imageValues,
    required this.imageSupported,
    required this.autoFocus,
    required this.autoFocusSupported,
    required this.autoWhiteBalance,
    required this.autoWhiteBalanceSupported,
    required this.micOn,
    required this.filterId,
    required this.animationId,
    required this.snackbar,
  });

  const CameraSnapshot.empty()
      : connection = 'closed',
        deviceId = null,
        message = null,
        mode = 'photo',
        isRecording = false,
        elapsedSeconds = 0,
        frameRate = 0,
        devices = const [],
        resolutions = const [],
        frameRates = const [15, 24, 30, 60],
        previewWidth = 640,
        previewHeight = 480,
        previewFps = 30,
        previewFormat = 'mjpeg',
        audioSource = 'system',
        rotate = 'ANGLE_0',
        segmentMinutes = 0,
        imageValues = const {},
        imageSupported = const [],
        autoFocus = false,
        autoFocusSupported = false,
        autoWhiteBalance = false,
        autoWhiteBalanceSupported = false,
        micOn = false,
        filterId = -1,
        animationId = -2,
        snackbar = null;

  final String connection;
  final int? deviceId;
  final String? message;
  final String mode;
  final bool isRecording;
  final int elapsedSeconds;
  final int frameRate;
  final List<UsbDeviceItem> devices;
  final List<ResolutionOption> resolutions;
  final List<int> frameRates;
  final int previewWidth;
  final int previewHeight;
  final int previewFps;
  final String previewFormat;
  final String audioSource;
  final String rotate;
  final int segmentMinutes;
  final Map<String, int> imageValues;
  final List<String> imageSupported;
  final bool autoFocus;
  final bool autoFocusSupported;
  final bool autoWhiteBalance;
  final bool autoWhiteBalanceSupported;
  final bool micOn;
  final int filterId;
  final int animationId;
  final String? snackbar;

  factory CameraSnapshot.fromMap(Map<Object?, Object?> raw) {
    return CameraSnapshot(
      connection: raw['connection'] as String? ?? 'closed',
      deviceId: raw['deviceId'] is num ? (raw['deviceId'] as num).toInt() : null,
      message: raw['message'] as String?,
      mode: raw['mode'] as String? ?? 'photo',
      isRecording: raw['isRecording'] == true,
      elapsedSeconds: _asInt(raw['elapsedSeconds']),
      frameRate: _asInt(raw['frameRate']),
      devices: _maps(raw['devices']).map((item) {
        return UsbDeviceItem(
          id: _asInt(item['id']),
          name: item['name'] as String? ?? '',
          summary: item['summary'] as String? ?? '',
        );
      }).toList(),
      resolutions: _maps(raw['resolutions']).map((item) {
        return ResolutionOption(width: _asInt(item['width']), height: _asInt(item['height']));
      }).toList(),
      frameRates: _ints(raw['frameRates']).isEmpty ? const [15, 24, 30, 60] : _ints(raw['frameRates']),
      previewWidth: _asInt(raw['previewWidth'], 640),
      previewHeight: _asInt(raw['previewHeight'], 480),
      previewFps: _asInt(raw['previewFps'], 30),
      previewFormat: raw['previewFormat'] as String? ?? 'mjpeg',
      audioSource: raw['audioSource'] as String? ?? 'system',
      rotate: raw['rotate'] as String? ?? 'ANGLE_0',
      segmentMinutes: _asInt(raw['segmentMinutes']),
      imageValues: _intMap(raw['imageValues']),
      imageSupported: _strings(raw['imageSupported']),
      autoFocus: raw['autoFocus'] == true,
      autoFocusSupported: raw['autoFocusSupported'] == true,
      autoWhiteBalance: raw['autoWhiteBalance'] == true,
      autoWhiteBalanceSupported: raw['autoWhiteBalanceSupported'] == true,
      micOn: raw['micOn'] == true,
      filterId: _asInt(raw['filterId'], -1),
      animationId: _asInt(raw['animationId'], -2),
      snackbar: raw['snackbar'] as String?,
    );
  }
}

int _asInt(Object? value, [int fallback = 0]) {
  return value is num ? value.toInt() : fallback;
}

List<Map<Object?, Object?>> _maps(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<Map>().map(Map<Object?, Object?>.from).toList();
}

List<String> _strings(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<String>().toList();
}

List<int> _ints(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<num>().map((item) => item.toInt()).toList();
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) {
    return const {};
  }
  return value.map((key, item) => MapEntry('$key', _asInt(item)));
}
