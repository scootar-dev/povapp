<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Http\Requests\Kiosk\StorePhotoRequest;
use App\Http\Resources\PhotoResource;
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
    public function store(StorePhotoRequest $request, Session $session)
    {
        $data = $request->validated();

        $path = $request->file('photo')->store("sessions/{$session->session_code}", 'public');

        $photo = Photo::create([
            'session_id' => $session->id,
            'slot_index' => $data['slot_index'],
            'file_path' => $path,
            'is_selected' => true,
            'attempt_number' => 1,
        ]);

        return new PhotoResource($photo);
    }

    /**
     * Daftar foto dalam sesi (untuk layar Preview & Retake).
     */
    public function index(Session $session)
    {
        $photos = $session->photos()->where('is_selected', true)->orderBy('slot_index')->get();

        return PhotoResource::collection($photos);
    }

    /**
     * Retake: foto lama ditandai tidak terpilih, lalu client upload ulang ke slot yang sama
     * lewat store() dengan attempt_number bertambah.
     */
    public function retake(Request $request, Session $session, Photo $photo)
    {
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
}
