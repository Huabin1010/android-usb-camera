import 'package:flutter/material.dart';

import 'l10n_ext.dart';

/// 色值对齐 cursor-remote：暖深灰底、半透明白字、细描边，按下只变淡。
class C {
  static const bg = Color(0xFF1C1B18);
  static const surface = Color(0xFF2A2925);
  static const surfaceHi = Color(0xFF3A3934);
  static const fg = Color(0xDBFFFFFF);
  static const fg68 = Color(0xADFFFFFF);
  static const fg48 = Color(0x7AFFFFFF);
  static const fg42 = Color(0x6BFFFFFF);
  static const fg30 = Color(0x4DFFFFFF);
  static const border = Color(0x1CFFFFFF);
  static const cardBorder = Color(0x17FFFFFF);
  static const blue2 = Color(0xFF5EB8ED);
  static const error = Color(0xFFE16C85);
}

class T {
  static const title = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: C.fg);
  static const sheetTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: C.fg);
  static const row = TextStyle(fontSize: 15, color: C.fg);
  static const section = TextStyle(fontSize: 13, color: C.fg42);
  static const small = TextStyle(fontSize: 13.5, color: C.fg42);
  static const chip = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: C.fg68);
}

const revealDuration = Duration(milliseconds: 220);
const panelDuration = Duration(milliseconds: 280);

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  const noOverlay = WidgetStatePropertyAll<Color>(Colors.transparent);
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    colorScheme: base.colorScheme.copyWith(
      primary: C.blue2,
      surface: C.bg,
      onSurface: C.fg,
      error: C.error,
    ),
    textButtonTheme: const TextButtonThemeData(style: ButtonStyle(overlayColor: noOverlay)),
    filledButtonTheme: const FilledButtonThemeData(style: ButtonStyle(overlayColor: noOverlay)),
    iconButtonTheme: const IconButtonThemeData(style: ButtonStyle(overlayColor: noOverlay)),
    dividerColor: C.border,
    listTileTheme: const ListTileThemeData(
      iconColor: C.fg68,
      textColor: C.fg,
      titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: C.fg),
      subtitleTextStyle: TextStyle(fontSize: 13, height: 1.35, color: C.fg42),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: C.blue2,
      inactiveTrackColor: C.border,
      thumbColor: C.fg,
      overlayColor: const Color(0x335EB8ED),
      trackHeight: 2,
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? C.blue2 : C.fg42;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? C.fg : C.fg48;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? const Color(0x665EB8ED) : C.surfaceHi;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: C.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: C.border),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: C.surface,
      contentTextStyle: TextStyle(color: C.fg, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: C.border),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: C.fg48),
  );
}

/// 按下时整体变淡，没有水波纹。
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.pressedOpacity = 0.6});

  final Widget child;
  final VoidCallback? onTap;
  final double pressedOpacity;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: tappable ? (_) => _set(true) : null,
      onTapCancel: tappable ? () => _set(false) : null,
      onTapUp: tappable ? (_) => _set(false) : null,
      child: AnimatedOpacity(
        opacity: _down ? widget.pressedOpacity : 1,
        duration: const Duration(milliseconds: 80),
        child: widget.child,
      ),
    );
  }
}

/// 32–36px 圆形描边按钮，对齐 Cursor Remote 顶栏圆钮。
class CircleBtn extends StatelessWidget {
  const CircleBtn({super.key, required this.icon, this.onTap, this.tooltip, this.size = 36, this.active = false});

  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: active ? C.surfaceHi : C.surface,
      shape: const CircleBorder(side: BorderSide(color: C.border)),
      child: Pressable(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.5, color: onTap == null ? C.fg42 : active ? C.fg : C.fg68),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

Future<R?> showAppSheet<R>(
  BuildContext context, {
  String? title,
  double maxHeight = 0.75,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<R>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: C.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      side: BorderSide(color: C.border),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (ctx) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * maxHeight),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: C.fg30, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 6, 2),
                child: Row(
                  children: [
                    Expanded(child: Text(title, style: T.sheetTitle)),
                    IconButton(
                      tooltip: AppLocalizations.of(ctx).close,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close, size: 18, color: C.fg48),
                      onPressed: () => Navigator.of(ctx).maybePop(),
                    ),
                  ],
                ),
              ),
            Flexible(child: Builder(builder: builder)),
          ],
        ),
      ),
    ),
  );
}

class SheetRow extends StatelessWidget {
  const SheetRow({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleMaxLines = 2,
    this.trailing,
    this.leading,
    this.onTap,
    this.chevron,
  });

  final String title;
  final String? subtitle;
  final int subtitleMaxLines;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool? chevron;

  @override
  Widget build(BuildContext context) {
    final showChevron = chevron ?? onTap != null;
    return Pressable(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: subtitle == null ? 44 : 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 10)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: T.row),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: subtitleMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: T.small,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (showChevron)
              const Padding(
                padding: EdgeInsets.only(left: 2),
                child: Icon(Icons.chevron_right, size: 18, color: C.fg42),
              ),
          ],
        ),
      ),
    );
  }
}
