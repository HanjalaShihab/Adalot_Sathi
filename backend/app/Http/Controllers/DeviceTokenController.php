<?php

namespace App\Http\Controllers;

use App\Http\Requests\RegisterDeviceTokenRequest;
use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    /**
     * Register a push notification device token for the authenticated user.
     */
    public function register(RegisterDeviceTokenRequest $request): JsonResponse
    {
        $user = $request->user();

        $token = DeviceToken::firstOrCreate(
            [
                'user_id' => $user->id,
                'token' => $request->token,
            ],
            [
                'platform' => $request->input('platform', 'android'),
            ],
        );

        return response()->json([
            'message' => 'Device token registered successfully.',
            'device_token' => [
                'id' => $token->id,
                'platform' => $token->platform,
            ],
        ], 201);
    }

    /**
     * Remove a device token (e.g. on logout or notification disable).
     */
    public function destroy(Request $request): JsonResponse
    {
        $user = $request->user();

        $deleted = DeviceToken::where('user_id', $user->id)
            ->where('token', $request->input('token'))
            ->delete();

        return response()->json([
            'message' => $deleted > 0
                ? 'Device token removed successfully.'
                : 'No matching device token found.',
        ]);
    }
}

