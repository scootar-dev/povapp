import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage.dart';
import '../services/api_service.dart';
import '../state/session_state.dart';

Future<void> showServerSettingsDialog(BuildContext context, WidgetRef ref) async {
  final current = await MobileStorage.getBaseUrl();
  final ctrl = TextEditingController(text: current);
  bool isTesting = false;
  String? testResult;
  bool testSuccess = false;

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings_ethernet, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Pengaturan Server IP', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan alamat IP dan port komputer host yang menjalankan povstudio_admin (Laravel):',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  labelText: 'URL Server Backend',
                  hintText: 'http://192.168.x.x:8000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 8),
              const Text(
                'Contoh: http://192.168.100.4:8000\nPastikan HP dan komputer terhubung ke Wi-Fi yang sama.',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              if (testResult != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: testSuccess ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: testSuccess ? Colors.green : Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        testSuccess ? Icons.check_circle : Icons.error,
                        color: testSuccess ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          testResult!,
                          style: TextStyle(
                            fontSize: 12,
                            color: testSuccess ? Colors.green.shade900 : Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isTesting
                      ? null
                      : () async {
                          setState(() {
                            isTesting = true;
                            testResult = null;
                          });
                          final ok = await ApiService().testConnection(ctrl.text.trim());
                          if (context.mounted) {
                            setState(() {
                              isTesting = false;
                              testSuccess = ok;
                              testResult = ok
                                  ? 'Berhasil terhubung ke server!'
                                  : 'Gagal terhubung! Cek IP atau pastikan php artisan serve --host=0.0.0.0 aktif.';
                            });
                          }
                        },
                  icon: isTesting
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.wifi_tethering, size: 18),
                  label: Text(isTesting ? 'Mengetes...' : 'Tes Koneksi'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await MobileStorage.resetBaseUrl();
              ref.invalidate(baseUrlProvider);
              ref.invalidate(framesProvider);
              ref.invalidate(stickersProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Reset Default', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () async {
              final newUrl = ctrl.text.trim();
              if (newUrl.isNotEmpty) {
                await MobileStorage.setBaseUrl(newUrl);
                ref.invalidate(baseUrlProvider);
                ref.invalidate(framesProvider);
                ref.invalidate(stickersProvider);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ),
  );
}
