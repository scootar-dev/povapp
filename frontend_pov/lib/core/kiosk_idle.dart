import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/session_state.dart';
import '../screens/welcome_screen.dart';

/// Wrapper global: jika tidak ada interaksi 90 detik di *screen apapun*
/// kecuali Welcome, otomatis reset sesi dan balik ke Welcome.
/// Juga set immersive + wakelock sudah di screen masing2.
class KioskIdleWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const KioskIdleWrapper({super.key, required this.child});
  @override
  ConsumerState<KioskIdleWrapper> createState() => _KioskIdleWrapperState();
}

class _KioskIdleWrapperState extends ConsumerState<KioskIdleWrapper> {
  Timer? _timer;
  static const _timeout = Duration(seconds: 90);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _reset();
  }

  void _reset() {
    _timer?.cancel();
    _timer = Timer(_timeout, _onIdle);
  }

  Future<void> _onIdle() async {
    final session = ref.read(sessionProvider);
    // Jangan ganggu WelcomeScreen (tidak ada sesi)
    if (session.sessionId == null) {
      _reset();
      return;
    }
    // Abort sesi, balik ke welcome
    try { await ref.read(sessionProvider.notifier).completeAndReset(); } catch (_) { ref.read(sessionProvider.notifier).resetLocal(); }
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesi direset karena idle 90 detik')));
    }
    _reset();
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _reset(),
      onPointerMove: (_) => _reset(),
      onPointerSignal: (_) => _reset(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
