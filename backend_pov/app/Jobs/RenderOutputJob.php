<?php

namespace App\Jobs;

use App\Models\Output;
use App\Models\Session;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Facades\Image; // composer require intervention/image

class RenderOutputJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(public Session $session)
    {
    }

    public function handle(): void
    {
        $session = $this->session->fresh(['frame.slots', 'selectedPhotos']);
        $frame = $session->frame;

        // Kanvas dasar sesuai resolusi output frame (300 DPI)
        $canvas = Image::canvas($frame->output_width_px, $frame->output_height_px, '#ffffff');

        foreach ($session->selectedPhotos as $photo) {
            $slot = $frame->slots->firstWhere('slot_index', $photo->slot_index);
            if (! $slot) {
                continue;
            }

            $img = Image::make(Storage::disk('public')->path($photo->file_path))
                ->fit($slot->width, $slot->height)
                ->rotate(-$slot->rotation);

            $canvas->insert($img, 'top-left', $slot->x, $slot->y);
        }

        // Tempel overlay frame (PNG transparan) di atas foto
        $overlayPath = Storage::disk('public')->path($frame->overlay_path);
        if (file_exists($overlayPath)) {
            $canvas->insert($overlayPath, 'top-left', 0, 0);
        }

        $outputPath = "sessions/{$session->session_code}/output_print.jpg";
        Storage::disk('public')->put($outputPath, (string) $canvas->encode('jpg', 95));

        Output::create([
            'session_id' => $session->id,
            'type' => 'print_image',
            'file_path' => $outputPath,
            'dpi' => $frame->dpi,
        ]);

        // Digital version (resolusi lebih rendah untuk WA/Email agar cepat dikirim)
        $digitalPath = "sessions/{$session->session_code}/output_digital.jpg";
        $canvas->resize($frame->output_width_px / 2, null, function ($c) {
            $c->aspectRatio();
        });
        Storage::disk('public')->put($digitalPath, (string) $canvas->encode('jpg', 85));

        Output::create([
            'session_id' => $session->id,
            'type' => 'digital_image',
            'file_path' => $digitalPath,
        ]);

        // TODO: generate GIF/video dari selectedPhotos (mis. pakai FFMpeg) sebagai output type 'gif'/'video'

        $session->update(['status' => 'reviewing']);
    }
}
