<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Unduh Foto - POV Studio</title>
    <style>
        * { box-sizing: border-box; }
        body {
            margin: 0;
            min-height: 100vh;
            font-family: system-ui, -apple-system, "Segoe UI", sans-serif;
            background: linear-gradient(160deg, #1a0b2e 0%, #6a1fb8 100%);
            color: #fff;
            display: flex;
            justify-content: center;
            padding: 24px 16px 48px;
        }
        .card {
            width: 100%;
            max-width: 560px;
            background: rgba(255,255,255,.97);
            color: #1a0b2e;
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 20px 60px rgba(0,0,0,.35);
        }
        h1 { margin: 0 0 4px; font-size: 22px; }
        .sub { margin: 0 0 20px; color: #7a7185; font-size: 13px; }
        .preview {
            width: 100%;
            border-radius: 14px;
            display: block;
            background: #f3f0f7;
            margin-bottom: 16px;
        }
        .btn {
            display: block;
            width: 100%;
            text-align: center;
            text-decoration: none;
            background: #cf185b;
            color: #fff;
            font-weight: 700;
            padding: 14px;
            border-radius: 12px;
            margin-bottom: 10px;
        }
        .btn.secondary { background: #efe9f6; color: #4b3a63; }
        .meta { font-size: 12px; color: #857b91; word-break: break-all; }
    </style>
</head>
<body>
    <main class="card">
        <h1>Foto kamu sudah siap 🎉</h1>
        <p class="sub">Kode sesi: {{ $session->session_code }}</p>

        @php
            $digital = $outputs->firstWhere('type', 'digital_image') ?? $outputs->first();
            $print = $outputs->firstWhere('type', 'print_image');
        @endphp

        @if ($digital)
            <img class="preview" src="{{ $digital['url'] }}" alt="Hasil foto">
            <a class="btn" href="{{ $digital['url'] }}" download>Unduh Foto Digital</a>
        @endif

        @if ($print && $print['url'] !== ($digital['url'] ?? null))
            <a class="btn secondary" href="{{ $print['url'] }}" download>Unduh Versi Cetak</a>
        @endif

        @if (! $outputs->count())
            <p class="meta">Hasil foto belum tersedia. Coba muat ulang halaman ini beberapa saat lagi.</p>
        @endif

        <p class="meta">Simpan halaman ini untuk mengunduh ulang foto kamu.</p>
    </main>
</body>
</html>
