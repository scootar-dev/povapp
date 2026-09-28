import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/session_state.dart';
import 'qr_result_screen.dart';

class PreviewSelectScreen extends ConsumerStatefulWidget {
  const PreviewSelectScreen({super.key});
  @override
  ConsumerState<PreviewSelectScreen> createState() => _PreviewSelectScreenState();
}

class _PreviewSelectScreenState extends ConsumerState<PreviewSelectScreen> {
  bool _uploading = false;

  Future<void> _next() async {
    final s = ref.read(mobileSessionProvider);
    if (s.selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal 1 foto untuk dicetak/unduh')));
      return;
    }
    setState(()=>_uploading=true);
    try {
      await ref.read(mobileSessionProvider.notifier).uploadAll();
      final id = await ref.read(mobileSessionProvider.notifier).render();
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> QrResultScreen(outputId: id)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally { if (mounted) setState(()=>_uploading=false); }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(mobileSessionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Foto'), actions: [Center(child: Padding(padding: const EdgeInsets.only(right:12), child: Text('${s.selectedIndices.length} dipilih')))]),
      body: Column(children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: s.localPhotos.length,
            itemBuilder: (_, i) {
              final sel = s.selectedIndices.contains(i);
              return GestureDetector(
                onTap: ()=>ref.read(mobileSessionProvider.notifier).toggleSelect(i),
                child: Stack(children: [
                  Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(s.localPhotos[i]), fit: BoxFit.cover))),
                  Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), child: Text('Foto ${i+1}', style: const TextStyle(color: Colors.white, fontSize:10)))),
                  Positioned(top: 8, right: 8, child: Icon(sel? Icons.check_circle: Icons.circle_outlined, color: sel? Colors.greenAccent: Colors.white)),
                  if (s.stickers.isNotEmpty)
                    Positioned.fill(child: IgnorePointer(child: Stack(children: s.stickers.map((p)=> Positioned(left: p.dx*160, top: p.dy*180, child: Text(p.sticker.emoji, style: const TextStyle(fontSize: 20)))).toList()))),
                ]),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(width: double.infinity, child: FilledButton(
            onPressed: _uploading? null: _next,
            child: Padding(padding: const EdgeInsets.symmetric(vertical:14), child: _uploading? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)): const Text('Cetak & Buat QR')),
          )),
        ),
        Padding(padding: const EdgeInsets.only(bottom:12), child: Text('Tap foto untuk pilih/Batal pilih', style: TextStyle(fontSize:11, color: Colors.grey.shade600))),
      ]),
    );
  }
}
