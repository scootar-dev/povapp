<?php

require 'vendor/autoload.php';
$app = require 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$cols = \Illuminate\Support\Facades\Schema::getColumnListing('stickers');
print_r($cols);

$cols2 = \Illuminate\Support\Facades\Schema::getColumnListing('frames');
print_r($cols2);