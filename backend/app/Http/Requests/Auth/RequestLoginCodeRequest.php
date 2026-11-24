<?php

namespace App\Http\Requests\Auth;

use App\Services\Auth\PhoneNumber;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class RequestLoginCodeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Validated in the stored shape, so "+91 98765 43210" passes as 919876543210.
     */
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
        ];
    }
}
