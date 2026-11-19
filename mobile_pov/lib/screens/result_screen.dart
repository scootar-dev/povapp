import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../state/session_state.dart';
import 'home_screen.dart';

enum PrintFormatPreset {
  photostrip('Photostrip (2x6 inci)', 'Ukuran strip photobooth standar'),
  photo4R('Foto 4R (4x6 inci)', 'Ukuran cetak foto 10 x 15 cm'),
  docA4('Kertas A4', 'Ukuran dokumen kertas penuh');

  final String title;
  final String desc;
  const PrintFormatPreset(this.title, this.desc);

  PdfPageFormat toPdfFormat() {
    switch (this) {
      case PrintFormatPreset.photostrip:
        return const PdfPageFormat(
          2.0 * PdfPageFormat.inch,
          6.0 * PdfPageFormat.inch,
          marginAll: 0,
        );
      case PrintFormatPreset.photo4R:
        return const PdfPageFormat(
          4.0 * PdfPageFormat.inch,
          6.0 * PdfPageFormat.inch,
          marginAll: 0,
        );
      case PrintFormatPreset.docA4:
        return PdfPageFormat.a4;
    }
  }
}

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final _api = ApiService();
  bool _busyPrint = false;
  bool _busyShare = false;

  String _storageUrl(String baseUrl, String? path) =>
      path == null || path.isEmpty ? '' : '$baseUrl/storage/$path';

  Future<void> _showPrintDialog(String baseUrl) async {
    final s = ref.read(mobileSessionProvider);
    final path = s.printPath ?? s.digitalPath;
    if (path == null || baseUrl.isEmpty) {
      _snack('Hasil render belum siap.');
      return;
    }

    final selectedPreset = await showModalBottomSheet<PrintFormatPreset>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Ukuran Cetak',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...PrintFormatPreset.values.map(
                (preset) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade50,
                    child: const Icon(Icons.print, color: Color(0xFF6A1FB8)),
                  ),
                  title: Text(
                    preset.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(preset.desc),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(ctx).pop(preset),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedPreset != null) {
      _executePrint(baseUrl, path, selectedPreset.toPdfFormat());
    }
  }

  Future<void> _executePrint(
    String baseUrl,
    String path,
    PdfPageFormat format,
  ) async {
    final s = ref.read(mobileSessionProvider);
    if (s.sessionId == null) return;

    setState(() => _busyPrint = true);
    int? logId;

    try {
      try {
        final res = await _api.requestPrint(
          s.sessionId!,
          outputId: s.printOutputId,
        );
        logId = res.data['data']['id'] as int?;
      } catch (_) {}

      final bytes = await _api.fetchStorageBytes(path);
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: format,
          build: (ctx) => pw.Center(
            child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
          ),
        ),
      );

      final printed = await Printing.layoutPdf(
        onLayout: (pdfFormat) async => doc.save(),
      );

      if (logId != null) {
        await _api.updatePrintStatus(logId, printed ? 'completed' : 'failed');
      }
      if (printed) _snack('Perintah cetak berhasil dikirim.');
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

  Future<void> _shareLink(String downloadUrl) async {
    final s = ref.read(mobileSessionProvider);
    if (s.sessionId == null || downloadUrl.isEmpty) {
      _snack('Link download belum tersedia.');
      return;
    }

    setState(() => _busyShare = true);
    try {
      await Share.share(
        'Lihat dan unduh foto POV Studio saya di: $downloadUrl',
      );
      await _api.recordShare(s.sessionId!, 'link', sharedWith: downloadUrl);
      _snack('Link berhasil dibagikan.');
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
    final downloadUrl = s.sessionCode == null
        ? ''
        : '$baseUrl/download/${s.sessionCode}';
    final imageUrl = _storageUrl(baseUrl, s.digitalPath ?? s.printPath);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Foto POV Studio'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Session Code Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Kode Sesi: ${s.sessionCode ?? "-"}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Image Render Output Preview
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.photo_outlined, size: 48, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Pratinjau sedang diproses...'),
                                ],
                              ),
                            ),
                          )
                        : const Center(
                            child: Text('Hasil foto belum siap'),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // QR Code Download Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: downloadUrl.isNotEmpty
                          ? QrImageView(
                              data: downloadUrl,
                              size: 96,
                            )
                          : const SizedBox(
                              width: 96,
                              height: 96,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.qr_code_scanner, size: 18, color: Color(0xFF6A1FB8)),
                              SizedBox(width: 6),
                              Text(
                                'Scan untuk Unduh Foto',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Arahkan kamera HP Anda ke kode QR untuk mengunduh foto digital beresolusi tinggi.',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _busyShare ? null : () => _shareLink(downloadUrl),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_busyShare)
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                else
                                  Icon(Icons.share, size: 14, color: Colors.purple.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  'Bagikan Link',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _busyPrint ? null : () => _showPrintDialog(baseUrl),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1FB8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _busyPrint
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.print_rounded),
                        label: const Text(
                          'Cetak Foto',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () async {
                        await ref.read(mobileSessionProvider.notifier).complete();
                        ref.read(mobileSessionProvider.notifier).reset();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (_) => false,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Selesai'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
