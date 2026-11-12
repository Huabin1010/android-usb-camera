import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_info.dart';
import 'camera_client.dart';
import 'camera_logic.dart';
import 'camera_snapshot.dart';
import 'hold_menu.dart';
import 'l10n_ext.dart';
import 'locale_controller.dart';
import 'preview_preset_controller.dart';
import 'preview_preset_ui.dart';
import 'theme.dart';
import 'theme_controller.dart';
import 'user_prefs.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.client,
    required this.prefs,
    required this.locales,
    required this.themes,
    required this.presets,
  });

  final CameraClient client;
  final UserPrefs prefs;
  final LocaleController locales;
  final ThemeController themes;
  final PreviewPresetController presets;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late String _workspace = widget.prefs.workspace;
  String? _section;
  String? _lastSnackbar;
  bool _watchChrome = false;
  bool _drawerOpen = false;

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
    final text = context.l10n.platformMessage(message, fallback: context.l10n.msgCameraError);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _setWorkspace(String next) async {
    final applied = switchWorkspace(
      current: _workspace,
      recording: widget.client.snapshot.isRecording,
      next: next,
    );
    if (applied == null) {
      if (widget.client.snapshot.isRecording && next != 'capture') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.recordingBlocksMode)),
        );
      }
      return;
    }
    setState(() {
      _workspace = applied;
      _section = null;
      _drawerOpen = false;
      _watchChrome = false;
    });
    await widget.prefs.setWorkspace(applied);
  }

  void _toggleDrawer() {
    setState(() {
      _drawerOpen = !_drawerOpen;
      if (!_drawerOpen) {
        _section = null;
      }
    });
  }

  void _closeDrawer() {
    if (!_drawerOpen && _section == null) {
      return;
    }
    setState(() {
      _drawerOpen = false;
      _section = null;
    });
  }

  void _selectSection(String id) {
    setState(() {
      _drawerOpen = true;
      _section = _section == id ? null : id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showCapture = _workspace == 'capture';
    final showTopChrome = _workspace != 'watch' || _watchChrome;
    final canDrawer = _workspace == 'tune';
    final drawerOpen = canDrawer && _drawerOpen;
    final sectionOpen = canDrawer && _section != null;

    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final short = constraints.maxHeight < 520;
            final reserve = showCapture ? (short ? 112.0 : captureBarReserve) : 72.0;
            // 抽屉打开时面板紧挨轨道；用 left/right 约束，避免宽度算多撑出屏幕。
            final panelLeft = drawerOpen ? drawerRailWidth + 16 : 8.0;
            const panelRight = 0.0;
            final panelWidth = overlayPanelWidth(constraints.maxWidth - panelLeft - panelRight);
            final panelMaxHeight = (constraints.maxHeight - 56 - reserve).clamp(160.0, constraints.maxHeight);
            return Stack(
              fit: StackFit.expand,
              children: [
                _Preview(
                  client: widget.client,
                  onTap: _workspace == 'watch' && !_watchChrome
                      ? () => setState(() => _watchChrome = true)
                      : null,
                ),
                _ConnectionMessage(client: widget.client),
                if (drawerOpen || sectionOpen)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _closeDrawer,
                    ),
                  ),
                if (showTopChrome)
                  _TopChrome(
                    workspace: _workspace,
                    client: widget.client,
                    presets: widget.presets,
                    onSelectWorkspace: _setWorkspace,
                    showDrawerToggle: canDrawer,
                    drawerOpen: drawerOpen,
                    onToggleDrawer: _toggleDrawer,
                    onHideWatch: _workspace == 'watch'
                        ? () => setState(() {
                              _watchChrome = false;
                              _drawerOpen = false;
                              _section = null;
                            })
                        : null,
                  ),
                if (!showTopChrome)
                  _StatusCluster(client: widget.client, soft: true),
                // 抽屉/侧栏叠在分辨率入口之上，避免被盖住；顶栏芯片仍可点。
                if (canDrawer)
                  _DrawerRail(
                    open: drawerOpen,
                    selected: _section,
                    onSelect: _selectSection,
                  ),
                _SidePanel(
                  open: sectionOpen,
                  left: panelLeft,
                  right: panelRight,
                  width: panelWidth,
                  maxHeight: panelMaxHeight,
                  child: sectionOpen
                      ? _Panel(
                          client: widget.client,
                          locales: widget.locales,
                          presets: widget.presets,
                          themes: widget.themes,
                          section: _section!,
                          onClose: () => setState(() => _section = null),
                        )
                      : const SizedBox.shrink(),
                ),
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
                          _drawerOpen = false;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: C.chromeScrim,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: C.border),
                          ),
                          child: Text(context.l10n.hideControls, style: T.chip),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
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
    required this.presets,
    required this.onSelectWorkspace,
    this.showDrawerToggle = false,
    this.drawerOpen = false,
    this.onToggleDrawer,
    this.onHideWatch,
  });

  final String workspace;
  final CameraClient client;
  final PreviewPresetController presets;
  final ValueChanged<String> onSelectWorkspace;
  final bool showDrawerToggle;
  final bool drawerOpen;
  final VoidCallback? onToggleDrawer;
  final VoidCallback? onHideWatch;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // 分辨率入口先画，模式/设备等芯片后画，避免下拉被盖住。
          Positioned(
            top: 54,
            left: 0,
            right: 0,
            child: Center(child: _PreviewStatusMenu(client: client, presets: presets)),
          ),
          Positioned(
            top: 10,
            left: 12,
            right: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (showDrawerToggle && onToggleDrawer != null)
                        CircleBtn(
                          icon: Icons.tune,
                          tooltip: context.l10n.tools,
                          active: drawerOpen,
                          onTap: onToggleDrawer,
                        ),
                      _WorkspaceChip(workspace: workspace, onSelect: onSelectWorkspace),
                      _DevicesChip(client: client),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _AudioChromeButton(client: client),
                if (onHideWatch != null) ...[
                  const SizedBox(width: 8),
                  CircleBtn(
                    icon: Icons.visibility_off_outlined,
                    tooltip: context.l10n.hideControls,
                    onTap: onHideWatch,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 首页右上角音频入口：点开展开音源与试听。
class _AudioChromeButton extends StatelessWidget {
  const _AudioChromeButton({required this.client});

  final CameraClient client;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: client,
      builder: (context, _) {
        final snapshot = client.snapshot;
        final busy = snapshot.isRecording;
        return Semantics(
          button: true,
          label: l10n.sectionAudio,
          child: HoldMenu(
            // 贴右上角展开：宽度收窄，避免被屏幕夹到左侧。
            width: 208,
            endAligned: true,
            header: l10n.audioSource,
            items: [
              HoldMenuItem(
                'system',
                l10n.micSystem,
                leading: Icon(Icons.mic_none_outlined, size: 16, color: C.fg68),
                checked: snapshot.audioSource == 'system',
                enabled: !busy,
              ),
              HoldMenuItem(
                'device',
                l10n.micDevice,
                leading: Icon(Icons.usb, size: 16, color: C.fg68),
                checked: snapshot.audioSource == 'device',
                enabled: !busy,
              ),
              HoldMenuItem(
                'auto',
                l10n.micAuto,
                leading: Icon(Icons.auto_mode_outlined, size: 16, color: C.fg68),
                checked: snapshot.audioSource == 'auto',
                enabled: !busy,
              ),
              HoldMenuItem(
                'mic',
                l10n.listenMic,
                leading: Icon(
                  snapshot.micOn ? Icons.hearing : Icons.hearing_disabled_outlined,
                  size: 16,
                  color: C.fg68,
                ),
                checked: snapshot.micOn,
                group: 1,
              ),
            ],
            onSelect: (id, _) {
              if (id == 'mic') {
                client.toggleMic();
                return;
              }
              client.selectAudio(id);
            },
            builder: (context, open, pressed) {
              final active = open || snapshot.micOn;
              return Tooltip(
                message: l10n.sectionAudio,
                child: Material(
                  color: active ? C.surfaceHi : C.surface,
                  shape: CircleBorder(side: BorderSide(color: C.border)),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.graphic_eq,
                      size: 18,
                      color: active ? C.fg : C.fg68,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

const _retryDeviceId = '__retry__';

List<HoldMenuItem> _deviceMenuItems(AppLocalizations l10n, CameraSnapshot snapshot) {
  if (snapshot.devices.isEmpty) {
    return [
      HoldMenuItem(
        _retryDeviceId,
        l10n.noUsbCamera,
        subtitle: l10n.retry,
        leading: Icon(Icons.refresh, size: 16, color: C.fg68),
        maxLines: 1,
      ),
    ];
  }
  return [
    for (final device in snapshot.devices)
      HoldMenuItem(
        '${device.id}',
        l10n.deviceDisplayName(device.name),
        subtitle: device.summary.isEmpty ? null : device.summary,
        leading: Icon(
          Icons.usb,
          size: 16,
          color: device.id == snapshot.deviceId ? C.blue2 : C.fg68,
        ),
        checked: device.id == snapshot.deviceId,
        maxLines: 1,
      ),
  ];
}

void _onDeviceMenuSelect(CameraClient client, String id) {
  if (id == _retryDeviceId) {
    client.retry();
    return;
  }
  final parsed = int.tryParse(id);
  if (parsed != null) {
    client.selectDevice(parsed);
  }
}

String _currentDeviceLabel(AppLocalizations l10n, CameraSnapshot snapshot) {
  if (snapshot.deviceId == null) {
    return l10n.devices;
  }
  for (final device in snapshot.devices) {
    if (device.id == snapshot.deviceId) {
      return l10n.deviceDisplayName(device.name);
    }
  }
  return l10n.devices;
}

class _DevicesChip extends StatelessWidget {
  const _DevicesChip({required this.client});

  final CameraClient client;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: client,
      builder: (context, _) {
        final snapshot = client.snapshot;
        final label = _currentDeviceLabel(l10n, snapshot);
        return Semantics(
          button: true,
          label: l10n.devices,
          child: HoldMenu(
            width: 280,
            header: l10n.devices,
            items: _deviceMenuItems(l10n, snapshot),
            onSelect: (id, _) => _onDeviceMenuSelect(client, id),
            builder: (context, open, pressed) {
              return _ChromeChipShell(
                open: open,
                maxWidth: 140,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.usb, size: 14, color: C.fg),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: T.chip.copyWith(color: C.fg, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 2),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(Icons.expand_more, size: 15, color: C.fg),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _WorkspaceChip extends StatelessWidget {
  const _WorkspaceChip({required this.workspace, required this.onSelect});

  final String workspace;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.mode,
      child: HoldMenu(
        width: 248,
        header: l10n.mode,
        items: [
          for (final id in workspaceModeIds)
            HoldMenuItem(
              id,
              l10n.workspaceLabel(id),
              subtitle: l10n.workspaceHint(id),
              leading: Icon(_workspaceIcon(id), size: 16, color: C.fg68),
              checked: id == workspace,
              maxLines: 1,
            ),
        ],
        onSelect: (id, _) => onSelect(id),
        builder: (context, open, pressed) {
          return _ChromeChipShell(
            open: open,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_workspaceIcon(workspace), size: 14, color: C.fg),
                const SizedBox(width: 5),
                Text(
                  l10n.workspaceLabel(workspace),
                  style: T.chip.copyWith(color: C.fg, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 2),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(Icons.expand_more, size: 15, color: C.fg),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 叠在预览上的顶栏 chip：用不透明底，避免浅色字/深色字贴在画面上发虚。
class _ChromeChipShell extends StatelessWidget {
  const _ChromeChipShell({
    required this.open,
    required this.child,
    this.maxWidth,
  });

  final bool open;
  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: maxWidth == null ? null : BoxConstraints(maxWidth: maxWidth!),
      padding: const EdgeInsets.fromLTRB(10, 7, 8, 7),
      decoration: ShapeDecoration(
        color: open ? C.surfaceHi : C.chromeScrim,
        shape: StadiumBorder(side: BorderSide(color: open ? C.fg42 : C.border)),
      ),
      child: child,
    );
  }
}

class _SidePanel extends StatefulWidget {
  const _SidePanel({
    required this.open,
    required this.width,
    required this.maxHeight,
    required this.child,
    this.left = 8,
    this.right = 0,
  });

  final bool open;
  final double width;
  final double maxHeight;
  final double left;
  final double right;
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
    const radius = BorderRadius.horizontal(left: Radius.circular(14));
    // left+right 锁在屏幕内；再按 t 从左侧裁剪展开，高度随内容封顶。
    return Positioned(
      left: widget.left,
      right: widget.right,
      top: 56,
      child: IgnorePointer(
        ignoring: t == 0,
        child: Opacity(
          opacity: t,
          child: ClipRect(
            child: Align(
              alignment: Alignment.topLeft,
              widthFactor: t == 0 ? 0.001 : t,
              heightFactor: 1,
              child: ClipRRect(
                borderRadius: radius,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.width,
                    maxHeight: widget.maxHeight,
                  ),
                  child: SizedBox(
                    width: widget.width,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: C.surface,
                        borderRadius: radius,
                        border: Border.all(color: C.border),
                      ),
                      child: _shown ?? widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Preview extends StatefulWidget {
  const _Preview({required this.client, this.onTap});

  final CameraClient client;
  final VoidCallback? onTap;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  late int _width = widget.client.snapshot.previewWidth;
  late int _height = widget.client.snapshot.previewHeight;
  late int _textureId = widget.client.snapshot.textureId;
  final TransformationController _zoom = TransformationController();
  int? _lastSurfaceW;
  int? _lastSurfaceH;

  @override
  void initState() {
    super.initState();
    widget.client.addListener(_syncPreview);
  }

  @override
  void didUpdateWidget(covariant _Preview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.client != widget.client) {
      oldWidget.client.removeListener(_syncPreview);
      widget.client.addListener(_syncPreview);
      _syncPreview();
    }
  }

  @override
  void dispose() {
    widget.client.removeListener(_syncPreview);
    _zoom.dispose();
    super.dispose();
  }

  void _syncPreview() {
    final snapshot = widget.client.snapshot;
    if (snapshot.previewWidth == _width &&
        snapshot.previewHeight == _height &&
        snapshot.textureId == _textureId) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _width = snapshot.previewWidth;
      _height = snapshot.previewHeight;
      _textureId = snapshot.textureId;
    });
  }

  void _resetZoom() {
    _zoom.value = Matrix4.identity();
  }

  void _reportCameraSurfaceSize() {
    final width = _width.clamp(1, 8192);
    final height = _height.clamp(1, 8192);
    if (width == _lastSurfaceW && height == _lastSurfaceH) {
      return;
    }
    _lastSurfaceW = width;
    _lastSurfaceH = height;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      // 缓冲尺寸跟采集分辨率一致，由 Flutter 把 Texture 放大居中；
      // 用显示尺寸当缓冲时，OpenGL 容易只画在角上留下大块黑边。
      widget.client.setSurfaceSize(width, height);
    });
  }

  @override
  Widget build(BuildContext context) {
    _reportCameraSurfaceSize();
    final ratio = previewAspectRatio(width: _width, height: _height);
    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final roomW = constraints.maxWidth;
          final roomH = constraints.maxHeight;
          // contain：横向优先铺满，高度自适应；完整显示画面，必要时整体缩小适应屏幕。
          final fitted = previewFitSize(roomWidth: roomW, roomHeight: roomH, aspectRatio: ratio);
          final viewW = fitted.width;
          final viewH = fitted.height;
          final left = (roomW - viewW) / 2;
          final top = (roomH - viewH) / 2;
          final frame = Positioned(
            left: left,
            top: top,
            width: viewW,
            height: viewH,
            child: _textureId < 0
                ? const SizedBox.expand()
                : Texture(textureId: _textureId, filterQuality: FilterQuality.low),
          );
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onDoubleTap: _resetZoom,
            child: ClipRect(
              child: InteractiveViewer(
                transformationController: _zoom,
                alignment: Alignment.center,
                constrained: false,
                minScale: previewZoomMin,
                maxScale: previewZoomMax,
                clipBehavior: Clip.hardEdge,
                panEnabled: true,
                scaleEnabled: true,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Stack(children: [frame]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

const _toolSectionIds = <String>['picture', 'video', 'effects'];

/// 左侧工具抽屉宽度：图标 + 文案。
const drawerRailWidth = 88.0;

IconData _toolSectionIcon(String id) {
  return switch (id) {
    'video' => Icons.videocam_outlined,
    'effects' => Icons.auto_awesome_outlined,
    'appearance' => Icons.palette_outlined,
    'settings' => Icons.settings_outlined,
    _ => Icons.tune,
  };
}

IconData _themeIcon(String id) {
  return switch (id) {
    'light' => Icons.light_mode_outlined,
    'dark' => Icons.dark_mode_outlined,
    _ => Icons.brightness_auto_outlined,
  };
}

/// 左侧抽屉：平时不占布局，打开后叠在预览上滑入。
class _DrawerRail extends StatefulWidget {
  const _DrawerRail({
    required this.open,
    required this.selected,
    required this.onSelect,
  });

  final bool open;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  State<_DrawerRail> createState() => _DrawerRailState();
}

class _DrawerRailState extends State<_DrawerRail> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: panelDuration,
    value: widget.open ? 1 : 0,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(_DrawerRail old) {
    super.didUpdateWidget(old);
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
    final l10n = context.l10n;
    final t = Curves.easeOutCubic.transform(_controller.value);
    if (t == 0) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: 8 + (t - 1) * (drawerRailWidth + 8),
      top: 56,
      bottom: 12,
      width: drawerRailWidth,
      child: Opacity(
        opacity: t,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: C.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: C.border.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: C.menuShadow.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: C.surfaceHi,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SvgPicture.asset('assets/brand/ic_launcher.svg', width: 24, height: 24),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    for (final id in _toolSectionIds)
                      _DrawerRailButton(
                        icon: _toolSectionIcon(id),
                        label: l10n.sectionTitle(id),
                        active: widget.selected == id,
                        onTap: () => widget.onSelect(id),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
                child: Container(height: 1, color: C.hairline),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    _DrawerRailButton(
                      icon: _toolSectionIcon('appearance'),
                      label: l10n.sectionTitle('appearance'),
                      active: widget.selected == 'appearance',
                      onTap: () => widget.onSelect('appearance'),
                    ),
                    _DrawerRailButton(
                      icon: _toolSectionIcon('settings'),
                      label: l10n.sectionTitle('settings'),
                      active: widget.selected == 'settings',
                      onTap: () => widget.onSelect('settings'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerRailButton extends StatelessWidget {
  const _DrawerRailButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? C.blue2 : C.fg68;
    final labelColor = active ? C.fg : C.fg48;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Pressable(
        onTap: onTap,
        pressedOpacity: 0.72,
        child: Semantics(
          button: true,
          label: label,
          selected: active,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
            decoration: BoxDecoration(
              color: active ? C.blue2.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active ? C.blue2.withValues(alpha: 0.16) : C.surfaceHi,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.1,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: labelColor,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.client,
    required this.locales,
    required this.presets,
    required this.themes,
    required this.section,
    required this.onClose,
  });

  final CameraClient client;
  final LocaleController locales;
  final PreviewPresetController presets;
  final ThemeController themes;
  final String section;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 6, 0),
          child: Row(
            children: [
              Expanded(child: Text(l10n.sectionTitle(section), style: T.sheetTitle)),
              IconButton(
                tooltip: l10n.close,
                visualDensity: VisualDensity.compact,
                onPressed: onClose,
                icon: Icon(Icons.close, size: 18, color: C.fg48),
              ),
            ],
          ),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: ListenableBuilder(
            listenable: client,
            builder: (context, _) => _body(context, client.snapshot),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, CameraSnapshot snapshot) {
    return switch (section) {
      'picture' => _PictureList(client: client, snapshot: snapshot),
      'video' => _VideoList(client: client, presets: presets, snapshot: snapshot),
      'effects' => _EffectList(client: client, snapshot: snapshot),
      'appearance' => _AppearanceList(themes: themes),
      _ => _SettingsList(client: client, locales: locales, presets: presets, snapshot: snapshot),
    };
  }
}

class _AppearanceList extends StatelessWidget {
  const _AppearanceList({required this.themes});

  final ThemeController themes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: themes,
      builder: (context, _) {
        final code = themes.code;
        return ListView(
          shrinkWrap: true,
          primary: false,
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(l10n.appearance, style: T.section),
            ),
            for (final id in AppThemes.ids)
              SheetRow(
                title: l10n.themeLabel(id),
                leading: Icon(_themeIcon(id), size: 18, color: C.fg68),
                chevron: false,
                trailing: id == code ? Icon(Icons.check, size: 18, color: C.fg) : null,
                onTap: () => themes.setCode(id),
              ),
          ],
        );
      },
    );
  }
}

class _PictureList extends StatelessWidget {
  const _PictureList({required this.client, required this.snapshot});

  final CameraClient client;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      children: [
        if (snapshot.autoFocusSupported)
          SheetRow(
            title: l10n.autoFocus,
            chevron: false,
            trailing: Switch(value: snapshot.autoFocus, onChanged: client.setAutoFocus),
          ),
        if (snapshot.autoWhiteBalanceSupported)
          SheetRow(
            title: l10n.autoWhiteBalance,
            chevron: false,
            trailing: Switch(value: snapshot.autoWhiteBalance, onChanged: client.setAutoWhiteBalance),
          ),
        for (final key in snapshot.imageSupported) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(l10n.imageLabel(key), style: T.section),
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
              child: Text(l10n.resetDefaults, style: TextStyle(fontSize: 14, color: C.blue2)),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoList extends StatelessWidget {
  const _VideoList({required this.client, required this.presets, required this.snapshot});

  final CameraClient client;
  final PreviewPresetController presets;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final busy = snapshot.isRecording;
    return ListenableBuilder(
      listenable: presets,
      builder: (context, _) {
        final catalog = availablePreviewPresets(
          resolutions: snapshot.resolutions.map((size) => (width: size.width, height: size.height)),
          frameRates: snapshot.frameRates,
          catalog: presets.items,
        );
        return ListView(
          shrinkWrap: true,
          primary: false,
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text(l10n.format, style: T.section)),
            _choice(context, 'MJPEG', snapshot.previewFormat == 'mjpeg', busy ? null : () => client.selectFormat('mjpeg')),
            _choice(context, 'YUYV', snapshot.previewFormat == 'yuyv', busy ? null : () => client.selectFormat('yuyv')),
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(l10n.orientation, style: T.section)),
            for (final id in rotateOptionIds)
              _choice(
                context,
                l10n.rotateLabel(id),
                snapshot.rotate == id,
                busy ? null : () => client.selectRotate(id),
              ),
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(l10n.previewPresets, style: T.section)),
            if (snapshot.resolutions.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(l10n.resolutionsAfterConnect, style: T.small),
              )
            else ...[
              for (final preset in catalog)
                _choice(
                  context,
                  preset.label,
                  snapshot.previewWidth == preset.width &&
                      snapshot.previewHeight == preset.height &&
                      snapshot.previewFps == preset.fps,
                  busy ? null : () => applyPreviewPreset(client, preset),
                ),
              SheetRow(
                title: l10n.presetCustom,
                onTap: busy
                    ? null
                    : () => showCustomPreviewPicker(context: context, client: client, presets: presets),
              ),
              SheetRow(
                title: l10n.presetManage,
                onTap: () => showPreviewPresetManager(context: context, client: client, presets: presets),
              ),
              Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(l10n.frameRate, style: T.section)),
              for (final fps in snapshot.frameRates)
                _choice(
                  context,
                  l10n.fpsOption(fps),
                  snapshot.previewFps == fps,
                  busy ? null : () => client.selectFps(fps),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _choice(BuildContext context, String label, bool selected, VoidCallback? onTap) {
    return SheetRow(
      title: label,
      chevron: false,
      trailing: selected ? Icon(Icons.check, size: 18, color: C.fg) : null,
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
    final l10n = context.l10n;
    return ListView(
      shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text(l10n.filter, style: T.section)),
        _choice(context, l10n.none, snapshot.filterId == -1, () => client.applyEffect('filter', -1)),
        _choice(context, l10n.filterMono, snapshot.filterId == 100, () => client.applyEffect('filter', 100)),
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(l10n.animation, style: T.section)),
        _choice(context, l10n.none, snapshot.animationId == -2, () => client.applyEffect('animation', -2)),
        _choice(context, l10n.animSoul, snapshot.animationId == 200, () => client.applyEffect('animation', 200)),
        _choice(context, l10n.animZoom, snapshot.animationId == 300, () => client.applyEffect('animation', 300)),
      ],
    );
  }

  Widget _choice(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return SheetRow(
      title: label,
      chevron: false,
      trailing: selected ? Icon(Icons.check, size: 18, color: C.fg) : null,
      onTap: onTap,
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({
    required this.client,
    required this.locales,
    required this.presets,
    required this.snapshot,
  });

  final CameraClient client;
  final LocaleController locales;
  final PreviewPresetController presets;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: locales,
      builder: (context, _) {
        final localeCode = locales.code;
        return ListView(
          shrinkWrap: true,
          primary: false,
          padding: const EdgeInsets.only(bottom: 12),
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text(l10n.about, style: T.section)),
            SheetRow(
              leading: SvgPicture.asset('assets/brand/ic_launcher.svg', width: 28, height: 28),
              title: l10n.appTitle,
              subtitle: l10n.aboutSubtitle(AppInfo.versionLabel),
              subtitleMaxLines: 4,
              chevron: false,
            ),
            PreviewPresetSettingsSection(client: client, presets: presets, snapshot: snapshot),
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(l10n.language, style: T.section)),
            SheetRow(
              title: l10n.languageSystem,
              chevron: false,
              trailing: localeCode == null ? Icon(Icons.check, size: 18, color: C.fg) : null,
              onTap: () => locales.setLocaleCode(null),
            ),
            for (final locale in AppLocales.supported)
              SheetRow(
                title: AppLocales.displayName(locale),
                chevron: false,
                trailing: localeCode == AppLocales.codeOf(locale)
                    ? Icon(Icons.check, size: 18, color: C.fg)
                    : null,
                onTap: () => locales.setLocaleCode(AppLocales.codeOf(locale)),
              ),
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(l10n.tips, style: T.section)),
            SheetRow(title: l10n.tipOtgTitle, subtitle: l10n.tipOtgBody, chevron: false),
            SheetRow(title: l10n.tipPrefsTitle, subtitle: l10n.tipPrefsBody, chevron: false),
            SheetRow(title: l10n.tipMultiTitle, subtitle: l10n.tipMultiBody, chevron: false),
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(l10n.segmentDuration, style: T.section)),
            for (final minutes in segmentOptions)
              SheetRow(
                title: minutes == 0 ? l10n.segmentNone : l10n.segmentMinutes(minutes),
                chevron: false,
                trailing: snapshot.segmentMinutes == minutes ? Icon(Icons.check, size: 18, color: C.fg) : null,
                onTap: snapshot.isRecording ? null : () => client.selectSegment(minutes),
              ),
          ],
        );
      },
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
        final opened = snapshot.connection == 'opened';
        final child = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.fpsLabel(snapshot.frameRate),
              style: TextStyle(fontSize: 13, color: soft ? C.fg42 : C.fg68),
            ),
            if (opened)
              Text(
                context.l10n.previewStatusLabel(
                  width: snapshot.previewWidth,
                  height: snapshot.previewHeight,
                  format: snapshot.previewFormat,
                  fps: snapshot.previewFps,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, color: soft ? C.fg30 : C.fg42),
              ),
            if (snapshot.isRecording)
              Text(
                formatElapsed(snapshot.elapsedSeconds),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: C.error),
              ),
          ],
        );
        if (soft) {
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(padding: const EdgeInsets.fromLTRB(14, 14, 14, 0), child: child),
          );
        }
        return child;
      },
    );
  }
}

const _presetCustomId = '__custom__';
const _presetManageId = '__manage__';

class _PreviewStatusMenu extends StatelessWidget {
  const _PreviewStatusMenu({required this.client, required this.presets});

  final CameraClient client;
  final PreviewPresetController presets;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: Listenable.merge([client, presets]),
      builder: (context, _) {
        final snapshot = client.snapshot;
        final opened = snapshot.connection == 'opened';
        final busy = snapshot.isRecording;
        final catalog = availablePreviewPresets(
          resolutions: snapshot.resolutions.map((size) => (width: size.width, height: size.height)),
          frameRates: snapshot.frameRates,
          catalog: presets.items,
        );
        final label = opened
            ? l10n.previewStatusLabel(
                width: snapshot.previewWidth,
                height: snapshot.previewHeight,
                format: snapshot.previewFormat,
                fps: snapshot.previewFps,
              )
            : l10n.fpsLabel(snapshot.frameRate);
        final currentId = '${snapshot.previewWidth}x${snapshot.previewHeight}@${snapshot.previewFps}';
        final items = <HoldMenuItem>[
          if (catalog.isEmpty)
            HoldMenuItem(
              '__empty__',
              opened ? l10n.resolutionsAfterConnect : l10n.waitingUsb,
              enabled: false,
              maxLines: 2,
            )
          else
            for (final preset in catalog)
              HoldMenuItem(
                preset.id,
                preset.label,
                subtitle: snapshot.previewFormat.toUpperCase(),
                leading: Icon(Icons.aspect_ratio, size: 16, color: C.fg68),
                checked: preset.id == currentId,
                enabled: !busy,
                maxLines: 1,
              ),
          HoldMenuItem(
            _presetCustomId,
            l10n.presetCustom,
            leading: Icon(Icons.tune, size: 16, color: C.fg68),
            enabled: opened && !busy && snapshot.resolutions.isNotEmpty,
            group: 1,
            maxLines: 1,
          ),
          HoldMenuItem(
            _presetManageId,
            l10n.presetManage,
            leading: Icon(Icons.edit_outlined, size: 16, color: C.fg68),
            enabled: opened,
            group: 1,
            maxLines: 1,
          ),
        ];
        return Semantics(
          button: true,
          label: l10n.resolution,
          child: HoldMenu(
            width: 280,
            centered: true,
            header: l10n.resolution,
            enabled: opened && !busy,
            items: items,
            onSelect: (id, _) async {
              if (id == _presetCustomId) {
                await showCustomPreviewPicker(context: context, client: client, presets: presets);
                return;
              }
              if (id == _presetManageId) {
                await showPreviewPresetManager(context: context, client: client, presets: presets);
                return;
              }
              final preset = catalog.where((item) => item.id == id).firstOrNull;
              if (preset != null) {
                await applyPreviewPreset(client, preset);
              }
            },
            builder: (context, open, pressed) {
              return Container(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                decoration: ShapeDecoration(
                  color: open ? C.surfaceHi : C.chromeScrim,
                  shape: StadiumBorder(side: BorderSide(color: open ? C.fg42 : C.border)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.fpsLabel(snapshot.frameRate),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: C.fg68),
                          ),
                          if (opened)
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11.5, color: C.fg42),
                            ),
                          if (snapshot.isRecording)
                            Text(
                              formatElapsed(snapshot.elapsedSeconds),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.error),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: AnimatedRotation(
                        turns: open ? 0.5 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: Icon(Icons.expand_more, size: 15, color: C.fg68),
                      ),
                    ),
                  ],
                ),
              );
            },
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
        final l10n = context.l10n;
        final isError = snapshot.connection == 'error';
        final headline = l10n.connectionTitle(snapshot.connection);
        final detail = isError
            ? l10n.platformMessage(snapshot.message, fallback: l10n.errorHint)
            : (snapshot.devices.isEmpty ? l10n.waitingHintEmpty : l10n.waitingHintDetected);
        final actionLabel = isError ? l10n.retryDevice : l10n.selectDevice;
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/brand/ic_launcher.svg', width: 56, height: 56),
                const SizedBox(height: 18),
                Text(
                  headline,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: C.fg),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, height: 1.45, color: C.fg42),
                ),
                const SizedBox(height: 18),
                HoldMenu(
                  width: 280,
                  centered: true,
                  header: l10n.devices,
                  items: _deviceMenuItems(l10n, snapshot),
                  onSelect: (id, _) => _onDeviceMenuSelect(client, id),
                  builder: (context, open, pressed) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: open ? C.surface : C.surfaceHi,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: open ? C.fg42 : C.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isError ? Icons.refresh : Icons.usb, size: 16, color: C.fg68),
                          const SizedBox(width: 8),
                          Text(actionLabel, style: T.row),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: open ? 0.5 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: Icon(Icons.expand_more, size: 16, color: C.fg68),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
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
        final l10n = context.l10n;
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
                    color: C.chromeScrim,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: C.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CaptureChip(
                          label: l10n.modePhoto,
                          icon: Icons.photo_camera,
                          selected: snapshot.mode == 'photo',
                          enabled: !snapshot.isRecording,
                          onTap: () => client.selectMode('photo'),
                        ),
                        _CaptureChip(
                          label: l10n.modeVideo,
                          icon: Icons.videocam,
                          selected: snapshot.mode == 'video',
                          enabled: !snapshot.isRecording,
                          onTap: () => client.selectMode('video'),
                        ),
                        _CaptureChip(
                          label: l10n.modeAudio,
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
                    label: l10n.shutter,
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
