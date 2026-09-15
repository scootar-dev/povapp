<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StudioResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'location' => $this->location,
            'camera_source' => $this->camera_source,
            'printer_driver' => $this->printer_driver,
            'welcome_overlay_url' => $this->welcome_overlay_path ? asset('storage/' . $this->welcome_overlay_path) : null,
            'event_type' => $this->event_type ?? 'general',
            'shoot_countdown_seconds' => (int) ($this->shoot_countdown_seconds ?? 5),
            'prep_timer_seconds' => (int) ($this->prep_timer_seconds ?? 10),
            'retake_quota' => (int) ($this->retake_quota ?? 2),
            'kiosk_pin_code' => $this->kiosk_pin_code ?? '1234',
            'is_active' => (bool) $this->is_active,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
