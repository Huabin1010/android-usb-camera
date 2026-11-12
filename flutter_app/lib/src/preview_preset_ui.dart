import 'package:flutter/material.dart';

import 'camera_client.dart';
import 'camera_logic.dart';
import 'camera_snapshot.dart';
import 'l10n_ext.dart';
import 'preview_preset_controller.dart';
import 'theme.dart';

Future<void> applyPreviewPreset(CameraClient client, PreviewPreset preset) async {
  await client.selectResolution(preset.width, preset.height);
  await client.selectFps(preset.fps);
}

Future<void> showPreviewPresetManager({
  required BuildContext context,
  required CameraClient client,
  required PreviewPresetController presets,
}) {
  return showAppSheet<void>(
    context,
    title: context.l10n.presetManage,
    maxHeight: 0.82,
    builder: (ctx) => _PresetManageBody(client: client, presets: presets),
  );
}

Future<void> showCustomPreviewPicker({
  required BuildContext context,
  required CameraClient client,
  required PreviewPresetController presets,
}) {
  return showAppSheet<void>(
    context,
    title: context.l10n.presetCustom,
    maxHeight: 0.82,
    builder: (ctx) => _CustomPresetBody(client: client, presets: presets),
  );
}

class _PresetManageBody extends StatelessWidget {
  const _PresetManageBody({required this.client, required this.presets});

  final CameraClient client;
  final PreviewPresetController presets;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: Listenable.merge([client, presets]),
      builder: (context, _) {
        final snapshot = client.snapshot;
        final items = presets.items;
        return ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            SheetRow(
              title: l10n.presetAddCurrent,
              subtitle: snapshot.connection == 'opened'
                  ? PreviewPreset(
                      width: snapshot.previewWidth,
                      height: snapshot.previewHeight,
                      fps: snapshot.previewFps,
                    ).label
                  : null,
              leading: Icon(Icons.add_circle_outline, size: 18, color: C.fg68),
              chevron: false,
              onTap: snapshot.connection != 'opened'
                  ? null
                  : () async {
                      final preset = PreviewPreset(
                        width: snapshot.previewWidth,
                        height: snapshot.previewHeight,
                        fps: snapshot.previewFps,
                      );
                      final added = await presets.add(preset);
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(added ? l10n.presetAdded : l10n.presetExists)),
                      );
                    },
            ),
            SheetRow(
              title: l10n.presetAdd,
              leading: Icon(Icons.tune, size: 18, color: C.fg68),
              onTap: () => showCustomPreviewPicker(
                context: context,
                client: client,
                presets: presets,
              ),
            ),
            SheetRow(
              title: l10n.presetReset,
              leading: Icon(Icons.restart_alt, size: 18, color: C.fg68),
              chevron: false,
              onTap: presets.resetDefaults,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(l10n.previewPresets, style: T.section),
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(l10n.presetEmpty, style: T.small),
              )
            else
              for (final preset in items)
                SheetRow(
                  title: preset.label,
                  chevron: false,
                  trailing: Pressable(
                    onTap: () => presets.remove(preset.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: Text(l10n.presetDelete, style: TextStyle(fontSize: 13, color: C.error)),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _CustomPresetBody extends StatefulWidget {
  const _CustomPresetBody({required this.client, required this.presets});

  final CameraClient client;
  final PreviewPresetController presets;

  @override
  State<_CustomPresetBody> createState() => _CustomPresetBodyState();
}

class _CustomPresetBodyState extends State<_CustomPresetBody> {
  int? _width;
  int? _height;
  int? _fps;
  bool _save = true;

  @override
  void initState() {
    super.initState();
    final snapshot = widget.client.snapshot;
    _width = snapshot.previewWidth;
    _height = snapshot.previewHeight;
    _fps = snapshot.previewFps;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: widget.client,
      builder: (context, _) {
        final snapshot = widget.client.snapshot;
        final busy = snapshot.isRecording;
        final sizes = snapshot.resolutions;
        final rates = snapshot.frameRates;
        _width ??= sizes.isNotEmpty ? sizes.first.width : null;
        _height ??= sizes.isNotEmpty ? sizes.first.height : null;
        _fps ??= rates.contains(30)
            ? 30
            : (rates.isNotEmpty ? rates.first : null);
        return ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(l10n.presetPickResolution, style: T.section),
            ),
            if (sizes.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(l10n.resolutionsAfterConnect, style: T.small),
              )
            else
              for (final size in sizes)
                SheetRow(
                  title: size.label,
                  chevron: false,
                  trailing: _width == size.width && _height == size.height
                      ? Icon(Icons.check, size: 18, color: C.fg)
                      : null,
                  onTap: () => setState(() {
                        _width = size.width;
                        _height = size.height;
                      }),
                ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(l10n.presetPickFps, style: T.section),
            ),
            for (final fps in rates)
              SheetRow(
                title: l10n.fpsOption(fps),
                chevron: false,
                trailing: _fps == fps ? Icon(Icons.check, size: 18, color: C.fg) : null,
                onTap: () => setState(() => _fps = fps),
              ),
            SheetRow(
              title: l10n.presetSave,
              chevron: false,
              trailing: Switch(value: _save, onChanged: (value) => setState(() => _save = value)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Pressable(
                onTap: busy || _width == null || _height == null || _fps == null
                    ? null
                    : () async {
                        final preset = PreviewPreset(width: _width!, height: _height!, fps: _fps!);
                        await applyPreviewPreset(widget.client, preset);
                        if (_save) {
                          final added = await widget.presets.add(preset);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(added ? l10n.presetAdded : l10n.presetExists)),
                            );
                          }
                        }
                        if (context.mounted) {
                          Navigator.of(context).maybePop();
                        }
                      },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: C.surfaceHi,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: C.border),
                  ),
                  child: Text(l10n.presetApply, textAlign: TextAlign.center, style: T.row),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PreviewPresetSettingsSection extends StatelessWidget {
  const PreviewPresetSettingsSection({
    super.key,
    required this.client,
    required this.presets,
    required this.snapshot,
  });

  final CameraClient client;
  final PreviewPresetController presets;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: presets,
      builder: (context, _) {
        final items = presets.items;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(l10n.previewPresets, style: T.section),
            ),
            for (final preset in items.take(6))
              SheetRow(
                title: preset.label,
                chevron: false,
                trailing: Pressable(
                  onTap: () => presets.remove(preset.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Text(l10n.presetDelete, style: TextStyle(fontSize: 13, color: C.error)),
                  ),
                ),
              ),
            if (items.length > 6)
              SheetRow(
                title: '+${items.length - 6}',
                chevron: false,
              ),
            SheetRow(
              title: l10n.presetAddCurrent,
              chevron: false,
              onTap: snapshot.connection != 'opened'
                  ? null
                  : () async {
                      final added = await presets.add(
                        PreviewPreset(
                          width: snapshot.previewWidth,
                          height: snapshot.previewHeight,
                          fps: snapshot.previewFps,
                        ),
                      );
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(added ? l10n.presetAdded : l10n.presetExists)),
                      );
                    },
            ),
            SheetRow(
              title: l10n.presetManage,
              onTap: () => showPreviewPresetManager(
                context: context,
                client: client,
                presets: presets,
              ),
            ),
            SheetRow(
              title: l10n.presetReset,
              chevron: false,
              onTap: presets.resetDefaults,
            ),
          ],
        );
      },
    );
  }
}
