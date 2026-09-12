// ignore_for_file: use_build_context_synchronously
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/app_config.dart';
import '../services/internal_camera_service.dart';
import '../services/timer_service.dart';
import '../state/session_state.dart';
import 'preview_retake_screen.dart';

class ShootScreen extends ConsumerStatefulWidget {
  /// Jika [singleSlotIndex] diisi, maka hanya foto slot tersebut yang diambil
  /// (mode retake 1 slot). Jika null, mode burst semua slot.
  final int? singleSlotIndex;

  const ShootScreen({super.key, this.singleSlotIndex});

  @override
  ConsumerState<ShootScreen> createState() => _ShootScreenState();
}

class _ShootScreenState extends ConsumerState<ShootScreen> {
  final _camera = InternalCameraService();
  final _timerService = TimerService();
  final _picker = ImagePicker();

  bool _cameraReady = false;
  bool _cameraFailed = false;
  String _cameraError = '';
  int _countdown = AppConfig.shootCountdownSeconds;
  String _status = 'Menyiapkan kamera...';
  bool _flash = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _initAndStart();
  }

  Future<void> _initAndStart() async {
    try {
      await _camera.initialize();
      if (!mounted) return;
      setState(() => _cameraReady = true);
    } catch (e) {
      if (!mounted) return;
      setState(() { _cameraFailed = true; _cameraError = e.toString(); _status = 'Kamera tidak tersedia'; });
      return;
    }
    _timerService.tick.listen((v) {
      if (mounted) setState(() => _countdown = v);
    });
    await _runBurst();
  }

  Future<String> _captureWithFallback(int slot) async {
    if (_cameraReady && !_cameraFailed) {
      // flash effect
      setState(()=>_flash=true);
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(()=>_flash=false);
      return await _camera.capturePhoto();
    } else {
      // Gallery fallback untuk testing di emulator tanpa kamera
      final x = await _picker.pickImage(source: ImageSource.gallery);
      if (x == null) throw Exception('Pilih foto dibatalkan');
      return x.path;
    }
  }

  Future<void> _runBurst() async {
    final isRetake = widget.singleSlotIndex != null;

    if (isRetake) {
      final slot = widget.singleSlotIndex!;
      if (_cameraFailed) {
        // langsung fallback gallery tanpa countdown
        try {
          final path = await _captureWithFallback(slot);
          await ref.read(sessionProvider.notifier).addPhoto(slot, path);
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
        }
        if (mounted) Navigator.of(context).pop();
        return;
      }
      setState(() => _status = 'Foto ulang slot ${slot + 1}');
      await _timerService.runShootCountdown(AppConfig.shootCountdownSeconds);
      try {
        final path = await _captureWithFallback(slot);
        await ref.read(sessionProvider.notifier).addPhoto(slot, path);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload gagal: $e')));
      }
      if (mounted) Navigator.of(context).pop();
      return;
    }

    if (_cameraFailed) {
      // mode manual fallback: tampilkan tombol pilih gallery untuk tiap slot
      setState(()=>_status='Mode gallery — tap untuk pilih foto');
      return;
    }

    final totalSlots = ref.read(sessionProvider).frame?.photoCount ?? 4;
    for (var slot = 0; slot < totalSlots; slot++) {
      if (!mounted) return;
      setState(() => _status = 'Foto ${slot + 1} dari $totalSlots');
      await _timerService.runShootCountdown(AppConfig.shootCountdownSeconds);
      try {
        final path = await _captureWithFallback(slot);
        await ref.read(sessionProvider.notifier).addPhoto(slot, path);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto $slot gagal: $e')));
      }
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PreviewRetakeScreen()));
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
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
          if (_cameraFailed)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.videocam_off, size: 48, color: Colors.white54),
                  const SizedBox(height: 12),
                  Text(_cameraError, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(onPressed: () async {
                    final slot = widget.singleSlotIndex ?? ref.read(sessionProvider).photos.length;
                    try {
                      final path = await _captureWithFallback(slot);
                      await ref.read(sessionProvider.notifier).addPhoto(slot, path);
                      if (mounted && widget.singleSlotIndex != null) Navigator.of(context).pop();
                      if (mounted && ref.read(sessionProvider).photos.length >= (ref.read(sessionProvider).frame?.photoCount ?? 4)) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PreviewRetakeScreen()));
                      }
                    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
                  }, icon: const Icon(Icons.photo_library), label: const Text('Pilih dari Galeri (Testing)')),
                  const SizedBox(height: 8),
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Kembali')),
                ]),
              ),
            )
          else if (_cameraReady)
            CameraPreview(_camera.controller)
          else
            const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Menyiapkan kamera...', style: TextStyle(color: Colors.white54))])),

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
          if (_flash) Container(color: Colors.white.withValues(alpha: 0.85)),
          if (!_cameraFailed)
            Align(
              alignment: Alignment.center,
              child: Text(
                '$_countdown',
                style: const TextStyle(color: Colors.white, fontSize: 160, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 20, color: Colors.black)]),
              ),
            ),
        ],
      ),
    );
  }
}
