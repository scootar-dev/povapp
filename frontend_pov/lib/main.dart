import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/kiosk_idle.dart';
import 'screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PovStudioApp()));
}

class PovStudioApp extends StatelessWidget {
  const PovStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POV Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromARGB(255, 228, 227, 231),
        brightness: Brightness.dark,
      ),
      builder: (ctx, child) => KioskIdleWrapper(child: child!),
      home: const WelcomeScreen(),
    );
  }
}