import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/app_config.dart';
import '../welcome_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTab = 0;
  bool _isLoading = false;

  List<dynamic> _studios = [];
  List<dynamic> _frames = [];
  Map<String, dynamic>? _reports;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final studiosRes = await ApiClient.instance.getStudiosAdmin();
      final framesRes = await ApiClient.instance.getFramesAdmin();
      final reportsRes = await ApiClient.instance.getReportsSummaryAdmin();

      setState(() {
        _studios = studiosRes.data['data'] ?? [];
        _frames = framesRes.data['data'] ?? [];
        _reports = reportsRes.data['data'] ?? {};
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data admin: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewStudioDialog() async {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    String cameraSource = 'internal';

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buat Event / Studio Kiosk Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Event / Studio')),
            TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Lokasi')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: cameraSource,
              decoration: const InputDecoration(labelText: 'Sumber Kamera Default'),
              items: const [
                DropdownMenuItem(value: 'internal', child: Text('Kamera Internal / Webcam / Tablet')),
                DropdownMenuItem(value: 'dslr', child: Text('Kamera DSLR / Mirrorless (USB)')),
              ],
              onChanged: (val) => cameraSource = val ?? 'internal',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              try {
                final res = await ApiClient.instance.createStudioAdmin(
                  name: nameCtrl.text.trim(),
                  location: locCtrl.text.trim(),
                  cameraSource: cameraSource,
                );
                final deviceToken = res.data['device_token'] as String;
                await AppConfig.saveSettings(studioToken: deviceToken, cameraSource: cameraSource);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Studio dibuat! Device Token disimpan otomatis ke Kiosk ini.')),
                  );
                  _loadDashboardData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal membuat studio: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan & Hubungkan Kiosk'),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewFrameDialog() async {
    final nameCtrl = TextEditingController();
    final overlayCtrl = TextEditingController(text: 'frames/sample_overlay.png');
    final countCtrl = TextEditingController(text: '4');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload & Setting Frame Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Frame')),
              TextField(controller: overlayCtrl, decoration: const InputDecoration(labelText: 'Overlay Path (storage/public)')),
              TextField(controller: countCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah Foto (Slots)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              final photoCount = int.tryParse(countCtrl.text) ?? 4;
              final slots = List.generate(photoCount, (i) => {
                'slot_index': i,
                'x': 100,
                'y': 100 + (i * 350),
                'width': 600,
                'height': 400,
                'rotation': 0,
              });

              try {
                await ApiClient.instance.createFrameAdmin({
                  'name': nameCtrl.text.trim(),
                  'category': 'General',
                  'overlay_path': overlayCtrl.text.trim(),
                  'photo_count': photoCount,
                  'output_width_px': 1200,
                  'output_height_px': 1800,
                  'dpi': 300,
                  'print_size': '4r',
                  'slots': slots,
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Frame baru berhasil ditambahkan!')),
                  );
                  _loadDashboardData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menambah frame: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan Frame'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POV Studio — Admin Dashboard'),
        backgroundColor: Colors.purple.shade900,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.screen_rotation, color: Colors.amberAccent),
            label: const Text('MASUK KIOSK MODE', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout Admin',
            onPressed: () async {
              await AppConfig.clearAdminToken();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedTab,
                  onDestinationSelected: (idx) => setState(() => _selectedTab = idx),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Ringkasan')),
                    NavigationRailDestination(icon: Icon(Icons.event), label: Text('Events / Studio')),
                    NavigationRailDestination(icon: Icon(Icons.filter_frames), label: Text('Frames')),
                    NavigationRailDestination(icon: Icon(Icons.camera_alt), label: Text('Pengaturan Kamera')),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildSummaryTab();
      case 1:
        return _buildStudiosTab();
      case 2:
        return _buildFramesTab();
      case 3:
        return _buildCameraConfigTab();
      default:
        return _buildSummaryTab();
    }
  }

  Widget _buildSummaryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ringkasan Statistik (30 Hari Terakhir)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard('Total Sesi', '${_reports?['total_sessions'] ?? 0}', Colors.purple),
            _buildStatCard('Sesi Selesai', '${_reports?['completed_sessions'] ?? 0}', Colors.green),
            _buildStatCard('Total Cetak', '${_reports?['total_prints'] ?? 0}', Colors.blue),
            _buildStatCard('Total Share WA/Mail', '${_reports?['total_shares'] ?? 0}', Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.15),
        margin: const EdgeInsets.only(right: 16),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudiosTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Daftar Event / Studio Kiosk', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tambah Event/Studio'),
              onPressed: _createNewStudioDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _studios.length,
            itemBuilder: (ctx, i) {
              final studio = _studios[i];
              final isCurrent = AppConfig.studioToken.isNotEmpty && AppConfig.studioToken == studio['device_token'];
              return Card(
                child: ListTile(
                  leading: Icon(
                    studio['camera_source'] == 'dslr' ? Icons.camera : Icons.linked_camera,
                    color: Colors.purpleAccent,
                  ),
                  title: Text('${studio['name']} ${isCurrent ? " (KIOSK INI)" : ""}'),
                  subtitle: Text('Lokasi: ${studio['location'] ?? "-"} | Kamera: ${studio['camera_source']}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await AppConfig.saveSettings(
                        studioToken: studio['device_token'],
                        cameraSource: studio['camera_source'],
                      );
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Kiosk dihubungkan ke: ${studio['name']}')),
                      );
                    },
                    child: Text(isCurrent ? 'Terhubung' : 'Hubungkan Kiosk ini'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFramesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Daftar Frame & Template Layout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Tambah Frame Baru'),
              onPressed: _createNewFrameDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _frames.length,
            itemBuilder: (ctx, i) {
              final f = _frames[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.filter_frames, size: 36, color: Colors.purpleAccent),
                  title: Text(f['name'] ?? 'Frame'),
                  subtitle: Text('${f['photo_count']} Slots | Size: ${f['print_size']}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCameraConfigTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pengaturan Hardware Kamera', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Mode Kamera Kiosk:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                RadioListTile<String>(
                  title: const Text('Kamera Internal / Webcam / Tablet Camera'),
                  subtitle: const Text('Menggunakan kamera bawaan tablet/webcam via package official camera'),
                  value: 'internal',
                  groupValue: AppConfig.cameraSource,
                  onChanged: (val) async {
                    await AppConfig.saveSettings(cameraSource: val);
                    setState(() {});
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Kamera DSLR / Mirrorless (Canon / Nikon / Sony via USB)'),
                  subtitle: const Text('Menggunakan native channel libgphoto2 / PTP protocol'),
                  value: 'dslr',
                  groupValue: AppConfig.cameraSource,
                  onChanged: (val) async {
                    await AppConfig.saveSettings(cameraSource: val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
