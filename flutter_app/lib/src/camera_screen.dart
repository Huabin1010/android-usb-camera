import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'camera_client.dart';
import 'camera_logic.dart';
import 'camera_snapshot.dart';
import 'theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.client});

  final CameraClient client;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String _workspace = 'watch';
  String? _section;
  String? _lastSnackbar;
  bool _watchChrome = false;

  @override
  void initState() {
    super.initState();
    widget.client.addListener(_onCamera);
    widget.client.listen();
  }

  @override
  void dispose() {
    widget.client.removeListener(_onCamera);
    super.dispose();
  }

  void _onCamera() {
    final message = widget.client.snapshot.snackbar;
    if (message == null || message == _lastSnackbar || !mounted) {
      return;
    }
    _lastSnackbar = message;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _setWorkspace(String next) {
    final applied = switchWorkspace(
      current: _workspace,
      recording: widget.client.snapshot.isRecording,
      next: next,
    );
    if (applied == null) {
      if (widget.client.snapshot.isRecording && next != 'capture') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('录像或录音进行中，先停下来再切换模式')),
        );
      }
      return;
    }
    setState(() {
      _workspace = applied;
      _section = null;
      _watchChrome = false;
    });
  }

  void _toggle(String section) {
    setState(() => _section = _section == section ? null : section);
  }

  Future<void> _openWorkspaceSheet() async {
    final next = await showAppSheet<String>(
      context,
      title: '模式',
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          for (final id in workspaceModeIds)
            Semantics(
              button: true,
              label: workspaceLabel(id),
              child: SheetRow(
                leading: Icon(_workspaceIcon(id), size: 18, color: C.fg68),
                title: workspaceLabel(id),
                subtitle: workspaceHint(id),
                chevron: false,
                trailing: id == _workspace ? const Icon(Icons.check, size: 18, color: C.fg) : null,
                onTap: () => Navigator.of(ctx).pop(id),
              ),
            ),
        ],
      ),
    );
    if (next != null && mounted) {
      _setWorkspace(next);
    }
  }

  Future<void> _openDevicesSheet() async {
    await showAppSheet<void>(
      context,
      title: '设备',
      builder: (ctx) => ListenableBuilder(
        listenable: widget.client,
        builder: (context, _) {
          final snapshot = widget.client.snapshot;
          if (snapshot.devices.isEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('还没有 USB 摄像头', style: T.small),
                  const SizedBox(height: 14),
                  Pressable(
                    onTap: widget.client.retry,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: C.surfaceHi,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: C.border),
                      ),
                      child: const Text('重试', style: T.row),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 12),
            children: [
              for (final device in snapshot.devices)
                SheetRow(
                  leading: Icon(
                    Icons.usb,
                    size: 18,
                    color: device.id == snapshot.deviceId ? C.blue2 : C.fg68,
                  ),
                  title: device.name,
                  subtitle: device.summary,
                  chevron: false,
                  trailing: device.id == snapshot.deviceId
                      ? const Icon(Icons.check, size: 18, color: C.fg)
                      : null,
                  onTap: () {
                    widget.client.selectDevice(device.id);
                    Navigator.of(ctx).maybePop();
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showRail = _workspace == 'tune';
    final showCapture = _workspace == 'capture';
    final showTopChrome = _workspace != 'watch' || _watchChrome;

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Row(
          children: [
            if (showRail)
              _Rail(
                selected: _section,
                onSelect: _toggle,
                showTools: _workspace == 'tune',
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final short = constraints.maxHeight < 520;
                  final reserve = showCapture ? (short ? 112.0 : captureBarReserve) : 72.0;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      const _Preview(),
                      _ConnectionMessage(client: widget.client),
                      if (_workspace == 'watch' && !_watchChrome)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => setState(() => _watchChrome = true),
                          ),
                        ),
                      if (_section != null)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => setState(() => _section = null),
                          ),
                        ),
                      _SidePanel(
                        open: _section != null,
                        width: overlayPanelWidth(constraints.maxWidth),
                        bottomReserve: reserve,
                        child: _section == null
                            ? const SizedBox.shrink()
                            : _Panel(
                                client: widget.client,
                                section: _section!,
                                onClose: () => setState(() => _section = null),
                              ),
                      ),
                      if (showTopChrome)
                        _TopChrome(
                          workspace: _workspace,
                          client: widget.client,
                          onOpenModes: _openWorkspaceSheet,
                          onOpenDevices: _openDevicesSheet,
                          onHideWatch: _workspace == 'watch'
                              ? () => setState(() {
                                    _watchChrome = false;
                                    _section = null;
                                  })
                              : null,
                        ),
                      if (!showTopChrome)
                        _StatusCluster(client: widget.client, soft: true),
                      if (showCapture) _CaptureBar(client: widget.client, compact: short),
                      if (_workspace == 'watch' && _watchChrome)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Pressable(
                              onTap: () => setState(() {
                                _watchChrome = false;
                                _section = null;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xCC1C1B18),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: C.border),
                                ),
                                child: const Text('隐藏控制', style: T.chip),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _workspaceIcon(String id) {
  return switch (id) {
    'capture' => Icons.photo_camera_outlined,
    'tune' => Icons.tune,
    _ => Icons.visibility_outlined,
  };
}

class _TopChrome extends StatelessWidget {
  const _TopChrome({
    required this.workspace,
    required this.client,
    required this.onOpenModes,
    required this.onOpenDevices,
    this.onHideWatch,
  });

  final String workspace;
  final CameraClient client;
  final VoidCallback onOpenModes;
  final VoidCallback onOpenDevices;
  final VoidCallback? onHideWatch;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: Row(
          children: [
            _WorkspaceChip(workspace: workspace, onTap: onOpenModes),
            const SizedBox(width: 8),
            CircleBtn(icon: Icons.usb, tooltip: '设备', onTap: onOpenDevices),
            if (onHideWatch != null) ...[
              const SizedBox(width: 8),
              CircleBtn(icon: Icons.visibility_off_outlined, tooltip: '隐藏控制', onTap: onHideWatch),
            ],
            const Spacer(),
            _StatusCluster(client: client),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceChip extends StatelessWidget {
  const _WorkspaceChip({required this.workspace, required this.onTap});

  final String workspace;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(9, 6, 7, 6),
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: StadiumBorder(side: BorderSide(color: C.border)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_workspaceIcon(workspace), size: 14, color: C.fg68),
            const SizedBox(width: 5),
            Text(workspaceLabel(workspace), style: T.chip),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more, size: 15, color: C.fg68),
          ],
        ),
      ),
    );
  }
}

class _SidePanel extends StatefulWidget {
  const _SidePanel({
    required this.open,
    required this.width,
    required this.bottomReserve,
    required this.child,
  });

  final bool open;
  final double width;
  final double bottomReserve;
  final Widget child;

  @override
  State<_SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<_SidePanel> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: panelDuration,
    value: widget.open ? 1 : 0,
  );
  Widget? _shown;

  @override
  void initState() {
    super.initState();
    _shown = widget.child;
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(_SidePanel old) {
    super.didUpdateWidget(old);
    if (widget.open) {
      _shown = widget.child;
    }
    if (old.open == widget.open) {
      return;
    }
    if (widget.open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeOutCubic.transform(_controller.value);
    return Positioned(
      left: 8,
      top: 56,
      bottom: widget.bottomReserve,
      width: widget.width * t,
      child: IgnorePointer(
        ignoring: t == 0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: widget.width,
            maxWidth: widget.width,
            child: Transform.translate(
              offset: Offset((t - 1) * 24, 0),
              child: Opacity(
                opacity: t,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: C.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: C.border),
                  ),
                  child: _shown ?? widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: 'ausbc-preview',
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        final view = PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: 'ausbc-preview',
          layoutDirection: TextDirection.ltr,
          creationParams: const <String, dynamic>{},
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () => params.onFocusChanged(true),
        );
        view.addOnPlatformViewCreatedListener(params.onPlatformViewCreated);
        view.create();
        return view;
      },
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.selected, required this.onSelect, required this.showTools});

  final String? selected;
  final ValueChanged<String> onSelect;
  final bool showTools;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: C.bg,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            const SizedBox(height: 10),
            SvgPicture.asset('assets/brand/ic_launcher.svg', width: 32, height: 32),
            const SizedBox(height: 8),
            if (showTools)
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _RailButton(id: 'picture', icon: Icons.tune, tooltip: '画面', selected: selected, onSelect: onSelect),
                    _RailButton(id: 'video', icon: Icons.aspect_ratio, tooltip: '视频', selected: selected, onSelect: onSelect),
                    _RailButton(id: 'effects', icon: Icons.auto_awesome_outlined, tooltip: '效果', selected: selected, onSelect: onSelect),
                    _RailButton(id: 'audio', icon: Icons.graphic_eq, tooltip: '音频', selected: selected, onSelect: onSelect),
                  ],
                ),
              )
            else
              const Spacer(),
            _RailButton(id: 'settings', icon: Icons.settings_outlined, tooltip: '设置', selected: selected, onSelect: onSelect),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.id,
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onSelect,
  });

  final String id;
  final IconData icon;
  final String tooltip;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final active = selected == id;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: CircleBtn(
          icon: icon,
          tooltip: tooltip,
          active: active,
          onTap: () => onSelect(id),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.client, required this.section, required this.onClose});

  final CameraClient client;
  final String section;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 6, 0),
          child: Row(
            children: [
              Expanded(child: Text(_title(section), style: T.sheetTitle)),
              IconButton(
                tooltip: '关闭',
                visualDensity: VisualDensity.compact,
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 18, color: C.fg48),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: client,
            builder: (context, _) => _body(client.snapshot),
          ),
        ),
      ],
    );
  }

  Widget _body(CameraSnapshot snapshot) {
    return switch (section) {
      'picture' => _PictureList(client: client, snapshot: snapshot),
      'video' => _VideoList(client: client, snapshot: snapshot),
      'effects' => _EffectList(client: client, snapshot: snapshot),
      'audio' => _AudioList(client: client, snapshot: snapshot),
      _ => _SettingsList(client: client, snapshot: snapshot),
    };
  }
}

