import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../models/photo_model.dart';

/// Menerapkan filter warna secara lokal untuk preview realtime (ColorFiltered)
/// dan untuk encoding final sebelum upload jika diperlukan.
class FilterService {
  /// Mengembalikan bytes JPEG hasil filter — untuk preview bytes atau re-upload.
  /// Sinkron untuk foto kecil (800x600). Untuk UI janky, pakai [applyFilterAsync].
  Uint8List applyFilter(String sourceFilePath, PhotoColorFilter filter) {
    final bytes = File(sourceFilePath).readAsBytesSync();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Gagal membaca file foto: $sourceFilePath');
    }

    image = _applyToImage(image, filter);
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  /// Versi async agar tidak block UI thread.
  Future<Uint8List> applyFilterAsync(String sourceFilePath, PhotoColorFilter filter) async {
    final bytes = await File(sourceFilePath).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) throw Exception('Gagal decode: $sourceFilePath');
    image = _applyToImage(image, filter);
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  img.Image _applyToImage(img.Image image, PhotoColorFilter filter) {
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
    return image;
  }

  /// Matriks 4x5 untuk [ColorFiltered] — preview realtime tanpa decode ulang.
  /// Dipakai di FilterScreen & PreviewRetake untuk overlay.
  static List<double> colorMatrix(PhotoColorFilter filter) {
    switch (filter) {
      case PhotoColorFilter.original:
        return const [
          1, 0, 0, 0, 0,
          0, 1, 0, 0, 0,
          0, 0, 1, 0, 0,
          0, 0, 0, 1, 0,
        ];
      case PhotoColorFilter.natural:
        // slight saturation + brightness via contrast trick
        return const [
          1.05, 0, 0, 0, 5,
          0, 1.05, 0, 0, 5,
          0, 0, 1.05, 0, 5,
          0, 0, 0, 1, 0,
        ];
      case PhotoColorFilter.cold:
        return const [
          1, 0, 0, 0, -10,
          0, 1, 0, 0, 0,
          0, 0, 1, 0, 20,
          0, 0, 0, 1, 0,
        ];
      case PhotoColorFilter.warm:
        return const [
          1, 0, 0, 0, 20,
          0, 1, 0, 0, 8,
          0, 0, 1, 0, -10,
          0, 0, 0, 1, 0,
        ];
      case PhotoColorFilter.blackWhite:
        // luminance grayscale
        return const [
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ];
      case PhotoColorFilter.vintage:
        // sepia matrix
        return const [
          0.393, 0.769, 0.189, 0, 0,
          0.349, 0.686, 0.168, 0, 0,
          0.272, 0.534, 0.131, 0, 0,
          0, 0, 0, 1, 0,
        ];
    }
  }

  static ColorFilter colorFilter(PhotoColorFilter filter) =>
      ColorFilter.matrix(colorMatrix(filter));
}
