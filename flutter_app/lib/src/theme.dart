import 'package:flutter/material.dart';

import 'l10n_ext.dart';

/// 应用色板；随 [ThemeData.extensions] 切换浅色 / 暗色。
///
/// 业务代码继续写 `C.bg`：由 [MaterialApp.builder] 在每次重建时 [C.apply]。
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceHi,
    required this.fg,
    required this.fg68,
    required this.fg48,
    required this.fg42,
    required this.fg30,
    required this.border,
    required this.cardBorder,
    required this.blue2,
    required this.error,
    required this.menuBg,
    required this.menuShadow,
    required this.menuHover,
    required this.scrim,
    required this.chromeScrim,
    required this.chipOpen,
    required this.hairline,
    required this.groupDivider,
    required this.sliderOverlay,
    required this.switchTrackOn,
  });

  final Color bg;
  final Color surface;
  final Color surfaceHi;
  final Color fg;
  final Color fg68;
  final Color fg48;
  final Color fg42;
  final Color fg30;
  final Color border;
  final Color cardBorder;
  final Color blue2;
  final Color error;
  final Color menuBg;
  final Color menuShadow;
  final Color menuHover;
  final Color scrim;
  final Color chromeScrim;
  final Color chipOpen;
  final Color hairline;
  final Color groupDivider;
  final Color sliderOverlay;
  final Color switchTrackOn;

  static const dark = AppColors(
    bg: Color(0xFF1C1B18),
    surface: Color(0xFF2A2925),
    surfaceHi: Color(0xFF3A3934),
    fg: Color(0xDBFFFFFF),
    fg68: Color(0xADFFFFFF),
    fg48: Color(0x7AFFFFFF),
    fg42: Color(0x6BFFFFFF),
    fg30: Color(0x4DFFFFFF),
    border: Color(0x1CFFFFFF),
    cardBorder: Color(0x17FFFFFF),
    blue2: Color(0xFF5EB8ED),
    error: Color(0xFFE16C85),
    menuBg: Color(0xE62C2B27),
    menuShadow: Color(0x66000000),
    menuHover: Color(0x1FFFFFFF),
    scrim: Color(0x33000000),
    chromeScrim: Color(0xF21C1B18),
    chipOpen: Color(0x22FFFFFF),
    hairline: Color(0x1FFFFFFF),
    groupDivider: Color(0x33000000),
    sliderOverlay: Color(0x335EB8ED),
    switchTrackOn: Color(0x665EB8ED),
  );

  /// 同系暖色浅色板：米白底、深字、细描边。
  static const light = AppColors(
    bg: Color(0xFFF3F2ED),
    surface: Color(0xFFFFFFFF),
    surfaceHi: Color(0xFFE8E7E1),
    fg: Color(0xEB1C1B18),
    fg68: Color(0xAD1C1B18),
    fg48: Color(0x7A1C1B18),
    fg42: Color(0x6B1C1B18),
    fg30: Color(0x4D1C1B18),
    border: Color(0x1A1C1B18),
    cardBorder: Color(0x141C1B18),
    blue2: Color(0xFF2F8FC9),
    error: Color(0xFFD14D6A),
    menuBg: Color(0xF2FFFFFF),
    menuShadow: Color(0x33000000),
    menuHover: Color(0x14000000),
    scrim: Color(0x29000000),
    chromeScrim: Color(0xF2F3F2ED),
    chipOpen: Color(0x14000000),
    hairline: Color(0x1A1C1B18),
    groupDivider: Color(0x14000000),
    sliderOverlay: Color(0x332F8FC9),
    switchTrackOn: Color(0x662F8FC9),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceHi,
    Color? fg,
    Color? fg68,
    Color? fg48,
    Color? fg42,
    Color? fg30,
    Color? border,
    Color? cardBorder,
    Color? blue2,
    Color? error,
    Color? menuBg,
    Color? menuShadow,
    Color? menuHover,
    Color? scrim,
    Color? chromeScrim,
    Color? chipOpen,
    Color? hairline,
    Color? groupDivider,
    Color? sliderOverlay,
    Color? switchTrackOn,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceHi: surfaceHi ?? this.surfaceHi,
      fg: fg ?? this.fg,
      fg68: fg68 ?? this.fg68,
      fg48: fg48 ?? this.fg48,
      fg42: fg42 ?? this.fg42,
      fg30: fg30 ?? this.fg30,
      border: border ?? this.border,
      cardBorder: cardBorder ?? this.cardBorder,
      blue2: blue2 ?? this.blue2,
      error: error ?? this.error,
      menuBg: menuBg ?? this.menuBg,
      menuShadow: menuShadow ?? this.menuShadow,
      menuHover: menuHover ?? this.menuHover,
      scrim: scrim ?? this.scrim,
      chromeScrim: chromeScrim ?? this.chromeScrim,
      chipOpen: chipOpen ?? this.chipOpen,
      hairline: hairline ?? this.hairline,
      groupDivider: groupDivider ?? this.groupDivider,
      sliderOverlay: sliderOverlay ?? this.sliderOverlay,
      switchTrackOn: switchTrackOn ?? this.switchTrackOn,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return AppColors(
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      surfaceHi: mix(surfaceHi, other.surfaceHi),
      fg: mix(fg, other.fg),
      fg68: mix(fg68, other.fg68),
      fg48: mix(fg48, other.fg48),
      fg42: mix(fg42, other.fg42),
      fg30: mix(fg30, other.fg30),
      border: mix(border, other.border),
      cardBorder: mix(cardBorder, other.cardBorder),
      blue2: mix(blue2, other.blue2),
      error: mix(error, other.error),
      menuBg: mix(menuBg, other.menuBg),
      menuShadow: mix(menuShadow, other.menuShadow),
      menuHover: mix(menuHover, other.menuHover),
      scrim: mix(scrim, other.scrim),
      chromeScrim: mix(chromeScrim, other.chromeScrim),
      chipOpen: mix(chipOpen, other.chipOpen),
      hairline: mix(hairline, other.hairline),
      groupDivider: mix(groupDivider, other.groupDivider),
      sliderOverlay: mix(sliderOverlay, other.sliderOverlay),
      switchTrackOn: mix(switchTrackOn, other.switchTrackOn),
    );
  }
}

