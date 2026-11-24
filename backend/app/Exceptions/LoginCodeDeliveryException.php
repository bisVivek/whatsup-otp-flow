<?php

namespace App\Exceptions;

use Exception;
use Illuminate\Http\JsonResponse;
use Throwable;

/**
 * The WhatsApp provider did not take the message. Reported with the
 * provider's answer; the app gets a plain retry message.
 */
class LoginCodeDeliveryException extends Exception
{
    /**
     * @param  array<string, mixed>  $providerContext
     */
    public function __construct(string $reason, public readonly array $providerContext = [], ?Throwable $previous = null)
    {
        parent::__construct($reason, 0, $previous);
    }

    /**
     * @return array<string, mixed>
     */
    public function context(): array
    {
        return $this->providerContext;
    }

    public function render(): JsonResponse
    {
        return response()->json([
            'message' => "We couldn't send the code on WhatsApp. Try again in a moment",
        ], 503);
    }
}
