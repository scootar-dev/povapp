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
  Map<String, dynamic>? _selectedEvent;

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
        if (_studios.isNotEmpty && _selectedEvent == null) {
          _selectedEvent = _studios.first;
        }
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
    final pinCtrl = TextEditingController(text: '1234');
    String cameraSource = 'internal';
    String eventType = 'wedding';

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F0038),
        title: const Text('🎉 Buat Folder Event Baru (LumaBooth Style)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Nama Event (mis. Pernikahan Budi & Ani)', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Lokasi Event / Venue', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: eventType,
                dropdownColor: const Color(0xFF1F0038),
                decoration: const InputDecoration(labelText: 'Kategori Event', labelStyle: TextStyle(color: Colors.white70)),
                items: const [
                  DropdownMenuItem(value: 'wedding', child: Text('💍 Pernikahan / Wedding', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'birthday', child: Text('🎂 Ulang Tahun / Birthday', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'corporate', child: Text('🏢 Corporate / Brand Launch', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'general', child: Text('✨ Event Umum', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) => eventType = val ?? 'wedding',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: cameraSource,
                dropdownColor: const Color(0xFF1F0038),
                decoration: const InputDecoration(labelText: 'Sumber Kamera', labelStyle: TextStyle(color: Colors.white70)),
                items: const [
                  DropdownMenuItem(value: 'internal', child: Text('📷 Kamera Internal / Webcam / Tablet', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'dslr', child: Text('📸 Kamera DSLR / Mirrorless (USB)', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) => cameraSource = val ?? 'internal',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'PIN Pengunci Kiosk (Exit Code)', labelStyle: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
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
                    SnackBar(content: Text('Folder Event "${nameCtrl.text}" berhasil dibuat!')),
                  );
                  _loadDashboardData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal membuat event: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _startEventKiosk(Map<String, dynamic> studio) async {
    await AppConfig.saveSettings(
      studioToken: studio['device_token'],
      cameraSource: studio['camera_source'],
    );

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.photo_camera_front_rounded, color: Colors.purpleAccent),
            SizedBox(width: 12),
            Text('POV BOOTH MANAGER (LUMABOOTH STYLE)', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        backgroundColor: const Color(0xFF190A2D),
        actions: [
          if (_selectedEvent != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text('MULAI ACARA (${_selectedEvent!['name'].toString().toUpperCase()})', style: const TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _startEventKiosk(_selectedEvent!),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
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
          ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
          : Row(
              children: [
                NavigationRail(
                  backgroundColor: const Color(0xFF140824),
                  selectedIndex: _selectedTab,
                  onDestinationSelected: (idx) => setState(() => _selectedTab = idx),
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: Colors.purpleAccent, size: 30),
                  unselectedIconTheme: const IconThemeData(color: Colors.white54),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.folder_special), label: Text('Folder Event')),
                    NavigationRailDestination(icon: Icon(Icons.filter_frames), label: Text('Frames')),
                    NavigationRailDestination(icon: Icon(Icons.tune), label: Text('Setting Waktu Shoot')),
                    NavigationRailDestination(icon: Icon(Icons.bar_chart), label: Text('Statistik')),
                  ],
                ),
                const VerticalDivider(width: 1, color: Colors.white12),
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
        return _buildEventsFolderTab();
      case 1:
        return _buildFramesTab();
      case 2:
        return _buildSettingsTab();
      case 3:
        return _buildSummaryTab();
      default:
        return _buildEventsFolderTab();
    }
  }

  Widget _buildEventsFolderTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Folder Sesi & Event Acara', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Pilih event yang akan dijalankan di booth photobooth ini', style: TextStyle(color: Colors.white60)),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.create_new_folder_rounded),
              label: const Text('Buat Event Baru', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _createNewStudioDialog,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _studios.isEmpty
              ? const Center(child: Text('Belum ada folder event. Klik "Buat Event Baru" untuk memulai.', style: TextStyle(color: Colors.white70)))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _studios.length,
                  itemBuilder: (ctx, i) {
                    final studio = _studios[i];
                    final isSelected = _selectedEvent?['id'] == studio['id'];
                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.purpleAccent.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? Colors.purpleAccent : Colors.white12, width: isSelected ? 2 : 1),
                        boxShadow: isSelected
                            ? [BoxShadow(color: Colors.purpleAccent.withOpacity(0.3), blurRadius: 20)]
                            : null,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => setState(() => _selectedEvent = studio),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.purpleAccent.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      studio['camera_source'] == 'dslr' ? Icons.camera : Icons.linked_camera,
                                      color: Colors.purpleAccent,
                                      size: 28,
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.greenAccent),
                                      ),
                                      child: const Text('EVENT AKTIF', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                studio['name'] ?? 'Event Booth',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text('📍 Venue: ${studio['location'] ?? "General"}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected ? Colors.greenAccent.shade700 : Colors.purpleAccent.withOpacity(0.3),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.play_arrow, size: 18),
                                  label: Text(isSelected ? 'MULAI ACARA BUKAT BOOTH' : 'Pilih Event Ini'),
                                  onPressed: () {
                                    setState(() => _selectedEvent = studio);
                                    _startEventKiosk(studio);
                                  },
                                ),
                              ),
                            ],
                          ),
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
        const Text('Frame Manager — Pilihan Design Template', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _frames.length,
            itemBuilder: (ctx, i) {
              final f = _frames[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_frames, size: 48, color: Colors.purpleAccent),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(f['name'] ?? 'Frame Template', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('${f['photo_count']} Slots | Size: ${f['print_size']}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Setting Kamera & Durasi Waktu Capture', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                const Text('📷 Sumber Kamera:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                RadioListTile<String>(
                  title: const Text('Kamera Internal / Webcam / Tablet Camera', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Default camera tablet atau webcam', style: TextStyle(color: Colors.white60)),
                  value: 'internal',
                  groupValue: AppConfig.cameraSource,
                  onChanged: (val) async {
                    await AppConfig.saveSettings(cameraSource: val);
                    setState(() {});
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Kamera DSLR / Mirrorless (USB)', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('PTP USB capture via libgphoto2', style: TextStyle(color: Colors.white60)),
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
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ringkasan Statistik Booth (30 Hari Terakhir)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildStatCard('Total Sesi', '${_reports?['total_sessions'] ?? 0}', Colors.purpleAccent),
            _buildStatCard('Sesi Selesai', '${_reports?['completed_sessions'] ?? 0}', Colors.greenAccent),
            _buildStatCard('Total Cetak', '${_reports?['total_prints'] ?? 0}', Colors.cyanAccent),
            _buildStatCard('Total Share WA/Mail', '${_reports?['total_shares'] ?? 0}', Colors.orangeAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
