<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProfileRequest extends FormRequest
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
        $userId = $this->user()->id;

        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'email', 'max:255', Rule::unique('users', 'email')->ignore($userId)],
            'phone' => [
                'nullable',
                'string',
                'regex:/^01[3-9][0-9]{8}$/',
                Rule::unique('users', 'phone')->ignore($userId),
            ],
            'password' => ['sometimes', 'string', 'min:8', 'confirmed'],
            'bar_council_number' => ['nullable', 'string', 'max:255'],
            'chamber_name' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string'],
            'district' => ['nullable', 'string', 'max:255'],
            'profile_photo' => ['nullable', 'string', 'max:2048'],
            'years_of_experience' => ['nullable', 'integer', 'min:0', 'max:100'],
            'practice_areas' => ['nullable', 'array'],
            'practice_areas.*' => ['string', 'max:255'],
            'preferred_court' => ['nullable', 'string', 'max:255'],
            'app_language' => ['sometimes', 'string', Rule::in(['bn', 'en'])],
            'notification_settings' => ['nullable', 'array'],
            'reminder_settings' => ['nullable', 'array'],
            'dark_mode' => ['nullable', 'boolean'],
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
            'phone.regex' => 'The phone number must be a valid Bangladeshi number (e.g. 01712345678).',
            'password.confirmed' => 'The password confirmation does not match.',
        ];
    }
}

