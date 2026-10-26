<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Models\Output;
use App\Models\PrintLog;
use App\Models\Session;
use Illuminate\Http\Request;

class PrintController extends Controller
{
    public function store(Request $request, Session $session)
    {
        $data = $request->validate([
            'output_id' => 'nullable|exists:outputs,id',
            'printer' => 'nullable|string|max:255',
            'copies' => 'nullable|integer|min:1|max:10',
        ]);

        $output = $this->resolveOutput($session, $data['output_id'] ?? null);

        if (! $output) {
            return response()->json(['message' => 'Output cetak belum tersedia. Render terlebih dahulu.'], 422);
        }

        $printLog = PrintLog::create([
            'session_id' => $session->id,
            'output_id' => $output->id,
            'printer' => $data['printer'] ?? null,
            'status' => 'pending',
            'copies' => $data['copies'] ?? 1,
        ]);

        return response()->json(['data' => $printLog], 202);
    }

    public function update(Request $request, PrintLog $printLog)
    {
        $data = $request->validate([
            'status' => 'required|in:pending,printing,completed,failed',
            'error_message' => 'nullable|string',
        ]);

        $printLog->update($data);

        if ($data['status'] === 'completed') {
            $printLog->session?->update(['status' => 'printed']);
        }

        return response()->json(['data' => $printLog->fresh()]);
    }

    private function resolveOutput(Session $session, ?int $outputId): ?Output
    {
        if ($outputId !== null) {
            $output = Output::find($outputId);

            return $output && (int) $output->session_id === (int) $session->id ? $output : null;
        }

        return $session->outputs()->where('type', 'print_image')->first()
            ?? $session->outputs()->first();
    }
}
