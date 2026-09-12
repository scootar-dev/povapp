import 'package:flutter/material.dart';
import '../models/frame_model.dart';

/// Overlay kiosk: gambar kotak slot foto di atas preview kamera.
/// Skala proporsional ke ukuran widget, highlight slot aktif (sedang countdown).
class FrameOverlay extends StatelessWidget {
  final FrameModel frame;
  final int activeSlot;
  const FrameOverlay({super.key, required this.frame, required this.activeSlot});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      return CustomPaint(
        size: Size(w, h),
        painter: _OverlayPainter(frame: frame, activeSlot: activeSlot, previewSize: Size(w, h)),
      );
    });
  }
}

class _OverlayPainter extends CustomPainter {
  final FrameModel frame;
  final int activeSlot;
  final Size previewSize;
  _OverlayPainter({required this.frame, required this.activeSlot, required this.previewSize});

  @override
  void paint(Canvas canvas, Size size) {
    // Jika tidak ada slot data (frame.slots kosong), fallback grid 2 kolom sederhana
    List<Rect> rects;
    if (frame.slots.isEmpty) {
      final cols = frame.photoCount == 2 ? 2 : 2;
      final rows = (frame.photoCount / cols).ceil();
      final cw = size.width / cols;
      final ch = size.height / rows;
      rects = List.generate(frame.photoCount, (i) {
        final r = i ~/ cols;
        final c_ = i % cols;
        return Rect.fromLTWH(c_ * cw + 12, r * ch + 12, cw - 24, ch - 24);
      });
    } else {
      // Normalisasi slot dari koordinat output_px ke preview size
      // Asumsi outputWidth ~ 1200, outputHeight ~ 800 (fallback 1200x800)
      // Kita pakai bounding box dari slots untuk scale
      final maxX = frame.slots.map((s) => s.x + s.width).reduce((a, b) => a > b ? a : b);
      final maxY = frame.slots.map((s) => s.y + s.height).reduce((a, b) => a > b ? a : b);
      final scaleX = size.width / (maxX == 0 ? 1200 : maxX);
      final scaleY = size.height / (maxY == 0 ? 800 : maxY);
      final scale = scaleX < scaleY ? scaleX : scaleY;
      final offsetX = (size.width - maxX * scale) / 2;
      final offsetY = (size.height - maxY * scale) / 2;
      rects = frame.slots.map((s) => Rect.fromLTWH(s.x * scale + offsetX, s.y * scale + offsetY, s.width * scale, s.height * scale)).toList();
    }

    // Darken luar slot
    final bg = Paint()..color = Colors.black.withValues(alpha: 0.45);
    final pathBg = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    for (final r in rects) {
      pathBg.addRect(r);
      pathBg.fillType = PathFillType.evenOdd;
    }
    // Gunakan evenOdd: tidak sempurna untuk multi rect, jadi fallback draw 4 luar rects manual
    // Sederhana: gambar overlay full lalu clear hole via blendMode
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);
    // Clear holes
    final clear = Paint()..color = Colors.transparent..blendMode = BlendMode.clear;
    for (final r in rects) {
      canvas.saveLayer(r, Paint());
      canvas.drawRect(r, clear);
      canvas.restore();
    }

    // Border untuk tiap slot
    for (int i = 0; i < rects.length; i++) {
      final isActive = i == activeSlot;
      final paint = Paint()
        ..color = isActive ? Colors.white : Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 3 : 1.5;
      canvas.drawRRect(RRect.fromRectAndRadius(rects[i], const Radius.circular(8)), paint);
      // Label slot
      final tp = TextPainter(
        text: TextSpan(text: 'SLOT ${i + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rects[i].center.dx - tp.width / 2, rects[i].center.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) => old.activeSlot != activeSlot || old.frame.id != frame.id;
}
