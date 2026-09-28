class FrameSlot {
  final int slotIndex;
  final double x, y, width, height, rotation;
  FrameSlot({required this.slotIndex, required this.x, required this.y, required this.width, required this.height, required this.rotation});
  factory FrameSlot.fromJson(Map<String, dynamic> j) => FrameSlot(slotIndex: j['slot_index'], x: (j['x'] as num).toDouble(), y: (j['y'] as num).toDouble(), width: (j['width'] as num).toDouble(), height: (j['height'] as num).toDouble(), rotation: (j['rotation'] as num?)?.toDouble() ?? 0);
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
  FrameModel({required this.id, required this.name, this.category, this.thumbnailPath, this.overlayPath, required this.photoCount, required this.printSize, this.slots = const []});
  factory FrameModel.fromJson(Map<String, dynamic> j) => FrameModel(
        id: j['id'],
        name: j['name'],
        category: j['category'],
        thumbnailPath: j['thumbnail_path'],
        overlayPath: j['overlay_path'],
        photoCount: j['photo_count'],
        printSize: j['print_size'] ?? '4r',
        slots: (j['slots'] as List<dynamic>? ?? []).map((s) => FrameSlot.fromJson(s)).toList(),
      );
}
