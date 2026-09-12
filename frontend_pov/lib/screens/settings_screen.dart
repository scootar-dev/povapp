import 'package:flutter/material.dart';
import '../core/storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    _urlCtrl.text = await KioskStorage.getBaseUrl();
    _tokenCtrl.text = await KioskStorage.getToken();
    if (mounted) setState(()=>_loading=false);
  }

  Future<void> _save() async {
    setState(()=>_saving=true);
    await KioskStorage.saveBaseUrl(_urlCtrl.text.trim());
    await KioskStorage.saveToken(_tokenCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tersimpan — restart sesi untuk pakai config baru')));
      setState(()=>_saving=false);
    }
  }

  @override
  void dispose() { _urlCtrl.dispose(); _tokenCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan Kiosk')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Konfigurasi ini disimpan lokal (SharedPreferences), tanpa rebuild.', style: TextStyle(fontSize:12, color: Colors.white54)),
          const SizedBox(height: 16),
          TextField(controller: _urlCtrl, decoration: const InputDecoration(labelText: 'API Base URL', hintText: 'http://localhost:8000/api', border: OutlineInputBorder(), prefixIcon: Icon(Icons.link)), keyboardType: TextInputType.url),
          const SizedBox(height: 12),
          TextField(controller: _tokenCtrl, decoration: const InputDecoration(labelText: 'Studio Token (device_token)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.key)), maxLines: 2, minLines: 1),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _saving?null:_save, icon: _saving? const SizedBox(width:14,height:14,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)): const Icon(Icons.save), label: const Text('Simpan'))),
          const SizedBox(height: 12),
          const Divider(),
          const ListTile(leading: Icon(Icons.info), title: Text('Cara dapat token'), subtitle: Text('Di backend: php artisan tinker -> Studio::pluck("device_token") atau via Admin Dashboard -> Studios')),
          const ListTile(leading: Icon(Icons.wifi), title: Text('Tes koneksi'), subtitle: Text('Gunakan IP laptop jika HP & laptop beda device. Emulator Android pakai 10.0.2.2:8000')),
        ],
      ),
    );
  }
}
