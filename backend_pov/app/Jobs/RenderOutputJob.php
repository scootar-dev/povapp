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
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Drivers\Gd\Driver as GdDriver;
use Intervention\Image\Format;
use Intervention\Image\ImageManager;

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

        if (! $frame) {
            Log::error("RenderOutputJob: frame not found for session {$session->id}");
            return;
        }

        $manager = new ImageManager(GdDriver::class);

        // Kanvas dasar sesuai resolusi output frame (300 DPI)
        $canvas = $manager->createImage($frame->output_width_px, $frame->output_height_px);
        $canvas->fill('#ffffff');

        // Fallback: jika slot tidak ada, tempatkan foto secara grid sederhana
        $slots = $frame->slots;

        foreach ($session->selectedPhotos as $photo) {
            $slot = $slots->firstWhere('slot_index', $photo->slot_index);
            if (! $slot) {
                Log::warning("RenderOutputJob: slot {$photo->slot_index} not found for frame {$frame->id}");
                continue;
            }

            $photoPath = Storage::disk('public')->path($photo->file_path);
            if (! file_exists($photoPath)) {
                Log::warning("RenderOutputJob: photo file not found {$photoPath}");
                continue;
            }

            try {
                $img = $manager->decodePath($photoPath);

                // Apply filter sesuai session (disimpan via applyFilter)
                $img = $this->applyFilterToImage($img, $session->filter_applied ?? 'original');

                // Cover agar mengisi penuh slot (crop center)
                $img->cover($slot->width, $slot->height);

                if ((float) $slot->rotation !== 0.0) {
                    $img->rotate(-(float) $slot->rotation, background: '#ffffff');
                }

                $canvas->insert($img, x: (int) $slot->x, y: (int) $slot->y, alignment: 'top-left');
            } catch (\Throwable $e) {
                Log::error("RenderOutputJob: gagal proses foto {$photo->id}: {$e->getMessage()}");
                continue;
            }
        }

        // Tempel overlay frame (PNG transparan) di atas foto
        $overlayPath = Storage::disk('public')->path($frame->overlay_path);
        if (file_exists($overlayPath)) {
            try {
                $overlay = $manager->decodePath($overlayPath);
                // Pastikan overlay seukuran canvas — resize jika berbeda
                if ($overlay->width() !== $frame->output_width_px || $overlay->height() !== $frame->output_height_px) {
                    $overlay->resize($frame->output_width_px, $frame->output_height_px);
                }
                $canvas->insert($overlay, x: 0, y: 0, alignment: 'top-left');
            } catch (\Throwable $e) {
                Log::warning("RenderOutputJob: gagal load overlay {$overlayPath}: {$e->getMessage()}");
            }
        }

        // Simpan print image (kualitas tinggi)
        $outputPath = "sessions/{$session->session_code}/output_print.jpg";
        $encodedPrint = $canvas->encode(Format::JPEG->encoder(quality: 95));
        Storage::disk('public')->put($outputPath, (string) $encodedPrint);

        Output::updateOrCreate(
            ['session_id' => $session->id, 'type' => 'print_image'],
            ['file_path' => $outputPath, 'dpi' => $frame->dpi]
        );

        // Digital version (resolusi setengah untuk WA/Email agar cepat dikirim)
        $digital = clone $canvas;
        $digital->scaleDown(width: (int) ($frame->output_width_px / 2));
        $digitalPath = "sessions/{$session->session_code}/output_digital.jpg";
        $encodedDigital = $digital->encode(Format::JPEG->encoder(quality: 85));
        Storage::disk('public')->put($digitalPath, (string) $encodedDigital);

        Output::updateOrCreate(
            ['session_id' => $session->id, 'type' => 'digital_image'],
            ['file_path' => $digitalPath, 'dpi' => $frame->dpi]
        );

        $session->update(['status' => 'reviewing']);
    }

    private function applyFilterToImage(\Intervention\Image\Interfaces\ImageInterface $image, string $filter): \Intervention\Image\Interfaces\ImageInterface
    {
        return match ($filter) {
            'natural' => $image->brightness(4)->contrast(5),
            'cold' => $image->colorize(red: -10, green: 0, blue: 18)->contrast(3),
            'warm' => $image->colorize(red: 18, green: 8, blue: -10)->brightness(3),
            'bw', 'blackWhite', 'blackwhite', 'black_white' => $image->grayscale(),
            'vintage' => $image->colorize(red: 15, green: 8, blue: -5)->contrast(-5)->brightness(-3),
            default => $image, // original
        };
    }

    public function failed(\Throwable $exception): void
    {
        Log::error("RenderOutputJob failed for session {$this->session->id}: {$exception->getMessage()}");
        // Tetap tandai agar polling tidak timeout selamanya — bisa cek log
        try {
            $this->session->update(['status' => 'rendering']);
        } catch (\Throwable $e) {
        }
    }
}
