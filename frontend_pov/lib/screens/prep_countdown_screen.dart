import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../services/timer_service.dart';
import 'shoot_screen.dart';

class PrepCountdownScreen extends ConsumerStatefulWidget {
  const PrepCountdownScreen({super.key});

  @override
  ConsumerState<PrepCountdownScreen> createState() => _PrepCountdownScreenState();
}

class _PrepCountdownScreenState extends ConsumerState<PrepCountdownScreen> {
  final _timerService = TimerService();
  int _remaining = AppConfig.prepTimerSeconds;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  Future<void> _startTimer() async {
    _timerService.tick.listen((value) {
      if (mounted) setState(() => _remaining = value);
    });

    await _timerService.runPrepTimer(AppConfig.prepTimerSeconds);

    if (mounted) _goToShoot();
  }

  void _onSiapPressed() {
    // Speed-up: memotong sisa waktu persiapan langsung menuju countdown pemotretan.
    _timerService.speedUp();
  }

  void _goToShoot() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ShootScreen()),
    );
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bersiap-siap!',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Text(
              '$_remaining',
              style: const TextStyle(color: Colors.white, fontSize: 120, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _onSiapPressed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                textStyle: const TextStyle(fontSize: 22),
              ),
              child: const Text('Siap / Jepret Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
