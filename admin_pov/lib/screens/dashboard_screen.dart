import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _summary;
  List _studios = [];
  List _frames = [];
  List _sessions = [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(()=>_loading=true);
    try {
      final s = await ApiService.instance.getSummary();
      final st = await ApiService.instance.getStudios();
      final fr = await ApiService.instance.getFrames();
      final se = await ApiService.instance.getSessions();
      setState(() {
        _summary = s.data['data'];
        _studios = st.data['data'] is List ? st.data['data'] : (st.data['data']['data'] ?? []);
        final fData = fr.data['data'];
        _frames = fData is List ? fData : (fData['data'] ?? []);
        final sessData = se.data['data'];
        _sessions = sessData is List ? sessData : (sessData['data'] ?? []);
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal load: $e')));
    } finally { if (mounted) setState(()=>_loading=false); }
  }

  Future<void> _logout() async {
    try { await ApiService.instance.logout(); } catch (_) {}
    await ApiService.instance.clearToken();
    if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POV Admin Dashboard'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh)), IconButton(onPressed: _logout, icon: const Icon(Icons.logout))]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          // Summary cards
          if (_summary!=null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(spacing: 12, runSpacing: 12, children: [
                _card('Total Sesi', '${_summary!['total_sessions']}', Colors.deepPurple),
                _card('Selesai', '${_summary!['completed_sessions']}', Colors.green),
                _card('Batal', '${_summary!['abandoned_sessions']}', Colors.red),
                _card('Print', '${_summary!['total_prints']}', Colors.orange),
                _card('Share', '${_summary!['total_shares']}', Colors.blue),
              ]),
            ),
          // Tabs
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(children: [
              _tabBtn('Sesi',0), _tabBtn('Studio',1), _tabBtn('Frame',2),
            ]),
          ),
          Expanded(child: _buildTab()),
        ],
      ),
    );
  }

  Widget _card(String t, String v, Color c) => Container(width: 140, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.withValues(alpha: 0.3))), child: Column(children: [Text(v, style: TextStyle(fontSize:22, fontWeight: FontWeight.bold, color: c)), const SizedBox(height:4), Text(t, style: const TextStyle(fontSize:11))]));

  Widget _tabBtn(String l, int i) => Expanded(child: InkWell(onTap: ()=>setState(()=>_tab=i), child: Container(padding: const EdgeInsets.symmetric(vertical:14), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _tab==i? Colors.deepPurple: Colors.transparent, width:3))), child: Text(l, textAlign: TextAlign.center, style: TextStyle(fontWeight: _tab==i?FontWeight.bold:FontWeight.normal, color: _tab==i? Colors.deepPurple: Colors.black54)))));

  Widget _buildTab() {
    if (_tab==1) {
      if (_studios.isEmpty) return const Center(child: Text('Belum ada studio'));
      return ListView.separated(padding: const EdgeInsets.all(12), itemCount: _studios.length, separatorBuilder: (_,_)=>const Divider(), itemBuilder: (_,i){
        final s=_studios[i]; return ListTile(leading: const Icon(Icons.store), title: Text(s['name']??'-'), subtitle: Text('Token: ${(s['device_token']??'').toString().substring(0, 20)}... | ${s['location']??'-'} | ${s['camera_source']??''}'), trailing: Chip(label: Text(s['is_active']==1||s['is_active']==true?'Aktif':'Nonaktif')));
      });
    }
    if (_tab==2) {
      if (_frames.isEmpty) return const Center(child: Text('Belum ada frame'));
      return GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: _frames.length, itemBuilder: (_,i){
        final f=_frames[i]; return Card(child: Column(children: [Expanded(child: f['thumbnail_path']!=null ? Image.network('http://localhost:8000/storage/${f['thumbnail_path']}', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_,_,_)=>const Icon(Icons.image)) : const Icon(Icons.filter_frames, size:48)), Padding(padding: const EdgeInsets.all(8), child: Text(f['name']??'', style: const TextStyle(fontWeight: FontWeight.w600))), Text('${f['photo_count']??'?'} foto', style: const TextStyle(fontSize:11))]));
      });
    }
    // sessions
    if (_sessions.isEmpty) return const Center(child: Text('Belum ada sesi'));
    return ListView.separated(padding: const EdgeInsets.all(12), itemCount: _sessions.length, separatorBuilder: (_,_)=>const Divider(), itemBuilder: (_,i){
      final s=_sessions[i]; return ListTile(leading: CircleAvatar(child: Text('${s['id']}')), title: Text('Sesi ${s['session_code']?.toString().substring(0,8)??s['id']} - ${s['status']}'), subtitle: Text('Studio: ${s['studio']?['name']??s['studio_id']} | Frame: ${s['frame']?['name']??s['frame_id']??'-'} | ${s['created_at']??''}'), trailing: const Icon(Icons.chevron_right), onTap: () async {
        final d = await ApiService.instance.getSession(s['id']);
        if (!mounted) return;
        showDialog(context: context, builder: (_)=>AlertDialog(title: Text('Detail Sesi ${s['id']}'), content: SingleChildScrollView(child: Text(d.data.toString())), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Tutup'))]));
      });
    });
  }
}
