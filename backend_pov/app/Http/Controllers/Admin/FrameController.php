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
            'overlay_path' => 'required|string',
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
        ]);

        $frame->update($data);

        return response()->json(['data' => $frame]);
    }

    public function destroy(Frame $frame)
    {
        $frame->delete();

        return response()->json(null, 204);
    }
}
