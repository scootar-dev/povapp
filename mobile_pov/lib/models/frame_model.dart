import 'package:flutter/material.dart';

class FrameSlot {
  final int slotIndex;
  final double x, y, width, height, rotation;

  const FrameSlot({
    required this.slotIndex,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0,
  });

  factory FrameSlot.fromJson(Map<String, dynamic> j) => FrameSlot(
        slotIndex: j['slot_index'] ?? 0,
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        width: (j['width'] as num).toDouble(),
        height: (j['height'] as num).toDouble(),
        rotation: (j['rotation'] as num?)?.toDouble() ?? 0,
      );
}

class FrameModel {
  final int id;
  final String name;
  final String? category;
  final String? thumbnailPath;
  final String? overlayPath;
  final int photoCount;
  final String printSize;
  final List<FrameSlot> slots;
  final Color backgroundColor;
  final Color textColor;
  final String? footerText;

  const FrameModel({
    required this.id,
    required this.name,
    this.category,
    this.thumbnailPath,
    this.overlayPath,
    required this.photoCount,
    required this.printSize,
    this.slots = const [],
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.footerText = 'POV STUDIO',
  });

  double get aspectRatio {
    if (printSize.toLowerCase() == '2x6' || photoCount == 3) {
      return 0.35; // Vertikal strip 2x6
    } else if (photoCount == 4) {
      return 0.75; // 2x2 grid
    } else {
      return 0.67; // 4x6 / 4R
    }
  }

  /// Menghasilkan slot yang terisi secara proporsional jika slots kosong
  List<FrameSlot> get effectiveSlots {
    if (slots.isNotEmpty) return slots;

    if (photoCount == 1) {
      return const [
        FrameSlot(slotIndex: 0, x: 0.08, y: 0.06, width: 0.84, height: 0.80),
      ];
    } else if (photoCount == 2) {
      return const [
        FrameSlot(slotIndex: 0, x: 0.08, y: 0.05, width: 0.84, height: 0.40),
        FrameSlot(slotIndex: 1, x: 0.08, y: 0.50, width: 0.84, height: 0.40),
      ];
    } else if (photoCount == 4) {
      return const [
        FrameSlot(slotIndex: 0, x: 0.06, y: 0.05, width: 0.42, height: 0.40),
        FrameSlot(slotIndex: 1, x: 0.52, y: 0.05, width: 0.42, height: 0.40),
        FrameSlot(slotIndex: 2, x: 0.06, y: 0.48, width: 0.42, height: 0.40),
        FrameSlot(slotIndex: 3, x: 0.52, y: 0.48, width: 0.42, height: 0.40),
      ];
    } else {
      // Default 3 foto vertikal (strip)
      return const [
        FrameSlot(slotIndex: 0, x: 0.08, y: 0.05, width: 0.84, height: 0.26),
        FrameSlot(slotIndex: 1, x: 0.08, y: 0.34, width: 0.84, height: 0.26),
        FrameSlot(slotIndex: 2, x: 0.08, y: 0.63, width: 0.84, height: 0.26),
      ];
    }
  }

  factory FrameModel.fromJson(Map<String, dynamic> j) {
    final rawSlots = (j['slots'] as List<dynamic>? ?? [])
        .map((s) => FrameSlot.fromJson(s))
        .toList();

    return FrameModel(
      id: j['id'] ?? 0,
      name: j['name'] ?? j['nama'] ?? 'Frame Photobooth',
      category: j['category'] ?? j['kategori'],
      thumbnailPath: j['thumbnail_path'] ?? j['gambar'],
      overlayPath: j['overlay_path'] ?? j['gambar'],
      photoCount: j['photo_count'] ?? (rawSlots.isNotEmpty ? rawSlots.length : 3),
      printSize: j['print_size'] ?? '4r',
      slots: rawSlots,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      footerText: 'POV STUDIO',
    );
  }

