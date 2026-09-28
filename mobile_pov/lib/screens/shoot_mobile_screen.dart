import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../state/session_state.dart';
import 'preview_select_screen.dart';

class ShootMobileScreen extends ConsumerStatefulWidget {
  const ShootMobileScreen({super.key});
  @override
  ConsumerState<ShootMobileScreen> createState() => _ShootMobileScreenState();
}

class _ShootMobileScreenState extends ConsumerState<ShootMobileScreen> {
  CameraController? _ctrl;
  bool _ready = false;
  final bool _busy = false;
  int _countdown = 0;
  String _status = 'Siap';
  final _picker = ImagePicker();

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) throw Exception('No camera');
      final cam = cams.firstWhere((c)=>c.lensDirection==CameraLensDirection.front, orElse: ()=>cams.first);
      _ctrl = CameraController(cam, ResolutionPreset.high, enableAudio: false);
      await _ctrl!.initialize();
      if (mounted) setState(()=>_ready=true);
      _burst();
    } catch (e) {
      if (mounted) setState(()=>_status='Kamera error: $e — pakai galeri');
    }
  }

  Future<void> _burst() async {
    final total = ref.read(mobileSessionProvider).frame?.photoCount ?? 3;
    for (int slot=0; slot<total; slot++) {
      if (!mounted) return;
      setState(()=>_status='Foto ${slot+1}/$total');
      for (int c=3; c>0; c--) {
        if (!mounted) return;
        setState(()=>_countdown=c);
        await Future.delayed(const Duration(seconds: 1));
      }
      setState(()=>_countdown=0);
      String path;
      try {
        if (_ctrl!=null && _ready) {
          final f = await _ctrl!.takePicture();
          path = f.path;
        } else {
          final x = await _picker.pickImage(source: ImageSource.gallery);
          if (x==null) throw Exception('Batal');
          path = x.path;
        }
        ref.read(mobileSessionProvider.notifier).addLocalPhoto(path);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal slot ${slot+1}: $e')));
      }
    }
    if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const PreviewSelectScreen()));
  }

  Future<void> _pickGallery() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x!=null) {
      ref.read(mobileSessionProvider.notifier).addLocalPhoto(x.path);
      if (ref.read(mobileSessionProvider).localPhotos.length >= (ref.read(mobileSessionProvider).frame?.photoCount ?? 3)) {
        if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const PreviewSelectScreen()));
      }
    }
  }

  @override
  void dispose() { _ctrl?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(mobileSessionProvider).frame?.photoCount ?? 3;
    final taken = ref.watch(mobileSessionProvider).localPhotos.length;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        if (_ready && _ctrl!=null) CameraPreview(_ctrl!) else const Center(child: CircularProgressIndicator()),
        Positioned(top: 40, left: 0, right: 0, child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal:12, vertical:6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: Text(_status, style: const TextStyle(color: Colors.white))))),
        Center(child: _countdown>0 ? Text('$_countdown', style: const TextStyle(color: Colors.white, fontSize: 120, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius:20, color: Colors.black)])) : const SizedBox()),
        Positioned(bottom: 30, left: 16, right: 16, child: Column(children: [
          LinearProgressIndicator(value: taken/total, backgroundColor: Colors.white24),
          const SizedBox(height: 8),
          Text('$taken/$total foto', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: _pickGallery, icon: const Icon(Icons.photo_library, color: Colors.white), label: const Text('Pilih dari Galeri', style: TextStyle(color: Colors.white))),
        ])),
        if (_busy) const Center(child: CircularProgressIndicator()),
      ]),
    );
  }
}
