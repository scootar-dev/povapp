import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import '../models/photo_model.dart';

/// Menerapkan filter warna dasar secara lokal (tidak perlu round-trip ke server),
/// supaya preview di layar Preview & Retake bisa realtime.
class FilterService {
  /// Mengembalikan bytes JPEG hasil filter, siap dipakai untuk preview
  /// (Image.memory) maupun disimpan ulang ke file sebelum di-render final.
  Uint8List applyFilter(String sourceFilePath, PhotoColorFilter filter) {
    final bytes = File(sourceFilePath).readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Gagal membaca file foto: $sourceFilePath');
    }

    switch (filter) {
      case PhotoColorFilter.original:
        break;
      case PhotoColorFilter.natural:
        image = img.adjustColor(image, saturation: 1.1, brightness: 1.02);
        break;
      case PhotoColorFilter.cold:
        image = img.colorOffset(image, red: -10, green: 0, blue: 20);
        image = img.adjustColor(image, saturation: 1.05);
        break;
      case PhotoColorFilter.warm:
        image = img.colorOffset(image, red: 20, green: 8, blue: -10);
        break;
      case PhotoColorFilter.blackWhite:
        image = img.grayscale(image);
        break;
      case PhotoColorFilter.vintage:
        image = img.sepia(image);
        image = img.adjustColor(image, contrast: 0.95, brightness: 0.98);
        break;
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }
}
