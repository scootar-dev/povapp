import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/frame_model.dart';
import '../state/session_state.dart';
import 'prep_countdown_screen.dart';

class FrameSelectionScreen extends ConsumerWidget {
  const FrameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final framesAsync = ref.watch(framesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PILIH TEMPLATE & LAYOUT FRAME', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1F0038),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1F0038), Color(0xFF0D001A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: framesAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.purpleAccent),
                SizedBox(height: 16),
                Text('Memuat pilihan frame...', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text('Gagal memuat frame: $err', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(framesProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
          data: (frames) => frames.isEmpty
              ? const Center(
                  child: Text('Belum ada frame aktif di database.', style: TextStyle(color: Colors.white70, fontSize: 18)),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(32),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: frames.length,
                  itemBuilder: (context, i) => _FrameCard(
                    frame: frames[i],
                    onTap: () => _selectFrame(context, ref, frames[i]),
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _selectFrame(BuildContext context, WidgetRef ref, FrameModel frame) async {
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: frame.thumbnailUrl != null && frame.thumbnailUrl!.isNotEmpty
                        ? Image.network(
                            frame.thumbnailUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.filter_frames, size: 64, color: Colors.purpleAccent),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.filter_frames, size: 64, color: Colors.purpleAccent),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  frame.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '📸 ${frame.photoCount} Foto (${frame.printSize.toUpperCase()})',
                    style: const TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
