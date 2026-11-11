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
  String? _section;
  String? _lastSnackbar;

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

  void _toggle(String section) {
    setState(() => _section = _section == section ? null : section);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Row(
          children: [
            _Rail(
              selected: _section,
              onSelect: _toggle,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final short = constraints.maxHeight < 520;
                  final reserve = short ? 112.0 : captureBarReserve;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      const _Preview(),
                      _ConnectionMessage(client: widget.client),
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
                      _StatusCluster(client: widget.client),
                      _CaptureBar(client: widget.client, compact: short),
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

class _SidePanel extends StatefulWidget {
  const _SidePanel({required this.open, required this.width, required this.bottomReserve, required this.child});

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
      top: 8,
      bottom: widget.bottomReserve,
      width: widget.width * t,
      child: IgnorePointer(
        ignoring: t == 0,
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: widget.width,
            maxWidth: widget.width,
            child: Transform.translate(
              offset: Offset((t - 1) * 28, 0),
              child: Opacity(
                opacity: t,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: C.surface,
                    border: Border(right: BorderSide(color: C.border)),
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
  const _Rail({required this.selected, required this.onSelect});

  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: C.bg,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const _BrandMark(),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _RailButton(id: 'devices', icon: Icons.usb, tooltip: '设备', selected: selected, onSelect: onSelect),
                  _RailButton(id: 'picture', icon: Icons.tune, tooltip: '画面', selected: selected, onSelect: onSelect),
                  _RailButton(id: 'video', icon: Icons.aspect_ratio, tooltip: '视频', selected: selected, onSelect: onSelect),
                  _RailButton(id: 'effects', icon: Icons.photo_filter, tooltip: '效果', selected: selected, onSelect: onSelect),
                  _RailButton(id: 'audio', icon: Icons.graphic_eq, tooltip: '音频', selected: selected, onSelect: onSelect),
                ],
              ),
            ),
            _RailButton(id: 'settings', icon: Icons.settings, tooltip: '设置', selected: selected, onSelect: onSelect),
            _RailButton(id: 'about', icon: Icons.info_outline, tooltip: '关于', selected: selected, onSelect: onSelect),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/brand/ic_launcher.svg', width: 36, height: 36);
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
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: () => onSelect(id),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: AnimatedContainer(
            duration: revealDuration,
            curve: Curves.linear,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active ? C.surfaceHi : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: active ? C.fg : C.fg48),
          ),
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
    return DecoratedBox(
      decoration: const BoxDecoration(color: C.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _title(section),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: C.fg),
                  ),
                ),
                Pressable(
                  onTap: onClose,
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(Icons.close, size: 18, color: C.fg68),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: client,
              builder: (context, _) => _body(context, client.snapshot),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, CameraSnapshot snapshot) {
    return switch (section) {
      'devices' => _DeviceList(client: client, snapshot: snapshot),
      'picture' => _PictureList(client: client, snapshot: snapshot),
      'video' => _VideoList(client: client, snapshot: snapshot),
      'effects' => _EffectList(client: client, snapshot: snapshot),
      'audio' => _AudioList(client: client, snapshot: snapshot),
      'settings' => _SettingsList(client: client, snapshot: snapshot),
      _ => const _AboutPanel(),
    };
  }
}

String _title(String section) {
  return switch (section) {
    'devices' => '设备',
    'picture' => '画面',
    'video' => '视频',
    'effects' => '效果',
    'audio' => '音频',
    'settings' => '设置',
    _ => '关于',
  };
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        SvgPicture.asset(
          'assets/brand/ic_launcher.svg',
          width: 96,
          height: 96,
        ),
        const SizedBox(height: 16),
        Text('USB 摄像头', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: C.fg)),
        const SizedBox(height: 8),
        const Text(
          'Flutter 界面，相机引擎沿用参考工程 libausbc。\n765067602@qq.com',
          style: TextStyle(fontSize: 14, height: 1.45, color: C.fg68),
        ),
      ],
    );
  }
}

class _DeviceList extends StatelessWidget {
  const _DeviceList({required this.client, required this.snapshot});

  final CameraClient client;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.devices.isEmpty) {
      return Center(
        child: FilledButton.tonal(onPressed: client.retry, child: const Text('重试')),
      );
    }
    return RadioGroup<int>(
      groupValue: snapshot.deviceId,
      onChanged: (id) {
        if (id != null) {
          client.selectDevice(id);
        }
      },
      child: ListView(
        children: [
          for (final device in snapshot.devices)
            RadioListTile<int>(
              value: device.id,
              title: Text(device.name),
              subtitle: Text(device.summary),
            ),
        ],
      ),
    );
  }
}

class _PictureList extends StatelessWidget {
  const _PictureList({required this.client, required this.snapshot});

