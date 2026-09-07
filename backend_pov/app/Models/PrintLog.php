<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PrintLog extends Model
{
    protected $fillable = ['session_id', 'output_id', 'status', 'error_message'];

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function output()
    {
        return $this->belongsTo(Output::class);
    }
}
