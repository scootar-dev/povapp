<?php

namespace App\Http\Controllers;

use App\Http\Resources\OutputResource;
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
                'outputs' => OutputResource::collection($session->outputs),
            ],
        ]);
    }
}
