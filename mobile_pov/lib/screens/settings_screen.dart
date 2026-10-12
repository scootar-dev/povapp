import 'package:flutter/material.dart';

import '../core/storage.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  bool _loading = true;
  bool _testing = false;
  String? _testResult;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    _urlCtrl.text = await MobileStorage.getBaseUrl();
    _tokenCtrl.text = await MobileStorage.getToken();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    await MobileStorage.saveBaseUrl(_urlCtrl.text.trim());
    await MobileStorage.saveToken(_tokenCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tersimpan — refresh layar frame untuk memuat ulang')));
    }
  }

  Future<void> _test() async {
    await _save();
    setState(() { _testing = true; _testResult = null; });
    try {
      final res = await ApiService().getFrames();
      final frames = res.data['data'] as List;
      setState(() => _testResult = 'Berhasil: ${frames.length} frame dari server.');
    } catch (e) {
      setState(() => _testResult = 'Gagal: $e');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  void dispose() { _urlCtrl.dispose(); _tokenCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Konfigurasi disimpan lokal (tanpa rebuild).', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'API Base URL',
                    hintText: 'http://10.0.2.2:8000',
                    helperText: 'Tanpa /api di belakang',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tokenCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Studio Token (device_token)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.key),
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Simpan'))),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _testing ? null : _test, icon: _testing ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.wifi_tethering), label: const Text('Tes Koneksi'))),
                if (_testResult != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_testResult!, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  ),
                const Divider(height: 32),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Cara dapat token'),
                  subtitle: Text('Dari backend: php artisan tinker → Studio::pluck("device_token")'),
                ),
                const ListTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('Uji di device'),
                  subtitle: Text('Gunakan IP laptop (mis. http://192.168.1.5:8000) jika HP dan laptop di jaringan berbeda. Emulator Android pakai 10.0.2.2:8000.'),
                ),
              ],
            ),
    );
  }
}