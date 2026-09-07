<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShareLog extends Model
{
    protected $fillable = [
        'session_id', 'channel', 'recipient', 'status', 'provider', 'error_message',
    ];

    public function session()
    {
        return $this->belongsTo(Session::class);
    }
}
