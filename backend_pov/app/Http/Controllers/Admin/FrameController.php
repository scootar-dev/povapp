<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreFrameRequest;
use App\Http\Requests\Admin\UpdateFrameRequest;
use App\Http\Resources\FrameResource;
use App\Models\Frame;
use Illuminate\Http\Request;

class FrameController extends Controller
{
    public function index()
    {
        return FrameResource::collection(Frame::with('slots')->latest()->paginate(20));
    }

    public function store(StoreFrameRequest $request)
    {
        $data = $request->validated();

        $frame = Frame::create($data);
        $frame->slots()->createMany($data['slots']);

        return new FrameResource($frame->load('slots'));
    }

    public function show(Frame $frame)
    {
        return new FrameResource($frame->load('slots'));
    }

    public function update(UpdateFrameRequest $request, Frame $frame)
    {
        $data = $request->validated();

        $frame->update($data);

        return new FrameResource($frame);
    }

    public function destroy(Frame $frame)
    {
        $frame->delete();

        return response()->json(null, 204);
    }
}
