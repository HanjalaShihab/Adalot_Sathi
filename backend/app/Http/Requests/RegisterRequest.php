<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
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
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'regex:/^01[3-9][0-9]{8}$/', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
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

