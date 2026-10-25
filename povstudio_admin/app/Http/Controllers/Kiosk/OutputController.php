<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Jobs\RenderOutputJob;
use App\Models\Session;
use Illuminate\Http\Request;

class OutputController extends Controller
{
    public function render(Request $request, Session $session)
    {
        $frame = $session->frame;
        if ($frame) {
            $expected = (int) $frame->photo_count;
            $actual = $session->selectedPhotos()->count();
            if ($actual < $expected) {
                return response()->json([
                    'message' => 'Foto belum lengkap: ' . $actual . '/' . $expected . ' slot terisi.',
                ], 422);
            }
        }

        $session->update(['status' => 'rendering']);

        RenderOutputJob::dispatch($session);

        return response()->json(['message' => 'Render dimulai.'], 202);
    }

    public function index(Request $request, Session $session)
    {
        return response()->json(['data' => $session->outputs]);
    }
}