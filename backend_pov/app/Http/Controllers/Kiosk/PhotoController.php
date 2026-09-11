<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Models\Photo;
use App\Models\Session;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class PhotoController extends Controller
{
    /**
     * Upload satu foto hasil jepretan untuk slot tertentu.
     */
    public function store(Request $request, Session $session)
    {
        $this->ensureStudioScope($request, $session);

        $data = $request->validate([
            'slot_index' => 'required|integer|min:0',
            'photo' => 'required|image|max:20480',
        ]);

        // Validasi slot_index sesuai frame (jika frame sudah dipilih)
        if ($session->frame_id) {
            $maxSlots = $session->frame->photo_count ?? null;
            if ($maxSlots !== null && $data['slot_index'] >= $maxSlots) {
                return response()->json(['message' => 'slot_index melebihi jumlah slot frame.'], 422);
            }
        }

        $path = $request->file('photo')->store("sessions/{$session->session_code}", 'public');

        // attempt_number = max attempt untuk slot ini + 1
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

        // Nonaktifkan foto lama di slot yang sama yang masih selected (hanya 1 selected per slot)
        Photo::where('session_id', $session->id)
            ->where('slot_index', $data['slot_index'])
            ->where('id', '!=', $photo->id)
            ->where('is_selected', true)
            ->update(['is_selected' => false]);

        return response()->json(['data' => $photo], 201);
    }

    /**
     * Daftar foto dalam sesi (untuk layar Preview & Retake).
     */
    public function index(Request $request, Session $session)
    {
        $this->ensureStudioScope($request, $session);

        $photos = $session->photos()->where('is_selected', true)->orderBy('slot_index')->get();

        return response()->json(['data' => $photos]);
    }

    /**
     * Retake: foto lama ditandai tidak terpilih, lalu client upload ulang ke slot yang sama
     * lewat store() dengan attempt_number bertambah.
     */
    public function retake(Request $request, Session $session, Photo $photo)
    {
        $this->ensureStudioScope($request, $session);

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

    private function ensureStudioScope(Request $request, Session $session): void
    {
        $studioId = $request->attributes->get('studio_id');
        if ((int) $session->studio_id !== (int) $studioId) {
            abort(403, 'Sesi tidak termasuk studio ini.');
        }
    }
}
