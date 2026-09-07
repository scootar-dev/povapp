import 'dart:async';

/// Mengelola dua jenis timer sesuai spesifikasi:
/// 1. Prep timer (idle/persiapan, mis. 50 detik) — bisa dipotong (speed-up)
///    kapan saja lewat speedUp().
/// 2. Shoot countdown (5-8 detik per foto) — berjalan otomatis tiap slot.
///
/// Dipakai lewat StreamBuilder/ref.listen di layar Prep & Shoot.
class TimerService {
  Timer? _timer;
  final _controller = StreamController<int>.broadcast();

  Stream<int> get tick => _controller.stream;

  bool _speedUpRequested = false;

  /// Jalankan prep timer. Jika speedUp() dipanggil sebelum selesai,
  /// timer langsung dipotong ke 0 pada tick berikutnya.
  Future<void> runPrepTimer(int totalSeconds) async {
    _speedUpRequested = false;
    var remaining = totalSeconds;
    _controller.add(remaining);

    final completer = Completer<void>();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_speedUpRequested) {
        remaining = 0;
      } else {
        remaining--;
      }
      _controller.add(remaining);

      if (remaining <= 0) {
        t.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  /// Dipanggil saat pelanggan menekan tombol "Siap/Jepret" — memotong
  /// sisa prep timer langsung ke habis, tanpa transisi kasar (tick terakhir
  /// tetap terkirim lewat stream agar UI bisa animasikan).
  void speedUp() {
    _speedUpRequested = true;
  }

  /// Countdown pendek sebelum tiap jepretan (dipanggil ulang per slot foto).
  Future<void> runShootCountdown(int seconds) async {
    var remaining = seconds;
    _controller.add(remaining);

    final completer = Completer<void>();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining--;
      _controller.add(remaining);
      if (remaining <= 0) {
        t.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
