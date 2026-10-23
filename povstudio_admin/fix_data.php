<?php

require 'vendor/autoload.php';
$app = require 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

// Create some stickers (boolean status)
$stickers = [
    ['nama' => 'Sticker 1', 'gambar' => 'stickers/sticker1.png', 'kategori' => 'fun', 'status' => 1],
    ['nama' => 'Sticker 2', 'gambar' => 'stickers/sticker2.png', 'kategori' => 'fun', 'status' => 1],
    ['nama' => 'Sticker 3', 'gambar' => 'stickers/sticker3.png', 'kategori' => 'fun', 'status' => 1],
];

foreach ($stickers as $sticker) {
    App\Models\Sticker::create($sticker);
    echo "Created sticker: " . $sticker['nama'] . PHP_EOL;
}

echo "Done!" . PHP_EOL;