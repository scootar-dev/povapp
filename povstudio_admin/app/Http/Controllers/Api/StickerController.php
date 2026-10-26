<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Session;
use App\Models\Sticker;
use Illuminate\Http\Request;

class StickerController extends Controller
{
    public function index()
    {
        $stickers = Sticker::whereIn('status', [1, '1', 'Aktif'])
            ->get()
            ->map(fn (Sticker $sticker) => $this->transform($sticker));

        return response()->json(['data' => $stickers]);
    }

    public function show(Sticker $sticker)
    {
        return response()->json(['data' => $this->transform($sticker)]);
    }

    public function storePlacements(Request $request, Session $session)
    {
        $data = $request->validate([
            'stickers' => 'present|array',
            'stickers.*.sticker_id' => 'required|exists:stickers,id',
            'stickers.*.x' => 'required|numeric|between:0,1',
            'stickers.*.y' => 'required|numeric|between:0,1',
            'stickers.*.size' => 'nullable|numeric|min:0.02|max:1',
            'stickers.*.rotation' => 'nullable|numeric|between:-180,180',
        ]);

        $session->stickerPlacements()->delete();

        foreach ($data['stickers'] as $item) {
            $session->stickerPlacements()->create([
                'sticker_id' => $item['sticker_id'],
                'x' => $item['x'],
                'y' => $item['y'],
                'size' => $item['size'] ?? 0.18,
                'rotation' => $item['rotation'] ?? 0,
            ]);
        }

        return response()->json(['data' => $session->stickerPlacements()->get()]);
    }

    private function transform(Sticker $sticker): array
    {
        return [
            'id' => (string) $sticker->id,
            'name' => $sticker->nama,
            'emoji' => null,
            'asset_path' => $sticker->gambar,
        ];
    }
}
