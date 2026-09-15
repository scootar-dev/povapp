<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreStudioRequest;
use App\Http\Requests\Admin\UpdateStudioRequest;
use App\Http\Resources\StudioResource;
use App\Models\Studio;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class StudioController extends Controller
{
    public function index()
    {
        return StudioResource::collection(Studio::latest()->get());
    }

    public function store(StoreStudioRequest $request)
    {
        $data = $request->validated();

        $token = Str::random(64);
        $data['device_token'] = $token;

        $studio = Studio::create($data);

        // token asli hanya ditampilkan sekali saat pembuatan
        return (new StudioResource($studio))->additional([
            'device_token' => $token,
        ]);
    }

    public function show(Studio $studio)
    {
        return new StudioResource($studio);
    }

    public function update(UpdateStudioRequest $request, Studio $studio)
    {
        $data = $request->validated();

        $studio->update($data);

        return new StudioResource($studio);
    }

    public function destroy(Studio $studio)
    {
        $studio->delete();

        return response()->json(null, 204);
    }
}
