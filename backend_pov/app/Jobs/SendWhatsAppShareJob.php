<?php

namespace App\Jobs;

use App\Models\ShareLog;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;

class SendWhatsAppShareJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $tries = 3;
    public $backoff = 15;

    public function __construct(public ShareLog $shareLog)
    {
    }

    public function handle(): void
    {
        $session = $this->shareLog->session()->with('outputs')->first();
        $digital = $session->outputs->firstWhere('type', 'digital_image');

        if (! $digital) {
            $this->shareLog->update(['status' => 'failed', 'error_message' => 'Output digital belum tersedia.']);
            return;
        }

        $fileUrl = asset('storage/' . $digital->file_path);

        // Contoh integrasi Fonnte — sesuaikan dengan provider WA yang dipakai
        $response = Http::asForm()
            ->withHeaders(['Authorization' => config('services.fonnte.token')])
            ->post('https://api.fonnte.com/send', [
                'target' => $this->shareLog->recipient,
                'message' => 'Terima kasih sudah foto di POV Studio! Berikut hasil fotomu 📸',
                'url' => $fileUrl,
            ]);

        if ($response->successful()) {
            $this->shareLog->update(['status' => 'sent']);
        } else {
            $this->shareLog->update([
                'status' => 'failed',
                'error_message' => $response->body(),
            ]);
        }
    }
}
