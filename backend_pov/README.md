# POV Studio — Backend (Laravel)

Skeleton backend untuk aplikasi Photobooth Self-Service "POV Studio". Ini bukan project Laravel penuh
(tidak menyertakan file inti framework seperti `artisan`, `bootstrap/`, `vendor/`), melainkan kumpulan
Models, Controllers, Migrations, Jobs, Routes, dan Mailable yang perlu kamu tempel ke dalam project
Laravel baru.

## Cara pakai

1. Buat project Laravel baru:
   ```bash
   composer create-project laravel/laravel pov-studio-backend
   cd pov-studio-backend
   ```

2. Install package tambahan yang dipakai di kode ini:
   ```bash
   composer require intervention/image simplesoftwareio/simple-qrcode laravel/sanctum
   ```

3. Copy folder-folder di sini ke project Laravel-mu (timpa file yang sudah ada bila perlu):
   - `app/Models/*` → `app/Models/`
   - `app/Http/Controllers/*` → `app/Http/Controllers/`
   - `app/Http/Middleware/*` → `app/Http/Middleware/`
   - `app/Jobs/*` → `app/Jobs/`
   - `app/Mail/*` → `app/Mail/`
   - `database/migrations/*` → `database/migrations/`
   - `resources/views/emails/*` → `resources/views/emails/`
   - `routes/api.php` → timpa `routes/api.php` bawaan

4. Daftarkan middleware `auth:studio-token` di `bootstrap/app.php` (Laravel 11+):
   ```php
   ->withMiddleware(function (Middleware $middleware) {
       $middleware->alias([
           'auth:studio-token' => \App\Http\Middleware\AuthenticateStudioToken::class,
       ]);
   })
   ```
   Atau di `app/Http/Kernel.php` (Laravel 10) tambahkan ke `$middlewareAliases`.

5. Set `.env`:
   ```env
   DB_CONNECTION=mysql
   DB_DATABASE=pov_studio
   QUEUE_CONNECTION=database   # atau redis untuk production

   MAIL_MAILER=mailgun         # atau smtp
   MAILGUN_DOMAIN=
   MAILGUN_SECRET=

   FONNTE_TOKEN=               # token provider WhatsApp
   ```
   Tambahkan `'fonnte' => ['token' => env('FONNTE_TOKEN')]` ke `config/services.php`.

6. Migrate & storage link:
   ```bash
   php artisan migrate
   php artisan storage:link
   php artisan queue:work   # wajib jalan agar render/print/share job diproses
   ```

## Yang masih perlu kamu lengkapi (TODO)

- Generate GIF/video burst hasil sesi di `RenderOutputJob` (disarankan pakai `php-ffmpeg/php-ffmpeg`).
- Broadcast realtime (Laravel Reverb/Pusher) supaya Flutter tahu kapan render/print selesai tanpa polling terus-menerus.
- Endpoint untuk Flutter melaporkan balik status print (`success`/`failed`) setelah eksekusi native print — karena cetak fisik terjadi di sisi device, bukan di server.
- Autentikasi Sanctum untuk grup `admin/*` (login user staf).
- Rate limiting & validasi tambahan untuk endpoint publik `/download/{sessionCode}`.
