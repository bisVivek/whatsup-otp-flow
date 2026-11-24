<?php

namespace App\Exceptions;

use Exception;
use Illuminate\Http\JsonResponse;

/**
 * A new code was asked for too soon after the last one.
 */
class LoginCodeCooldownException extends Exception
{
    public function __construct(public readonly int $retryAfter)
    {
        parent::__construct("Hold on. You can ask for another code in {$retryAfter} seconds");
    }

    public function render(): JsonResponse
    {
        return response()->json([
            'message' => $this->getMessage(),
            'retry_after' => $this->retryAfter,
        ], 429, ['Retry-After' => (string) $this->retryAfter]);
    }
}
