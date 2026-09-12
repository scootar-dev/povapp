import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(text: 'admin@example.com');
  final _pass = TextEditingController(text: 'password');
  bool _loading = false;
  String? _err;

  Future<void> _login() async {
    setState(()=>_loading=true);
    try {
      final res = await ApiService.instance.login(_email.text.trim(), _pass.text);
      final token = res.data['data']['token'] as String;
      await ApiService.instance.saveToken(token);
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>const DashboardScreen()));
    } catch (e) {
      setState(()=>_err='Login gagal: $e');
    } finally { if (mounted) setState(()=>_loading=false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A0B2E), Color(0xFF6A1FB8)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              margin: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.admin_panel_settings, size: 48, color: Colors.deepPurple),
                  const SizedBox(height: 12),
                  const Text('POV Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email))),
                  const SizedBox(height: 12),
                  TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)), onSubmitted: (_)=>_login()),
                  if (_err!=null) Padding(padding: const EdgeInsets.only(top:12), child: Text(_err!, style: const TextStyle(color: Colors.red, fontSize:12))),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, child: FilledButton(onPressed: _loading?null:_login, child: Padding(padding: const EdgeInsets.symmetric(vertical:14), child: _loading? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)): const Text('Login')))),
                  const SizedBox(height: 8),
                  const Text('Default: admin@example.com / password', style: TextStyle(fontSize:10, color: Colors.black54)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
