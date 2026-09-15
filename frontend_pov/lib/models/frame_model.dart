class FrameSlot {
  final int slotIndex;
  final double x, y, width, height, rotation;

  FrameSlot({
    required this.slotIndex,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rotation,
  });

  factory FrameSlot.fromJson(Map<String, dynamic> json) => FrameSlot(
        slotIndex: json['slot_index'] ?? 0,
        x: (json['x'] as num?)?.toDouble() ?? 0,
        y: (json['y'] as num?)?.toDouble() ?? 0,
        width: (json['width'] as num?)?.toDouble() ?? 100,
        height: (json['height'] as num?)?.toDouble() ?? 100,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      );
}

class FrameModel {
  final int id;
  final String name;
  final String? category;
  final String? thumbnailUrl;
  final String? overlayUrl;
  final int photoCount;
  final String printSize;
  final List<FrameSlot> slots;

  FrameModel({
    required this.id,
    required this.name,
    this.category,
    this.thumbnailUrl,
    this.overlayUrl,
    required this.photoCount,
    required this.printSize,
    this.slots = const [],
  });

  factory FrameModel.fromJson(Map<String, dynamic> json) => FrameModel(
        id: json['id'],
        name: json['name'] ?? 'Frame',
        category: json['category'],
        thumbnailUrl: json['thumbnail_url'] ?? json['thumbnail_path'],
        overlayUrl: json['overlay_url'] ?? json['overlay_path'],
        photoCount: json['photo_count'] ?? 4,
        printSize: json['print_size'] ?? '4r',
        slots: (json['slots'] as List<dynamic>? ?? [])
            .map((s) => FrameSlot.fromJson(s))
            .toList(),
      );
}
