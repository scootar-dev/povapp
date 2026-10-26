<?php

namespace App\Http\Controllers;

use App\Models\Session;

class PublicDownloadController extends Controller
{
    public function show(string $sessionCode)
    {
        $session = Session::where('session_code', $sessionCode)
            ->with('outputs')
            ->firstOrFail();

        $outputs = $session->outputs->map(fn ($output) => [
            'type' => $output->type,
            'url' => url('storage/' . $output->file_path),
        ])->values();

        if (request()->wantsJson()) {
            return response()->json([
                'data' => [
                    'session_code' => $session->session_code,
                    'outputs' => $outputs,
                ],
            ]);
        }

        return view('download', [
            'session' => $session,
            'outputs' => $outputs,
        ]);
    }
}
