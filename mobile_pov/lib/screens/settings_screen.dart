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
  bool _testOk = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tersimpan — buka MULAI untuk memuat ulang frame')),
      );
    }
  }

  Future<void> _reset() async {
    await MobileStorage.resetBaseUrl();
    await MobileStorage.resetToken();
    await _load();
  }

  Future<void> _test() async {
    await _save();
    setState(() { _testing = true; _testResult = null; _testOk = false; });
    try {
      final res = await ApiService().getFrames();
      final frames = res.data['data'] as List;
      setState(() { _testOk = true; _testResult = 'Berhasil: ${frames.length} frame dari server.'; });
    } catch (e) {
      setState(() { _testOk = false; _testResult = 'Gagal: $e'; });
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
                Text('Konfigurasi disimpan lokal (tanpa rebuild). Koneksi via HTTP ke backend.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlCtrl,
                  decoration: InputDecoration(
                    labelText: 'API Base URL',
                    hintText: MobileStorage.defaultBaseUrl,
                    helperText: 'Tanpa /api. Default (kosongkan & reset): ${MobileStorage.defaultBaseUrl}',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tokenCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Studio Token (device_token)',
                    helperText: 'Ambil dari server: php artisan studio:token NamaStudio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.key),
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: _reset, child: const Text('Reset')),
                ]),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _testing ? null : _test,
                    icon: _testing
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.wifi_tethering),
                    label: const Text('Tes Koneksi'),
                  ),
                ),
                if (_testResult != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _testOk ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _testOk ? Colors.green.shade300 : Colors.red.shade300),
                      ),
                      child: Text(
                        _testResult!,
                        style: TextStyle(fontWeight: FontWeight.w600, color: _testOk ? Colors.green.shade800 : Colors.red.shade700),
                      ),
                    ),
                  ),
                const Divider(height: 32),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Cara dapat token'),
                  subtitle: Text('Jalankan di folder backend: php artisan studio:token NamaStudio — token akan dicetak sekali.'),
                ),
                const ListTile(
                  leading: Icon(Icons.phone_android),
                  title: Text('Base URL yang benar'),
                  subtitle: Text('Web/Desktop/iOS sim: http://127.0.0.1:8001 • Android emulator: http://10.0.2.2:8001 • HP asli: http://IP-laptop:8001'),
                ),
              ],
            ),
    );
  }
}