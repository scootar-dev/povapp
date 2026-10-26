<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Models\Output;
use App\Models\Session;
use App\Models\ShareLog;
use Illuminate\Http\Request;

class ShareController extends Controller
{
    public function store(Request $request, Session $session)
    {
        $data = $request->validate([
            'method' => 'required|in:qr,link,email,whatsapp',
            'shared_with' => 'nullable|string|max:255',
            'output_id' => 'nullable|exists:outputs,id',
        ]);

        $output = $this->resolveOutput($session, $data['output_id'] ?? null);

        if (! $output) {
            return response()->json(['message' => 'Output digital belum tersedia. Render terlebih dahulu.'], 422);
        }

        $shareLog = ShareLog::create([
            'session_id' => $session->id,
            'output_id' => $output->id,
            'method' => $data['method'],
            'shared_with' => $data['shared_with'] ?? null,
            'shared_at' => now(),
        ]);

        $session->update(['status' => 'shared']);

        return response()->json(['data' => $shareLog], 201);
    }

    private function resolveOutput(Session $session, ?int $outputId): ?Output
    {
        if ($outputId !== null) {
            $output = Output::find($outputId);

            return $output && (int) $output->session_id === (int) $session->id ? $output : null;
        }

        return $session->outputs()->where('type', 'digital_image')->first()
            ?? $session->outputs()->first();
    }
}
