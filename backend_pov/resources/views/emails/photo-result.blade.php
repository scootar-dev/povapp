@component('mail::message')
# Terima kasih sudah foto di POV Studio! 📸

Berikut hasil sesi fotomu. File resolusi cetak sudah kami lampirkan di email ini.

@component('mail::button', ['url' => $downloadPageUrl])
Lihat & Unduh Semua File
@endcomponent

Sampai jumpa di sesi foto berikutnya!

Salam,<br>
POV Studio
@endcomponent
