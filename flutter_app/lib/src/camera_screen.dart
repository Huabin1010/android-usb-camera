import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_info.dart';
import 'camera_client.dart';
import 'camera_logic.dart';
import 'camera_snapshot.dart';
import 'hold_menu.dart';
import 'l10n_ext.dart';
import 'locale_controller.dart';
import 'theme.dart';
import 'user_prefs.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.client,
    required this.prefs,
    required this.locales,
  });

  final CameraClient client;
  final UserPrefs prefs;
  final LocaleController locales;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late String _workspace = widget.prefs.workspace;
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
      _watchChrome = false;
    });
    await widget.prefs.setWorkspace(applied);
  }

  void _toggle(String section) {
    setState(() => _section = _section == section ? null : section);
  }

  Future<void> _openDevicesSheet() async {
    final l10n = context.l10n;
    await showAppSheet<void>(
      context,
      title: l10n.devices,
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
                  Text(l10n.noUsbCamera, style: T.small),
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
                      child: Text(l10n.retry, style: T.row),
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
                      _ConnectionMessage(
                        client: widget.client,
                        onOpenDevices: _openDevicesSheet,
                      ),
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
                                locales: widget.locales,
                                section: _section!,
                                onClose: () => setState(() => _section = null),
                              ),
                      ),
                      if (showTopChrome)
                        _TopChrome(
                          workspace: _workspace,
                          client: widget.client,
                          onSelectWorkspace: _setWorkspace,
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
    required this.onSelectWorkspace,
    required this.onOpenDevices,
    this.onHideWatch,
  });

  final String workspace;
  final CameraClient client;
  final ValueChanged<String> onSelectWorkspace;
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
            _WorkspaceChip(workspace: workspace, onSelect: onSelectWorkspace),
            const SizedBox(width: 8),
            CircleBtn(icon: Icons.usb, tooltip: context.l10n.devices, onTap: onOpenDevices),
            if (onHideWatch != null) ...[
              const SizedBox(width: 8),
              CircleBtn(
                icon: Icons.visibility_off_outlined,
                tooltip: context.l10n.hideControls,
                onTap: onHideWatch,
              ),
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
          return Container(
            padding: const EdgeInsets.fromLTRB(9, 6, 7, 6),
            decoration: ShapeDecoration(
              color: open ? const Color(0x22FFFFFF) : Colors.transparent,
              shape: StadiumBorder(side: BorderSide(color: open ? C.fg42 : C.border)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_workspaceIcon(workspace), size: 14, color: C.fg68),
                const SizedBox(width: 5),
                Text(l10n.workspaceLabel(workspace), style: T.chip),
                const SizedBox(width: 2),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(Icons.expand_more, size: 15, color: C.fg68),
                ),
              ],
            ),
          );
        },
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
    final l10n = context.l10n;
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
                    _RailButton(
                      id: 'picture',
                      icon: Icons.tune,
                      tooltip: l10n.sectionTitle('picture'),
                      selected: selected,
                      onSelect: onSelect,
                    ),
                    _RailButton(
                      id: 'video',
                      icon: Icons.aspect_ratio,
                      tooltip: l10n.sectionTitle('video'),
                      selected: selected,
                      onSelect: onSelect,
                    ),
                    _RailButton(
                      id: 'effects',
                      icon: Icons.auto_awesome_outlined,
                      tooltip: l10n.sectionTitle('effects'),
                      selected: selected,
                      onSelect: onSelect,
                    ),
                    _RailButton(
                      id: 'audio',
                      icon: Icons.graphic_eq,
                      tooltip: l10n.sectionTitle('audio'),
                      selected: selected,
                      onSelect: onSelect,
                    ),
                  ],
                ),
              )
            else
              const Spacer(),
            _RailButton(
              id: 'settings',
              icon: Icons.settings_outlined,
              tooltip: l10n.sectionTitle('settings'),
              selected: selected,
              onSelect: onSelect,
            ),
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
  const _Panel({
    required this.client,
    required this.locales,
    required this.section,
    required this.onClose,
  });

  final CameraClient client;
  final LocaleController locales;
  final String section;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
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
                icon: const Icon(Icons.close, size: 18, color: C.fg48),
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
    );
  }

  Widget _body(BuildContext context, CameraSnapshot snapshot) {
    return switch (section) {
      'picture' => _PictureList(client: client, snapshot: snapshot),
      'video' => _VideoList(client: client, snapshot: snapshot),
      'effects' => _EffectList(client: client, snapshot: snapshot),
      'audio' => _AudioList(client: client, snapshot: snapshot),
      _ => _SettingsList(client: client, locales: locales, snapshot: snapshot),
    };
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
              child: Text(l10n.resetDefaults, style: const TextStyle(fontSize: 14, color: C.blue2)),
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
    final l10n = context.l10n;
    final busy = snapshot.isRecording;
    return ListView(
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
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(l10n.resolution, style: T.section)),
        if (snapshot.resolutions.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(l10n.resolutionsAfterConnect, style: T.small),
          )
        else
          for (final size in snapshot.resolutions)
            _choice(
              context,
              size.label,
              snapshot.previewWidth == size.width && snapshot.previewHeight == size.height,
              busy ? null : () => client.selectResolution(size.width, size.height),
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
    );
  }

  Widget _choice(BuildContext context, String label, bool selected, VoidCallback? onTap) {
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
    final l10n = context.l10n;
    return ListView(
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
    final l10n = context.l10n;
    final busy = snapshot.isRecording;
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text(l10n.audioSource, style: T.section)),
        _choice(context, l10n.micSystem, snapshot.audioSource == 'system', busy ? null : () => client.selectAudio('system')),
        _choice(context, l10n.micDevice, snapshot.audioSource == 'device', busy ? null : () => client.selectAudio('device')),
        _choice(context, l10n.micAuto, snapshot.audioSource == 'auto', busy ? null : () => client.selectAudio('auto')),
        SheetRow(
          title: l10n.listenMic,
          chevron: false,
          trailing: Switch(value: snapshot.micOn, onChanged: (_) => client.toggleMic()),
        ),
      ],
    );
  }

  Widget _choice(BuildContext context, String label, bool selected, VoidCallback? onTap) {
    return SheetRow(
      title: label,
      chevron: false,
      trailing: selected ? const Icon(Icons.check, size: 18, color: C.fg) : null,
      onTap: onTap,
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({required this.client, required this.locales, required this.snapshot});

  final CameraClient client;
  final LocaleController locales;
  final CameraSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: locales,
      builder: (context, _) {
        final localeCode = locales.code;
        return ListView(
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
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text(l10n.language, style: T.section)),
            SheetRow(
              title: l10n.languageSystem,
              chevron: false,
              trailing: localeCode == null ? const Icon(Icons.check, size: 18, color: C.fg) : null,
              onTap: () => locales.setLocaleCode(null),
            ),
            for (final locale in AppLocales.supported)
              SheetRow(
                title: AppLocales.displayName(locale),
                chevron: false,
                trailing: localeCode == AppLocales.codeOf(locale)
                    ? const Icon(Icons.check, size: 18, color: C.fg)
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
                trailing: snapshot.segmentMinutes == minutes ? const Icon(Icons.check, size: 18, color: C.fg) : null,
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
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.fpsLabel(snapshot.frameRate),
              style: TextStyle(fontSize: 13, color: soft ? C.fg42 : C.fg68),
            ),
            if (opened)
              Text(
                formatPreviewLabel(
                  width: snapshot.previewWidth,
                  height: snapshot.previewHeight,
                  format: snapshot.previewFormat,
                  fps: snapshot.previewFps,
                ),
                style: TextStyle(fontSize: 11.5, color: soft ? C.fg30 : C.fg42),
              ),
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
  const _ConnectionMessage({required this.client, required this.onOpenDevices});

  final CameraClient client;
  final VoidCallback onOpenDevices;

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
            ? (snapshot.message ?? l10n.errorHint)
            : (snapshot.devices.isEmpty ? l10n.waitingHintEmpty : l10n.waitingHintDetected);
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
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: C.fg),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, height: 1.45, color: C.fg42),
                ),
                const SizedBox(height: 18),
                Pressable(
                  onTap: onOpenDevices,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: C.surfaceHi,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: C.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isError ? Icons.refresh : Icons.usb, size: 16, color: C.fg68),
                        const SizedBox(width: 8),
                        Text(isError ? l10n.retryDevice : l10n.selectDevice, style: T.row),
                      ],
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
