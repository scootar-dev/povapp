import 'dart:io';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Mencetak langsung ke printer default tanpa menampilkan dialog print OS,
/// sesuai requirement UX photobooth (customer tidak boleh lihat dialog print).
///
/// - iPad: `printing` package memakai AirPrint di balik layar; dengan
///   `Printing.directPrintPdf` ke printer yang sudah dipilih/di-pair sebagai
///   default, dialog native tidak muncul.
/// - Windows: gunakan `Printing.directPrintPdf` dengan printer Epson yang
///   sudah di-set sebagai default OS printer, atau panggil Epson ePOS SDK
///   lewat platform channel jika printer model khusus (mis. Epson photo
///   printer non-standar driver).
class PrintService {
  /// Printer dipilih SEKALI saat setup kios (mis. lewat layar admin/setup
  /// terpisah yang memanggil `Printing.pickPrinter(context: ...)` dengan
  /// BuildContext asli), lalu disimpan di sini untuk dipakai berulang tanpa
  /// dialog muncul lagi tiap sesi pelanggan.
  Printer? savedPrinter;

  /// Dipanggil sekali dari layar setup (yang punya BuildContext) untuk
  /// membiarkan admin memilih printer default kios.
  Future<void> pickAndSavePrinter(BuildContext context) async {
    savedPrinter = await Printing.pickPrinter(context: context);
  }

  /// Konversi file gambar hasil render (JPEG 300 DPI) menjadi PDF satu halaman
  /// berukuran sesuai print_size (4R atau strip 2x6), lalu kirim langsung ke
  /// `savedPrinter` — tidak ada dialog yang muncul di sini.
  Future<void> printImageDirect({
    required String imageFilePath,
    required String printSize, // '4r' | 'strip_2x6'
  }) async {
    if (savedPrinter == null) {
      throw StateError(
        'Printer belum di-setup. Panggil pickAndSavePrinter() sekali saat setup kios.',
      );
    }

    final imageBytes = File(imageFilePath).readAsBytesSync();
    final image = pw.MemoryImage(imageBytes);

    // 1 inch = 72 point (satuan PdfPageFormat).
    final pageFormat = printSize == 'strip_2x6'
        ? const PdfPageFormat(2 * 72, 6 * 72) // strip 2x6 inch
        : const PdfPageFormat(4 * 72, 6 * 72); // 4R (4x6 inch)

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.Image(image, fit: pw.BoxFit.cover),
      ),
    );

    await Printing.directPrintPdf(
      printer: savedPrinter!,
      onLayout: (_) => doc.save(),
    );
  }
}
