<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CaseResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $data = [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'title' => $this->title,
            'case_number' => $this->case_number,
            'client_name' => $this->client_name,
            'client_phone' => $this->client_phone,
            'court_name' => $this->court_name,
            'opposing_party' => $this->opposing_party,
            'case_type' => $this->case_type,
            'status' => $this->status,
            'notes' => $this->notes,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];

        if ($this->relationLoaded('deadlines')) {
            $data['deadlines'] = DeadlineResource::collection($this->deadlines);
        }

        return $data;
    }
}

