<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Whether the user wants an email when the app actually ships.
 */
class LaunchNotificationController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        return $this->set($request, true);
    }

    public function destroy(Request $request): JsonResponse
    {
        return $this->set($request, false);
    }

    private function set(Request $request, bool $notify): JsonResponse
    {
        $request->user()->update(['notify_launch' => $notify]);

        return response()->json([
            'notify_launch' => $notify,
            'message' => $notify ? "You're on the list. So is everyone else" : 'Fair enough',
        ]);
    }
}
