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
        slotIndex: json['slot_index'],
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      );
}

class FrameModel {
  final int id;
  final String name;
  final String? category;
  final String? thumbnailPath;
  final int photoCount;
  final String printSize;
  final List<FrameSlot> slots;

  FrameModel({
    required this.id,
    required this.name,
    this.category,
    this.thumbnailPath,
    required this.photoCount,
    required this.printSize,
    this.slots = const [],
  });

  factory FrameModel.fromJson(Map<String, dynamic> json) => FrameModel(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        thumbnailPath: json['thumbnail_path'],
        photoCount: json['photo_count'],
        printSize: json['print_size'],
        slots: (json['slots'] as List<dynamic>? ?? [])
            .map((s) => FrameSlot.fromJson(s))
            .toList(),
      );
}
