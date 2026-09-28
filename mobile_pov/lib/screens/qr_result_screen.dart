import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config.dart';
import '../state/session_state.dart';
import 'welcome_logo_screen.dart';

class QrResultScreen extends ConsumerWidget {
  final int outputId;
  const QrResultScreen({super.key, required this.outputId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(mobileSessionProvider);
    final qrUrl = '${AppConfig.baseUrl}/api/download/${s.sessionCode}';
    // juga url storage langsung bisa dipakai, tapi QR pakai /download agar public
    return Scaffold(
      appBar: AppBar(title: const Text('Cetak & Unduh'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Foto siap!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Kode sesi: ${s.sessionCode}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                child: QrImageView(data: qrUrl, size: 220),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(qrUrl, style: const TextStyle(fontSize:10, color: Colors.black54), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text('Scan QR untuk mengunduh foto di HP lain\natau cetak langsung dari kiosk', textAlign: TextAlign.center, style: TextStyle(fontSize:12, color: Colors.black54)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: (){}, icon: const Icon(Icons.print), label: const Text('Cetak Sekarang (Kiosk)'))),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () async {
            await ref.read(mobileSessionProvider.notifier).complete();
            ref.read(mobileSessionProvider.notifier).reset();
            if (context.mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_)=> const WelcomeLogoScreen()), (_)=>false);
          }, child: const Text('Selesai — Kembali ke Awal'))),
          const SizedBox(height: 8),
          Text('Stiker dipilih: ${s.stickers.map((e)=>e.sticker.emoji).join(" ")}', style: const TextStyle(fontSize: 11)),
        ]),
      ),
    );
  }
}
