<?php

namespace App\Http\Controllers\Kiosk;

use App\Http\Controllers\Controller;
use App\Jobs\SendPrintJob;
use App\Models\Output;
use App\Models\PrintLog;
use App\Models\Session;
use Illuminate\Http\Request;

class PrintController extends Controller
{
    /**
     * Queue perintah cetak. Eksekusi cetak sebenarnya dilakukan di sisi Flutter
     * (lewat Epson AirPrint / Windows driver) atau lewat print-service lokal;
     * endpoint ini mencatat & melacak statusnya agar dashboard admin bisa lihat riwayat.
     */
    public function store(Request $request, Session $session)
    {
        $this->ensureStudioScope($request, $session);

        $data = $request->validate([
            'output_id' => 'required|exists:outputs,id',
        ]);

        $output = Output::findOrFail($data['output_id']);
        if ((int) $output->session_id !== (int) $session->id) {
            return response()->json(['message' => 'Output tidak termasuk sesi ini.'], 422);
        }

        $printLog = PrintLog::create([
            'session_id' => $session->id,
            'output_id' => $output->id,
            'status' => 'queued',
        ]);

        SendPrintJob::dispatch($printLog);

        return response()->json(['data' => $printLog], 202);
    }

    public function status(Request $request, PrintLog $printLog)
    {
        // Check via session relation — printLog->session->studio_id must match token
        $studioId = $request->attributes->get('studio_id');
        $printLog->loadMissing('session');
        if ($printLog->session && (int) $printLog->session->studio_id !== (int) $studioId) {
            abort(403, 'Print log tidak termasuk studio ini.');
        }

        return response()->json(['data' => $printLog]);
    }

    private function ensureStudioScope(Request $request, Session $session): void
    {
        $studioId = $request->attributes->get('studio_id');
        if ((int) $session->studio_id !== (int) $studioId) {
            abort(403, 'Sesi tidak termasuk studio ini.');
        }
    }
}
