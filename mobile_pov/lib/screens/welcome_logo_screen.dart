import 'package:flutter/material.dart';
import 'frame_sticker_screen.dart';

class WelcomeLogoScreen extends StatelessWidget {
  const WelcomeLogoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const FrameStickerScreen())),
        child: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A0B2E), Color(0xFF6A1FB8)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)]),
                child: const Icon(Icons.camera_alt_rounded, size: 72, color: Color(0xFF6A1FB8)),
              ),
              const SizedBox(height: 24),
              const Text('POV STUDIO', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4)),
              const SizedBox(height: 8),
              const Text('Tap di mana saja untuk mulai', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 32),
              Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)), child: const Text('MULAI', style: TextStyle(color: Color(0xFF6A1FB8), fontWeight: FontWeight.bold))),
            ]),
          ),
        ),
      ),
    );
  }
}
