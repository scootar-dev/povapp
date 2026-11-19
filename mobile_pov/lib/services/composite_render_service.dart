import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/frame_model.dart';
import '../models/sticker_model.dart';

class CompositeRenderService {
  CompositeRenderService._();

  static Future<String> renderAndSave({
    required FrameModel frame,
    required List<String> photoPaths,
    required List<PlacedSticker> stickers,
  }) async {
    // Tentukan resolusi cetak 300 DPI
    double outW = 1200;
    double outH = 1800;

    if (frame.printSize.toLowerCase() == '2x6' || frame.photoCount == 3) {
      outW = 1200;
      outH = 3400; // Standar photostrip 2x6
    } else if (frame.photoCount == 4) {
      outW = 1500;
      outH = 2000;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, outW, outH));

    // 1. Gambar Background Frame
    final bgPaint = Paint()..color = frame.backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, outW, outH), bgPaint);

    // Border Frame luar halus
    final borderPaint = Paint()
      ..color = frame.textColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRect(Rect.fromLTWH(12, 12, outW - 24, outH - 24), borderPaint);

    // 2. Gambar Foto pada tiap Slot
    final slots = frame.effectiveSlots;
    for (int i = 0; i < slots.length; i++) {
      final slot = slots[i];
      final slotRect = Rect.fromLTWH(
        slot.x * outW,
        slot.y * outH,
        slot.width * outW,
        slot.height * outH,
      );

      // Gambar placeholder atau foto asli
      if (i < photoPaths.length && File(photoPaths[i]).existsSync()) {
        try {
          final photoImg = await _decodeImage(photoPaths[i]);
          _paintImageCover(canvas, photoImg, slotRect, radius: 16);
        } catch (_) {
          _paintSlotPlaceholder(canvas, slotRect, i + 1, frame.textColor);
        }
      } else {
        _paintSlotPlaceholder(canvas, slotRect, i + 1, frame.textColor);
      }
    }

    // 3. Gambar Footer Branding / Nama Studio
    final footer = frame.footerText ?? 'POV STUDIO';
    final textPainter = TextPainter(
      text: TextSpan(
        text: footer,
        style: TextStyle(
          color: frame.textColor,
          fontSize: outW * 0.038,
          fontWeight: FontWeight.w900,
          letterSpacing: 4.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textX = (outW - textPainter.width) / 2;
    final textY = outH - (outH * 0.05);
    textPainter.paint(canvas, Offset(textX, textY));

    // 4. Gambar Stiker yang Ditempatkan
    for (final placed in stickers) {
      final stickerX = placed.dx * outW;
      final stickerY = placed.dy * outH;
      final stickerSize = outW * 0.12 * placed.scale;

      final stickerPainter = TextPainter(
        text: TextSpan(
          text: placed.sticker.emoji.isNotEmpty ? placed.sticker.emoji : '✨',
          style: TextStyle(fontSize: stickerSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      stickerPainter.paint(canvas, Offset(stickerX, stickerY));
    }

    // 5. Finalisasi Gambar & Simpan ke File
    final picture = recorder.endRecording();
    final img = await picture.toImage(outW.toInt(), outH.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final tempDir = await getApplicationDocumentsDirectory();
    final fileName = 'pov_result_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    return file.path;
  }

  static Future<ui.Image> _decodeImage(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  static void _paintImageCover(
    Canvas canvas,
    ui.Image img,
    Rect destRect, {
    double radius = 16,
  }) {
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(destRect, Radius.circular(radius)));

    final srcW = img.width.toDouble();
    final srcH = img.height.toDouble();
    final destW = destRect.width;
    final destH = destRect.height;

    final srcAspect = srcW / srcH;
    final destAspect = destW / destH;

    Rect srcRect;
    if (srcAspect > destAspect) {
      // Crop kiri-kanan
      final newW = srcH * destAspect;
      final xOffset = (srcW - newW) / 2;
      srcRect = Rect.fromLTWH(xOffset, 0, newW, srcH);
    } else {
      // Crop atas-bawah
      final newH = srcW / destAspect;
      final yOffset = (srcH - newH) / 2;
      srcRect = Rect.fromLTWH(0, yOffset, srcW, newH);
    }

    canvas.drawImageRect(img, srcRect, destRect, Paint()..filterQuality = FilterQuality.high);

    // Border halus di sekeliling foto
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(RRect.fromRectAndRadius(destRect, Radius.circular(radius)), borderPaint);

    canvas.restore();
  }

  static void _paintSlotPlaceholder(
    Canvas canvas,
    Rect destRect,
    int slotNum,
    Color textColor,
  ) {
    final bgPaint = Paint()..color = Colors.grey.shade200;
    canvas.drawRRect(RRect.fromRectAndRadius(destRect, const Radius.circular(16)), bgPaint);

    final border = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(destRect, const Radius.circular(16)), border);

    final tp = TextPainter(
      text: TextSpan(
        text: 'Slot $slotNum',
        style: TextStyle(
          color: textColor.withValues(alpha: 0.6),
          fontSize: destRect.width * 0.1,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(
        destRect.center.dx - (tp.width / 2),
        destRect.center.dy - (tp.height / 2),
      ),
    );
  }
}
