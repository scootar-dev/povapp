<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FrameSlot extends Model
{
    protected \ = [
        'frame_id', 'slot_index', 'x', 'y', 'width', 'height', 'rotation',
    ];

    protected \ = [
        'rotation' => 'decimal:2',
    ];

    public function frame()
    {
        return \->belongsTo(Frame::class);
    }
}
