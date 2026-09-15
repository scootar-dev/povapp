<?php

namespace App\Jobs;

use App\Models\Output;
use App\Models\Session;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class GenerateGifJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 2;

    public function __construct(public Session $session)
    {
    }

    public function handle(): void
    {
        $session = $this->session->fresh(['selectedPhotos']);

        if ($session->selectedPhotos->isEmpty()) {
            return;
        }

        Log::info("Generating GIF preview for session {$session->id}");

        // Placeholder for FFMpeg or ImageMagick GIF creation logic
        // E.g., convert selectedPhotos into an animated gif/video sequence
    }
}
