<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SessionSticker extends Model
{
    protected $fillable = [
        'session_id', 'sticker_id', 'x', 'y', 'size', 'rotation',
    ];

    protected $casts = [
        'x' => 'float',
        'y' => 'float',
        'size' => 'float',
        'rotation' => 'float',
    ];

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function sticker()
    {
        return $this->belongsTo(Sticker::class);
    }
}
