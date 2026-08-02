<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateDeadlineRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'title' => ['sometimes', 'string', 'max:255'],
            'event_type' => ['sometimes', 'string', Rule::in(['hearing', 'filing', 'appeal', 'other'])],
            'due_date' => ['sometimes', 'date', 'date_format:Y-m-d'],
            'due_time' => ['nullable', 'date_format:H:i'],
            'description' => ['nullable', 'string'],
            'status' => ['sometimes', 'string', Rule::in(['pending', 'completed', 'missed'])],
            'reminder_days_before' => ['sometimes', 'array'],
            'reminder_days_before.*' => ['integer', 'min:0', 'max:365'],
        ];
    }
}

