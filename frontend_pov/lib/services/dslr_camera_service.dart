import 'dart:async';
import 'package:flutter/services.dart';

/// Tidak ada package Flutter resmi yang stabil untuk libgphoto2, jadi DSLR
/// diintegrasikan lewat MethodChannel + native code:
///   - Windows/macOS: proses/daemon gphoto2 CLI atau binding libgphoto2 (C++)
///     yang dipanggil dari platform channel (mis. lewat FFI atau plugin desktop custom).
///   - Live preview DSLR di-stream sebagai JPEG frame berkala (mis. tiap 100-200ms)
///     lewat EventChannel, lalu dirender sebagai Image.memory() di Flutter.
///
/// Kelas ini adalah kontrak/interface-nya — implementasi native perlu dibuat
/// terpisah per platform (Windows: C++ plugin; macOS: Swift + libgphoto2 via Homebrew).
class DslrCameraService {
  static const _methodChannel = MethodChannel('pov_studio/dslr_camera');
  static const _previewEventChannel = EventChannel('pov_studio/dslr_camera/preview');

  Stream<Uint8List>? _previewStream;

  Future<bool> connect() async {
    final result = await _methodChannel.invokeMethod<bool>('connect');
    return result ?? false;
  }

  /// Stream JPEG frame untuk live preview DSLR (dianalogikan seperti CameraPreview
  /// bawaan, tapi datanya berupa byte JPEG per-frame dari gphoto2 live-view API).
  Stream<Uint8List> livePreviewStream() {
    _previewStream ??= _previewEventChannel
        .receiveBroadcastStream()
        .map((event) => event as Uint8List);
    return _previewStream!;
  }

  Future<String> capturePhoto() async {
    // Native side: trigger shutter, download file dari kamera ke local storage,
    // kembalikan path file lokal.
    final path = await _methodChannel.invokeMethod<String>('capturePhoto');
    if (path == null) {
      throw Exception('Gagal mengambil foto dari DSLR.');
    }
    return path;
  }

  Future<void> disconnect() async {
    await _methodChannel.invokeMethod('disconnect');
  }
}
