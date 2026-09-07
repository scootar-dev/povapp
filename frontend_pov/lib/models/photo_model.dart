class PhotoModel {
  final int id;
  final int slotIndex;
  final String filePath; // path relatif di server (storage/public)
  final String? localPath; // path file lokal sebelum/selagi upload

  PhotoModel({
    required this.id,
    required this.slotIndex,
    required this.filePath,
    this.localPath,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) => PhotoModel(
        id: json['id'],
        slotIndex: json['slot_index'],
        filePath: json['file_path'],
      );
}

/// Sesuai spesifikasi: Original, Natural, Cold/Cool Tone, Warm Tone,
/// Black & White, Vintage/Sepia.
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
