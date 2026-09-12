import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/app_config.dart';
import '../core/responsive.dart';
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
  final _inputController = TextEditingController();
  String _channel = 'whatsapp';
  bool _printing = false;
  bool _sharing = false;
  String? _feedback;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final qrUrl = '${AppConfig.baseUrl.replaceFirst('/api', '')}/download/${session.sessionCode}';
    final isMobile = Responsive.isMobile(context);

    Widget printColumn() => Column(
          children: [
            const Text('Cetak Foto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.print),
                label: Text(_printing ? 'Mencetak...' : 'Cetak Sekarang'),
                onPressed: _printing ? null : _handlePrint,
              ),
            ),
            const SizedBox(height: 32),
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

  Future<void> _handlePrint() async {
    setState(() => _printing = true);
    try {
      // Queue perintah cetak di backend (mencatat log), lalu eksekusi cetak
      // fisik lewat PrintService (native AirPrint/Windows Print Spooler)
      // menggunakan file output print_image yang sudah di-render.
      await ref.read(sessionProvider.notifier).printResult();
      // TODO: panggil PrintService().printImageDirect(...) dengan path file
      // output print_image yang sudah diunduh/di-cache lokal.
      setState(() => _feedback = 'Perintah cetak terkirim.');
    } catch (e) {
      setState(() => _feedback = 'Gagal mencetak: $e');
    } finally {
      setState(() => _printing = false);
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
