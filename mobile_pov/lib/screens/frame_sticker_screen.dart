import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/frame_model.dart';
import '../models/sticker_model.dart';
import '../state/session_state.dart';
import 'camera_shoot_screen.dart';

class FrameStickerScreen extends ConsumerStatefulWidget {
  const FrameStickerScreen({super.key});

  @override
  ConsumerState<FrameStickerScreen> createState() => _FrameStickerScreenState();
}

class _FrameStickerScreenState extends ConsumerState<FrameStickerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _proceedToCamera() async {
    setState(() => _starting = true);
    try {
      await ref.read(mobileSessionProvider.notifier).startSession();
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CameraShootScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Catatan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(mobileSessionProvider);
    final framesAsync = ref.watch(framesProvider);
    final stickersAsync = ref.watch(stickersProvider);
    final baseUrl = ref.watch(baseUrlProvider).valueOrNull ?? '';

    final frame = session.frame ?? FrameModel.defaultFrames.first;
    final stickers = session.stickers;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Desain Frame & Stiker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. KANVAS INTERAKTIF FRAME DI ATAS
          Expanded(
            flex: 6,
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

                          // Slot-slot foto
                          ...frame.effectiveSlots.map((slot) {
                            return Positioned(
                              left: slot.x * cw,
                              top: slot.y * ch,
                              width: slot.width * cw,
                              height: slot.height * ch,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade500,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        size: cw * 0.12,
                                        color: Colors.grey.shade700,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Slot ${slot.slotIndex + 1}',
                                        style: TextStyle(
                                          fontSize: cw * 0.065,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Branding Footer Text
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

                          // Stiker yang ditempatkan (dapat digeser manual)
                          ...stickers.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final placed = entry.value;
                            final stLeft = (placed.dx * cw).clamp(0.0, cw - 36);
                            final stTop = (placed.dy * ch).clamp(0.0, ch - 36);

                            return Positioned(
                              left: stLeft,
                              top: stTop,
                              child: GestureDetector(
                                onPanUpdate: (d) {
                                  final newDx = placed.dx + (d.delta.dx / cw);
                                  final newDy = placed.dy + (d.delta.dy / ch);
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
                                        color: Colors.white.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.purple.shade300,
                                        ),
                                      ),
                                      child: placed.sticker.assetPath != null
                                          ? Image.network(
                                              placed.sticker.getAssetUrl(baseUrl)!,
                                              width: 34,
                                              height: 34,
                                              errorBuilder: (_, _, _) => Text(
                                                placed.sticker.emoji.isNotEmpty
                                                    ? placed.sticker.emoji
                                                    : '✨',
                                                style: const TextStyle(fontSize: 26),
                                              ),
                                            )
                                          : Text(
                                              placed.sticker.emoji.isNotEmpty
                                                  ? placed.sticker.emoji
                                                  : '✨',
                                              style: const TextStyle(fontSize: 26),
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
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 12,
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
            ),
          ),

          // 2. TAB CONTROLLER: PILIH FRAME / TAMBAH STIKER
          TabBar(
            controller: _tabCtrl,
            indicatorColor: const Color(0xFF6A1FB8),
            labelColor: const Color(0xFF6A1FB8),
            unselectedLabelColor: Colors.black54,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard_customize_outlined), text: 'Pilih Frame'),
              Tab(icon: Icon(Icons.emoji_emotions_outlined), text: 'Tambah Stiker'),
            ],
          ),

          // 3. TAB VIEW ISI KONTEN
          Expanded(
            flex: 4,
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // TAB 1: GRID FRAME
                framesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _buildFrameList(FrameModel.defaultFrames, frame),
                  data: (frames) => _buildFrameList(frames, frame),
                ),

                // TAB 2: GRID STIKER
                stickersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => _buildStickerList(kStickers, baseUrl),
                  data: (stks) => _buildStickerList(stks, baseUrl),
                ),
              ],
            ),
          ),

          // 4. TOMBOL LANJUT KE KAMERA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _starting ? null : _proceedToCamera,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1FB8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _starting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.camera_alt),
                  label: Text(
                    'Lanjut ke Kamera (${frame.photoCount} Foto)',
                    style: const TextStyle(
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

  Widget _buildFrameList(List<FrameModel> frames, FrameModel selectedFrame) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: frames.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (ctx, i) {
        final f = frames[i];
        final isSelected = f.id == selectedFrame.id;

        return GestureDetector(
          onTap: () => ref.read(mobileSessionProvider.notifier).selectFrame(f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 130,
            decoration: BoxDecoration(
              color: f.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFF6A1FB8) : Colors.grey.shade400,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF6A1FB8).withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Miniatur Visual Frame
                Container(
                  width: 44,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      f.photoCount.clamp(1, 4),
                      (_) => Container(
                        width: 32,
                        height: 7,
                        decoration: BoxDecoration(
                          color: f.textColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    f.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? const Color(0xFF6A1FB8) : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${f.photoCount} Foto',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickerList(List<StickerModel> stickers, String baseUrl) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: stickers.length,
      itemBuilder: (ctx, i) {
        final s = stickers[i];
        final assetUrl = s.getAssetUrl(baseUrl);

        return InkWell(
          onTap: () {
            ref.read(mobileSessionProvider.notifier).addSticker(s);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Stiker ${s.name} ditambahkan. Geser di kanvas atas untuk mengatur posisi.'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
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
                        s.emoji.isNotEmpty ? s.emoji : '✨',
                        style: const TextStyle(fontSize: 24),
                      ),
                    )
                  : Text(
                      s.emoji.isNotEmpty ? s.emoji : '✨',
                      style: const TextStyle(fontSize: 24),
                    ),
            ),
          ),
        );
      },
    );
  }
}
