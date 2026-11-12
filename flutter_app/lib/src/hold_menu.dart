import 'dart:math' as math;
import 'dart:ui' show DisplayFeatureType, ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme.dart';

/// 菜单里的一项。[group] 不同的相邻两项之间画一条粗分隔（iOS 菜单分组）。
/// [subtitle] 显示在标题下方（不可用原因等）；[maxLines] 是标题最多显示的行数。
class HoldMenuItem {
  const HoldMenuItem(
    this.id,
    this.title, {
    this.subtitle,
    this.leading,
    this.enabled = true,
    this.checked = false,
    this.group = 0,
    this.maxLines = 1,
  });
  final String id, title;
  final String? subtitle;
  final Widget? leading;
  final bool enabled, checked;
  final int group, maxLines;
}

/// 侧边挖孔向屏幕内伸进多少。菜单从这一侧展开时要让开，避免画在前置摄像头上。
double _cutoutClearance(MediaQueryData mq, {required bool start}) {
  var edge = start ? mq.viewPadding.left : mq.viewPadding.right;
  final size = mq.size;
  for (final feature in mq.displayFeatures) {
    if (feature.type != DisplayFeatureType.cutout) continue;
    final bounds = feature.bounds;
    final onThisSide = start
        ? bounds.center.dx < size.width / 2
        : bounds.center.dx > size.width / 2;
    if (!onThisSide) continue;
    final into = start ? bounds.right : size.width - bounds.left;
    if (into <= 0 || into > size.width * 0.45) continue;
    edge = math.max(edge, into);
  }
  return edge;
}

/// iOS 下拉菜单式按钮：
/// - 点一下：菜单从按钮处弹性展开，点选一项后收起；
/// - 按住：轻震后立即展开，手指不松开滑到某一项上松手即选中（滑过的项高亮并轻震）；
///   松手时不在可选项上则菜单保持打开。
/// 点空白处收起。[onSelect] 的 dragged 为 true 表示是按住滑动松手选中的。
/// [above] 为 true 时菜单向上展开（按钮在屏幕底部时用）。
class HoldMenu extends StatefulWidget {
  const HoldMenu({
    super.key,
    required this.items,
    required this.onSelect,
    required this.builder,
    this.header,
    this.width = 264,
    this.above = false,
    this.centered = false,
    this.endAligned = false,
    this.fromScreenStart = false,
    this.fromScreenEnd = false,
    this.enabled = true,
    this.onOpen,
    this.allowOpen,
  });
  final List<HoldMenuItem> items;
  final void Function(String id, bool dragged) onSelect;

  /// 按钮本身。[open] 菜单是否打开，[pressed] 是否正被按下（用来做按压缩放）。
  final Widget Function(BuildContext context, bool open, bool pressed) builder;
  final String? header;
  final double width;
  final bool above, enabled;

  /// 菜单水平居中对齐按钮（按钮在顶栏中间时用），否则左对齐。
  final bool centered;

  /// 菜单右边缘对齐按钮右边缘（右上角按钮展开时用）。
  final bool endAligned;

  /// 菜单从屏幕左侧向右展开（横屏左侧按钮用），并避开挖孔。
  final bool fromScreenStart;

  /// 菜单贴在屏幕右缘，从右侧向左展开（横屏右侧按钮用）。
  final bool fromScreenEnd;

  /// 每次展开时调用（如刷新菜单数据）。
  final VoidCallback? onOpen;

  /// 返回 false 时这次点按或长按不展开（例如正在用这次触摸收起键盘）。
  final bool Function()? allowOpen;

  static const openDuration = Duration(milliseconds: 360);
  static const closeDuration = Duration(milliseconds: 200);

  @override
  State<HoldMenu> createState() => _HoldMenuState();
}

