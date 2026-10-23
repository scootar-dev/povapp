<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Output extends Model
{
    protected \ = ['session_id', 'type', 'file_path', 'dpi'];

    public function session()
    {
        return \->belongsTo(Session::class);
    }

    public function printLogs()
    {
        return \->hasMany(PrintLog::class);
    }
}
