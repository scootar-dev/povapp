<?php

require 'vendor/autoload.php';
$app = require 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

// Check column type for stickers.status
$columns = \Illuminate\Support\Facades\DB::select("SHOW COLUMNS FROM stickers WHERE Field = 'status'");
print_r($columns);

$columns2 = \Illuminate\Support\Facades\DB::select("SHOW COLUMNS FROM frames WHERE Field = 'status'");
print_r($columns2);