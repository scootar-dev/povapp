<?php

require 'vendor/autoload.php';
$app = require 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "Frames: " . App\Models\Frame::count() . PHP_EOL;
App\Models\Frame::all()->each(function($f) {
    echo $f->id . ' ' . $f->nama . ' ' . $f->status . PHP_EOL;
});

echo "Stickers: " . App\Models\Sticker::count() . PHP_EOL;
App\Models\Sticker::all()->each(function($s) {
    echo $s->id . ' ' . $s->nama . ' ' . $s->status . PHP_EOL;
});