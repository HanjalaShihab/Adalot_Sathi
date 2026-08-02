<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\UpdateProfileRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    /**
     * Register a new lawyer account.
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => $request->password,
            'role' => 'lawyer',
            'subscription_tier' => 'free',
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Registration successful. Welcome to Adalot Sathi.',
            'token' => $token,
            'user' => new UserResource($user),
        ], 201);
    }

    /**
     * Log an existing user in.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'The provided credentials are incorrect.',
                'errors' => [
                    'email' => ['The provided credentials are incorrect.'],
                ],
            ], 422);
        }

        // Revoke previous tokens for this device-independent session, then issue a fresh one.
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful. Welcome back to Adalot Sathi.',
            'token' => $token,
            'user' => new UserResource($user),
        ]);
    }

    /**
     * Return the currently authenticated user.
     */
    public function me(Request $request): UserResource
    {
        return new UserResource($request->user());
    }

    /**
     * Update the authenticated user's profile.
     */
    public function updateProfile(UpdateProfileRequest $request): UserResource
    {
        $user = $request->user();

        $data = $request->only(['name', 'email', 'phone']);

        if ($request->filled('password')) {
            $data['password'] = $request->password;
        }

        $user->update($data);

        return new UserResource($user->fresh());
    }

    /**
     * Log the user out (revoke the current token).
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully.',
        ]);
    }
}

