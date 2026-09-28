class StickerModel {
  final String id;
  final String name;
  final String emoji;
  final String? assetPath;
  const StickerModel({required this.id, required this.name, required this.emoji, this.assetPath});
}

const kStickers = [
  StickerModel(id: 's1', name: 'Love', emoji: '❤️'),
  StickerModel(id: 's2', name: 'Star', emoji: '⭐'),
  StickerModel(id: 's3', name: 'Party', emoji: '🎉'),
  StickerModel(id: 's4', name: 'Cool', emoji: '😎'),
  StickerModel(id: 's5', name: 'Crown', emoji: '👑'),
  StickerModel(id: 's6', name: 'Fire', emoji: '🔥'),
  StickerModel(id: 's7', name: 'Bear', emoji: '🐻'),
  StickerModel(id: 's8', name: 'Cat', emoji: '🐱'),
  StickerModel(id: 's9', name: 'Bow', emoji: '🎀'),
  StickerModel(id: 's10', name: 'Spark', emoji: '✨'),
];

class PlacedSticker {
  final StickerModel sticker;
  final double dx;
  final double dy;
  final double scale;
  PlacedSticker({required this.sticker, required this.dx, required this.dy, this.scale = 1.0});
}
