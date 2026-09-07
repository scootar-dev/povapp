<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Frame extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'category', 'overlay_path', 'thumbnail_path',
        'photo_count', 'output_width_px', 'output_height_px',
        'dpi', 'print_size', 'is_active',
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