  final CameraClient client;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        if (snapshot.autoFocusSupported)
          SwitchListTile(
            title: const Text('自动对焦'),
            value: snapshot.autoFocus,
            onChanged: client.setAutoFocus,
          ),
        if (snapshot.autoWhiteBalanceSupported)
          SwitchListTile(
            title: const Text('自动白平衡'),
            value: snapshot.autoWhiteBalance,
            onChanged: client.setAutoWhiteBalance,
          ),
        for (final key in snapshot.imageSupported)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(imageLabels[key] ?? key),
                Slider(
                  value: (snapshot.imageValues[key] ?? 50).clamp(0, 100).toDouble(),
                  max: 100,
                  onChanged: (value) => client.setImage(key, value.round()),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(onPressed: client.resetImage, child: const Text('恢复默认')),
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
      children: [
        const ListTile(title: Text('格式')),
        RadioGroup<String>(
          groupValue: snapshot.previewFormat,
          onChanged: (value) {
            if (!busy && value != null) {
              client.selectFormat(value);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              RadioListTile<String>(value: 'mjpeg', title: Text('MJPEG')),
              RadioListTile<String>(value: 'yuyv', title: Text('YUYV')),
            ],
          ),
        ),
        const ListTile(title: Text('方向')),
        RadioGroup<String>(
          groupValue: snapshot.rotate,
          onChanged: (value) {
            if (value != null) {
              client.selectRotate(value);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in rotateOptions.entries)
                RadioListTile<String>(value: entry.key, title: Text(entry.value)),
            ],
          ),
        ),
        const ListTile(title: Text('分辨率')),
        RadioGroup<String>(
          groupValue: '${snapshot.previewWidth}×${snapshot.previewHeight}',
          onChanged: (value) {
            if (busy || value == null) {
              return;
            }
            for (final size in snapshot.resolutions) {
              if (size.label == value) {
                client.selectResolution(size.width, size.height);
              }
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final size in snapshot.resolutions)
                RadioListTile<String>(value: size.label, title: Text(size.label)),
            ],
          ),
        ),
      ],
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
      children: [
        const ListTile(title: Text('滤镜')),
        _choice(context, '无', snapshot.filterId == -1, () => client.applyEffect('filter', -1)),
        _choice(context, '黑白', snapshot.filterId == 100, () => client.applyEffect('filter', 100)),
        const ListTile(title: Text('动画')),
        _choice(context, '无', snapshot.animationId == -2, () => client.applyEffect('animation', -2)),
        _choice(context, '灵魂', snapshot.animationId == 200, () => client.applyEffect('animation', 200)),
        _choice(context, '缩放', snapshot.animationId == 300, () => client.applyEffect('animation', 300)),
      ],
    );
  }

  Widget _choice(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return ListTile(
      selected: selected,
      title: Text(label),
      trailing: selected ? const Icon(Icons.check) : null,
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
      children: [
        RadioGroup<String>(
          groupValue: snapshot.audioSource,
          onChanged: (value) {
            if (!busy && value != null) {
              client.selectAudio(value);
            }
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(value: 'system', title: Text('系统麦克风')),
              RadioListTile<String>(value: 'device', title: Text('设备麦克风')),
              RadioListTile<String>(value: 'auto', title: Text('自动')),
            ],
          ),
        ),
        SwitchListTile(
          title: const Text('监听麦克风'),
          value: snapshot.micOn,
          onChanged: (_) => client.toggleMic(),
        ),
      ],
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
      children: [
        const ListTile(
          title: Text('多路预览'),
          subtitle: Text('多路网格仍在参考工程的 Android 界面里。Flutter 版先提供单路预览。'),
        ),
        const ListTile(title: Text('分段时长')),
        RadioGroup<int>(
          groupValue: snapshot.segmentMinutes,
          onChanged: (value) {
            if (!snapshot.isRecording && value != null) {
              client.selectSegment(value);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final minutes in segmentOptions)
                RadioListTile<int>(
                  value: minutes,
                  title: Text(minutes == 0 ? '不分段' : '$minutes 分钟'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusCluster extends StatelessWidget {
  const _StatusCluster({required this.client});

  final CameraClient client;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: client,
      builder: (context, _) {
        final snapshot = client.snapshot;
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${snapshot.frameRate} FPS', style: const TextStyle(fontSize: 13, color: C.fg68)),
                if (snapshot.isRecording)
                  Text(
                    formatElapsed(snapshot.elapsedSeconds),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: C.error),
                  ),
              ],
            ),
          ),
        );
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
                        _ModeChip(
                          label: '拍照',
                          icon: Icons.photo_camera,
                          selected: snapshot.mode == 'photo',
                          enabled: !snapshot.isRecording,
                          onTap: () => client.selectMode('photo'),
                        ),
                        _ModeChip(
                          label: '录像',
                          icon: Icons.videocam,
                          selected: snapshot.mode == 'video',
                          enabled: !snapshot.isRecording,
                          onTap: () => client.selectMode('video'),
                        ),
                        _ModeChip(
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
                        border: Border.all(color: snapshot.isRecording ? C.error : C.fg30, width: 2),
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

class _ModeChip extends StatelessWidget {
  const _ModeChip({
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
    final color = !enabled ? C.fg30 : selected ? C.fg : C.fg48;
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
