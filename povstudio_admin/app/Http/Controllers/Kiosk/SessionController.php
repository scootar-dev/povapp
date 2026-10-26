<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Models\Session;
use App\Models\Frame;
use Illuminate\Http\Request;

class SessionController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'frame_id' => 'required|exists:frames,id',
            'retake_quota' => 'nullable|integer|min:0|max:10',
        ]);

        $session = Session::create([
            'frame_id' => $data['frame_id'],
            'retake_quota' => $data['retake_quota'] ?? 2,
            'status' => 'started',
        ]);

        return response()->json(['data' => $session], 201);
    }

    public function updateStatus(Request $request, Session $session)
    {
        $data = $request->validate([
            'status' => 'required|in:started,shooting,reviewing,rendering,printed,shared,completed,abandoned',
        ]);

        $session->update(['status' => $data['status']]);

        if ($data['status'] === 'completed') {
            $session->update(['completed_at' => now()]);
        }

        return response()->json(['data' => $session]);
    }

    public function complete(Request $request, Session $session)
    {
        $session->update([
            'status' => 'completed',
            'completed_at' => now(),
        ]);

        return response()->json(['data' => $session]);
    }
}