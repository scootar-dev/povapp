<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Output extends Model
{
    protected $fillable = ['session_id', 'type', 'file_path', 'dpi'];

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function printLogs()
    {
        return $this->hasMany(PrintLog::class);
    }
}
