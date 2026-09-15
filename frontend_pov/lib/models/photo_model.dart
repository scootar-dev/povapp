class PhotoModel {
  final int id;
  final int slotIndex;
  final String? url;
  final String? filePath;
  final String? localPath;

  PhotoModel({
    required this.id,
    required this.slotIndex,
    this.url,
    this.filePath,
    this.localPath,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) => PhotoModel(
        id: json['id'],
        slotIndex: json['slot_index'] ?? 0,
        url: json['url'],
        filePath: json['file_path'],
      );
}

enum PhotoColorFilter { original, natural, cold, warm, blackWhite, vintage }

extension PhotoColorFilterX on PhotoColorFilter {
  String get apiValue => switch (this) {
        PhotoColorFilter.original => 'original',
        PhotoColorFilter.natural => 'natural',
        PhotoColorFilter.cold => 'cold',
        PhotoColorFilter.warm => 'warm',
        PhotoColorFilter.blackWhite => 'bw',
        PhotoColorFilter.vintage => 'vintage',
      };

  String get label => switch (this) {
        PhotoColorFilter.original => 'Original',
        PhotoColorFilter.natural => 'Natural',
        PhotoColorFilter.cold => 'Cold Tone',
        PhotoColorFilter.warm => 'Warm Tone',
        PhotoColorFilter.blackWhite => 'Black & White',
        PhotoColorFilter.vintage => 'Vintage',
      };
}
