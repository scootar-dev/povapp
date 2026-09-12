import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../core/responsive.dart';
import '../models/frame_model.dart';
import '../state/session_state.dart';
import 'prep_countdown_screen.dart';

class FrameSelectionScreen extends ConsumerWidget {
  const FrameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final framesAsync = ref.watch(framesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Layout & Frame')),
      body: framesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat frame: $err')),
        data: (frames) => GridView.builder(
          padding: EdgeInsets.all(Responsive.padding(context)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.frameColumns(context),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: Responsive.isMobile(context) ? 0.85 : 0.75,
          ),
          itemCount: frames.length,
          itemBuilder: (context, i) => _FrameCard(
            frame: frames[i],
            onTap: () => _selectFrame(context, ref, frames[i]),
          ),
        ),
      ),
    );
  }

  Future<void> _selectFrame(BuildContext context, WidgetRef ref, FrameModel frame) async {
    // Catatan: idealnya panggil getFrameDetail(frame.id) dulu agar `frame.slots`
    // (koordinat tiap foto) terisi sebelum masuk sesi shoot. Contoh ini
    // langsung memakai objek `frame` dari daftar untuk simplisitas.
    await ref.read(sessionProvider.notifier).startSession(frame);

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PrepCountdownScreen()),
      );
    }
  }
}

class _FrameCard extends StatelessWidget {
  final FrameModel frame;
  final VoidCallback onTap;

  const _FrameCard({required this.frame, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: frame.thumbnailPath != null
                  ? Image.network(
                      '${AppConfig.baseUrl.replaceFirst('/api', '')}/storage/${frame.thumbnailPath}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                    )
                  : const Icon(Icons.filter_frames, size: 48),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                frame.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('${frame.photoCount} foto', style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
