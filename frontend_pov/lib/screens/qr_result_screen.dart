import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/app_config.dart';
import '../core/responsive.dart';
import '../state/session_state.dart';
import 'welcome_screen.dart';

class QrResultScreen extends ConsumerStatefulWidget {
  const QrResultScreen({super.key});
  @override
  ConsumerState<QrResultScreen> createState() => _QrResultScreenState();
}

class _QrResultScreenState extends ConsumerState<QrResultScreen> {
  bool _printing = false;
  String? _feedback;

  Future<void> _print() async {
    setState(() => _printing = true);
    try {
      await ref.read(sessionProvider.notifier).printResult();
      setState(() => _feedback = 'Perintah cetak terkirim');
    } catch (e) {
      setState(() => _feedback = 'Gagal cetak: $e');
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sessionProvider);
    final qrUrl = '${AppConfig.baseUrl.replaceFirst('/api', '')}/download/${s.sessionCode}';
    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cetak & Unduh'), automaticallyImplyLeading: false),
      body: Padding(
        padding: EdgeInsets.all(Responsive.padding(context)),
        child: isMobile
            ? SingleChildScrollView(
                child: Column(children: [
                  const Text('Foto siap!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Kode: ${s.sessionCode}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                  const SizedBox(height: 16),
                  Center(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: QrImageView(data: qrUrl, size: 200))),
                  const SizedBox(height: 12),
                  SelectableText(qrUrl, style: const TextStyle(fontSize: 10, color: Colors.white54), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _printing ? null : _print, icon: _printing ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.print), label: Text(_printing ? 'Mencetak...' : 'Cetak Sekarang'))),
                  if (_feedback != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_feedback!, style: const TextStyle(color: Colors.greenAccent, fontSize: 12))),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () async { await ref.read(sessionProvider.notifier).completeAndReset(); if (context.mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false); }, child: const Text('Selesai — Kembali ke Awal'))),
                ]),
              )
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Column(children: [const Text('Scan untuk unduh', style: TextStyle(fontSize: 16)), const SizedBox(height: 12), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: QrImageView(data: qrUrl, size: 180)), const SizedBox(height: 8), SelectableText(qrUrl, style: const TextStyle(fontSize: 10, color: Colors.white54)), const SizedBox(height: 12), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _printing ? null : _print, icon: const Icon(Icons.print), label: Text(_printing ? 'Mencetak...' : 'Cetak Sekarang'))), if (_feedback != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_feedback!, style: const TextStyle(color: Colors.greenAccent)))])),
                const VerticalDivider(width: 32),
                Expanded(child: Column(children: [const Text('Sesi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('Kode: ${s.sessionCode}'), const SizedBox(height: 8), Text('Stiker: ${s.stickers.map((e) => e.sticker.emoji).join(" ")}'), const SizedBox(height: 16), SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () async { await ref.read(sessionProvider.notifier).completeAndReset(); if (context.mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false); }, child: const Text('Selesai')))])),
              ]),
      ),
    );
  }
}
