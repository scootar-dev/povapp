import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../state/session_state.dart';
import 'filter_screen.dart';
import 'shoot_screen.dart';

class PreviewRetakeScreen extends ConsumerWidget {
  const PreviewRetakeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview & Retake'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('Sisa retake: ${session.retakeRemaining}'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (session.frame != null &&
              session.photos.length < session.frame!.photoCount)
            Container(
              width: double.infinity,
              color: Colors.orange.shade900,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                'Foto belum lengkap: ${session.photos.length}/${session.frame!.photoCount} slot terisi. Lakukan retake atau hubungi petugas.',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: session.photos.isEmpty
                ? const Center(child: Text('Belum ada foto. Kembali ke shoot.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: session.photos.length,
                    itemBuilder: (context, i) {
                      final photo = session.photos[i];
                      final thumbUrl =
                          '${AppConfig.baseUrl.replaceFirst('/api', '')}/storage/${photo.filePath}';
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                thumbUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (ctx, child, progress) =>
                                    progress == null ? child : const Center(child: CircularProgressIndicator()),
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade900,
                                  child: const Icon(Icons.broken_image, size: 48, color: Colors.white54),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Slot ${photo.slotIndex + 1}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: FloatingActionButton.small(
                              heroTag: 'retake_${photo.id}',
                              tooltip: session.retakeRemaining > 0 ? 'Retake' : 'Kuota habis',
                              onPressed: session.retakeRemaining > 0
                                  ? () => _retake(context, ref, photo.id)
                                  : null,
                              child: const Icon(Icons.refresh),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: session.frame != null && session.photos.length < session.frame!.photoCount
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FilterScreen()),
                        );
                      },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Lanjut ke Pilih Filter', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _retake(BuildContext context, WidgetRef ref, int photoId) async {
    final session = ref.read(sessionProvider);
    if (session.retakeRemaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kuota retake sudah habis.')),
      );
      return;
    }

    final photo = session.photos.firstWhere((p) => p.id == photoId);
    final slotIndex = photo.slotIndex;

    // Konfirmasi
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retake foto?'),
        content: Text('Foto slot ${slotIndex + 1} akan dihapus dan diambil ulang.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Retake')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(sessionProvider.notifier).retakePhoto(photoId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mempersiapkan retake slot ${slotIndex + 1}...')),
        );
        // Navigasi ke ShootScreen mode single-slot
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ShootScreen(singleSlotIndex: slotIndex)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal retake: $e')),
        );
      }
    }
  }
}
