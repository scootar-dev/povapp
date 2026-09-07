import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../services/internal_camera_service.dart';
import '../services/timer_service.dart';
import '../state/session_state.dart';
import 'preview_retake_screen.dart';

class ShootScreen extends ConsumerStatefulWidget {
  const ShootScreen({super.key});

  @override
  ConsumerState<ShootScreen> createState() => _ShootScreenState();
}

class _ShootScreenState extends ConsumerState<ShootScreen> {
  final _camera = InternalCameraService();
  final _timerService = TimerService();

  bool _cameraReady = false;
  int _countdown = AppConfig.shootCountdownSeconds;
  String _status = 'Menyiapkan kamera...';

  @override
  void initState() {
    super.initState();
    _initAndStart();
  }

  Future<void> _initAndStart() async {
    // NOTE: kalau studio ini pakai DSLR (studio.camera_source == 'dslr'),
    // ganti InternalCameraService dengan DslrCameraService di sini — logic
    // burst di bawah tetap sama karena keduanya punya method capturePhoto().
    await _camera.initialize();
    setState(() => _cameraReady = true);
    _timerService.tick.listen((v) {
      if (mounted) setState(() => _countdown = v);
    });
    await _runBurst();
  }

  Future<void> _runBurst() async {
    final totalSlots = ref.read(sessionProvider).frame?.photoCount ?? 4;

    for (var slot = 0; slot < totalSlots; slot++) {
      setState(() => _status = 'Foto ${slot + 1} dari $totalSlots');

      await _timerService.runShootCountdown(AppConfig.shootCountdownSeconds);

      final path = await _camera.capturePhoto();
      await ref.read(sessionProvider.notifier).addPhoto(slot, path);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PreviewRetakeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _timerService.dispose();
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_cameraReady)
            CameraPreview(_camera.controller)
          else
            const Center(child: CircularProgressIndicator()),

          // Overlay frame transparan bisa ditumpuk di sini menggunakan
          // frame.slots[slot ke berapa yang sedang berjalan] sebagai acuan posisi kotak foto.
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _status,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              '$_countdown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 160,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 20, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
