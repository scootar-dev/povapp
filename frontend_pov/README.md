# POV Studio — Frontend (Flutter)

Struktur project Flutter untuk kios Photobooth Self-Service. Sudah termasuk `pubspec.yaml`
lengkap dengan dependency yang dipakai kode ini.

## Cara pakai

1. Pastikan Flutter SDK ≥ 3.3 sudah terpasang, lalu dari folder ini:
   ```bash
   flutter pub get
   ```

2. Set base URL & token studio saat build/run (lihat `lib/core/app_config.dart`):
   ```bash
   flutter run -d windows \
     --dart-define=API_BASE_URL=https://pov-studio-api.example.com/api \
     --dart-define=STUDIO_TOKEN=<device_token_dari_admin_panel>
   ```
   Untuk production, sebaiknya baca token dari `flutter_secure_storage` yang diisi
   sekali saat setup awal kios, bukan lewat `--dart-define` di build command.

3. Jalankan di target platform:
   - **iPad**: `flutter run -d <device_id>` (perlu Apple Developer account untuk deploy ke device fisik / TestFlight).
   - **Windows**: `flutter run -d windows` (aktifkan dulu `flutter config --enable-windows-desktop`).
   - **Android Tablet**: `flutter run -d <device_id>`.

## Alur layar (sesuai urutan navigasi)

```
WelcomeScreen
  → FrameSelectionScreen   (GET /kiosk/frames, lalu POST /kiosk/sessions)
  → PrepCountdownScreen    (idle timer 50s + speed-up)
  → ShootScreen            (live preview + automated burst per grid frame)
  → PreviewRetakeScreen    (preview semua foto + retake sesuai kuota)
  → FilterScreen           (pilih filter warna, real-time via FilterService)
  → RenderingScreen        (POST /kiosk/sessions/{id}/render, polling output)
  → PrintShareScreen       (cetak langsung + kirim WA/Email + QR download)
  → ThankYouScreen         (auto-reset ke WelcomeScreen setelah beberapa detik)
```

State lintas layar dikelola oleh `sessionProvider` (Riverpod) di `lib/state/session_state.dart` —
semua layar tinggal `ref.watch(sessionProvider)` untuk baca data sesi aktif.

## Yang masih perlu kamu lengkapi (TODO)

- **Integrasi DSLR nyata**: `lib/services/dslr_camera_service.dart` baru kontrak
  `MethodChannel`. Perlu ditulis native plugin:
  - Windows: C++ plugin yang bind ke `libgphoto2` (atau jalankan proses `gphoto2` CLI dan parse output-nya).
  - macOS: Swift plugin yang memanggil `libgphoto2` (install via Homebrew) lewat FFI/C-bridge.
- **Retake per-slot**: `PreviewRetakeScreen._retake()` saat ini hanya menghapus foto dari
  state dan menampilkan snackbar. Perlu dibuatkan mode khusus di `ShootScreen` (atau layar
  terpisah `RetakeShootScreen`) yang hanya memfoto ulang 1 slot tertentu, lalu kembali ke
  `PreviewRetakeScreen`.
- **Printer default per-kios**: `PrintService.printImageDirect()` memakai `Printing.pickPrinter()`
  yang akan menampilkan dialog pilih printer — untuk kios sebaiknya simpan printer pilihan
  di setup awal (local storage) supaya tidak perlu pilih ulang tiap sesi.
- **Overlay frame di layar Shoot**: gambar frame (SVG/PNG) dari `frame.overlay_path` belum
  ditumpuk di atas `CameraPreview`. Bisa dipasang dengan `Stack` + `Positioned` mengikuti
  koordinat `frame.slots[_currentSlot]`.
- **GIF/video hasil burst**: belum ada layar/preview untuk output tipe `gif`/`video` dari backend.
- **Kiosk mode native**: kunci device supaya tidak bisa keluar aplikasi (Android: pinning
  mode / kiosk launcher; Windows: assigned access; iPad: Guided Access) — di luar cakupan kode Flutter.
