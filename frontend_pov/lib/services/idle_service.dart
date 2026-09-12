import 'dart:async';

/// Kiosk idle watcher: jika tidak ada interaksi selama [timeout],
/// panggil [onIdle]. Dipakai di Welcome -> auto reset, juga di semua
/// screen tengah sesi -> kembali ke Welcome agar tidak nyangkut.
class IdleService {
  Timer? _timer;
  final Duration timeout;
  final void Function() onIdle;

  IdleService({required this.timeout, required this.onIdle});

  void start() {
    _reset();
  }

  void poke() => _reset();

  void _reset() {
    _timer?.cancel();
    _timer = Timer(timeout, onIdle);
  }

  void dispose() => _timer?.cancel();
}
