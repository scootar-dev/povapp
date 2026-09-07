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
        $data = $request->validate([
            'output_id' => 'required|exists:outputs,id',
        ]);

        $output = Output::findOrFail($data['output_id']);

        $printLog = PrintLog::create([
            'session_id' => $session->id,
            'output_id' => $output->id,
            'status' => 'queued',
        ]);

        SendPrintJob::dispatch($printLog);

        return response()->json(['data' => $printLog], 202);
    }

    public function status(PrintLog $printLog)
    {
        return response()->json(['data' => $printLog]);
    }
}
