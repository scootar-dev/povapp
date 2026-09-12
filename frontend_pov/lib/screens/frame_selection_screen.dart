import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../core/responsive.dart';
import '../models/frame_model.dart';
import '../state/session_state.dart';
import 'prep_countdown_screen.dart';
import 'settings_screen.dart';

class FrameSelectionScreen extends ConsumerWidget {
  const FrameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final framesAsync = ref.watch(framesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Layout & Frame'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.invalidate(framesProvider)),
        ],
      ),
      body: framesAsync.when(
        loading: () => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Memuat frame...')])),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.white54),
              const SizedBox(height: 12),
              Text('Gagal memuat frame:\n$err', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text('Cek API Base URL & Token di Pengaturan', style: TextStyle(fontSize: 11, color: Colors.white54)),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: () => ref.invalidate(framesProvider), icon: const Icon(Icons.refresh), label: const Text('Coba Lagi')),
              TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())), child: const Text('Buka Pengaturan')),
            ]),
          ),
        ),
        data: (frames) {
          if (frames.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.filter_none, size: 48), const SizedBox(height: 12), const Text('Belum ada frame aktif'), const SizedBox(height: 12), FilledButton(onPressed: () => ref.invalidate(framesProvider), child: const Text('Refresh'))]));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(framesProvider),
            child: GridView.builder(
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
          );
        },
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
