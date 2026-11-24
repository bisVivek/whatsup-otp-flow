<?php

namespace App\Services\Auth;

use App\Exceptions\InvalidLoginCodeException;
use App\Exceptions\LoginCodeCooldownException;
use App\Exceptions\LoginCodeDeliveryException;
use App\Models\LoginCode;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\RateLimiter;

/**
 * Passwordless sign in with a 6-digit code sent on WhatsApp.
 *
 * Invite only: codes are issued for existing users. Unknown numbers get the
 * same response and the same resend cooldown as known ones, so the endpoint
 * does not reveal who has an account.
 *
 * Phones arrive normalized (see {@see PhoneNumber}); the form requests do it.
 */
class LoginCodeService
{
    public function __construct(private LoginCodeSender $sender) {}

    /**
     * Issue a fresh code for the phone and send it on WhatsApp.
     *
     * @return array{expires_in: int, resend_in: int}
     *
     * @throws LoginCodeCooldownException
     * @throws LoginCodeDeliveryException
     */
    public function issue(string $phone, ?string $ipAddress = null): array
    {
        $ttl = (int) config('otp.ttl');
        $resendAfter = (int) config('otp.resend_after');

        $cooldownKey = 'login-code-cooldown:'.hash('sha256', $phone);
        if (RateLimiter::tooManyAttempts($cooldownKey, 1)) {
            throw new LoginCodeCooldownException(max(1, RateLimiter::availableIn($cooldownKey)));
        }
        RateLimiter::hit($cooldownKey, $resendAfter);

        $user = User::where('phone', $phone)->first();
        $response = ['expires_in' => $ttl, 'resend_in' => $resendAfter];

        if ($user === null) {
            return $response;
        }

        $testCode = $this->testCodeFor($phone);
        $code = $testCode ?? $this->generateCode();

        DB::transaction(function () use ($phone, $code, $ttl, $ipAddress): void {
            LoginCode::where('phone', $phone)->whereNull('consumed_at')->update(['consumed_at' => now()]);

            LoginCode::create([
                'phone' => $phone,
                'code_hash' => $this->hash($code),
                'expires_at' => now()->addSeconds($ttl),
                'ip_address' => $ipAddress,
            ]);
        });

        if ($testCode === null) {
            try {
                $this->sender->send($phone, $code, (int) ceil($ttl / 60));
            } catch (LoginCodeDeliveryException $e) {
                // Nothing reached the person, so let them try again straight away.
                RateLimiter::clear($cooldownKey);

                throw $e;
            }
        }

        return $response;
    }

    /**
     * Check a code and, if it is right, sign the user in.
     *
     * @return array{token: string, expires_at: string, user: User}
     *
     * @throws InvalidLoginCodeException
     */
    public function verify(string $phone, string $code, string $deviceName): array
    {
        $maxAttempts = (int) config('otp.max_attempts');

        $loginCode = LoginCode::where('phone', $phone)->usable()->latest('id')->first();
        $user = User::where('phone', $phone)->first();

        if ($loginCode === null || $user === null) {
            throw InvalidLoginCodeException::expired();
        }

        if ($loginCode->attempts >= $maxAttempts) {
            throw InvalidLoginCodeException::exhausted();
        }

        if (! hash_equals($loginCode->code_hash, $this->hash($code))) {
            $loginCode->increment('attempts');
            $left = $maxAttempts - $loginCode->attempts;

            if ($left <= 0) {
                $loginCode->forceFill(['consumed_at' => now()])->save();

                throw InvalidLoginCodeException::exhausted();
            }

            throw InvalidLoginCodeException::wrong($left);
        }

        $expiresAt = now()->addDays((int) config('otp.token_ttl_days'));

        $token = DB::transaction(function () use ($loginCode, $user, $deviceName, $expiresAt): string {
            $loginCode->forceFill(['consumed_at' => now()])->save();

            $user->forceFill([
                'phone_verified_at' => $user->phone_verified_at ?? now(),
                'last_login_at' => now(),
            ])->save();

            return $user->createToken($deviceName, ['*'], $expiresAt)->plainTextToken;
        });

        return [
            'token' => $token,
            'expires_at' => $expiresAt->toIso8601String(),
            'user' => $user,
        ];
    }

    private function generateCode(): string
    {
        return str_pad((string) random_int(0, 999_999), 6, '0', STR_PAD_LEFT);
    }

    private function testCodeFor(string $phone): ?string
    {
        return config('otp.test_accounts')[$phone] ?? null;
    }

    /**
     * Keyed with the app key, so a leaked table cannot be brute forced offline
     * without it.
     */
    private function hash(string $code): string
    {
        return hash_hmac('sha256', $code, (string) config('app.key'));
    }
}
