import 'dart:io';
import 'dart:typed_data';
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

  Future<void> _showPrintDialog(String baseUrl) async {
    final s = ref.read(mobileSessionProvider);
    final localPath = s.localCompositePath;
    final serverPath = s.printPath ?? s.digitalPath;

    if ((localPath == null || !File(localPath).existsSync()) &&
        (serverPath == null || baseUrl.isEmpty)) {
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
                'Pilih Ukuran Kertas Cetak',
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
      _executePrint(selectedPreset.toPdfFormat());
    }
  }

  Future<void> _executePrint(PdfPageFormat format) async {
    final s = ref.read(mobileSessionProvider);
    setState(() => _busyPrint = true);

    try {
      List<int> bytes;
      if (s.localCompositePath != null &&
          File(s.localCompositePath!).existsSync()) {
        bytes = await File(s.localCompositePath!).readAsBytes();
      } else if (s.printPath != null) {
        bytes = await _api.fetchStorageBytes(s.printPath!);
      } else {
        throw Exception('File foto komposit tidak ditemukan');
      }

      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: format,
          build: (ctx) => pw.Center(
            child: pw.Image(
              pw.MemoryImage(Uint8List.fromList(bytes)),
              fit: pw.BoxFit.contain,
            ),
          ),
        ),
      );

      final printed = await Printing.layoutPdf(
        onLayout: (pdfFormat) async => doc.save(),
      );

      if (printed) _snack('Perintah cetak berhasil dikirim.');
    } catch (e) {
      _snack('Gagal mencetak: $e');
    } finally {
      if (mounted) setState(() => _busyPrint = false);
    }
  }

  Future<void> _sharePhoto(String downloadUrl) async {
    final s = ref.read(mobileSessionProvider);
    setState(() => _busyShare = true);

    try {
      if (s.localCompositePath != null &&
          File(s.localCompositePath!).existsSync()) {
        await Share.shareXFiles(
          [XFile(s.localCompositePath!)],
          text: 'Hasil foto POV Studio Photobooth! Unduh juga di: $downloadUrl',
        );
      } else if (downloadUrl.isNotEmpty) {
        await Share.share('Lihat dan unduh foto POV Studio saya di: $downloadUrl');
      } else {
        _snack('File foto tidak tersedia untuk dibagikan.');
      }
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
    final code = s.sessionCode ?? 'POV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final downloadUrl = baseUrl.isNotEmpty ? '$baseUrl/download/$code' : 'https://povstudio.id/download/$code';

    final localPath = s.localCompositePath;
    final hasLocalImage = localPath != null && File(localPath).existsSync();

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
              // Badge Kode Sesi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Kode Sesi: $code',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Pratinjau Gambar Hasil Komposit (Frame + Foto + Stiker)
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: hasLocalImage
                        ? Image.file(
                            File(localPath),
                            fit: BoxFit.contain,
                          )
                        : (s.printPath != null && baseUrl.isNotEmpty)
                            ? Image.network(
                                '$baseUrl/storage/${s.printPath}',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(Icons.broken_image, size: 48),
                                ),
                              )
                            : const Center(
                                child: Text('Hasil foto sedang disiapkan...'),
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Kartu QR Code Unduh
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
                      child: QrImageView(
                        data: downloadUrl,
                        size: 92,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.qr_code_scanner, size: 18, color: Color(0xFF6A1FB8)),
                              SizedBox(width: 6),
                              Text(
                                'Scan QR untuk Unduh',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Scan dengan kamera HP lain untuk mengunduh foto digital resolusi tinggi.',
                            style: TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _busyShare ? null : () => _sharePhoto(downloadUrl),
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
                                  'Bagikan / Simpan Foto',
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
              const SizedBox(height: 10),

              // Tombol Cetak & Selesai
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
