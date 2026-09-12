import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(const PovAdminApp());

class PovAdminApp extends StatelessWidget {
  const PovAdminApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POV Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _hasToken;
  @override
  void initState() { super.initState(); _check(); }
  Future<void> _check() async {
    final p = await SharedPreferences.getInstance();
    setState(()=>_hasToken = p.getString('admin_token')!=null);
  }
  @override
  Widget build(BuildContext context) {
    if (_hasToken==null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return _hasToken! ? const DashboardScreen() : const LoginScreen();
  }
}