  String? getThumbnailUrl(String baseUrl) {
    if (thumbnailPath == null || thumbnailPath!.isEmpty) return null;
    if (thumbnailPath!.startsWith('http')) return thumbnailPath;
    return '$baseUrl/storage/$thumbnailPath';
  }

  String? getOverlayUrl(String baseUrl) {
    if (overlayPath == null || overlayPath!.isEmpty) return null;
    if (overlayPath!.startsWith('http')) return overlayPath;
    return '$baseUrl/storage/$overlayPath';
  }

  /// Daftar frame preset bawaan yang selalu tersedia bahkan saat server offline
  static const List<FrameModel> defaultFrames = [
    FrameModel(
      id: -1,
      name: 'Classic Black Strip',
      category: 'Photostrip',
      photoCount: 3,
      printSize: '2x6',
      backgroundColor: Color(0xFF1E1E24),
      textColor: Colors.white,
      footerText: '★ POV STUDIO ★',
      slots: [
        FrameSlot(slotIndex: 0, x: 0.08, y: 0.04, width: 0.84, height: 0.26),
        FrameSlot(slotIndex: 1, x: 0.08, y: 0.33, width: 0.84, height: 0.26),
        FrameSlot(slotIndex: 2, x: 0.08, y: 0.62, width: 0.84, height: 0.26),
      ],
    ),
    FrameModel(
      id: -2,
      name: 'Pure White Strip',
      category: 'Photostrip',
      photoCount: 3,
      printSize: '2x6',
      backgroundColor: Colors.white,
      textColor: Color(0xFF333333),
      footerText: 'POV STUDIO • MEMORIES',
      slots: [
        FrameSlot(slotIndex: 0, x: 0.08, y: 0.04, width: 0.84, height: 0.26),
        FrameSlot(slotIndex: 1, x: 0.08, y: 0.33, width: 0.84, height: 0.26),
        FrameSlot(slotIndex: 2, x: 0.08, y: 0.62, width: 0.84, height: 0.26),
      ],
    ),
    FrameModel(
      id: -3,
      name: 'Pastel Lilac Strip',
      category: 'Photostrip',
      photoCount: 3,
      printSize: '2x6',
      backgroundColor: Color(0xFFEADBFF),
      textColor: Color(0xFF5A1E96),
      footerText: 'POV STUDIO ♡ SWEET',
      slots: [
        FrameSlot(slotIndex: 0, x: 0.08, y: 0.04, width: 0.84, height: 0.26),
        FrameSlot(slotIndex: 1, x: 0.08, y: 0.33, width: 0.84, height: 0.26),
        FrameSlot(slotIndex: 2, x: 0.08, y: 0.62, width: 0.84, height: 0.26),
      ],
    ),
    FrameModel(
      id: -4,
      name: 'Aesthetic 2x2 Grid',
      category: 'Grid',
      photoCount: 4,
      printSize: '4r',
      backgroundColor: Color(0xFFF7F3EE),
      textColor: Color(0xFF4A3E3D),
      footerText: 'POV STUDIO PHOTOBOOTH',
      slots: [
        FrameSlot(slotIndex: 0, x: 0.06, y: 0.05, width: 0.42, height: 0.40),
        FrameSlot(slotIndex: 1, x: 0.52, y: 0.05, width: 0.42, height: 0.40),
        FrameSlot(slotIndex: 2, x: 0.06, y: 0.48, width: 0.42, height: 0.40),
        FrameSlot(slotIndex: 3, x: 0.52, y: 0.48, width: 0.42, height: 0.40),
      ],
    ),
    FrameModel(
      id: -5,
      name: 'Minimalist Single 4R',
      category: 'Single',
      photoCount: 1,
      printSize: '4r',
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      footerText: 'POV STUDIO PORTRAIT',
      slots: [
        FrameSlot(slotIndex: 0, x: 0.08, y: 0.06, width: 0.84, height: 0.80),
      ],
    ),
  ];
}
