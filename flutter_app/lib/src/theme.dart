import 'package:flutter/material.dart';

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
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? C.blue2 : C.fg42;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? C.blue2 : C.fg48;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? const Color(0x665EB8ED) : C.surfaceHi;
      }),
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
