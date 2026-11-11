import 'package:flutter/material.dart';

import 'src/camera_client.dart';
import 'src/camera_screen.dart';
import 'src/theme.dart';

void main() {
  runApp(const AusbcApp());
}

class AusbcApp extends StatelessWidget {
  const AusbcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USB 摄像头',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const PermissionGate(),
    );
  }
}

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key});

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
              const Text('需要相机、麦克风和相册权限'),
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: _ask, child: const Text('重试')),
            ],
          ),
        ),
      );
    }
    return CameraScreen(client: _client);
  }
}
