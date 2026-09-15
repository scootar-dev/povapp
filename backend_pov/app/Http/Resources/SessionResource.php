<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SessionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'session_code' => $this->session_code,
            'studio_id' => $this->studio_id,
            'frame_id' => $this->frame_id,
            'filter_applied' => $this->filter_applied,
            'retake_quota' => $this->retake_quota,
            'retake_used' => $this->retake_used,
            'retake_remaining' => $this->retakeRemaining(),
            'status' => $this->status,
            'started_at' => $this->started_at?->toIso8601String(),
            'completed_at' => $this->completed_at?->toIso8601String(),
            'studio' => new StudioResource($this->whenLoaded('studio')),
            'frame' => new FrameResource($this->whenLoaded('frame')),
            'photos' => PhotoResource::collection($this->whenLoaded('photos')),
            'selected_photos' => PhotoResource::collection($this->whenLoaded('selectedPhotos')),
            'outputs' => OutputResource::collection($this->whenLoaded('outputs')),
            'print_logs' => PrintLogResource::collection($this->whenLoaded('printLogs')),
            'share_logs' => ShareLogResource::collection($this->whenLoaded('shareLogs')),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
