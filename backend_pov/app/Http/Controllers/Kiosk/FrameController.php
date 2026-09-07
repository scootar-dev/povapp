<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Models\Frame;

class FrameController extends Controller
{
    /**
     * Daftar frame aktif — dipanggil sekali saat idle & di-cache di Flutter.
     */
    public function index()
    {
        $frames = Frame::where('is_active', true)
            ->select('id', 'name', 'category', 'thumbnail_path', 'photo_count', 'print_size')
            ->get();

        return response()->json(['data' => $frames]);
    }

    /**
     * Detail frame + koordinat slot foto (dipakai untuk menyusun UI overlay live preview).
     */
    public function show(Frame $frame)
    {
        $frame->load('slots');

        return response()->json(['data' => $frame]);
    }
}