String _title(String section) {
  return switch (section) {
    'picture' => '画面',
    'video' => '视频',
    'effects' => '效果',
    'audio' => '音频',
    _ => '设置',
  };
}

class _PictureList extends StatelessWidget {
  const _PictureList({required this.client, required this.snapshot});

  final CameraClient client;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      children: [
        if (snapshot.autoFocusSupported)
          SheetRow(
            title: '自动对焦',
            chevron: false,
            trailing: Switch(value: snapshot.autoFocus, onChanged: client.setAutoFocus),
          ),
        if (snapshot.autoWhiteBalanceSupported)
          SheetRow(
            title: '自动白平衡',
            chevron: false,
            trailing: Switch(value: snapshot.autoWhiteBalance, onChanged: client.setAutoWhiteBalance),
          ),
        for (final key in snapshot.imageSupported) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(imageLabels[key] ?? key, style: T.section),
          ),
          Slider(
            value: (snapshot.imageValues[key] ?? 50).clamp(0, 100).toDouble(),
            max: 100,
            onChanged: (value) => client.setImage(key, value.round()),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Pressable(
              onTap: client.resetImage,
              child: const Text('恢复默认', style: TextStyle(fontSize: 14, color: C.blue2)),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoList extends StatelessWidget {
  const _VideoList({required this.client, required this.snapshot});

  final CameraClient client;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final busy = snapshot.isRecording;
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text('格式', style: T.section)),
        _choice('MJPEG', snapshot.previewFormat == 'mjpeg', busy ? null : () => client.selectFormat('mjpeg')),
        _choice('YUYV', snapshot.previewFormat == 'yuyv', busy ? null : () => client.selectFormat('yuyv')),
        const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('方向', style: T.section)),
        for (final entry in rotateOptions.entries)
          _choice(entry.value, snapshot.rotate == entry.key, () => client.selectRotate(entry.key)),
        const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('分辨率', style: T.section)),
        if (snapshot.resolutions.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('接入设备后显示', style: T.small),
          )
        else
          for (final size in snapshot.resolutions)
            _choice(
              size.label,
              snapshot.previewWidth == size.width && snapshot.previewHeight == size.height,
              busy ? null : () => client.selectResolution(size.width, size.height),
            ),
      ],
    );
  }

  Widget _choice(String label, bool selected, VoidCallback? onTap) {
    return SheetRow(
      title: label,
      chevron: false,
      trailing: selected ? const Icon(Icons.check, size: 18, color: C.fg) : null,
      onTap: onTap,
    );
  }
}

