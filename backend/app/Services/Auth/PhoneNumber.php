<?php

namespace App\Services\Auth;

/**
 * WhatsApp numbers in one stored shape: digits only, country code first,
 * no "+" (919876543210), which is what WhatsApp APIs expect.
 */
final class PhoneNumber
{
    /**
     * Normalize what a person typed, or null when it cannot be a number.
     *
     * "+91 98765-43210", "0091 9876543210", "09876543210" and "9876543210"
     * all become 919876543210. A bare 10-digit number (or 11 with a leading
     * 0) gets the default country code from `otp.default_country_code`.
     */
    public static function normalize(?string $input): ?string
    {
        $input = trim((string) $input);
        $hasPlus = str_starts_with($input, '+');
        $digits = preg_replace('/\D+/', '', $input) ?? '';

        if (! $hasPlus) {
            if (str_starts_with($digits, '00')) {
                $digits = substr($digits, 2);
            } elseif (strlen($digits) === 11 && str_starts_with($digits, '0')) {
                $digits = self::defaultCountryCode().substr($digits, 1);
            } elseif (strlen($digits) === 10) {
                $digits = self::defaultCountryCode().$digits;
            }
        }

        if (preg_match('/^[1-9]\d{9,14}$/', $digits) !== 1) {
            return null;
        }

        return $digits;
    }

    private static function defaultCountryCode(): string
    {
        return preg_replace('/\D+/', '', (string) config('otp.default_country_code')) ?? '';
    }
}
