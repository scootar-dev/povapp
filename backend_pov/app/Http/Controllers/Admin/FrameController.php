<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Frame;
use Illuminate\Http\Request;

class FrameController extends Controller
{
    public function index()
    {
        return response()->json(['data' => Frame::with('slots')->latest()->paginate(20)]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'nullable|string|max:100',
            'overlay' => 'nullable|image|max:10240',
            'overlay_path' => 'nullable|string',
            'thumbnail' => 'nullable|image|max:5120',
            'thumbnail_path' => 'nullable|string',
            'photo_count' => 'required|integer|min:1|max:12',
            'output_width_px' => 'required|integer',
            'output_height_px' => 'required|integer',
            'dpi' => 'nullable|integer',
            'print_size' => 'required|in:4r,strip_2x6',
            'slots' => 'required|array|min:1',
            'slots.*.slot_index' => 'required|integer|min:0',
            'slots.*.x' => 'required|integer',
            'slots.*.y' => 'required|integer',
            'slots.*.width' => 'required|integer',
            'slots.*.height' => 'required|integer',
            'slots.*.rotation' => 'nullable|numeric',
        ]);

        // Handle file uploads untuk overlay & thumbnail (prioritas file > string path)
        if ($request->hasFile('overlay')) {
            $data['overlay_path'] = $request->file('overlay')->store('frames/overlays', 'public');
        }
        if ($request->hasFile('thumbnail')) {
            $data['thumbnail_path'] = $request->file('thumbnail')->store('frames/thumbnails', 'public');
        }

        // Hapus key file agar tidak masuk ke create()
        unset($data['overlay'], $data['thumbnail']);

        if (empty($data['overlay_path'] ?? null)) {
            return response()->json(['message' => 'overlay_path atau file overlay wajib diisi'], 422);
        }

        $frame = Frame::create($data);
        $frame->slots()->createMany($data['slots']);

        return response()->json(['data' => $frame->load('slots')], 201);
    }

    public function show(Frame $frame)
    {
        return response()->json(['data' => $frame->load('slots')]);
    }

    public function update(Request $request, Frame $frame)
    {
        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'category' => 'nullable|string|max:100',
            'is_active' => 'sometimes|boolean',
            'overlay' => 'nullable|image|max:10240',
            'thumbnail' => 'nullable|image|max:5120',
        ]);

        if ($request->hasFile('overlay')) {
            $data['overlay_path'] = $request->file('overlay')->store('frames/overlays', 'public');
        }
        if ($request->hasFile('thumbnail')) {
            $data['thumbnail_path'] = $request->file('thumbnail')->store('frames/thumbnails', 'public');
        }
        unset($data['overlay'], $data['thumbnail']);

        $frame->update($data);

        return response()->json(['data' => $frame->load('slots')]);
    }

    public function destroy(Frame $frame)
    {
        $frame->delete();

        return response()->json(null, 204);
    }
}
