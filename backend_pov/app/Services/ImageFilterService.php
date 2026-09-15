<?php

namespace App\Services;

use Intervention\Image\Image;

class ImageFilterService
{
    /**
     * Apply filter matrix/effects on Intervention Image instance.
     */
    public static function apply(Image $img, string $filter): Image
    {
        return match ($filter) {
            'bw' => $img->greyscale(),
            'vintage' => $img->greyscale()->brightness(10)->contrast(-5),
            'warm' => $img->brightness(5)->colorize(15, 5, -10),
            'cold' => $img->brightness(5)->colorize(-10, 5, 15),
            'natural' => $img->contrast(5),
            default => $img, // original
        };
    }
}
