<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Sticker;

class StickerController extends Controller
{
    public function index()
    {
        $stickers = Sticker::where('status', 1)
            ->select('id', 'nama as name', 'gambar as asset_path')
            ->get()
            ->map(function ($sticker) {
                return [
                    'id' => (string) $sticker->id,
                    'name' => $sticker->name,
                    'emoji' => $sticker->name,
                    'asset_path' => $sticker->asset_path ? asset('storage/' . $sticker->asset_path) : null,
                ];
            });

        return response()->json(['data' => $stickers]);
    }

    public function show(Sticker $sticker)
    {
        return response()->json([
            'data' => [
                'id' => (string) $sticker->id,
                'name' => $sticker->nama,
                'emoji' => $sticker->nama,
                'asset_path' => $sticker->gambar ? asset('storage/' . $sticker->gambar) : null,
            ]
        ]);
    }
}