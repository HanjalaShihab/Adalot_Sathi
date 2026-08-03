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
            'client_email' => $this->client_email,
            'client_address' => $this->client_address,
            'court_name' => $this->court_name,
            'judge_name' => $this->judge_name,
            'bench' => $this->bench,
            'opposing_party' => $this->opposing_party,
            'opposing_lawyer' => $this->opposing_lawyer,
            'case_type' => $this->case_type,
            'status' => $this->status,
            'notes' => $this->notes,
            'filing_date' => $this->filing_date?->format('Y-m-d'),
            'next_hearing_date' => $this->next_hearing_date?->format('Y-m-d'),
            'judgment_date' => $this->judgment_date?->format('Y-m-d'),
            'reminder_date' => $this->reminder_date?->format('Y-m-d'),
            'reminder_time' => $this->reminder_time,
            'reminder_option' => $this->reminder_option,
            'repeat_reminder' => $this->repeat_reminder,
            'professional_fee' => $this->professional_fee,
            'paid_amount' => $this->paid_amount,
            'due_amount' => $this->due_amount,
            'payment_status' => $this->payment_status,
            'case_progress' => $this->case_progress,
            'ai_flags' => $this->ai_flags,
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];

        if ($this->relationLoaded('deadlines')) {
            $data['deadlines'] = DeadlineResource::collection($this->deadlines);
        }

        if ($this->relationLoaded('documents')) {
            $data['documents'] = $this->documents->map(fn ($d) => [
                'id' => $d->id,
                'file_name' => $d->file_name,
                'file_path' => $d->file_path,
                'mime_type' => $d->mime_type,
                'size' => $d->size,
                'type' => $d->type,
                'created_at' => $d->created_at?->toIso8601String(),
            ]);
        }

        return $data;
    }
}

