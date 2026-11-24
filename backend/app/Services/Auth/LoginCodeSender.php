<?php

namespace App\Services\Auth;

use App\Exceptions\LoginCodeDeliveryException;

/**
 * Delivers a sign in code to a phone. Picked by `otp.sender`.
 */
interface LoginCodeSender
{
    /**
     * @param  string  $phone  Normalized, see {@see PhoneNumber}.
     *
     * @throws LoginCodeDeliveryException
     */
    public function send(string $phone, string $code, int $minutes): void;
}
