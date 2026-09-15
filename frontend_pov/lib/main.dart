import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_config.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.load();
  runApp(const ProviderScope(child: PovStudioApp()));
}

class PovStudioApp extends StatelessWidget {
  const PovStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    // If admin is authenticated, open Admin Dashboard Launcher; otherwise open Admin Login.
    final initialHome = AppConfig.adminToken.isNotEmpty
        ? const AdminDashboardScreen()
        : const AdminLoginScreen();

    return MaterialApp(
      title: 'POV Studio Booth Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.purple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F071A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF190A2D),
          elevation: 0,
        ),
      ),
      home: initialHome,
    );
  }
}
