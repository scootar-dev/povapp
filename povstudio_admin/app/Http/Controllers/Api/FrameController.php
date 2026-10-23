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
            ->select('id', 'nama as name', 'kategori as category', 'gambar as thumbnail_path', 'gambar as overlay_path')
            ->get()
            ->map(function ($frame) {
                return [
                    'id' => $frame->id,
                    'name' => $frame->name,
                    'category' => $frame->category,
                    'thumbnail_path' => $frame->thumbnail_path ? asset('storage/' . $frame->thumbnail_path) : null,
                    'overlay_path' => $frame->overlay_path ? asset('storage/' . $frame->overlay_path) : null,
                    'photo_count' => 1,
                    'print_size' => '4r',
                    'slots' => [
                        [
                            'slot_index' => 0,
                            'x' => 0.1,
                            'y' => 0.1,
                            'width' => 0.8,
                            'height' => 0.8,
                            'rotation' => 0,
                        ]
                    ],
                ];
            });

        return response()->json(['data' => $frames]);
    }

    public function show(Frame $frame)
    {
        return response()->json([
            'data' => [
                'id' => $frame->id,
                'name' => $frame->nama,
                'category' => $frame->kategori,
                'thumbnail_path' => $frame->gambar ? asset('storage/' . $frame->gambar) : null,
                'overlay_path' => $frame->gambar ? asset('storage/' . $frame->gambar) : null,
                'photo_count' => 1,
                'print_size' => '4r',
                'slots' => [
                    [
                        'slot_index' => 0,
                        'x' => 0.1,
                        'y' => 0.1,
                        'width' => 0.8,
                        'height' => 0.8,
                        'rotation' => 0,
                    ]
                ],
            ]
        ]);
    }
}