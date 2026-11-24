<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\RequestLoginCodeRequest;
use App\Http\Requests\Auth\VerifyLoginCodeRequest;
use App\Http\Resources\UserResource;
use App\Services\Auth\LoginCodeService;
use Illuminate\Http\JsonResponse;

class OtpController extends Controller
{
    public function __construct(private LoginCodeService $loginCodes) {}

    /**
     * Send a sign in code on WhatsApp. Same answer whether or not the account exists.
     */
    public function store(RequestLoginCodeRequest $request): JsonResponse
    {
        $ticket = $this->loginCodes->issue($request->string('phone')->toString(), $request->ip());

        return response()->json([
            'message' => 'If that number has an account, a code is on its way on WhatsApp',
            ...$ticket,
        ]);
    }

    /**
     * Trade a correct code for an API token.
     */
    public function verify(VerifyLoginCodeRequest $request): JsonResponse
    {
        $session = $this->loginCodes->verify(
            $request->string('phone')->toString(),
            $request->string('code')->toString(),
            $request->string('device_name')->toString() ?: 'app',
        );

        return response()->json([
            'token' => $session['token'],
            'token_type' => 'Bearer',
            'expires_at' => $session['expires_at'],
            'user' => new UserResource($session['user']),
        ]);
    }
}
