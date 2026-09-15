<?php

namespace App\Http\Requests\Kiosk;

use Illuminate\Foundation\Http\FormRequest;

class StorePhotoRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'slot_index' => 'required|integer|min:0',
            'photo' => 'required|image|max:20480', // Max 20MB
        ];
    }
}
