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
            'event_type' => 'nullable|string',
            'shoot_countdown_seconds' => 'nullable|integer|min:1|max:60',
            'prep_timer_seconds' => 'nullable|integer|min:1|max:120',
            'retake_quota' => 'nullable|integer|min:0|max:10',
            'kiosk_pin_code' => 'nullable|string|max:10',
            'is_active' => 'sometimes|boolean',
        ];
    }
}
