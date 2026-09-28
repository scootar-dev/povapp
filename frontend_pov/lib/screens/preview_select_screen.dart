import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_config.dart';
import '../core/responsive.dart';
import '../state/session_state.dart';
import 'shoot_screen.dart';
import 'qr_result_screen.dart';

class PreviewSelectScreen extends ConsumerStatefulWidget {
  const PreviewSelectScreen({super.key});
  @override
  ConsumerState<PreviewSelectScreen> createState() => _PreviewSelectScreenState();
}

class _PreviewSelectScreenState extends ConsumerState<PreviewSelectScreen> {
  bool _rendering = false;

  Future<void> _next() async {
    final s = ref.read(sessionProvider);
    // jika belum pilih, pilih semua default
    if (s.selectedIndices.isEmpty) {
      for (int i = 0; i < s.photos.length; i++) {
        ref.read(sessionProvider.notifier).toggleSelect(i);
      }
    }
    setState(() => _rendering = true);
    try {
      // stickers sudah di state, tapi backend belum pakai — untuk MVP preview saja
      await ref.read(sessionProvider.notifier).renderAndWaitOutput();
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const QrResultScreen()));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal render: $e')));
    } finally {
      if (mounted) setState(() => _rendering = false);
    }
  }

  Future<void> _retake(int photoId) async {
    final session = ref.read(sessionProvider);
    if (session.retakeRemaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kuota retake habis')));
      return;
    }
    final photo = session.photos.firstWhere((p) => p.id == photoId);
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Retake?'), content: Text('Foto slot ${photo.slotIndex + 1} akan diulang'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Retake'))]));
    if (ok != true) return;
    try {
      await ref.read(sessionProvider.notifier).retakePhoto(photoId);
      if (mounted) await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ShootScreen(singleSlotIndex: photo.slotIndex)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal retake: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sessionProvider);
    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Foto'), actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 12), child: Text('${s.selectedIndices.length}/${s.photos.length} dipilih')))]),
      body: Column(children: [
        if (s.photos.length < (s.frame?.photoCount ?? 0))
          Container(width: double.infinity, color: Colors.orange.shade900, padding: const EdgeInsets.all(8), child: Text('Foto belum lengkap: ${s.photos.length}/${s.frame!.photoCount}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))),
        Expanded(
          child: s.photos.isEmpty
              ? const Center(child: Text('Belum ada foto'))
              : GridView.builder(
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: Responsive.photoColumns(context), crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: s.photos.length,
                  itemBuilder: (_, i) {
                    final p = s.photos[i];
                    final sel = s.selectedIndices.contains(i);
                    final url = '${AppConfig.baseUrl.replaceFirst('/api', '')}/storage/${p.filePath}';
                    return GestureDetector(
                      onTap: () => ref.read(sessionProvider.notifier).toggleSelect(i),
                      child: Stack(children: [
                        Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade800, child: const Icon(Icons.broken_image))))),
                        Positioned(top: 6, left: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), child: Text('Slot ${p.slotIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 10)))),
                        Positioned(top: 6, right: 6, child: Icon(sel ? Icons.check_circle : Icons.circle_outlined, color: sel ? Colors.greenAccent : Colors.white)),
                        // stiker overlay preview
                        if (s.stickers.isNotEmpty)
                          Positioned.fill(child: IgnorePointer(child: Stack(children: s.stickers.map((st) => Positioned(left: st.dx * 160, top: st.dy * 180, child: Text(st.sticker.emoji, style: const TextStyle(fontSize: 20)))).toList()))),
                        Positioned(bottom: 6, right: 6, child: FloatingActionButton.small(heroTag: 'retake_$i', onPressed: s.retakeRemaining > 0 ? () => _retake(p.id) : null, child: const Icon(Icons.refresh))),
                      ]),
                    );
                  },
                ),
        ),
        Padding(
          padding: EdgeInsets.all(Responsive.padding(context)),
          child: Column(children: [
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _rendering ? null : _next, child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: _rendering ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isMobile ? 'Cetak & Buat QR' : 'Lanjut Cetak & QR')))),
            const SizedBox(height: 6),
            Text('Tap foto untuk pilih/Batal pilih • Stiker: ${s.stickers.map((e) => e.sticker.emoji).join(" ")}', style: const TextStyle(fontSize: 11, color: Colors.white54), textAlign: TextAlign.center),
          ]),
        ),
      ]),
    );
  }
}
