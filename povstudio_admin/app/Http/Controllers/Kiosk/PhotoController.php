<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Models\Photo;
use App\Models\Session;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PhotoController extends Controller
{
    public function store(Request $request, Session $session)
    {
        $this->ensureUserScope($request, $session);

        $data = $request->validate([
            'slot_index' => 'required|integer|min:0',
            'photo' => 'required|image|max:20480',
        ]);

        if ($session->frame_id) {
            $frame = $session->frame;
            $maxSlots = $frame->photo_count ?? null;
            if ($maxSlots !== null && $data['slot_index'] >= $maxSlots) {
                return response()->json(['message' => 'slot_index melebihi jumlah slot frame.'], 422);
            }
        }

        $path = $request->file('photo')->store('sessions/' . $session->session_code, 'public');

        $maxAttempt = Photo::where('session_id', $session->id)
            ->where('slot_index', $data['slot_index'])
            ->max('attempt_number') ?? 0;

        $photo = Photo::create([
            'session_id' => $session->id,
            'slot_index' => $data['slot_index'],
            'file_path' => $path,
            'is_selected' => true,
            'attempt_number' => $maxAttempt + 1,
        ]);

        Photo::where('session_id', $session->id)
            ->where('slot_index', $data['slot_index'])
            ->where('id', '!=', $photo->id)
            ->where('is_selected', true)
            ->update(['is_selected' => false]);

        return response()->json(['data' => $photo], 201);
    }

    public function index(Request $request, Session $session)
    {
        $this->ensureUserScope($request, $session);

        $photos = $session->photos()->where('is_selected', true)->orderBy('slot_index')->get();

        return response()->json(['data' => $photos]);
    }

    public function retake(Request $request, Session $session, Photo $photo)
    {
        $this->ensureUserScope($request, $session);

        if ((int) $photo->session_id !== (int) $session->id) {
            return response()->json(['message' => 'Foto tidak termasuk sesi ini.'], 422);
        }

        if ($session->retakeRemaining() <= 0) {
            return response()->json(['message' => 'Kuota retake sudah habis.'], 422);
        }

        $photo->update(['is_selected' => false]);
        $session->increment('retake_used');

        return response()->json([
            'data' => [
                'slot_index' => $photo->slot_index,
                'next_attempt_number' => $photo->attempt_number + 1,
                'retake_remaining' => $session->fresh()->retakeRemaining(),
            ],
        ]);
    }

    private function ensureUserScope(Request $request, Session $session): void
    {
        $userId = $request->attributes->get('user_id');
        if ((int) $session->user_id !== (int) $userId) {
            abort(403, 'Sesi tidak termasuk user ini.');
        }
    }
}
