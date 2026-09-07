<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Photo extends Model
{
    protected $fillable = [
        'session_id', 'slot_index', 'file_path', 'is_selected', 'attempt_number',
    ];

    protected $casts = [
        'is_selected' => 'boolean',
    ];

    public function session()
    {
        return $this->belongsTo(Session::class);
    }
}
