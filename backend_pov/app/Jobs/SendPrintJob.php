<?php

namespace App\Jobs;

use App\Models\PrintLog;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendPrintJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(public PrintLog $printLog)
    {
    }

    /**
     * Catatan: eksekusi cetak fisik dilakukan oleh Flutter (native channel ke
     * Epson AirPrint / Windows Print Spooler), bukan oleh Laravel. Job ini hanya
     * menandai log sebagai "printing" — Flutter akan memanggil endpoint terpisah
     * (mis. PATCH /kiosk/print-jobs/{id}) untuk melaporkan hasil sukses/gagal,
     * atau kamu bisa expose print_logs lewat WebSocket/Pusher untuk update realtime.
     */
    public function handle(): void
    {
        $this->printLog->update(['status' => 'printing']);

        // TODO: broadcast event PrintJobQueued ke Flutter (mis. via Laravel Reverb/Pusher)
        // agar app bisa langsung eksekusi native print begitu job ini jalan.
    }
}
