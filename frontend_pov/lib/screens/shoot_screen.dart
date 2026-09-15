import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../services/dslr_camera_service.dart';
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
  final _internalCamera = InternalCameraService();
  final _dslrCamera = DslrCameraService();
  final _timerService = TimerService();

  bool _isDslr = false;
  bool _cameraReady = false;
  bool _showFlash = false;
  int _countdown = AppConfig.shootCountdownSeconds;
  String _status = 'Menyiapkan kamera...';

  @override
  void initState() {
    super.initState();
    _isDslr = AppConfig.cameraSource == 'dslr';
    _initAndStart();
  }

  Future<void> _initAndStart() async {
    if (_isDslr) {
      try {
        final connected = await _dslrCamera.connect();
        setState(() => _cameraReady = connected);
      } catch (e) {
        // Fallback ke kamera internal jika DSLR tidak terhubung
        await _internalCamera.initialize();
        setState(() {
          _isDslr = false;
          _cameraReady = true;
        });
      }
    } else {
      await _internalCamera.initialize();
      setState(() => _cameraReady = true);
    }

    _timerService.tick.listen((v) {
      if (mounted) setState(() => _countdown = v);
    });

    await _runBurst();
  }

  Future<void> _runBurst() async {
    final totalSlots = ref.read(sessionProvider).frame?.photoCount ?? 4;

    for (var slot = 0; slot < totalSlots; slot++) {
      if (!mounted) return;
      setState(() => _status = 'MENGAMBIL FOTO ${slot + 1} DARI $totalSlots');

      await _timerService.runShootCountdown(AppConfig.shootCountdownSeconds);

      // Flash effect trigger
      setState(() => _showFlash = true);
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) setState(() => _showFlash = false);
      });

      String path;
      if (_isDslr) {
        path = await _dslrCamera.capturePhoto();
      } else {
        path = await _internalCamera.capturePhoto();
      }

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
    if (_isDslr) {
      _dslrCamera.disconnect();
    } else {
      _internalCamera.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Live Camera Preview (DSLR vs Internal)
          if (_cameraReady)
            _isDslr
                ? StreamBuilder<Uint8List>(
                    stream: _dslrCamera.livePreviewStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(snapshot.data!, fit: BoxFit.cover);
                      }
                      return const Center(
                        child: Text('Menunggu Live View DSLR...', style: TextStyle(color: Colors.white70)),
                      );
                    },
                  )
                : CameraPreview(_internalCamera.controller)
          else
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.purpleAccent),
                  SizedBox(height: 16),
                  Text('Menghubungkan Kamera...', style: TextStyle(color: Colors.white70, fontSize: 18)),
                ],
              ),
            ),

          // Camera Source Badge
          Positioned(
            top: 24,
            left: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(_isDslr ? Icons.camera : Icons.linked_camera, color: Colors.purpleAccent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _isDslr ? 'DSLR CAMERA' : 'INTERNAL CAMERA',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Top Status Bar
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(blurRadius: 15, color: Colors.purpleAccent)],
                ),
                child: Text(
                  _status,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ),

          // Center Large Countdown
          Align(
            alignment: Alignment.center,
            child: Text(
              '$_countdown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 180,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(blurRadius: 40, color: Colors.purpleAccent),
                  Shadow(blurRadius: 20, color: Colors.black),
                ],
              ),
            ),
          ),

          // Shutter Flash Overlay Effect
          if (_showFlash)
            Container(
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
