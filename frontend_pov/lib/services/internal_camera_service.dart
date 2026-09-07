import 'package:camera/camera.dart';

/// Wrapper di atas package `camera` untuk kamera bawaan perangkat
/// (webcam desktop / kamera iPad / kamera tablet Android).
class InternalCameraService {
  CameraController? _controller;

  Future<void> initialize({ResolutionPreset resolution = ResolutionPreset.high}) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('Tidak ada kamera terdeteksi pada perangkat ini.');
    }

    // Pilih kamera belakang/eksternal utama; untuk photobooth biasanya kamera
    // yang menghadap pelanggan (front-facing di tablet berdiri).
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(camera, resolution, enableAudio: false);
    await _controller!.initialize();
  }

  CameraController get controller {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw StateError('Kamera belum di-initialize. Panggil initialize() dahulu.');
    }
    return _controller!;
  }

  /// Live preview widget dipasang langsung di layar shoot lewat CameraPreview(controller).

  Future<String> capturePhoto() async {
    final file = await controller.takePicture();
    return file.path;
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
