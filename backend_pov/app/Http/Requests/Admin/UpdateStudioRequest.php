<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class UpdateStudioRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => 'sometimes|string|max:255',
            'location' => 'nullable|string|max:255',
            'camera_source' => 'sometimes|in:internal,dslr',
            'printer_driver' => 'nullable|string',
            'welcome_overlay_path' => 'nullable|string',
            'is_active' => 'sometimes|boolean',
        ];
    }
}
