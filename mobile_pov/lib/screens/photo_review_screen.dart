import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sticker_model.dart';
import '../state/session_state.dart';
import 'camera_shoot_screen.dart';
import 'result_screen.dart';

class PhotoReviewScreen extends ConsumerStatefulWidget {
  const PhotoReviewScreen({super.key});

  @override
  ConsumerState<PhotoReviewScreen> createState() => _PhotoReviewScreenState();
}

class _PhotoReviewScreenState extends ConsumerState<PhotoReviewScreen> {
  bool _processing = false;
  String _processStatus = '';

  Future<void> _proceedToRender() async {
    final session = ref.read(mobileSessionProvider);
    final totalSlots = session.frame?.photoCount ?? session.localPhotos.length;

    if (session.localPhotos.length < totalSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto belum lengkap ($totalSlots foto diperlukan)')),
      );
      return;
    }

    setState(() {
      _processing = true;
      _processStatus = 'Mengunggah foto...';
    });

    try {
      await ref.read(mobileSessionProvider.notifier).uploadAllPhotos();

      if (mounted) {
        setState(() {
          _processStatus = 'Memproses & merender template...';
        });
      }

      await ref.read(mobileSessionProvider.notifier).render();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses render: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _retakeSlot(int slotIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CameraShootScreen(retakeSlotIndex: slotIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(mobileSessionProvider);
    final stickersAsync = ref.watch(stickersProvider);
    final baseUrl = ref.watch(baseUrlProvider).valueOrNull ?? '';
    final photos = session.localPhotos;
    final stickers = session.stickers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tinjau & Hias Foto'),
        centerTitle: true,
      ),
      body: _processing
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Color(0xFF6A1FB8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _processStatus,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Mohon tunggu sebentar...',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Kanvas Preview dengan Stiker yang bisa di-drag
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        final canvasW = constraints.maxWidth;
                        final canvasH = constraints.maxHeight;

                        return Stack(
                          children: [
                            // Grid foto yang diambil
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.9,
                                ),
                                itemCount: photos.length,
                                itemBuilder: (ctx, i) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          File(photos[i]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      // Badge nomor foto
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Slot ${i + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Tombol foto ulang (retake)
                                      Positioned(
                                        bottom: 6,
                                        right: 6,
                                        child: InkWell(
                                          onTap: () => _retakeSlot(i),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black87,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.refresh_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Foto Ulang',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            // Overlay Stiker yang dapat digeser manual (drag and drop)
                            ...stickers.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final placed = entry.value;
                              final stickerLeft = (placed.dx * canvasW).clamp(0.0, canvasW - 44);
                              final stickerTop = (placed.dy * canvasH).clamp(0.0, canvasH - 44);

                              return Positioned(
                                left: stickerLeft,
                                top: stickerTop,
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    final newDx = placed.dx + (details.delta.dx / canvasW);
                                    final newDy = placed.dy + (details.delta.dy / canvasH);
                                    ref
                                        .read(mobileSessionProvider.notifier)
                                        .updateStickerPos(idx, newDx, newDy);
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.purple.withValues(alpha: 0.5),
                                            style: BorderStyle.solid,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: placed.sticker.assetPath != null
                                            ? Image.network(
                                                placed.sticker.getAssetUrl(baseUrl)!,
                                                width: 38,
                                                height: 38,
                                                errorBuilder: (_, _, _) => Text(
                                                  placed.sticker.emoji.isNotEmpty
                                                      ? placed.sticker.emoji
                                                      : '⭐',
                                                  style: const TextStyle(fontSize: 28),
                                                ),
                                              )
                                            : Text(
                                                placed.sticker.emoji.isNotEmpty
                                                    ? placed.sticker.emoji
                                                    : '⭐',
                                                style: const TextStyle(fontSize: 28),
                                              ),
                                      ),
                                      Positioned(
                                        top: -6,
                                        right: -6,
                                        child: GestureDetector(
                                          onTap: () => ref
                                              .read(mobileSessionProvider.notifier)
                                              .removeSticker(idx),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Petunjuk & Panel Stiker
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.touch_app, size: 16, color: Colors.purple),
                      SizedBox(width: 6),
                      Text(
                        'Tap stiker untuk menambah, geser langsung di atas foto',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                // Daftar Stiker yang bisa dipilih (Horizontal Picker)
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: stickersAsync.when(
                    loading: () => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: kStickers.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final s = kStickers[i];
                        return _StickerChip(
                          sticker: s,
                          onTap: () => ref
                              .read(mobileSessionProvider.notifier)
                              .addSticker(s),
                        );
                      },
                    ),
                    error: (_, _) => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: kStickers.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final s = kStickers[i];
                        return _StickerChip(
                          sticker: s,
                          onTap: () => ref
                              .read(mobileSessionProvider.notifier)
                              .addSticker(s),
                        );
                      },
                    ),
                    data: (apiStickers) {
                      final allStickers = [
                        ...apiStickers,
                        ...kStickers.where(
                          (ks) => !apiStickers.any((as) => as.name == ks.name),
                        ),
                      ];
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: allStickers.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final s = allStickers[i];
                          return _StickerChip(
                            sticker: s,
                            baseUrl: baseUrl,
                            onTap: () => ref
                                .read(mobileSessionProvider.notifier)
                                .addSticker(s),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _proceedToRender,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1FB8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text(
                          'Cetak & Buat QR Foto',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StickerChip extends StatelessWidget {
  final StickerModel sticker;
  final String? baseUrl;
  final VoidCallback onTap;

  const _StickerChip({
    required this.sticker,
    this.baseUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final assetUrl = baseUrl != null ? sticker.getAssetUrl(baseUrl!) : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple.shade100),
        ),
        child: Center(
          child: assetUrl != null
              ? Image.network(
                  assetUrl,
                  width: 32,
                  height: 32,
                  errorBuilder: (_, _, _) => Text(
                    sticker.emoji.isNotEmpty ? sticker.emoji : '✨',
                    style: const TextStyle(fontSize: 22),
                  ),
                )
              : Text(
                  sticker.emoji.isNotEmpty ? sticker.emoji : '✨',
                  style: const TextStyle(fontSize: 22),
                ),
        ),
      ),
    );
  }
}
