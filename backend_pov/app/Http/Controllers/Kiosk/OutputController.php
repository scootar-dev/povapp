<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Jobs\RenderOutputJob;
use App\Models\Session;

class OutputController extends Controller
{
    /**
     * Trigger render gabungan foto+frame (300 DPI) secara async lewat queue.
     * Flutter polling GET /sessions/{id}/outputs sampai hasil muncul.
     */
    public function render(\Illuminate\Http\Request $request, Session $session)
    {
        $this->ensureStudioScope($request, $session);

        // Validasi kelengkapan foto sebelum render
        $frame = $session->frame;
        if ($frame) {
            $expected = (int) $frame->photo_count;
            $actual = $session->selectedPhotos()->count();
            if ($actual < $expected) {
                return response()->json([
                    'message' => "Foto belum lengkap: {$actual}/{$expected} slot terisi.",
                ], 422);
            }
        }

        $session->update(['status' => 'rendering']);

        RenderOutputJob::dispatch($session);

        return response()->json(['message' => 'Render dimulai.'], 202);
    }

    public function index(\Illuminate\Http\Request $request, Session $session)
    {
        $this->ensureStudioScope($request, $session);

        return response()->json(['data' => $session->outputs]);
    }

    private function ensureStudioScope(\Illuminate\Http\Request $request, Session $session): void
    {
        $studioId = $request->attributes->get('studio_id');
        if ((int) $session->studio_id !== (int) $studioId) {
            abort(403, 'Sesi tidak termasuk studio ini.');
        }
    }
}
