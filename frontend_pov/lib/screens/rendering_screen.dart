import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/session_state.dart';
import 'print_share_screen.dart';

class RenderingScreen extends ConsumerStatefulWidget {
  const RenderingScreen({super.key});

  @override
  ConsumerState<RenderingScreen> createState() => _RenderingScreenState();
}

class _RenderingScreenState extends ConsumerState<RenderingScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _render();
  }

  Future<void> _render() async {
    try {
      // Memanggil POST /sessions/{id}/render lalu polling sampai output siap
      // (lihat SessionNotifier.renderAndWaitOutput — untuk produksi ganti
      // polling dengan WebSocket event agar lebih responsif).
      await ref.read(sessionProvider.notifier).renderAndWaitOutput();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PrintShareScreen()),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Gagal memproses foto: $_error'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      setState(() => _error = null);
                      _render();
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              )
            : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text('Sedang menyusun hasil fotomu...', style: TextStyle(fontSize: 18)),
                ],
              ),
      ),
    );
  }
}
