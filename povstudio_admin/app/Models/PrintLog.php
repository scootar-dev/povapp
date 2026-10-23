<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PrintLog extends Model
{
    protected \ = [
        'session_id', 'output_id', 'printer', 'status', 'copies', 'error_message',
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
