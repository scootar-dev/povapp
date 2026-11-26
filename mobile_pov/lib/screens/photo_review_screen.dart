import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/frame_model.dart';
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
      _processStatus = 'Merender hasil komposit frame & foto...';
    });

    try {
      await ref.read(mobileSessionProvider.notifier).render();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal render: $e')),
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
    final baseUrl = ref.watch(baseUrlProvider).valueOrNull ?? '';
    final frame = session.frame ?? FrameModel.defaultFrames.first;
    final photos = session.localPhotos;
    final stickers = session.stickers;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tinjau Hasil Foto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                      'Menyusun foto ke dalam frame...',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Kanvas Pratinjau Foto di dalam Frame
                Expanded(
                  flex: 7,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: frame.aspectRatio,
                        child: LayoutBuilder(
                          builder: (ctx, constraints) {
                            final cw = constraints.maxWidth;
                            final ch = constraints.maxHeight;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Background Frame
                                Container(
                                  decoration: BoxDecoration(
                                    color: frame.backgroundColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: frame.textColor.withValues(alpha: 0.2),
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),

                                // Slot Foto yang terisi
                                ...frame.effectiveSlots.map((slot) {
                                  final idx = slot.slotIndex;
                                  final hasPhoto = idx < photos.length;

                                  return Positioned(
                                    left: slot.x * cw,
                                    top: slot.y * ch,
                                    width: slot.width * cw,
                                    height: slot.height * ch,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: hasPhoto
                                              ? Image.memory(
                                                  photos[idx].bytes,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  color: Colors.grey.shade300,
                                                  child: const Center(
                                                    child: Icon(Icons.photo),
                                                  ),
                                                ),
                                        ),
                                        // Tombol Foto Ulang kecil
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: InkWell(
                                            onTap: () => _retakeSlot(idx),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.refresh,
                                                    size: 11,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 3),
                                                  Text(
                                                    'Foto Ulang',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                // Footer Branding
                                Positioned(
                                  bottom: ch * 0.02,
                                  left: 0,
                                  right: 0,
                                  child: Text(
                                    frame.footerText ?? 'POV STUDIO',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: frame.textColor,
                                      fontSize: cw * 0.06,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),

                                // Stiker yang sudah terpasang
                                ...stickers.asMap().entries.map((entry) {
                                  final placed = entry.value;
                                  final stLeft =
                                      (placed.dx * cw).clamp(0.0, cw - 36);
                                  final stTop =
                                      (placed.dy * ch).clamp(0.0, ch - 36);

                                  return Positioned(
                                    left: stLeft,
                                    top: stTop,
                                    child: placed.sticker.assetPath != null
                                        ? Image.network(
                                            placed.sticker.getAssetUrl(baseUrl)!,
                                            width: 32,
                                            height: 32,
                                            errorBuilder: (_, __, ___) => Text(
                                              placed.sticker.emoji.isNotEmpty
                                                  ? placed.sticker.emoji
                                                  : '✨',
                                              style:
                                                  const TextStyle(fontSize: 24),
                                            ),
                                          )
                                        : Text(
                                            placed.sticker.emoji.isNotEmpty
                                                ? placed.sticker.emoji
                                                : '✨',
                                            style:
                                                const TextStyle(fontSize: 24),
                                          ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Petunjuk & Slot Carousel untuk Retake
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.purple),
                      const SizedBox(width: 6),
                      Text(
                        'Total ${photos.length} foto siap dicetak & diunduh.',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          // Opsi retake seluruh foto
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const CameraShootScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.replay, size: 14),
                        label: const Text(
                          'Ulang Semua',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
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
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'Selesai & Buat Hasil Foto',
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
