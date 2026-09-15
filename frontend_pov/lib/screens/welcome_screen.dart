import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../services/dslr_camera_service.dart';
import '../services/internal_camera_service.dart';
import 'admin/admin_dashboard_screen.dart';
import 'frame_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final _internalCamera = InternalCameraService();
  final _dslrCamera = DslrCameraService();

  bool _isDslr = false;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _isDslr = AppConfig.cameraSource == 'dslr';
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (_isDslr) {
      try {
        final connected = await _dslrCamera.connect();
        if (mounted) setState(() => _cameraReady = connected);
      } catch (e) {
        await _internalCamera.initialize();
        if (mounted) {
          setState(() {
            _isDslr = false;
            _cameraReady = true;
          });
        }
      }
    } else {
      await _internalCamera.initialize();
      if (mounted) setState(() => _cameraReady = true);
    }
  }

  Future<void> _showExitPinDialog() async {
    final pinCtrl = TextEditingController();
    String? pinError;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1F0038),
          title: const Row(
            children: [
              Icon(Icons.lock, color: Colors.purpleAccent),
              SizedBox(width: 8),
              Text('PIN Operator (Keluar Kiosk)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan PIN operator untuk kembali ke Admin Event Manager:', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '••••',
                  hintStyle: const TextStyle(color: Colors.white24),
                  errorText: pinError,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
              onPressed: () {
                if (pinCtrl.text.trim() == '1234') {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                    (route) => false,
                  );
                } else {
                  setDialogState(() => pinError = 'PIN Salah! Default PIN: 1234');
                }
              },
              child: const Text('Keluar ke Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    if (_isDslr) {
      _dslrCamera.disconnect();
    } else {
      _internalCamera.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. LIVE CAMERA PREVIEW BACKGROUND
          if (_cameraReady)
            _isDslr
                ? StreamBuilder<Uint8List>(
                    stream: _dslrCamera.livePreviewStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(snapshot.data!, fit: BoxFit.cover);
                      }
                      return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
                    },
                  )
                : CameraPreview(_internalCamera.controller)
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D0B4E), Color(0xFF0D001A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.purpleAccent),
              ),
            ),

          // 2. FUN VIGNETTE OVERLAY
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.purple.withOpacity(0.15),
                  Colors.black.withOpacity(0.75),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Fun Sticker Badges
          Positioned(
            top: 40,
            left: 40,
            child: _buildFunBadge('📸 SELF-SERVICE PHOTOBOOTH', Colors.pinkAccent),
          ),
          Positioned(
            top: 40,
            right: 80,
            child: _buildFunBadge('✨ POSE YOUR BEST!', Colors.amberAccent),
          ),
          Positioned(
            bottom: 120,
            left: 40,
            child: _buildFunBadge('🎉 FUN FILTERS & STRIPS', Colors.cyanAccent),
          ),

          // 3. MAIN INTERACTIVE CONTENT (TAP ANYWHERE TO START)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FrameSelectionScreen()),
              );
            },
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purpleAccent.withOpacity(0.25),
                        border: Border.all(color: Colors.purpleAccent, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.5),
                            blurRadius: 50,
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.touch_app_rounded, size: 90, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'POV PHOTOBOOTH',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          shadows: [
                            const Shadow(blurRadius: 30, color: Colors.purpleAccent),
                            const Shadow(blurRadius: 10, color: Colors.black),
                          ],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.purpleAccent),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: Colors.amberAccent),
                        SizedBox(width: 8),
                        Text(
                          'TOUCH SCREEN TO START / SENTUH UNTUK MULAI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. OPERATOR LOCK / PIN EXIT BUTTON (TOP RIGHT)
          Positioned(
            top: 24,
            right: 24,
            child: IconButton(
              icon: Icon(Icons.lock_outline_rounded, color: Colors.white.withOpacity(0.7), size: 32),
              tooltip: 'Keluar ke Event Manager (PIN)',
              onPressed: _showExitPinDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, shadows: [
          Shadow(blurRadius: 5, color: color),
        ]),
      ),
    );
  }
}