class _EffectList extends StatelessWidget {
  const _EffectList({required this.client, required this.snapshot});

  final CameraClient client;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text('滤镜', style: T.section)),
        _choice('无', snapshot.filterId == -1, () => client.applyEffect('filter', -1)),
        _choice('黑白', snapshot.filterId == 100, () => client.applyEffect('filter', 100)),
        const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('动画', style: T.section)),
        _choice('无', snapshot.animationId == -2, () => client.applyEffect('animation', -2)),
        _choice('灵魂', snapshot.animationId == 200, () => client.applyEffect('animation', 200)),
        _choice('缩放', snapshot.animationId == 300, () => client.applyEffect('animation', 300)),
      ],
    );
  }

  Widget _choice(String label, bool selected, VoidCallback onTap) {
    return SheetRow(
      title: label,
      chevron: false,
      trailing: selected ? const Icon(Icons.check, size: 18, color: C.fg) : null,
      onTap: onTap,
    );
  }
}

class _AudioList extends StatelessWidget {
  const _AudioList({required this.client, required this.snapshot});

  final CameraClient client;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final busy = snapshot.isRecording;
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text('音源', style: T.section)),
        _choice('系统麦克风', snapshot.audioSource == 'system', busy ? null : () => client.selectAudio('system')),
        _choice('设备麦克风', snapshot.audioSource == 'device', busy ? null : () => client.selectAudio('device')),
        _choice('自动', snapshot.audioSource == 'auto', busy ? null : () => client.selectAudio('auto')),
        SheetRow(
          title: '监听麦克风',
          chevron: false,
          trailing: Switch(value: snapshot.micOn, onChanged: (_) => client.toggleMic()),
        ),
      ],
    );
  }

  Widget _choice(String label, bool selected, VoidCallback? onTap) {
    return SheetRow(
      title: label,
      chevron: false,
      trailing: selected ? const Icon(Icons.check, size: 18, color: C.fg) : null,
      onTap: onTap,
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({required this.client, required this.snapshot});

  final CameraClient client;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        const SheetRow(
          title: '多路预览',
          subtitle: '多路网格仍在参考工程的 Android 界面里。Flutter 版先提供单路预览。',
          chevron: false,
        ),
        const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('分段时长', style: T.section)),
        for (final minutes in segmentOptions)
          SheetRow(
            title: minutes == 0 ? '不分段' : '$minutes 分钟',
            chevron: false,
            trailing: snapshot.segmentMinutes == minutes ? const Icon(Icons.check, size: 18, color: C.fg) : null,
            onTap: snapshot.isRecording ? null : () => client.selectSegment(minutes),
          ),
      ],
    );
  }
}

