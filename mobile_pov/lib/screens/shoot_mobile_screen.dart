import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/photo_model.dart';
import '../state/session_state.dart';
import 'preview_select_screen.dart';

bool get _isDesktop =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS);

class ShootMobileScreen extends ConsumerStatefulWidget {
  const ShootMobileScreen({super.key});
  @override
  ConsumerState<ShootMobileScreen> createState() => _ShootMobileScreenState();
}

class _ShootMobileScreenState extends ConsumerState<ShootMobileScreen> {
  CameraController? _ctrl;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIdx = 0;
  bool _ready = false;
  bool _busy = false;
  bool _bursting = false;
  int _countdown = 0;
  String _status = 'Inisialisasi kamera...';
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mobileSessionProvider.notifier).clearLocalPhotos();
      _init();
    });
  }

  Future<void> _init() async {
    if (_isDesktop) {
      if (mounted) setState(() => _status = 'Mode desktop: pilih foto dari file/galeri');
      return;
    }

    try {
      final cams = await availableCameras();
      _cameras = cams;
      if (cams.isNotEmpty) {
        final frontIdx = cams.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
        _selectedCameraIdx = frontIdx >= 0 ? frontIdx : 0;
        await _startCamera(cams[_selectedCameraIdx]);
      } else {
        if (mounted) setState(() => _status = 'Kamera tidak ditemukan — gunakan galeri/kamera HP');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _status = 'Akses kamera langsung terkendala — gunakan kamera bawaan/galeri');
      }
    }
  }

  Future<void> _startCamera(CameraDescription cam) async {
    await _ctrl?.dispose();
    _ctrl = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _ctrl!.initialize();
      if (mounted) {
        setState(() {
          _ready = true;
          _status = 'Siap mengambil foto';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _ready = false;
          _status = 'Gagal inisialisasi kamera: $e';
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _busy || _bursting) return;
    _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras.length;
    setState(() => _ready = false);
    await _startCamera(_cameras[_selectedCameraIdx]);
  }

  Future<void> _addPhotoFromXFile(XFile file) async {
    final bytes = await file.readAsBytes();
    final photo = CapturedPhoto(
      name: file.name.isNotEmpty ? file.name : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      path: file.path,
      bytes: bytes,
    );
    ref.read(mobileSessionProvider.notifier).addLocalPhoto(photo);

    final total = ref.read(mobileSessionProvider).frame?.photoCount ?? 3;
    final current = ref.read(mobileSessionProvider).localPhotos.length;

    if (current >= total && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PreviewSelectScreen()),
      );
    }
  }

  Future<void> _captureManual() async {
    if (_busy || _bursting) return;
    setState(() => _busy = true);
    try {
      if (_ctrl != null && _ready) {
        final f = await _ctrl!.takePicture();
        await _addPhotoFromXFile(f);
      } else {
        await _pickCameraNative();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal ambil foto: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startAutoBurst() async {
    if (_bursting || _busy) return;
    setState(() => _bursting = true);

    final total = ref.read(mobileSessionProvider).frame?.photoCount ?? 3;
    while (mounted) {
      final current = ref.read(mobileSessionProvider).localPhotos.length;
      if (current >= total) break;

      setState(() => _status = 'Foto ${current + 1}/$total');
      for (int c = 3; c > 0; c--) {
        if (!mounted || !_bursting) {
          setState(() {
            _countdown = 0;
            _bursting = false;
          });
          return;
        }
        setState(() => _countdown = c);
        await Future.delayed(const Duration(seconds: 1));
      }
      setState(() => _countdown = 0);

      try {
        if (_ctrl != null && _ready) {
          final f = await _ctrl!.takePicture();
          await _addPhotoFromXFile(f);
        } else {
          final x = await _picker.pickImage(source: ImageSource.camera);
          if (x != null) {
            await _addPhotoFromXFile(x);
          } else {
            break;
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error foto: $e')));
        }
        break;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) setState(() => _bursting = false);
  }

  Future<void> _pickCameraNative() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (x != null) {
        await _addPhotoFromXFile(x);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka kamera: $e')),
        );
      }
    }
  }

  Future<void> _pickGallery() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (x != null) {
        await _addPhotoFromXFile(x);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih dari galeri: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(mobileSessionProvider).frame?.photoCount ?? 3;
    final taken = ref.watch(mobileSessionProvider).localPhotos.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text('Ambil Foto ($taken/$total)', style: const TextStyle(fontSize: 16)),
        actions: [
          if (_cameras.length > 1 && _ready)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              tooltip: 'Ganti Kamera',
              onPressed: _switchCamera,
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview or Fallback View
          if (_ready && _ctrl != null)
            LayoutBuilder(
              builder: (context, constraints) {
                final sensorAspectRatio = _ctrl!.value.aspectRatio;
                final isPortrait = constraints.maxHeight >= constraints.maxWidth;
                // CameraPreview swaps its aspect ratio in portrait orientation.
                final previewAspectRatio = isPortrait
                    ? 1 / sensorAspectRatio
                    : sensorAspectRatio;
                final previewHeight = constraints.maxHeight;
                return ClipRect(
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: previewHeight * previewAspectRatio,
                        height: previewHeight,
                        child: CameraPreview(_ctrl!),
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_camera, size: 64, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gunakan tombol di bawah untuk mengambil foto langsung dari HP Anda:',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      onPressed: _busy ? null : _pickCameraNative,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Buka Kamera HP', style: TextStyle(fontSize: 15)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      onPressed: _busy ? null : _pickGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Pilih dari Galeri', style: TextStyle(fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),

          // Countdown overlay
          if (_countdown > 0)
            Center(
              child: Text(
                '$_countdown',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 140,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 30, color: Colors.black)],
                ),
              ),
            ),

          // Bottom Controls (when camera preview is active)
          if (_ready && _ctrl != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  // Progress indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? (taken / total) : 0,
                      backgroundColor: Colors.white24,
                      color: Colors.deepPurpleAccent,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery option
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white, size: 28),
                        tooltip: 'Pilih dari Galeri',
                        onPressed: _busy || _bursting ? null : _pickGallery,
                      ),
                      // Shutter button
                      GestureDetector(
                        onTap: _busy || _bursting ? null : _captureManual,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          child: Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Auto burst countdown
                      IconButton(
                        icon: Icon(
                          _bursting ? Icons.stop_circle : Icons.timer,
                          color: _bursting ? Colors.redAccent : Colors.white,
                          size: 28,
                        ),
                        tooltip: _bursting ? 'Hentikan Otomatis' : 'Auto 3s Timer',
                        onPressed: _busy
                            ? null
                            : () {
                                if (_bursting) {
                                  setState(() => _bursting = false);
                                } else {
                                  _startAutoBurst();
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),

          if (_busy)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
