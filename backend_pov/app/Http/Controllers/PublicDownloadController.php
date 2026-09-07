<?php

namespace App\Http\Controllers;

use App\Models\Session;

class PublicDownloadController extends Controller
{
    /**
     * Halaman publik yang dibuka pelanggan setelah scan QR — tanpa auth.
     * Menampilkan foto/GIF/video hasil sesi untuk diunduh langsung.
     */
    public function show(string $sessionCode)
    {
        $session = Session::where('session_code', $sessionCode)
            ->with('outputs')
            ->firstOrFail();

        return response()->json([
            'data' => [
                'session_code' => $session->session_code,
                'outputs' => $session->outputs->map(fn ($o) => [
                    'type' => $o->type,
                    'url' => asset('storage/' . $o->file_path),
                ]),
            ],
        ]);
    }
}
