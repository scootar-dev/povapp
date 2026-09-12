import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  String? _error;

  Future<void> _fetch() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Masukkan kode sesi atau link download');
      return;
    }
    // dukung paste full URL: https://host/download/<uuid>
    final sessionCode = code.contains('/download/') ? code.split('/download/').last.split('?').first.split('/').first : code;

    setState(() { _loading = true; _error = null; });
    try {
      final result = await _api.fetchDownload(sessionCode);
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultScreen(result: result)));
      }
    } catch (e) {
      setState(() => _error = 'Gagal memuat: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF2D0B4E), Color(0xFF6A1FB8)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.camera_alt_rounded, size: 64, color: Colors.white),
                const SizedBox(height: 12),
                const Text('POV STUDIO', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3)),
                const Text('Download foto kamu', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 32),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Masukkan Kode / Link QR', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'contoh: f1c456f0-... atau https://.../download/...',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.qr_code),
                          ),
                          onSubmitted: (_) => _fetch(),
                        ),
                        const SizedBox(height: 12),
                        if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _loading ? null : _fetch,
                          icon: _loading ? const SizedBox(width:16,height:16, child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Icon(Icons.search),
                          label: Text(_loading ? 'Memuat...' : 'Lihat Foto'),
                        ),
                        const SizedBox(height: 8),
                        const Text('Scan QR di layar kiosk, lalu paste link-nya di sini. Atau ketik kode sesi.', style: TextStyle(fontSize: 11, color: Colors.black54), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Text('Butuh bantuan? Hubungi petugas studio', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