/// 当前生效色板。由 [MaterialApp.builder] 调用 [apply] 同步。
class C {
  static AppColors _palette = AppColors.dark;

  static void apply(AppColors palette) => _palette = palette;

  static AppColors get palette => _palette;

  static Color get bg => _palette.bg;
  static Color get surface => _palette.surface;
  static Color get surfaceHi => _palette.surfaceHi;
  static Color get fg => _palette.fg;
  static Color get fg68 => _palette.fg68;
  static Color get fg48 => _palette.fg48;
  static Color get fg42 => _palette.fg42;
  static Color get fg30 => _palette.fg30;
  static Color get border => _palette.border;
  static Color get cardBorder => _palette.cardBorder;
  static Color get blue2 => _palette.blue2;
  static Color get error => _palette.error;
  static Color get menuBg => _palette.menuBg;
  static Color get menuShadow => _palette.menuShadow;
  static Color get menuHover => _palette.menuHover;
  static Color get scrim => _palette.scrim;
  static Color get chromeScrim => _palette.chromeScrim;
  static Color get chipOpen => _palette.chipOpen;
  static Color get hairline => _palette.hairline;
  static Color get groupDivider => _palette.groupDivider;
  static Color get sliderOverlay => _palette.sliderOverlay;
  static Color get switchTrackOn => _palette.switchTrackOn;
}

class T {
  static TextStyle get title => TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: C.fg);
  static TextStyle get sheetTitle => TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: C.fg);
  static TextStyle get row => TextStyle(fontSize: 15, color: C.fg);
  static TextStyle get section => TextStyle(fontSize: 13, color: C.fg42);
  static TextStyle get small => TextStyle(fontSize: 13.5, color: C.fg42);
  static TextStyle get chip => TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: C.fg68);
}

const revealDuration = Duration(milliseconds: 220);
const panelDuration = Duration(milliseconds: 280);

ThemeData buildTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  const noOverlay = WidgetStatePropertyAll<Color>(Colors.transparent);
  return base.copyWith(
    scaffoldBackgroundColor: colors.bg,
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    extensions: <ThemeExtension<dynamic>>[colors],
    colorScheme: base.colorScheme.copyWith(
      primary: colors.blue2,
      surface: colors.bg,
      onSurface: colors.fg,
      error: colors.error,
    ),
    textButtonTheme: const TextButtonThemeData(style: ButtonStyle(overlayColor: noOverlay)),
    filledButtonTheme: const FilledButtonThemeData(style: ButtonStyle(overlayColor: noOverlay)),
    iconButtonTheme: const IconButtonThemeData(style: ButtonStyle(overlayColor: noOverlay)),
    dividerColor: colors.border,
    listTileTheme: ListTileThemeData(
      iconColor: colors.fg68,
      textColor: colors.fg,
      titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colors.fg),
      subtitleTextStyle: TextStyle(fontSize: 13, height: 1.35, color: colors.fg42),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: colors.blue2,
      inactiveTrackColor: colors.border,
      thumbColor: colors.fg,
      overlayColor: colors.sliderOverlay,
      trackHeight: 2,
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? colors.blue2 : colors.fg42;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? colors.fg : colors.fg48;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? colors.switchTrackOn : colors.surfaceHi;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: colors.border),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.surface,
      contentTextStyle: TextStyle(color: colors.fg, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        side: BorderSide(color: colors.border),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.fg48),
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
      shape: CircleBorder(side: BorderSide(color: C.border)),
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
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                      icon: Icon(Icons.close, size: 18, color: C.fg48),
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
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Icon(Icons.chevron_right, size: 18, color: C.fg42),
              ),
          ],
        ),
      ),
    );
  }
}
