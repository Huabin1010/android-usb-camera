import 'package:flutter/material.dart';

import 'src/camera_client.dart';
import 'src/camera_screen.dart';
import 'src/l10n_ext.dart';
import 'src/locale_controller.dart';
import 'src/theme.dart';
import 'src/user_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await UserPrefs.load();
  runApp(AusbcApp(prefs: prefs));
}

class AusbcApp extends StatefulWidget {
  const AusbcApp({super.key, required this.prefs});

  final UserPrefs prefs;

  @override
  State<AusbcApp> createState() => _AusbcAppState();
}

class _AusbcAppState extends State<AusbcApp> {
  late final LocaleController _locales = LocaleController(widget.prefs);

  @override
  void dispose() {
    _locales.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _locales,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          locale: _locales.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: PermissionGate(prefs: widget.prefs, locales: _locales),
        );
      },
    );
  }
}

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key, required this.prefs, required this.locales});

  final UserPrefs prefs;
  final LocaleController locales;

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  final CameraClient _client = CameraClient();
  bool? _granted;

  @override
  void initState() {
    super.initState();
    _ask();
  }

  @override
  void dispose() {
    _client.dispose();
    super.dispose();
  }

  Future<void> _ask() async {
    final granted = await _client.ensurePermissions();
    if (mounted) {
      setState(() => _granted = granted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final granted = _granted;
    if (granted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!granted) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.permissionNeeded),
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: _ask, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }
    return CameraScreen(client: _client, prefs: widget.prefs, locales: widget.locales);
  }
}
