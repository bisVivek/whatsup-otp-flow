<?php

namespace Database\Factories;

use App\Models\LoginCode;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<LoginCode>
 */
class LoginCodeFactory extends Factory
{
    protected $model = LoginCode::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'phone' => '91'.fake()->unique()->numerify('9#########'),
            'code_hash' => hash_hmac('sha256', '123456', (string) config('app.key')),
            'expires_at' => now()->addMinutes(5),
        ];
    }

    /**
     * A code for the given plain value.
     */
    public function withCode(string $code): static
    {
        return $this->state(fn (): array => [
            'code_hash' => hash_hmac('sha256', $code, (string) config('app.key')),
        ]);
    }

    public function expired(): static
    {
        return $this->state(fn (): array => ['expires_at' => now()->subMinute()]);
    }
}
