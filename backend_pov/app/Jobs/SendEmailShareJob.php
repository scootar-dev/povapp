<?php

namespace App\Jobs;

use App\Mail\PhotoResultMail;
use App\Models\ShareLog;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Mail;

class SendEmailShareJob implements ShouldQueue
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

        try {
            Mail::to($this->shareLog->recipient)->send(new PhotoResultMail($session));
            $this->shareLog->update(['status' => 'sent']);
        } catch (\Throwable $e) {
            $this->shareLog->update(['status' => 'failed', 'error_message' => $e->getMessage()]);
        }
    }
}
