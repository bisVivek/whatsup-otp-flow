<?php

namespace App\Services\Auth;

use Illuminate\Support\Facades\Log;

/**
 * Writes the code to the log instead of sending it. For local development
 * only, like `MAIL_MAILER=log`.
 */
class LogLoginCodeSender implements LoginCodeSender
{
    public function send(string $phone, string $code, int $minutes): void
    {
        Log::info("WhatsApp sign in code for +{$phone}: {$code} (expires in {$minutes} minutes)");
    }
}
