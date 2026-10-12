<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Sticker extends Model
{
    protected $fillable = [
        'nama',
        'gambar',
        'kategori',
        'deskripsi',
        'tag',
        'status',
    ];
}