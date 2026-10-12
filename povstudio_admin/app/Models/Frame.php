<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Frame extends Model
{
    protected $fillable = [
        'nama',
        'gambar',
        'kategori',
        'deskripsi',
        'tag',
        'status',
        'total_penggunaan',
    ];
}