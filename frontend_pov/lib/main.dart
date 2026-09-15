import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_config.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(const ProviderScope(child: PovStudioApp()));
}

class PovStudioApp extends StatelessWidget {
  const PovStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POV Studio',
      debugShowCheckedModeBanner: false,
      // Kiosk selalu landscape & tidak boleh idle-timeout OS — atur di
      // main native (AndroidManifest / Info.plist) untuk kiosk mode penuh.
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: const WelcomeScreen(),
    );
  }
}
