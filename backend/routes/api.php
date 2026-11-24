<?php

use App\Http\Controllers\Api\V1\Auth\LogoutController;
use App\Http\Controllers\Api\V1\Auth\OtpController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\LaunchNotificationController;
use App\Http\Controllers\Api\V1\MeController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->name('api.v1.')->group(function () {
    Route::post('auth/otp/request', [OtpController::class, 'store'])
        ->middleware('throttle:otp-request')
        ->name('auth.otp.request');

    Route::post('auth/otp/verify', [OtpController::class, 'verify'])
        ->middleware('throttle:otp-verify')
        ->name('auth.otp.verify');

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('auth/logout', LogoutController::class)->name('auth.logout');
        Route::get('me', MeController::class)->name('me');
        Route::get('dashboard', DashboardController::class)->name('dashboard');
        Route::post('launch-notification', [LaunchNotificationController::class, 'store'])->name('launch-notification.store');
        Route::delete('launch-notification', [LaunchNotificationController::class, 'destroy'])->name('launch-notification.destroy');
    });
});
