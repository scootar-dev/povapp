<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Session extends Model
{
    use HasFactory;

    protected $fillable = [
        'session_code', 'studio_id', 'frame_id', 'filter_applied',
        'retake_quota', 'retake_used', 'status', 'started_at', 'completed_at',
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    protected static function booted()
    {
        static::creating(function (Session $session) {
            $session->session_code = $session->session_code ?? (string) Str::uuid();
            $session->started_at = $session->started_at ?? now();
        });
    }

    public function studio()
    {
        return $this->belongsTo(Studio::class);
    }

    public function frame()
    {
        return $this->belongsTo(Frame::class);
    }

    public function photos()
    {
        return $this->hasMany(Photo::class);
    }

    // Hanya foto yang lolos seleksi (tidak di-retake ulang)
    public function selectedPhotos()
    {
        return $this->hasMany(Photo::class)->where('is_selected', true)->orderBy('slot_index');
    }

    public function outputs()
    {
        return $this->hasMany(Output::class);
    }

    public function printLogs()
    {
        return $this->hasMany(PrintLog::class);
    }

    public function shareLogs()
    {
        return $this->hasMany(ShareLog::class);
    }

    public function retakeRemaining(): int
    {
        return max(0, $this->retake_quota - $this->retake_used);
    }
}
