<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Studio extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'location', 'camera_source', 'printer_driver',
        'device_token', 'is_active',
    ];

    protected $hidden = ['device_token'];

    public function sessions()
    {
        return $this->hasMany(Session::class);
    }
}
