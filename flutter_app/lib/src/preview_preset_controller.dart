import 'package:flutter/foundation.dart';

import 'camera_logic.dart';
import 'user_prefs.dart';

class PreviewPresetController extends ChangeNotifier {
  PreviewPresetController(this._prefs) : _items = List<PreviewPreset>.of(_prefs.previewPresets);

  final UserPrefs _prefs;
  List<PreviewPreset> _items;

  List<PreviewPreset> get items => List.unmodifiable(_items);

  Future<void> replaceAll(List<PreviewPreset> next) async {
    final normalized = _normalize(next);
    if (listEquals(normalized, _items)) {
      return;
    }
    _items = normalized.isEmpty ? List<PreviewPreset>.of(defaultPreviewPresets) : normalized;
    await _prefs.setPreviewPresets(_items);
    notifyListeners();
  }

  Future<bool> add(PreviewPreset preset) async {
    if (_items.any((item) => item.id == preset.id)) {
      return false;
    }
    await replaceAll([..._items, preset]);
    return true;
  }

  Future<void> remove(String id) async {
    final next = _items.where((item) => item.id != id).toList();
    if (next.length == _items.length) {
      return;
    }
    await replaceAll(next);
  }

  Future<void> resetDefaults() => replaceAll(defaultPreviewPresets);

  List<PreviewPreset> _normalize(Iterable<PreviewPreset> source) {
    final out = <PreviewPreset>[];
    final seen = <String>{};
    for (final preset in source) {
      if (preset.width <= 0 || preset.height <= 0 || preset.fps <= 0) {
        continue;
      }
      if (seen.add(preset.id)) {
        out.add(preset);
      }
    }
    return out;
  }
}
