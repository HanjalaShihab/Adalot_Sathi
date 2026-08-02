<?php

use App\Http\Controllers\Admin\UserAdminController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CaseController;
use App\Http\Controllers\DeadlineController;
use App\Http\Controllers\DeviceTokenController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and assigned to the "api"
| middleware group. Enjoy building your API!
|
*/

Route::prefix('v1')->group(function () {
    // Public auth routes.
    Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:5,1');
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:5,1');

    // Authenticated user routes.
    Route::middleware('auth:sanctum')->group(function () {
        // Profile.
        Route::get('/me', [AuthController::class, 'me']);
        Route::put('/me', [AuthController::class, 'updateProfile']);
        Route::post('/logout', [AuthController::class, 'logout']);

        // Device tokens (push notifications).
        Route::post('/device-tokens', [DeviceTokenController::class, 'register']);
        Route::delete('/device-tokens', [DeviceTokenController::class, 'destroy']);

        // Cases.
        Route::get('/cases', [CaseController::class, 'index']);
        Route::post('/cases', [CaseController::class, 'store']);
        Route::get('/cases/{case}', [CaseController::class, 'show']);
        Route::put('/cases/{case}', [CaseController::class, 'update']);
        Route::delete('/cases/{case}', [CaseController::class, 'destroy']);

        // Deadlines.
        Route::get('/deadlines/upcoming', [DeadlineController::class, 'upcoming']);
        Route::get('/cases/{case}/deadlines', [DeadlineController::class, 'index']);
        Route::post('/cases/{case}/deadlines', [DeadlineController::class, 'store']);
        Route::get('/cases/{case}/deadlines/{deadline}', [DeadlineController::class, 'show']);
        Route::put('/cases/{case}/deadlines/{deadline}', [DeadlineController::class, 'update']);
        Route::delete('/cases/{case}/deadlines/{deadline}', [DeadlineController::class, 'destroy']);
        Route::post('/cases/{case}/deadlines/{deadline}/complete', [DeadlineController::class, 'markCompleted']);

        // Super admin routes.
        Route::middleware('admin')->prefix('admin')->group(function () {
            Route::get('/users', [UserAdminController::class, 'index']);
            Route::get('/users/{user}', [UserAdminController::class, 'show']);
            Route::put('/users/{user}', [UserAdminController::class, 'update']);
            Route::delete('/users/{user}', [UserAdminController::class, 'destroy']);
        });
    });
});

