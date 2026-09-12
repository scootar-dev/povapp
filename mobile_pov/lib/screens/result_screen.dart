import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';

class ResultScreen extends StatefulWidget {
  final SessionResult result;
  const ResultScreen({super.key, required this.result});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _downloading = false;
  String? _msg;

  OutputItem? get printOutput => widget.result.outputs.where((o)=>o.type=='print_image').isNotEmpty ? widget.result.outputs.firstWhere((o)=>o.type=='print_image') : null;
  OutputItem? get digitalOutput => widget.result.outputs.where((o)=>o.type=='digital_image').isNotEmpty ? widget.result.outputs.firstWhere((o)=>o.type=='digital_image') : widget.result.outputs.isNotEmpty ? widget.result.outputs.first : null;

  Future<void> _downloadAndShare(String url) async {
    setState(()=>_downloading=true);
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/pov_${widget.result.sessionCode}.jpg';
      await Dio().download(url, path);
      await Share.shareXFiles([XFile(path)], text: 'Foto POV Studio - ${widget.result.sessionCode}');
      setState(()=>_msg='Berhasil diunduh & dibagikan');
    } catch (e) {
      setState(()=>_msg='Gagal download: $e');
    } finally { setState(()=>_downloading=false); }
  }

  Future<void> _download(String url) async {
    setState(()=>_downloading=true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/pov_${widget.result.sessionCode}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await Dio().download(url, path);
      if (!mounted) return;
      setState(()=>_msg='Tersimpan di: $path');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Disimpan: $path')));
    } catch (e) {
      if (mounted) setState(()=>_msg='Gagal: $e');
    } finally { if (mounted) setState(()=>_downloading=false); }
  }

  @override
  Widget build(BuildContext context) {
    final imgUrl = digitalOutput?.url ?? printOutput?.url;
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Foto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (imgUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(imageUrl: imgUrl, fit: BoxFit.cover, placeholder: (_,_)=> const SizedBox(height:200, child:Center(child:CircularProgressIndicator())), errorWidget: (_,_,_)=> Container(height:200,color:Colors.grey.shade900, child: const Icon(Icons.broken_image,color:Colors.white54))),
            )
          else
            Container(height:200, decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('Belum ada output', style: TextStyle(color: Colors.white54)))),

          const SizedBox(height: 16),
          Text('Kode: ${widget.result.sessionCode}', style: const TextStyle(fontSize:12, color: Colors.black54), textAlign: TextAlign.center),
          const SizedBox(height: 16),

          if (_msg != null) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: Text(_msg!, style: TextStyle(color: Colors.green.shade900, fontSize:12))),

          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _downloading || imgUrl==null ? null : ()=>_download(imgUrl), icon: const Icon(Icons.download), label: Text(_downloading?'Memproses...':'Download ke HP')),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: _downloading || imgUrl==null ? null : ()=>_downloadAndShare(imgUrl), icon: const Icon(Icons.share), label: const Text('Bagikan')),
          const SizedBox(height: 12),
          if (widget.result.outputs.length>1) ...[
            const Divider(),
            const Text('Semua file:', style: TextStyle(fontWeight: FontWeight.w600)),
            ...widget.result.outputs.map((o)=> ListTile(leading: Icon(o.type=='print_image'?Icons.print:Icons.phone_iphone), title: Text(o.type), subtitle: Text(o.url, maxLines:1, overflow: TextOverflow.ellipsis), trailing: IconButton(icon: const Icon(Icons.download), onPressed: ()=>_download(o.url)))),
          ],
        ],
      ),
    );
  }
}
