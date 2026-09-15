<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PhotoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'slot_index' => $this->slot_index,
            'url' => $this->file_path ? asset('storage/' . $this->file_path) : null,
            'is_selected' => (bool) $this->is_selected,
            'attempt_number' => $this->attempt_number,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
