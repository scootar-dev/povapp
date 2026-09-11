<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Models\Session;
use Illuminate\Http\Request;
use SimpleSoftwareIO\QrCode\Facades\QrCode; // composer require simplesoftwareio/simple-qrcode

class SessionController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'frame_id' => 'nullable|exists:frames,id',
            'retake_quota' => 'nullable|integer|min:0|max:10',
        ]);

        $session = Session::create([
            'studio_id' => $request->attributes->get('studio_id'),
            'frame_id' => $data['frame_id'] ?? null,
            'retake_quota' => $data['retake_quota'] ?? 2,
            'status' => 'started',
        ]);

        return response()->json(['data' => $session], 201);
    }

    public function updateStatus(Request $request, Session $session)
    {
        $this->ensureStudioScope($request, $session);

        $data = $request->validate([
            'status' => 'required|in:started,shooting,reviewing,rendering,printed,shared,completed,abandoned',
        ]);

        $session->update(['status' => $data['status']]);

        return response()->json(['data' => $session]);
    }

    public function applyFilter(Request $request, Session $session)
    {
        $this->ensureStudioScope($request, $session);

        $data = $request->validate([
            'filter' => 'required|in:original,natural,cold,warm,bw,vintage',
        ]);

        $session->update(['filter_applied' => $data['filter']]);

        return response()->json(['data' => $session]);
    }

    public function qrCode(Request $request, Session $session)
    {
        $this->ensureStudioScope($request, $session);

        $url = config('app.url') . "/download/{$session->session_code}";

        try {
            $svg = QrCode::format('svg')->size(300)->generate($url);
            return response($svg)->header('Content-Type', 'image/svg+xml');
        } catch (\Throwable $e) {
            // Fallback JSON jika driver imagick/GD untuk QR bermasalah
            return response()->json(['data' => ['url' => $url, 'svg_error' => $e->getMessage()]]);
        }
    }

    public function complete(Request $request, Session $session)
    {
        $this->ensureStudioScope($request, $session);

        $session->update([
            'status' => 'completed',
            'completed_at' => now(),
        ]);

        return response()->json(['data' => $session]);
    }

    private function ensureStudioScope(Request $request, Session $session): void
    {
        $studioId = $request->attributes->get('studio_id');
        if ((int) $session->studio_id !== (int) $studioId) {
            abort(403, 'Sesi tidak termasuk studio ini.');
        }
    }
}
