<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShareLog extends Model
{
    protected \ = [
        'session_id', 'output_id', 'method', 'shared_with', 'shared_at',
    ];

    protected \ = [
        'shared_at' => 'datetime',
    ];

    public function session()
    {
        return \->belongsTo(Session::class);
    }

    public function output()
    {
        return \->belongsTo(Output::class);
    }
}
