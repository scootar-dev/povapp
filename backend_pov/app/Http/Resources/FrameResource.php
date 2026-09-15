<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FrameResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'category' => $this->category,
            'overlay_url' => $this->overlay_path ? asset('storage/' . $this->overlay_path) : null,
            'thumbnail_url' => $this->thumbnail_path ? asset('storage/' . $this->thumbnail_path) : null,
            'photo_count' => $this->photo_count,
            'output_width_px' => $this->output_width_px,
            'output_height_px' => $this->output_height_px,
            'dpi' => $this->dpi ?? 300,
            'print_size' => $this->print_size,
            'is_active' => $this->is_active,
            'slots' => FrameSlotResource::collection($this->whenLoaded('slots')),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
