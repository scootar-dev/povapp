import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../state/session_state.dart';
import 'photo_review_screen.dart';

bool get _isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

class CameraShootScreen extends ConsumerStatefulWidget {
  final int? retakeSlotIndex;

  const CameraShootScreen({super.key, this.retakeSlotIndex});

  @override
  ConsumerState<CameraShootScreen> createState() => _CameraShootScreenState();
}

class _CameraShootScreenState extends ConsumerState<CameraShootScreen> {
  List<CameraDescription> _cameras = [];
  CameraController? _ctrl;
  int _selectedCamIndex = 0;
  bool _cameraReady = false;
  bool _isShooting = false;
  int _countdown = 0;
  String _statusText = 'Menyiapkan kamera...';
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (_isDesktop) {
      if (mounted) {
        setState(() {
          _statusText = 'Mode Desktop: Pilih foto dari berkas/galeri';
        });
      }
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) throw Exception('Tidak ada kamera terdeteksi');

      // Default camera depan (selfie photobooth) jika ada
      final frontIdx = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _selectedCamIndex = frontIdx != -1 ? frontIdx : 0;

      await _setupCameraController(_cameras[_selectedCamIndex]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Kamera tidak tersedia: $e\n(Gunakan tombol Galeri)';
        });
      }
    }
  }

  Future<void> _setupCameraController(CameraDescription desc) async {
    await _ctrl?.dispose();
    _ctrl = CameraController(
      desc,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _ctrl!.initialize();
      if (mounted) {
        setState(() {
          _cameraReady = true;
          _statusText = widget.retakeSlotIndex != null
              ? 'Foto Ulang Slot ${widget.retakeSlotIndex! + 1}'
              : 'Siap mengambil foto';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Gagal inisialisasi kamera: $e';
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isShooting) return;
    _selectedCamIndex = (_selectedCamIndex + 1) % _cameras.length;
    setState(() => _cameraReady = false);
    await _setupCameraController(_cameras[_selectedCamIndex]);
  }

  Future<void> _startPhotoBurst() async {
    if (_isShooting) return;
    setState(() => _isShooting = true);

    final totalSlots = ref.read(mobileSessionProvider).frame?.photoCount ?? 3;

    if (widget.retakeSlotIndex != null) {
      // Hanya foto 1 kali untuk slot yang di-retake
      final slot = widget.retakeSlotIndex!;
      await _captureSlot(slot, totalSlots);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // Ambil berurutan untuk semua slot
    for (int slot = 0; slot < totalSlots; slot++) {
      if (!mounted) return;
      final ok = await _captureSlot(slot, totalSlots);
      if (!ok) break;
      if (slot < totalSlots - 1) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PhotoReviewScreen()),
      );
    }
  }

  Future<bool> _captureSlot(int slotIndex, int totalSlots) async {
    if (!mounted) return false;
    setState(() {
      _statusText = 'Foto ${slotIndex + 1} dari $totalSlots';
    });

    // Countdown 3 detik
    for (int c = 3; c > 0; c--) {
      if (!mounted) return false;
      setState(() => _countdown = c);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return false;
    setState(() => _countdown = 0);

    try {
      String path;
      if (_ctrl != null && _cameraReady) {
        final f = await _ctrl!.takePicture();
        path = f.path;
      } else {
        final x = await _picker.pickImage(source: ImageSource.gallery);
        if (x == null) throw Exception('Batal memilih foto');
        path = x.path;
      }

      if (widget.retakeSlotIndex != null) {
        ref.read(mobileSessionProvider.notifier).retakePhoto(slotIndex, path);
      } else {
        ref.read(mobileSessionProvider.notifier).addLocalPhoto(path);
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto slot ${slotIndex + 1} gagal: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _pickSingleFromGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;

    final notifier = ref.read(mobileSessionProvider.notifier);
    if (widget.retakeSlotIndex != null) {
      notifier.retakePhoto(widget.retakeSlotIndex!, x.path);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    notifier.addLocalPhoto(x.path);
    final currentCount = ref.read(mobileSessionProvider).localPhotos.length;
    final totalSlots = ref.read(mobileSessionProvider).frame?.photoCount ?? 3;

    if (currentCount >= totalSlots && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PhotoReviewScreen()),
      );
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(mobileSessionProvider);
    final totalSlots = session.frame?.photoCount ?? 3;
    final takenCount = session.localPhotos.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.retakeSlotIndex != null
              ? 'Foto Ulang Slot #${widget.retakeSlotIndex! + 1}'
              : 'Ambil Foto ($takenCount/$totalSlots)',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (_cameras.length > 1 && !_isShooting)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios_rounded),
              onPressed: _switchCamera,
              tooltip: 'Ganti Kamera',
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Live Camera Preview / Desktop Fallback
          if (_isDesktop || !_cameraReady || _ctrl == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_camera_back_outlined,
                      size: 64,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickSingleFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Pilih Foto dari Galeri'),
                    ),
                  ],
                ),
              ),
            )
          else
            CameraPreview(_ctrl!),

          // Status Badge atas
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Countdown raksasa di tengah
          if (_countdown > 0)
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$_countdown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 90,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.retakeSlotIndex == null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: totalSlots > 0 ? (takenCount / totalSlots) : 0,
                      backgroundColor: Colors.white24,
                      color: const Color(0xFF6A1FB8),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library, color: Colors.white70),
                      onPressed: _isShooting ? null : _pickSingleFromGallery,
                      tooltip: 'Pilih dari Berkas',
                    ),
                    // Shutter button
                    GestureDetector(
                      onTap: _isShooting ? null : _startPhotoBurst,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: _isShooting
                              ? Colors.grey
                              : const Color(0xFF6A1FB8),
                        ),
                        child: Icon(
                          _isShooting
                              ? Icons.hourglass_top_rounded
                              : Icons.camera_alt,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer penyeimbang
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
