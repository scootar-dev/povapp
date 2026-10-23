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
            'frame_id' => 'nullable|exists:frames,id',
            'retake_quota' => 'nullable|integer|min:0|max:10',
        ]);

        $userId = $request->attributes->get('user_id');

        $session = Session::create([
            'user_id' => $userId,
            'frame_id' => $data['frame_id'] ?? null,
            'retake_quota' => $data['retake_quota'] ?? 2,
            'status' => 'started',
        ]);

        return response()->json(['data' => $session], 201);
    }

    public function updateStatus(Request $request, Session $session)
    {
        $this->ensureUserScope($request, $session);

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
        $this->ensureUserScope($request, $session);

        $session->update([
            'status' => 'completed',
            'completed_at' => now(),
        ]);

        return response()->json(['data' => $session]);
    }

    private function ensureUserScope(Request $request, Session $session): void
    {
        $userId = $request->attributes->get('user_id');
        if ((int) $session->user_id !== (int) $userId) {
            abort(403, 'Sesi tidak termasuk user ini.');
        }
    }
}
