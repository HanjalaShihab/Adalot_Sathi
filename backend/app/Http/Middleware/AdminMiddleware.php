<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    /**
     * Ensure the authenticated user is a super admin.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user || ! $user->isAdmin()) {
            return response()->json([
                'error' => 'forbidden',
                'message' => 'You do not have permission to access this resource.',
            ], 403);
        }

        return $next($request);
    }
}

