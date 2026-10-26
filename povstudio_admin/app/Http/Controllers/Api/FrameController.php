<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Frame;
use Illuminate\Http\Request;

class FrameController extends Controller
{
    public function index()
    {
        $frames = Frame::where('status', 1)
            ->with('slots')
            ->get()
            ->map(fn (Frame $frame) => $this->transform($frame));

        return response()->json(['data' => $frames]);
    }

    public function show(Frame $frame)
    {
        $frame->load('slots');

        return response()->json(['data' => $this->transform($frame)]);
    }

    private function transform(Frame $frame): array
    {
        $width = (int) ($frame->output_width_px ?: 1200);
        $height = (int) ($frame->output_height_px ?: 1800);

        $slots = $frame->slots->map(fn ($slot) => [
            'slot_index' => $slot->slot_index,
            'x' => round($slot->x / $width, 4),
            'y' => round($slot->y / $height, 4),
            'width' => round($slot->width / $width, 4),
            'height' => round($slot->height / $height, 4),
            'rotation' => (float) $slot->rotation,
        ])->values();

        if ($slots->isEmpty()) {
            $slots = collect([[
                'slot_index' => 0,
                'x' => 0.1,
                'y' => 0.1,
                'width' => 0.8,
                'height' => 0.8,
                'rotation' => 0,
            ]]);
        }

        return [
            'id' => $frame->id,
            'name' => $frame->nama,
            'category' => $frame->kategori,
            'thumbnail_path' => $frame->thumbnail_path ?: $frame->gambar,
            'overlay_path' => $frame->overlay_path ?: $frame->gambar,
            'photo_count' => (int) ($frame->photo_count ?: $slots->count()),
            'print_size' => $frame->print_size ?: '4r',
            'output_width_px' => $width,
            'output_height_px' => $height,
            'slots' => $slots,
        ];
    }
}
