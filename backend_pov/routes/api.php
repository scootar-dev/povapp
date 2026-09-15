<?php

use App\Http\Controllers\Admin;
use App\Http\Controllers\Kiosk;
use App\Http\Controllers\PublicDownloadController;
use Illuminate\Support\Facades\Route;

// ===== KIOSK API (dipanggil Flutter) =====
Route::prefix('kiosk')->middleware(['auth:studio-token', 'throttle:kiosk'])->group(function () {

    Route::get('/frames', [Kiosk\FrameController::class, 'index']);
    Route::get('/frames/{frame}', [Kiosk\FrameController::class, 'show']);

    Route::post('/sessions', [Kiosk\SessionController::class, 'store']);
    Route::patch('/sessions/{session}/status', [Kiosk\SessionController::class, 'updateStatus']);
    Route::post('/sessions/{session}/photos', [Kiosk\PhotoController::class, 'store']);
    Route::post('/sessions/{session}/photos/{photo}/retake', [Kiosk\PhotoController::class, 'retake']);
    Route::get('/sessions/{session}/photos', [Kiosk\PhotoController::class, 'index']);

    Route::post('/sessions/{session}/apply-filter', [Kiosk\SessionController::class, 'applyFilter']);

    Route::post('/sessions/{session}/render', [Kiosk\OutputController::class, 'render']);
    Route::get('/sessions/{session}/outputs', [Kiosk\OutputController::class, 'index']);

    Route::post('/sessions/{session}/print', [Kiosk\PrintController::class, 'store']);
    Route::get('/print-jobs/{printLog}', [Kiosk\PrintController::class, 'status']);

    Route::post('/sessions/{session}/share', [Kiosk\ShareController::class, 'store']);
    Route::get('/sessions/{session}/qr', [Kiosk\SessionController::class, 'qrCode']);

    Route::post('/sessions/{session}/complete', [Kiosk\SessionController::class, 'complete']);
});

// ===== PUBLIC (diakses via QR code, tanpa auth studio) =====
Route::get('/download/{sessionCode}', [PublicDownloadController::class, 'show'])->middleware('throttle:public_download');

// ===== ADMIN AUTH & API (dashboard, auth Sanctum) =====
Route::prefix('admin')->group(function () {
    Route::post('/login', [Admin\AuthController::class, 'login'])->middleware('throttle:admin_login');

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/me', [Admin\AuthController::class, 'me']);
        Route::post('/logout', [Admin\AuthController::class, 'logout']);

        Route::apiResource('frames', Admin\FrameController::class);
        Route::apiResource('studios', Admin\StudioController::class);
        Route::get('/sessions', [Admin\SessionController::class, 'index']);
        Route::get('/sessions/{session}', [Admin\SessionController::class, 'show']);
        Route::get('/reports/summary', [Admin\ReportController::class, 'summary']);
    });
});
