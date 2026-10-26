import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../state/session_state.dart';
import 'welcome_logo_screen.dart';

class QrResultScreen extends ConsumerStatefulWidget {
  final int outputId;
  const QrResultScreen({super.key, required this.outputId});

  @override
  ConsumerState<QrResultScreen> createState() => _QrResultScreenState();
}

class _QrResultScreenState extends ConsumerState<QrResultScreen> {
  final _api = ApiService();
  bool _busyPrint = false;
  bool _busyShare = false;

  String _storageUrl(String baseUrl, String? path) =>
      path == null || path.isEmpty ? '' : '$baseUrl/storage/$path';

  Future<void> _print(String baseUrl) async {
    final s = ref.read(mobileSessionProvider);
    final path = s.printPath ?? s.digitalPath;
    if (s.sessionId == null || path == null || baseUrl.isEmpty) {
      _snack('Hasil render belum siap.');
      return;
    }

    setState(() => _busyPrint = true);
    int? logId;
    try {
      try {
        final res = await _api.requestPrint(s.sessionId!, outputId: s.printOutputId);
        logId = res.data['data']['id'] as int?;
      } catch (_) {}

      final bytes = await _api.fetchStorageBytes(path);
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Center(
            child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
          ),
        ),
      );

      final printed = await Printing.layoutPdf(onLayout: (format) async => doc.save());

      if (logId != null) {
        await _api.updatePrintStatus(logId, printed ? 'completed' : 'failed');
      }
      if (printed) _snack('Perintah cetak dikirim.');
    } catch (e) {
      if (logId != null) {
        try {
          await _api.updatePrintStatus(logId, 'failed');
        } catch (_) {}
      }
      _snack('Gagal mencetak: $e');
    } finally {
      if (mounted) setState(() => _busyPrint = false);
    }
  }

  Future<void> _share(String downloadUrl) async {
    final s = ref.read(mobileSessionProvider);
    if (s.sessionId == null || downloadUrl.isEmpty) {
      _snack('Link download belum siap.');
      return;
    }

    setState(() => _busyShare = true);
    try {
      await Share.share(downloadUrl);
      await _api.recordShare(s.sessionId!, 'link', sharedWith: downloadUrl);
      _snack('Link dibagikan.');
    } catch (e) {
      _snack('Gagal membagikan: $e');
    } finally {
      if (mounted) setState(() => _busyShare = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(mobileSessionProvider);
    final baseUrl = ref.watch(baseUrlProvider).valueOrNull ?? '';
    final downloadUrl = s.sessionCode == null ? '' : '$baseUrl/download/${s.sessionCode}';
    final imageUrl = _storageUrl(baseUrl, s.digitalPath ?? s.printPath);

    return Scaffold(
      appBar: AppBar(title: const Text('Cetak & Unduh'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Foto siap!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Kode sesi: ${s.sessionCode}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 12),
          Expanded(
            child: imageUrl.isEmpty
                ? const Center(child: Text('Hasil render belum tersedia.'))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image, size: 64)),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: QrImageView(data: downloadUrl, size: 120),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Scan QR untuk mengunduh', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                SelectableText(downloadUrl, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                const SizedBox(height: 8),
                const Text(
                  'Buka link di HP lain atau bagikan ke teman.',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busyPrint ? null : () => _print(baseUrl),
              icon: _busyPrint
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.print),
              label: const Text('Cetak Sekarang (Kiosk)'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _busyShare ? null : () => _share(downloadUrl),
              icon: _busyShare
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.share),
              label: const Text('Bagikan Link'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                await ref.read(mobileSessionProvider.notifier).complete();
                ref.read(mobileSessionProvider.notifier).reset();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeLogoScreen()),
                    (_) => false,
                  );
                }
              },
              child: const Text('Selesai — Kembali ke Awal'),
            ),
          ),
          Text(
            'Stiker dipilih: ${s.stickers.map((e) => e.sticker.name).join(", ")}',
            style: const TextStyle(fontSize: 11),
          ),
        ]),
      ),
    );
  }
}
