import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'camera_snapshot.dart';

class CameraClient extends ChangeNotifier {
  CameraClient({MethodChannel? camera, EventChannel? events, MethodChannel? host})
      : _camera = camera ?? const MethodChannel('com.jiangdg.ausbc/camera'),
        _events = events ?? const EventChannel('com.jiangdg.ausbc/events'),
        _host = host ?? const MethodChannel('com.jiangdg.ausbc/host');

  final MethodChannel _camera;
  final EventChannel _events;
  final MethodChannel _host;
  StreamSubscription<dynamic>? _subscription;
  CameraSnapshot snapshot = const CameraSnapshot.empty();

  Future<bool> ensurePermissions() async {
    final granted = await _host.invokeMethod<bool>('ensurePermissions');
    return granted == true;
  }

  void listen() {
    _subscription ??= _events.receiveBroadcastStream().listen((event) {
      if (event is! Map) {
        return;
      }
      snapshot = CameraSnapshot.fromMap(Map<Object?, Object?>.from(event));
      notifyListeners();
    });
  }

  Future<void> selectDevice(int id) => _call('selectDevice', {'id': id});

  Future<void> selectMode(String mode) => _call('selectMode', {'mode': mode});

  Future<void> shutter() => _call('shutter');

  Future<void> selectResolution(int width, int height) {
    return _call('selectResolution', {'width': width, 'height': height});
  }

  Future<void> selectFps(int fps) => _call('selectFps', {'fps': fps});

  Future<void> selectFormat(String format) => _call('selectFormat', {'format': format});

  Future<void> selectRotate(String rotate) => _call('selectRotate', {'rotate': rotate});

  Future<void> selectAudio(String source) => _call('selectAudio', {'source': source});

  Future<void> selectSegment(int minutes) => _call('selectSegment', {'minutes': minutes});

  Future<void> setImage(String key, int value) => _call('setImage', {'key': key, 'value': value});

  Future<void> setAutoFocus(bool enabled) => _call('setAutoFocus', {'enabled': enabled});

  Future<void> setAutoWhiteBalance(bool enabled) => _call('setAutoWhiteBalance', {'enabled': enabled});

  Future<void> resetImage() => _call('resetImage');

  Future<void> toggleMic() => _call('toggleMic');

  Future<void> applyEffect(String kind, int id) => _call('applyEffect', {'kind': kind, 'id': id});

  Future<void> retry() => _call('retry');

  Future<void> setSurfaceSize(int width, int height) {
    return _call('setSurfaceSize', {'width': width, 'height': height});
  }

  Future<void> _call(String method, [Map<String, Object?>? args]) async {
    try {
      await _camera.invokeMethod<void>(method, args);
    } on PlatformException {
      // The preview view registers the session. A tap before that is ignored.
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
