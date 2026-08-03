<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreCaseRequest extends FormRequest
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
            'title' => ['required', 'string', 'max:255'],
            'case_number' => ['required', 'string', 'max:255'],
            'client_name' => ['required', 'string', 'max:255'],
            'client_phone' => ['required', 'string', 'regex:/^01[3-9][0-9]{8}$/'],
            'client_email' => ['nullable', 'email', 'max:255'],
            'client_address' => ['nullable', 'string'],
            'court_name' => ['required', 'string', 'max:255'],
            'judge_name' => ['nullable', 'string', 'max:255'],
            'bench' => ['nullable', 'string', 'max:255'],
            'opposing_party' => ['nullable', 'string', 'max:255'],
            'opposing_lawyer' => ['nullable', 'string', 'max:255'],
            'case_type' => ['required', 'string', 'max:255'],
            'status' => ['sometimes', 'string', Rule::in(['active', 'closed', 'on_hold'])],
            'notes' => ['nullable', 'string'],
            'filing_date' => ['nullable', 'date', 'date_format:Y-m-d'],
            'next_hearing_date' => ['nullable', 'date', 'date_format:Y-m-d'],
            'judgment_date' => ['nullable', 'date', 'date_format:Y-m-d'],
            'reminder_date' => ['nullable', 'date', 'date_format:Y-m-d'],
            'reminder_time' => ['nullable', 'date_format:H:i'],
            'reminder_option' => ['nullable', 'string', Rule::in(['1', '2', '3', '7', 'custom'])],
            'repeat_reminder' => ['nullable', 'boolean'],
            'professional_fee' => ['nullable', 'numeric', 'min:0'],
            'paid_amount' => ['nullable', 'numeric', 'min:0'],
            'due_amount' => ['nullable', 'numeric', 'min:0'],
            'payment_status' => ['nullable', 'string', Rule::in(['paid', 'partial', 'unpaid'])],
            'case_progress' => ['nullable', 'array'],
            'ai_flags' => ['nullable', 'array'],
        ];
    }

    /**
     * Get custom validation messages.
     *
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'client_phone.regex' => 'The client phone number must be a valid Bangladeshi number (e.g. 01712345678).',
        ];
    }
}

