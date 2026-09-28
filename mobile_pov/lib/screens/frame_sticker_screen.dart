import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config.dart';
import '../models/sticker_model.dart';
import '../state/session_state.dart';
import 'shoot_mobile_screen.dart';

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
  Widget build(BuildContext context) {
    final framesAsync = ref.watch(framesProvider);
    final session = ref.watch(mobileSessionProvider);
    final selectedFrame = session.frame;
    final stickers = session.stickers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Frame & Stiker'),
        bottom: TabBar(controller: _tab, tabs: const [Tab(icon: Icon(Icons.dashboard), text: 'Template'), Tab(icon: Icon(Icons.brush), text: 'Kustom')]),
      ),
      body: Column(
        children: [
          // Preview kustom
          Container(
            height: 140,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: Stack(
              children: [
                Center(child: selectedFrame == null ? const Text('Pilih frame dulu', style: TextStyle(color: Colors.black54)) : Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.filter_frames, size: 32, color: Colors.deepPurple), Text(selectedFrame.name, style: TextStyle(fontWeight: FontWeight.bold)), Text('${selectedFrame.photoCount} foto')])),
                ...stickers.asMap().entries.map((e) => Positioned(
                  left: e.value.dx * 260, top: e.value.dy * 100,
                  child: GestureDetector(
                    onPanUpdate: (d) => ref.read(mobileSessionProvider.notifier).updateStickerPos(e.key, (e.value.dx + d.delta.dx/300).clamp(0.0, 0.85), (e.value.dy + d.delta.dy/120).clamp(0.0, 0.85)),
                    child: Text(e.value.sticker.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                )),
              ],
            ),
          ),
          if (stickers.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: stickers.map((p) => Chip(label: Text(p.sticker.emoji), onDeleted: ()=>ref.read(mobileSessionProvider.notifier).toggleSticker(p.sticker))).toList(),
              ),
            ),
          Expanded(
            child: TabBarView(controller: _tab, children: [
              // TEMPLATE TAB: grid frame dari admin
              framesAsync.when(
                loading: ()=> const Center(child: CircularProgressIndicator()),
                error: (e,_)=> Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Gagal: $e'), FilledButton(onPressed: ()=>ref.invalidate(framesProvider), child: Text('Retry'))])),
                data: (frames) => GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: frames.length,
                  itemBuilder: (_, i) {
                    final f = frames[i];
                    final sel = selectedFrame?.id == f.id;
                    return GestureDetector(
                      onTap: ()=>ref.read(mobileSessionProvider.notifier).selectFrame(f),
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: sel? Colors.deepPurple: Colors.grey.shade300, width: sel?3:1), borderRadius: BorderRadius.circular(12)),
                        child: Column(children: [
                          Expanded(child: f.thumbnailPath != null ? Image.network('${AppConfig.baseUrl.replaceFirst('/api','')}/storage/${f.thumbnailPath}', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_,_,_)=> const Icon(Icons.image)) : const Icon(Icons.filter_frames, size: 48)),
                          Padding(padding: const EdgeInsets.all(8), child: Text(f.name, style: TextStyle(fontWeight: sel?FontWeight.bold:FontWeight.normal))),
                          Text('${f.photoCount} foto', style: const TextStyle(fontSize: 11)),
                          if (sel) const Icon(Icons.check_circle, color: Colors.deepPurple, size: 16),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              // KUSTOM TAB: frame list kecil + sticker picker
              Column(children: [
                Expanded(
                  child: framesAsync.when(
                    loading: ()=> const Center(child: CircularProgressIndicator()),
                    error: (e,_)=> Center(child: Text('Error $e')),
                    data: (frames) => GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.75, crossAxisSpacing: 8, mainAxisSpacing: 8),
                      itemCount: frames.length,
                      itemBuilder: (_, i) {
                        final f = frames[i];
                        final sel = selectedFrame?.id == f.id;
                        return InkWell(onTap: ()=>ref.read(mobileSessionProvider.notifier).selectFrame(f), child: Container(decoration: BoxDecoration(border: Border.all(color: sel? Colors.deepPurple: Colors.grey.shade300, width: sel?2:1), borderRadius: BorderRadius.circular(8)), child: Column(children: [Expanded(child: Icon(Icons.filter_frames, color: sel? Colors.deepPurple: Colors.black54)), Text(f.name, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center)])));
                      },
                    ),
                  ),
                ),
                const Divider(),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Align(alignment: Alignment.centerLeft, child: Text('Pilih Stiker (tap untuk tambah, drag di preview untuk pindah)', style: TextStyle(fontSize: 11, color: Colors.black54)))),
                SizedBox(
                  height: 80,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, mainAxisSpacing: 8),
                    itemCount: kStickers.length,
                    itemBuilder: (_, i) {
                      final s = kStickers[i];
                      final chosen = stickers.any((p)=>p.sticker.id==s.id);
                      return GestureDetector(
                        onTap: ()=>ref.read(mobileSessionProvider.notifier).toggleSticker(s),
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(color: chosen? Colors.deepPurple.withValues(alpha: 0.15): Colors.grey.shade100, border: Border.all(color: chosen? Colors.deepPurple: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
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
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: selectedFrame==null ? null : () async {
                  try {
                    await ref.read(mobileSessionProvider.notifier).startSession();
                    if (context.mounted) Navigator.of(context).push(MaterialPageRoute(builder: (_)=> const ShootMobileScreen()));
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
