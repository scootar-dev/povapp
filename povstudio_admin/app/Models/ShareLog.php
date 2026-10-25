<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShareLog extends Model
{
    protected $fillable = [
        'session_id', 'output_id', 'method', 'shared_with', 'shared_at',
    ];

    protected $casts = [
        'shared_at' => 'datetime',
    ];

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function output()
    {
        return $this->belongsTo(Output::class);
    }
}