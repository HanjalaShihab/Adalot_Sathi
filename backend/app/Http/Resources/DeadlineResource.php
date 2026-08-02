<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DeadlineResource extends JsonResource
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
            'case_id' => $this->case_id,
            'title' => $this->title,
            'event_type' => $this->event_type,
            'due_date' => $this->due_date?->format('Y-m-d'),
            'due_time' => $this->due_time,
            'description' => $this->description,
            'status' => $this->status,
            'reminder_days_before' => $this->reminder_days_before,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];

        if ($this->relationLoaded('case')) {
            $data['case'] = [
                'id' => $this->case->id,
                'title' => $this->case->title,
                'case_number' => $this->case->case_number,
                'client_name' => $this->case->client_name,
            ];
        }

        return $data;
    }
}


