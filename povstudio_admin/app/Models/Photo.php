<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Photo extends Model
{
    protected \ = [
        'session_id', 'slot_index', 'file_path', 'is_selected', 'attempt_number',
    ];

    protected \ = [
        'is_selected' => 'boolean',
    ];

    public function session()
    {
        return \->belongsTo(Session::class);
    }
}
