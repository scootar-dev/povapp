import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../state/session_state.dart';
import 'filter_screen.dart';

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
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: session.photos.length,
              itemBuilder: (context, i) {
                final photo = session.photos[i];
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        '${AppConfig.baseUrl.replaceFirst('/api', '')}/storage/${photo.filePath}',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: FloatingActionButton.small(
                        heroTag: 'retake_${photo.id}',
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
                onPressed: () {
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
    // Simpan slot_index dulu sebelum foto dihapus dari state, agar tahu
    // slot mana yang perlu difoto ulang di layar shoot-retake.
    final photo = ref.read(sessionProvider).photos.firstWhere((p) => p.id == photoId);
    await ref.read(sessionProvider.notifier).retakePhoto(photoId);

    if (context.mounted) {
      // Layar shoot khusus 1 slot (reuse ShootScreen dengan mode single-slot)
      // — lihat catatan di README Flutter untuk detail implementasi mode ini.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan foto ulang slot ${photo.slotIndex + 1}')),
      );
    }
  }
}
