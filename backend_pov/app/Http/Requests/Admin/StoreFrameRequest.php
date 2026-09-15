<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreFrameRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'required|string|max:255',
            'category' => 'nullable|string|max:100',
            'overlay_path' => 'required|string',
            'thumbnail_path' => 'nullable|string',
            'photo_count' => 'required|integer|min:1|max:12',
            'output_width_px' => 'required|integer',
            'output_height_px' => 'required|integer',
            'dpi' => 'nullable|integer',
            'print_size' => 'required|in:4r,strip_2x6',
            'slots' => 'required|array|min:1',
            'slots.*.slot_index' => 'required|integer|min:0',
            'slots.*.x' => 'required|integer',
            'slots.*.y' => 'required|integer',
            'slots.*.width' => 'required|integer',
            'slots.*.height' => 'required|integer',
            'slots.*.rotation' => 'nullable|numeric',
        ];
    }
}
