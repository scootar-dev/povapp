<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Http\Resources\FrameResource;
use App\Models\Frame;

class FrameController extends Controller
{
    /**
     * Daftar frame aktif — dipanggil sekali saat idle & di-cache di Flutter.
     */
    public function index()
    {
        $frames = Frame::where('is_active', true)->get();

        return FrameResource::collection($frames);
    }

    /**
     * Detail frame + koordinat slot foto (dipakai untuk menyusun UI overlay live preview).
     */
    public function show(Frame $frame)
    {
        $frame->load('slots');

        return new FrameResource($frame);
    }
}