class _HoldMenuState extends State<HoldMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  final _btnKey = GlobalKey();
  OverlayEntry? _entry;
  bool _pressed = false;

  /// 菜单各行的 key，按住滑动时据此判断手指在哪一行上。
  final _rowKeys = <String, GlobalKey>{};
  String? _hover;

  bool get _isOpen => _entry != null;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: HoldMenu.openDuration,
      reverseDuration: HoldMenu.closeDuration,
    );
  }

  @override
  void didUpdateWidget(HoldMenu old) {
    super.didUpdateWidget(old);
    // 打开期间菜单项变了（如电脑端检测到 Kiro），菜单跟着刷新。构建阶段不能标记
    // overlay 里的组件，放到这一帧之后。
    if (_isOpen)
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _entry?.markNeedsBuild(),
      );
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    _anim.dispose();
    super.dispose();
  }

  void _open() {
    if (_isOpen) return;
    _hover = null;
    _entry = OverlayEntry(builder: _buildMenu);
    Overlay.of(context, rootOverlay: true).insert(_entry!);
    _anim.forward(from: 0);
    setState(() {});
    widget.onOpen?.call();
  }

  Future<void> _close() async {
    if (!_isOpen) return;
    await _anim.reverse();
    _entry?.remove();
    _entry = null;
    _hover = null;
    if (mounted) setState(() {});
  }

  HoldMenuItem? _item(String id) =>
      widget.items.where((i) => i.id == id).firstOrNull;

  Future<void> _choose(String id, {bool dragged = false}) async {
    final it = _item(id);
    if (it == null || !it.enabled) return;
    HapticFeedback.selectionClick();
    await _close();
    widget.onSelect(id, dragged);
  }

  /// 手指所在的可选行；不在任何可选行上时为 null。
  String? _rowAt(Offset global) {
    for (final e in _rowKeys.entries) {
      final box = e.value.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached) continue;
      if (!(box.localToGlobal(Offset.zero) & box.size).contains(global))
        continue;
      return _item(e.key)?.enabled == true ? e.key : null;
    }
    return null;
  }

  void _setHover(String? id) {
    if (id == _hover) return;
    _hover = id;
    if (id != null) HapticFeedback.selectionClick();
    _entry?.markNeedsBuild();
  }

  bool _mayOpen() => widget.allowOpen?.call() ?? true;

  void _press(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.enabled;
    return GestureDetector(
      key: _btnKey,
      behavior: HitTestBehavior.opaque,
      onTapDown: on ? (_) => _press(true) : null,
      onTapCancel: on ? () => _press(false) : null,
      onTapUp: on ? (_) => _press(false) : null,
      onTap: on
          ? () {
              if (!_mayOpen()) return;
              _isOpen ? _close() : _open();
            }
          : null,
      onLongPressStart: on
          ? (_) {
              if (!_mayOpen()) return;
              _press(false);
              HapticFeedback.mediumImpact();
              _open();
            }
          : null,
      onLongPressMoveUpdate: on
          ? (d) => _setHover(_rowAt(d.globalPosition))
          : null,
      onLongPressEnd: on
          ? (d) {
              final id = _rowAt(d.globalPosition);
              if (id != null) {
                _choose(id, dragged: true);
              } else {
                _setHover(null);
              }
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.builder(context, _isOpen, _pressed),
      ),
    );
  }

  Widget _buildMenu(BuildContext overlayCtx) {
    final box = _btnKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box == null ? Offset.zero : box.localToGlobal(Offset.zero);
    final btn = box?.size ?? const Size(30, 30);
    final mq = MediaQuery.of(overlayCtx);
    final screen = mq.size;
    final margin = 8.0;
    // 横屏前置摄像头在侧边挖孔上。菜单让开挖孔，避免卡片被镜头挡住一块。
    final startClear = _cutoutClearance(mq, start: true);
    final endClear = _cutoutClearance(mq, start: false);
    final startPad = widget.fromScreenStart
        ? math.max(margin, startClear + margin)
        : margin;
    final endPad = widget.fromScreenEnd
        ? math.max(margin, endClear + margin)
        : margin;
    final width = math.min(widget.width, screen.width - startPad - endPad);
    final pinned = widget.fromScreenStart || widget.fromScreenEnd;
    final x = widget.fromScreenEnd
        ? screen.width - width - endPad
        : widget.fromScreenStart
        ? startPad
        : widget.centered
        ? origin.dx + btn.width / 2 - width / 2
        : widget.endAligned
        ? origin.dx + btn.width - width
        : origin.dx;
    final left = x
        .clamp(margin, math.max(margin, screen.width - width - margin))
        .toDouble();
    // 缩放原点落在按钮正下方（上方），看起来是从按钮里长出来的。
    // 横屏则固定从屏幕右缘长出来。
    final ax = width <= 0
        ? -1.0
        : ((origin.dx + btn.width / 2 - left) / width * 2 - 1).clamp(-1.0, 1.0);
    final anchor = widget.fromScreenEnd
        ? Alignment.centerRight
        : widget.fromScreenStart
        ? Alignment.centerLeft
        : widget.centered
        ? Alignment(ax, widget.above ? 1 : -1)
        : widget.endAligned
        ? (widget.above ? Alignment.bottomRight : Alignment.topRight)
        : (widget.above ? Alignment.bottomLeft : Alignment.topLeft);
    // 菜单最多占到按钮和屏幕边缘之间的空间，放不下时内部滚动。
    final room = pinned
        ? screen.height - mq.padding.vertical - margin * 2
        : widget.above
        ? origin.dy - mq.padding.top - 16
        : screen.height - origin.dy - btn.height - mq.padding.bottom - 16;
    final open = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    final fade = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0, 0.5, curve: Curves.easeOut),
    );
    final card = FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.55, end: 1).animate(open),
        alignment: anchor,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: math.max(120, room)),
          child: _menuCard(width),
        ),
      ),
    );
    return Stack(
      children: [
        // 点空白处收起；背景轻微压暗，突出菜单。
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: FadeTransition(
              opacity: fade,
              child: ColoredBox(color: C.scrim),
            ),
          ),
        ),
        if (widget.fromScreenEnd)
          Positioned(
            right: endPad,
            top: mq.padding.top + margin,
            bottom: mq.padding.bottom + margin,
            child: Align(alignment: Alignment.centerRight, child: card),
          )
        else if (widget.fromScreenStart)
          Positioned(
            left: startPad,
            top: mq.padding.top + margin,
            bottom: mq.padding.bottom + margin,
            child: Align(alignment: Alignment.centerLeft, child: card),
          )
        else if (widget.above)
          Positioned(
            left: left,
            bottom: screen.height - origin.dy + 8,
            child: card,
          )
        else
          Positioned(left: left, top: origin.dy + btn.height + 8, child: card),
      ],
    );
  }

  Widget _menuCard(double width) {
    final items = widget.items;
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        // iOS 菜单里不同组之间用一条粗分隔，同组之间是细线。
        rows.add(
          items[i].group != items[i - 1].group
              ? Container(height: 7, color: C.groupDivider)
              : _Hairline(indent: items[i].leading == null ? 14 : 52),
        );
      }
      rows.add(_row(items[i]));
    }
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: C.menuShadow,
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: C.menuBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: C.border, width: 0.6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.header case final h?) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 11, 16, 7),
                      child: Text(
                        h,
                        style: TextStyle(
                          fontSize: 12,
                          color: C.fg42,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const _Hairline(),
                  ],
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: rows,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(HoldMenuItem it) {
    final k = _rowKeys.putIfAbsent(it.id, GlobalKey.new);
    final hover = _hover == it.id;
    return GestureDetector(
      key: k,
      behavior: HitTestBehavior.opaque,
      onTapDown: it.enabled ? (_) => _setHover(it.id) : null,
      onTapCancel: () => _setHover(null),
      onTap: it.enabled ? () => _choose(it.id) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        color: hover ? C.menuHover : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        child: Row(
          children: [
            if (it.leading case final l?) ...[
              SizedBox(width: 26, child: Center(child: l)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    it.title,
                    maxLines: it.maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: it.enabled ? C.fg : C.fg42,
                    ),
                  ),
                  if (it.subtitle case final s?) ...[
                    const SizedBox(height: 2),
                    Text(s, style: TextStyle(fontSize: 12, color: C.fg30)),
                  ],
                ],
              ),
            ),
            if (it.checked) Icon(Icons.check, size: 18, color: C.fg),
          ],
        ),
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline({this.indent = 0});
  final double indent;
  @override
  Widget build(BuildContext context) => Container(
    height: 0.5,
    margin: EdgeInsets.only(left: indent),
    color: C.hairline,
  );
}
