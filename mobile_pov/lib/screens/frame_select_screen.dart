import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/session_state.dart';
import 'camera_shoot_screen.dart';

class FrameSelectScreen extends ConsumerStatefulWidget {
  const FrameSelectScreen({super.key});

  @override
  ConsumerState<FrameSelectScreen> createState() => _FrameSelectScreenState();
}

class _FrameSelectScreenState extends ConsumerState<FrameSelectScreen> {
  bool _starting = false;

  Future<void> _proceed() async {
    final session = ref.read(mobileSessionProvider);
    if (session.frame == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih salah satu frame terlebih dahulu')),
      );
      return;
    }

    setState(() => _starting = true);
    try {
      await ref.read(mobileSessionProvider.notifier).startSession();
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CameraShootScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai sesi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final framesAsync = ref.watch(framesProvider);
    final baseUrl = ref.watch(baseUrlProvider).valueOrNull ?? '';
    final session = ref.watch(mobileSessionProvider);
    final selectedFrame = session.frame;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pilih Frame',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: framesAsync.when(
              loading: () => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Memuat daftar template frame...'),
                  ],
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat frame:\n$err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => ref.invalidate(framesProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (frames) {
                if (frames.isEmpty) {
                  return const Center(child: Text('Belum ada frame yang aktif.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: frames.length,
                  itemBuilder: (ctx, i) {
                    final f = frames[i];
                    final isSelected = selectedFrame?.id == f.id;
                    final thumbUrl = f.getThumbnailUrl(baseUrl);

                    return GestureDetector(
                      onTap: () =>
                          ref.read(mobileSessionProvider.notifier).selectFrame(f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6A1FB8) : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? const Color(0xFF6A1FB8).withValues(alpha: 0.25)
                                  : Colors.black.withValues(alpha: 0.05),
                              blurRadius: isSelected ? 12 : 4,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(13),
                                ),
                                child: thumbUrl != null
                                    ? Image.network(
                                        thumbUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Center(
                                          child: Icon(
                                            Icons.filter_frames_rounded,
                                            size: 48,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.filter_frames_rounded,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 14,
                                      color: isSelected ? const Color(0xFF6A1FB8) : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${f.photoCount} Foto',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.purple.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF6A1FB8),
                                          size: 18,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Bottom Continue Bar
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
                child: FilledButton(
                  onPressed: selectedFrame == null || _starting ? null : _proceed,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1FB8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _starting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          selectedFrame == null
                              ? 'Pilih Frame Dahulu'
                              : 'Lanjut ke Kamera (${selectedFrame.photoCount} Foto)',
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
}
