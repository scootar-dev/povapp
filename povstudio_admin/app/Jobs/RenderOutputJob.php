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
        $session = $this->session->fresh(['frame.slots', 'selectedPhotos', 'stickerPlacements.sticker']);
        $frame = $session->frame;

        if (! $frame) {
            Log::error("RenderOutputJob: frame not found for session {$session->id}");
            return;
        }

        $manager = new ImageManager(GdDriver::class);

        $canvas = $manager->createImage($frame->output_width_px, $frame->output_height_px);
        $canvas->fill('#ffffff');

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

                $img = $this->applyFilterToImage($img, $session->filter_applied ?? 'original');

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

        foreach ($session->stickerPlacements as $placement) {
            $sticker = $placement->sticker;
            if (! $sticker) {
                continue;
            }

            $stickerPath = Storage::disk('public')->path($sticker->gambar);
            if (! file_exists($stickerPath)) {
                Log::warning("RenderOutputJob: sticker file not found {$stickerPath}");
                continue;
            }

            try {
                $stickerImage = $manager->decodePath($stickerPath);

                $size = max(24, (int) round($placement->size * $frame->output_width_px));
                $stickerImage->scale(width: $size, height: $size);

                if ((float) $placement->rotation !== 0.0) {
                    $stickerImage->rotate(-(float) $placement->rotation, background: 'transparent');
                }

                $x = (int) round($placement->x * $frame->output_width_px);
                $y = (int) round($placement->y * $frame->output_height_px);
                $x = max(0, min($x, $frame->output_width_px - $stickerImage->width()));
                $y = max(0, min($y, $frame->output_height_px - $stickerImage->height()));

                $canvas->insert($stickerImage, x: $x, y: $y, alignment: 'top-left');
            } catch (\Throwable $e) {
                Log::error("RenderOutputJob: gagal proses stiker {$sticker->id}: {$e->getMessage()}");
                continue;
            }
        }

        if ($frame->overlay_path) {
            $overlayPath = Storage::disk('public')->path($frame->overlay_path);
            if (file_exists($overlayPath)) {
                try {
                    $overlay = $manager->decodePath($overlayPath);
                    if ($overlay->width() !== $frame->output_width_px || $overlay->height() !== $frame->output_height_px) {
                        $overlay->resize($frame->output_width_px, $frame->output_height_px);
                    }
                    $canvas->insert($overlay, x: 0, y: 0, alignment: 'top-left');
                } catch (\Throwable $e) {
                    Log::warning("RenderOutputJob: gagal load overlay {$overlayPath}: {$e->getMessage()}");
                }
            }
        }

        $outputPath = "sessions/{$session->session_code}/output_print.jpg";
        $encodedPrint = $canvas->encode(Format::JPEG->encoder(quality: 95));
        Storage::disk('public')->put($outputPath, (string) $encodedPrint);

        Output::updateOrCreate(
            ['session_id' => $session->id, 'type' => 'print_image'],
            ['file_path' => $outputPath, 'dpi' => $frame->dpi]
        );

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
            default => $image,
        };
    }

    public function failed(\Throwable $exception): void
    {
        Log::error("RenderOutputJob failed for session {$this->session->id}: {$exception->getMessage()}");
        try {
            $this->session->update(['status' => 'rendering']);
        } catch (\Throwable $e) {
        }
    }
}
