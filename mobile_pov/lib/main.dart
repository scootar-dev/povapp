import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const PovCustomerApp());

class PovCustomerApp extends StatelessWidget {
  const PovCustomerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POV Customer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple, brightness: Brightness.light),
      home: const HomeScreen(),
    );
  }
}
