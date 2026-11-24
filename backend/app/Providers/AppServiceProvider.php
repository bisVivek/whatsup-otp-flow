<?php

namespace App\Providers;

use App\Services\Auth\AmicaWhatsAppSender;
use App\Services\Auth\LoginCodeSender;
use App\Services\Auth\LogLoginCodeSender;
use App\Services\Auth\PhoneNumber;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use InvalidArgumentException;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(LoginCodeSender::class, fn (): LoginCodeSender => match (config('otp.sender')) {
            'amica' => new AmicaWhatsAppSender,
            'log' => new LogLoginCodeSender,
            default => throw new InvalidArgumentException('OTP_SENDER must be "amica" or "log".'),
        });
    }

    public function boot(): void
    {
        $this->configureRateLimiting();
    }

    /**
     * Code requests are capped per IP and per phone; guesses per IP and per
     * phone, on top of the per-code attempt limit.
     */
    private function configureRateLimiting(): void
    {
        RateLimiter::for('otp-request', fn (Request $request): array => [
            Limit::perMinute(10)->by('ip:'.$request->ip()),
            Limit::perHour(10)->by('phone:'.$this->phoneKey($request)),
        ]);

        RateLimiter::for('otp-verify', fn (Request $request): array => [
            Limit::perMinute(20)->by('ip:'.$request->ip()),
            Limit::perMinute(10)->by('phone:'.$this->phoneKey($request)),
        ]);
    }

    /**
     * Throttling runs before validation, so normalize here too: "+91 98765
     * 43210" and "9876543210" share one bucket.
     */
    private function phoneKey(Request $request): string
    {
        $raw = $request->input('phone');

        return is_string($raw) ? (PhoneNumber::normalize($raw) ?? $raw) : '';
    }
}
