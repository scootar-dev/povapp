<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FrameSlot extends Model
{
    protected $fillable = [
        'frame_id', 'slot_index', 'x', 'y', 'width', 'height', 'rotation',
    ];

    public function frame()
    {
        return $this->belongsTo(Frame::class);
    }
}
