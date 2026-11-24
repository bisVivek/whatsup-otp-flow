<?php

/*
|--------------------------------------------------------------------------
| WhatsApp one-time codes
|--------------------------------------------------------------------------
*/

$testAccounts = collect(explode(',', (string) env('OTP_TEST_ACCOUNTS', '')))
    ->map(fn (string $pair) => array_map('trim', explode(':', $pair, 2)))
    ->filter(fn (array $pair) => count($pair) === 2 && $pair[0] !== '' && preg_match('/^\d{6}$/', $pair[1]))
    ->mapWithKeys(fn (array $pair) => [preg_replace('/\D+/', '', $pair[0]) => $pair[1]])
    ->all();

return [

    /*
    | Who delivers the code: "amica" sends it on WhatsApp through the AMICA
    | panel (see services.amica_whatsapp); "log" writes it to the log for
    | local development.
    */
    'sender' => env('OTP_SENDER', 'log'),

    // Added to 10-digit numbers typed without a country code.
    'default_country_code' => env('OTP_DEFAULT_COUNTRY_CODE', '91'),

    // How long a code stays valid, in seconds.
    'ttl' => (int) env('OTP_TTL', 300),

    // How long before the same number may ask for another code, in seconds.
    'resend_after' => (int) env('OTP_RESEND_AFTER', 30),

    // Wrong guesses allowed per code before it is burned.
    'max_attempts' => (int) env('OTP_MAX_ATTEMPTS', 5),

    // Lifetime of the API token handed out after sign in, in days.
    'token_ttl_days' => (int) env('AUTH_TOKEN_TTL_DAYS', 30),

    /*
    | Accounts that always accept a fixed code and get no WhatsApp message,
    | for demos and app store review. Full number with country code:
    | "919999999999:123456,918888888888:654321".
    | Leave empty in production unless you really mean it.
    */
    'test_accounts' => $testAccounts,

];
