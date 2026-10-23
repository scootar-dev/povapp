<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Frame extends Model
{
    use HasFactory;

    protected $fillable = [
        'nama',
        'gambar',
        'overlay_path',
        'thumbnail_path',
        'kategori',
        'deskripsi',
        'tag',
        'total_penggunaan',
        'photo_count',
        'output_width_px',
        'output_height_px',
        'dpi',
        'print_size',
        'is_active',
        'status',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'total_penggunaan' => 'integer',
        'photo_count' => 'integer',
        'output_width_px' => 'integer',
        'output_height_px' => 'integer',
        'dpi' => 'integer',
    ];

    public function slots()
    {
        return $this->hasMany(FrameSlot::class)->orderBy('slot_index');
    }

    public function sessions()
    {
        return $this->hasMany(Session::class);
    }
}
