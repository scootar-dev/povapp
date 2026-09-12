import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../core/app_config.dart';
import '../core/responsive.dart';
import '../core/storage.dart';
import '../services/print_service.dart';
import '../services/share_service.dart';
import '../state/session_state.dart';
import 'thank_you_screen.dart';

class PrintShareScreen extends ConsumerStatefulWidget {
  const PrintShareScreen({super.key});

  @override
  ConsumerState<PrintShareScreen> createState() => _PrintShareScreenState();
}

class _PrintShareScreenState extends ConsumerState<PrintShareScreen> {
  final _shareService = ShareService();
  final _printService = PrintService();
  final _inputController = TextEditingController();
  String _channel = 'whatsapp';
  bool _printing = false;
  bool _sharing = false;
  String? _feedback;
  String? _previewUrl;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final session = ref.read(sessionProvider);
      if (session.sessionId == null) return;
      // Ambil outputs untuk preview thumbnail
      final dio = Dio(BaseOptions(baseUrl: await KioskStorage.getBaseUrl(), headers: {'Authorization': 'Bearer ${await KioskStorage.getToken()}'}));
      final res = await dio.get('/kiosk/sessions/${session.sessionId}/outputs');
      final outs = res.data['data'] as List;
      final printOut = outs.cast<Map?>().firstWhere((o)=>o!=null && o['type']=='print_image', orElse: ()=>null);
      if (printOut != null && mounted) {
        final filePath = printOut['file_path'] as String;
        final base = (await KioskStorage.getBaseUrl()).replaceFirst('/api','');
        setState(()=>_previewUrl = '$base/storage/$filePath');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final base = AppConfig.baseUrl.replaceFirst('/api', '');
    final qrUrl = '$base/download/${session.sessionCode}';
    final isMobile = Responsive.isMobile(context);

    Widget printColumn() => Column(
          children: [
            if (_previewUrl != null)
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_previewUrl!, height: 180, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.image, size:48))),
            if (_previewUrl != null) const SizedBox(height: 12),
            const Text('Cetak Foto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.print),
                label: Text(_printing ? 'Mencetak...' : 'Cetak Sekarang'),
                onPressed: _printing ? null : _handlePrint,
              ),
            ),
            TextButton.icon(onPressed: _printService.savedPrinter==null ? ()=>_pickPrinter() : null, icon: const Icon(Icons.settings, size:16), label: Text(_printService.savedPrinter==null ? 'Pilih Printer (Setup)' : 'Printer: ${_printService.savedPrinter!.name}', style: const TextStyle(fontSize:11))),
            const SizedBox(height: 16),
            const Text('Scan untuk unduh digital', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Center(child: QrImageView(data: qrUrl, size: isMobile ? 160 : 180)),
            const SizedBox(height: 8),
            SelectableText(qrUrl, style: const TextStyle(fontSize: 10, color: Colors.white54), textAlign: TextAlign.center),
          ],
        );

    Widget shareColumn() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Kirim Digital', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'whatsapp', label: Text('WhatsApp'), icon: Icon(Icons.chat)),
                ButtonSegment(value: 'email', label: Text('Email'), icon: Icon(Icons.email)),
              ],
              selected: {_channel},
              onSelectionChanged: (s) => setState(() => _channel = s.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              keyboardType: _channel == 'whatsapp' ? TextInputType.phone : TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: _channel == 'whatsapp' ? 'Nomor WhatsApp' : 'Alamat Email',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.send),
              label: Text(_sharing ? 'Mengirim...' : 'Kirim'),
              onPressed: _sharing ? null : _handleShare,
            ),
            if (_feedback != null) ...[
              const SizedBox(height: 12),
              Text(_feedback!, style: const TextStyle(color: Colors.greenAccent)),
            ],
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _goToThankYou, child: const Text('Selesai')),
          ],
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Cetak & Bagikan')),
      body: Padding(
        padding: EdgeInsets.all(Responsive.padding(context)),
        child: isMobile
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    printColumn(),
                    const Divider(height: 48),
                    shareColumn(),
                  ],
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: printColumn()),
                  const VerticalDivider(width: 48),
                  Expanded(child: shareColumn()),
                ],
              ),
      ),
    );
  }

  Future<void> _pickPrinter() async {
    try {
      await _printService.pickAndSavePrinter(context);
      if (mounted) setState(()=>_feedback='Printer dipilih: ${_printService.savedPrinter?.name}');
    } catch (e) {
      if (mounted) setState(()=>_feedback='Gagal pilih printer: $e');
    }
  }

  Future<void> _handlePrint() async {
    setState(() { _printing = true; _feedback = null; });
    try {
      final session = ref.read(sessionProvider);
      await ref.read(sessionProvider.notifier).printResult();

      // Download file print_image lalu print fisik
      String? localPath;
      if (_previewUrl != null) {
        try {
          final dir = await getTemporaryDirectory();
          localPath = '${dir.path}/print_${session.sessionCode}.jpg';
          await Dio().download(_previewUrl!, localPath);
        } catch (_) {}
      }

      if (localPath != null && File(localPath).existsSync()) {
        if (_printService.savedPrinter == null) {
          setState(()=>_feedback='Tercatat di server. Pilih printer dulu untuk cetak fisik (Setup).');
        } else {
          // ignore: dead_null_aware_expression
          await _printService.printImageDirect(imageFilePath: localPath, printSize: session.frame?.printSize ?? '4r');
          setState(()=>_feedback='Berhasil dicetak!');
        }
      } else {
        setState(()=>_feedback='Perintah cetak tercatat di server. File cetak siap.');
      }
    } catch (e) {
      setState(()=>_feedback='Gagal mencetak: $e');
    } finally {
      if (mounted) setState(()=>_printing=false);
    }
  }

  Future<void> _handleShare() async {
    final input = _inputController.text.trim();
    final valid = _channel == 'whatsapp'
        ? _shareService.isValidWhatsAppNumber(input)
        : _shareService.isValidEmail(input);

    if (!valid) {
      setState(() => _feedback = _channel == 'whatsapp'
          ? 'Nomor WhatsApp tidak valid.'
          : 'Alamat email tidak valid.');
      return;
    }

    final recipient = _channel == 'whatsapp'
        ? _shareService.normalizeWhatsAppNumber(input)
        : input;

    setState(() => _sharing = true);
    try {
      await ref.read(sessionProvider.notifier).shareResult(_channel, recipient);
      setState(() => _feedback = 'Berhasil dikirim ke antrean pengiriman.');
    } catch (e) {
      setState(() => _feedback = 'Gagal mengirim: $e');
    } finally {
      setState(() => _sharing = false);
    }
  }

  void _goToThankYou() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ThankYouScreen()),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
