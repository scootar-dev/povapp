import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../state/session_state.dart';
import 'welcome_screen.dart';

class ThankYouScreen extends ConsumerStatefulWidget {
  const ThankYouScreen({super.key});

  @override
  ConsumerState<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends ConsumerState<ThankYouScreen> {
  Timer? _resetTimer;
  Timer? _tick;
  int _remaining = AppConfig.thankYouResetSeconds;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (t){ if(mounted) setState(()=>_remaining = (_remaining-1).clamp(0, AppConfig.thankYouResetSeconds)); });
    _resetTimer = Timer(const Duration(seconds: AppConfig.thankYouResetSeconds), _resetToWelcome);
  }

  Future<void> _resetToWelcome() async {
    await ref.read(sessionProvider.notifier).completeAndReset();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() { _tick?.cancel(); _resetTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.favorite, color: Colors.pinkAccent, size: 72),
            const SizedBox(height: 24),
            const Text('Terima Kasih!', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Sampai jumpa di sesi foto berikutnya', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 24),
            Text('Kembali ke awal dalam $_remaining detik', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 16),
            SizedBox(width: 160, child: LinearProgressIndicator(value: _remaining / AppConfig.thankYouResetSeconds)),
            const SizedBox(height: 24),
            FilledButton(onPressed: _resetToWelcome, child: const Text('Selesai Sekarang')),
          ]),
        ),
      ),
    );
  }
}
