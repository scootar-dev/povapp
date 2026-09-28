import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/responsive.dart';
import '../models/sticker_model.dart';
import '../state/session_state.dart';
import 'shoot_screen.dart';
import 'settings_screen.dart';

class FrameStickerScreen extends ConsumerStatefulWidget {
  const FrameStickerScreen({super.key});
  @override
  ConsumerState<FrameStickerScreen> createState() => _FrameStickerScreenState();
}

class _FrameStickerScreenState extends ConsumerState<FrameStickerScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final framesAsync = ref.watch(framesProvider);
    final session = ref.watch(sessionProvider);
    final selectedFrame = session.frame;
    final stickers = session.stickers;
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Frame & Stiker'),
        bottom: TabBar(controller: _tab, tabs: const [Tab(icon: Icon(Icons.dashboard), text: 'Template'), Tab(icon: Icon(Icons.brush), text: 'Kustom')]),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ],
      ),
      body: Column(
        children: [
          // Preview kustom responsive
          Container(
            height: isMobile ? 140 : 180,
            margin: EdgeInsets.all(Responsive.padding(context)),
            decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade700)),
            child: Stack(children: [
              Center(
                child: selectedFrame == null
                    ? const Text('Pilih frame dulu', style: TextStyle(color: Colors.white54))
                    : Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.filter_frames, size: 32, color: Colors.deepPurple),
                        Text(selectedFrame.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('${selectedFrame.photoCount} foto', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ]),
              ),
              ...stickers.asMap().entries.map((e) => Positioned(
                    left: e.value.dx * (isMobile ? 260 : 500),
                    top: e.value.dy * (isMobile ? 100 : 140),
                    child: GestureDetector(
                      onPanUpdate: (d) => ref.read(sessionProvider.notifier).updateStickerPos(e.key, (e.value.dx + d.delta.dx / 300).clamp(0.0, 0.85), (e.value.dy + d.delta.dy / 120).clamp(0.0, 0.85)),
                      child: Text(e.value.sticker.emoji, style: TextStyle(fontSize: isMobile ? 28 : 32)),
                    ),
                  )),
            ]),
          ),
          if (stickers.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(padding: const EdgeInsets.symmetric(horizontal: 12), scrollDirection: Axis.horizontal, children: stickers.map((p) => Padding(padding: const EdgeInsets.only(right: 8), child: Chip(label: Text(p.sticker.emoji), onDeleted: () => ref.read(sessionProvider.notifier).toggleSticker(p.sticker)))).toList()),
            ),
          Expanded(
            child: TabBarView(controller: _tab, children: [
              // TEMPLATE
              framesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Gagal: $e'), const SizedBox(height: 12), const FilledButton(onPressed: null, child: Text('Retry'))])),
                data: (frames) => GridView.builder(
                  padding: EdgeInsets.all(Responsive.padding(context)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.frameColumns(context),
                    childAspectRatio: isMobile ? 0.85 : 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: frames.length,
                  itemBuilder: (_, i) {
                    final f = frames[i];
                    final sel = selectedFrame?.id == f.id;
                    return GestureDetector(
                      onTap: () => ref.read(sessionProvider.notifier).selectFrameForSticker(f),
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: sel ? Colors.deepPurple : Colors.grey.shade700, width: sel ? 3 : 1), borderRadius: BorderRadius.circular(12)),
                        child: Column(children: [
                          Expanded(child: f.thumbnailPath != null ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.network('${f.thumbnailPath}', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => const Icon(Icons.image))) : const Icon(Icons.filter_frames, size: 48)),
                          Padding(padding: const EdgeInsets.all(8), child: Text(f.name, style: TextStyle(fontWeight: sel ? FontWeight.bold : FontWeight.normal))),
                          Text('${f.photoCount} foto', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                          if (sel) const Icon(Icons.check_circle, color: Colors.deepPurple, size: 16),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              // KUSTOM
              Column(children: [
                Expanded(
                  child: framesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error $e')),
                    data: (frames) => GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: isMobile ? 3 : 4, childAspectRatio: 0.75, crossAxisSpacing: 8, mainAxisSpacing: 8),
                      itemCount: frames.length,
                      itemBuilder: (_, i) {
                        final f = frames[i];
                        final sel = selectedFrame?.id == f.id;
                        return InkWell(
                          onTap: () => ref.read(sessionProvider.notifier).selectFrameForSticker(f),
                          child: Container(decoration: BoxDecoration(border: Border.all(color: sel ? Colors.deepPurple : Colors.grey.shade700, width: sel ? 2 : 1), borderRadius: BorderRadius.circular(8)), child: Column(children: [Expanded(child: Icon(Icons.filter_frames, color: sel ? Colors.deepPurple : Colors.white54)), Text(f.name, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center)])),
                        );
                      },
                    ),
                  ),
                ),
                const Divider(),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Align(alignment: Alignment.centerLeft, child: Text('Pilih Stiker (tap tambah, drag di preview)', style: TextStyle(fontSize: 11, color: Colors.white54)))),
                SizedBox(
                  height: 80,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, mainAxisSpacing: 8),
                    itemCount: kStickers.length,
                    itemBuilder: (_, i) {
                      final s = kStickers[i];
                      final chosen = stickers.any((p) => p.sticker.id == s.id);
                      return GestureDetector(
                        onTap: () => ref.read(sessionProvider.notifier).toggleSticker(s),
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(color: chosen ? Colors.deepPurple.withValues(alpha: 0.2) : Colors.grey.shade800, border: Border.all(color: chosen ? Colors.deepPurple : Colors.grey.shade700), borderRadius: BorderRadius.circular(8)),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(s.emoji, style: const TextStyle(fontSize: 28)), Text(s.name, style: const TextStyle(fontSize: 9))]),
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ]),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.padding(context)),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: selectedFrame == null
                    ? null
                    : () async {
                        try {
                          // buat session jika belum ada
                          if (ref.read(sessionProvider).sessionId == null) {
                            await ref.read(sessionProvider.notifier).startSession(selectedFrame);
                          }
                          if (context.mounted) Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShootScreen()));
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mulai sesi: $e')));
                        }
                      },
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Lanjut Foto')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


