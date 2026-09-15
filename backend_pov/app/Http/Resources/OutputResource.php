<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OutputResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'type' => $this->type,
            'url' => $this->file_path ? asset('storage/' . $this->file_path) : null,
            'dpi' => $this->dpi,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
