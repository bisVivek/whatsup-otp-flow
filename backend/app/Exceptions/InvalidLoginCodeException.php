<?php

namespace App\Exceptions;

use Exception;
use Illuminate\Http\JsonResponse;

/**
 * A code that was wrong, expired or tried too often.
 *
 * Renders in Laravel's validation error shape, plus `attempts_left`.
 */
class InvalidLoginCodeException extends Exception
{
    public function __construct(string $message, public readonly ?int $attemptsLeft = null)
    {
        parent::__construct($message);
    }

    public static function wrong(int $attemptsLeft): self
    {
        return new self("That code isn't right", $attemptsLeft);
    }

    public static function expired(): self
    {
        return new self('That code has expired. Ask for a new one', 0);
    }

    public static function exhausted(): self
    {
        return new self('Too many wrong tries. Ask for a new code', 0);
    }

    public function render(): JsonResponse
    {
        return response()->json([
            'message' => $this->getMessage(),
            'errors' => ['code' => [$this->getMessage()]],
            'attempts_left' => $this->attemptsLeft,
        ], 422);
    }
}
