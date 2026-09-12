import 'package:flutter/material.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/responsive.dart';
import 'frame_selection_screen.dart';
import 'settings_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() { super.initState(); WakelockPlus.enable(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FrameSelectionScreen()),
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2D0B4E), Color(0xFF6A1FB8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(Responsive.padding(context)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onLongPress: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    child: Icon(Icons.camera_alt_rounded, size: isMobile ? 72 : 96, color: Colors.white),
                  ),
                  SizedBox(height: isMobile ? 16 : 24),
                  Text(
                    'POV STUDIO',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: isMobile ? 2 : 4, fontSize: isMobile ? 28 : null),
                  ),
                  const SizedBox(height: 12),
                  Text(isMobile ? 'Tap untuk mulai' : 'Sentuh layar untuk mulai',
                      style: TextStyle(color: Colors.white70, fontSize: isMobile ? 16 : 18)),
                  const SizedBox(height: 8),
                  const Text('Tahan lama logo 2 detik untuk Pengaturan', style: TextStyle(color: Colors.white24, fontSize: 10)),
                  if (isMobile) ...[
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FrameSelectionScreen())),
                      child: const Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), child: Text('MULAI')),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