class _StatusCluster extends StatelessWidget {
  const _StatusCluster({required this.client, this.soft = false});

  final CameraClient client;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: client,
      builder: (context, _) {
        final snapshot = client.snapshot;
        final child = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${snapshot.frameRate} FPS', style: TextStyle(fontSize: 13, color: soft ? C.fg42 : C.fg68)),
            if (snapshot.isRecording)
              Text(
                formatElapsed(snapshot.elapsedSeconds),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: C.error),
              ),
          ],
        );
        if (soft) {
          return Align(
            alignment: Alignment.topRight,
            child: Padding(padding: const EdgeInsets.all(14), child: child),
          );
        }
        return child;
      },
    );
  }
}

class _ConnectionMessage extends StatelessWidget {
  const _ConnectionMessage({required this.client});

  final CameraClient client;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: client,
      builder: (context, _) {
        final snapshot = client.snapshot;
        if (snapshot.connection == 'opened') {
          return const SizedBox.shrink();
        }
        final text = snapshot.connection == 'error' ? (snapshot.message ?? '相机打开失败') : '等待 USB 摄像头';
        return Center(child: Text(text, style: const TextStyle(fontSize: 15, color: C.fg68)));
      },
    );
  }
}

class _CaptureBar extends StatelessWidget {
  const _CaptureBar({required this.client, required this.compact});

  final CameraClient client;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: client,
      builder: (context, _) {
        final snapshot = client.snapshot;
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, compact ? 12 : 24),
            child: Flex(
              direction: compact ? Axis.horizontal : Axis.vertical,
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xCC1C1B18),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: C.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CaptureChip(
                          label: '拍照',
                          icon: Icons.photo_camera,
                          selected: snapshot.mode == 'photo',
                          enabled: !snapshot.isRecording,
                          onTap: () => client.selectMode('photo'),
                        ),
                        _CaptureChip(
                          label: '录像',
                          icon: Icons.videocam,
                          selected: snapshot.mode == 'video',
                          enabled: !snapshot.isRecording,
                          onTap: () => client.selectMode('video'),
                        ),
                        _CaptureChip(
                          label: '录音',
                          icon: Icons.mic,
                          selected: snapshot.mode == 'audio',
                          enabled: !snapshot.isRecording,
                          onTap: () => client.selectMode('audio'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: compact ? 16 : 0, height: compact ? 0 : 16),
                Pressable(
                  onTap: client.shutter,
                  child: Semantics(
                    button: true,
                    label: '快门',
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: C.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: snapshot.isRecording ? C.error : C.fg30, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: revealDuration,
                        curve: Curves.linear,
                        width: snapshot.isRecording ? 26 : 52,
                        height: snapshot.isRecording ? 26 : 52,
                        decoration: BoxDecoration(
                          color: snapshot.mode == 'photo' ? C.fg : C.error,
                          borderRadius: BorderRadius.circular(snapshot.isRecording ? 6 : 26),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CaptureChip extends StatelessWidget {
  const _CaptureChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? C.fg30
        : selected
            ? C.fg
            : C.fg48;
    return Pressable(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: revealDuration,
        curve: Curves.linear,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? C.surfaceHi : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }
}
