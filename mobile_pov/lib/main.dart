import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/welcome_logo_screen.dart';

void main() => runApp(const ProviderScope(child: PovCustomerApp()));

class PovCustomerApp extends StatelessWidget {
  const PovCustomerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POV Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple, brightness: Brightness.light),
      home: const WelcomeLogoScreen(),
    );
  }
}
