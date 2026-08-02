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
            'case_number' => ['nullable', 'string', 'max:255'],
            'client_name' => ['required', 'string', 'max:255'],
            'client_phone' => ['nullable', 'string', 'regex:/^01[3-9][0-9]{8}$/'],
            'court_name' => ['nullable', 'string', 'max:255'],
            'opposing_party' => ['nullable', 'string', 'max:255'],
            'case_type' => ['nullable', 'string', 'max:255'],
            'status' => ['sometimes', 'string', Rule::in(['active', 'closed', 'on_hold'])],
            'notes' => ['nullable', 'string'],
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

