<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Studio;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class StudioController extends Controller
{
    public function index()
    {
        return response()->json(['data' => Studio::latest()->get()]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'location' => 'nullable|string|max:255',
            'camera_source' => 'required|in:internal,dslr',
            'printer_driver' => 'nullable|string',
        ]);

        $data['device_token'] = Str::random(64);

        $studio = Studio::create($data);

        // token asli hanya ditampilkan sekali saat pembuatan
        return response()->json(['data' => $studio, 'device_token' => $data['device_token']], 201);
    }

    public function show(Studio $studio)
    {
        return response()->json(['data' => $studio]);
    }

    public function update(Request $request, Studio $studio)
    {
        $data = $request->validate([
            'name' => 'sometimes|string|max:255',
            'location' => 'nullable|string|max:255',
            'camera_source' => 'sometimes|in:internal,dslr',
            'printer_driver' => 'nullable|string',
            'is_active' => 'sometimes|boolean',
        ]);

        $studio->update($data);

        return response()->json(['data' => $studio]);
    }

    public function destroy(Studio $studio)
    {
        $studio->delete();

        return response()->json(null, 204);
    }
}
