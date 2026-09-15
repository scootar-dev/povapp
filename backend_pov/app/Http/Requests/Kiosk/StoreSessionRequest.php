<?php

namespace App\Http\Requests\Kiosk;

use Illuminate\Foundation\Http\FormRequest;

class StoreSessionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'frame_id' => 'nullable|exists:frames,id',
            'retake_quota' => 'nullable|integer|min:0|max:10',
        ];
    }
}
