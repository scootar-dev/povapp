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
  int _attempt = 0;
  bool _cancelled = false;

  @override
  void initState() { super.initState(); _render(); }

  Future<void> _render() async {
    try {
      await ref.read(sessionProvider.notifier).renderAndWaitOutput(onTick: (i){ if(mounted) setState(()=>_attempt=i); if(_cancelled) throw Exception('Dibatalkan'); });
      if (_cancelled) return;
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PrintShareScreen()));
    } catch (e) {
      if (_cancelled) return;
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_attempt / 30).clamp(0.0, 1.0);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _error != null
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text('Gagal memproses foto', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 16),
                  Wrap(spacing: 12, children: [
                    FilledButton(onPressed: () { setState(()=>_error=null); _render(); }, child: const Text('Coba Lagi')),
                    OutlinedButton(onPressed: ()=>Navigator.of(context).pop(), child: const Text('Kembali')),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Pastikan queue worker jalan: php artisan queue:listen', style: TextStyle(fontSize: 10, color: Colors.white24)),
                ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: 120, height: 120, child: Stack(alignment: Alignment.center, children: [
                    CircularProgressIndicator(value: progress==0?null:progress, strokeWidth: 6),
                    Text('${(progress*100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])),
                  const SizedBox(height: 24),
                  const Text('Sedang menyusun hasil fotomu...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Percobaan ${_attempt+1}/30 • 2 detik interval', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 24),
                  TextButton(onPressed: (){ setState(()=>_cancelled=true); Navigator.of(context).pop(); }, child: const Text('Batal')),
                ]),
        ),
      ),
    );
  }
}
