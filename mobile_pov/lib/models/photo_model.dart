import 'dart:typed_data';

class CapturedPhoto {
  final String name;
  final String? path;
  final Uint8List bytes;

  const CapturedPhoto({
    required this.name,
    this.path,
    required this.bytes,
  });
}
