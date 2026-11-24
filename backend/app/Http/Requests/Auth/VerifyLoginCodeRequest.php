<?php

namespace App\Http\Requests\Auth;

use App\Services\Auth\PhoneNumber;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class VerifyLoginCodeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        if (is_string($this->input('phone'))) {
            $this->merge(['phone' => PhoneNumber::normalize($this->input('phone')) ?? $this->input('phone')]);
        }
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'phone' => ['required', 'string', 'regex:/^[1-9]\d{9,14}$/'],
            'code' => ['required', 'string', 'digits:6'],
            'device_name' => ['nullable', 'string', 'max:100'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'phone.required' => 'Enter your WhatsApp number',
            'phone.string' => 'Enter a valid WhatsApp number',
            'phone.regex' => 'Enter a valid WhatsApp number',
            'code.required' => 'Enter the 6-digit code',
            'code.digits' => 'The code is 6 digits',
        ];
    }
}
