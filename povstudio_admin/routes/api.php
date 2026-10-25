<?php

use App\Http\Controllers\Api\FrameController;
use App\Http\Controllers\Api\StickerController;
use App\Http\Controllers\Kiosk\SessionController;
use App\Http\Controllers\Kiosk\PhotoController;
use App\Http\Controllers\Kiosk\OutputController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/test-request', function (Request $request) {
    \Log::info('Test request all: ' . json_encode($request->all()));
    \Log::info('Test request input: ' . json_encode($request->input()));
    \Log::info('Test request json: ' . json_encode($request->json()->all()));
    \Log::info('Test request content: ' . $request->getContent());
    return response()->json(['all' => $request->all(), 'input' => $request->input(), 'json' => $request->json()->all(), 'content' => $request->getContent()]);
})->withoutMiddleware([ParseJson::class]);

Route::prefix('kiosk')->group(function () {
    Route::get('/frames', [FrameController::class, 'index']);
    Route::get('/frames/{frame}', [FrameController::class, 'show']);
    
    Route::get('/stickers', [StickerController::class, 'index']);
    Route::get('/stickers/{sticker}', [StickerController::class, 'show']);

    Route::post('/sessions', [SessionController::class, 'store']);
    Route::patch('/sessions/{session}/status', [SessionController::class, 'updateStatus']);
    Route::post('/sessions/{session}/photos', [PhotoController::class, 'store']);
    Route::get('/sessions/{session}/photos', [PhotoController::class, 'index']);
    Route::post('/sessions/{session}/photos/{photo}/retake', [PhotoController::class, 'retake']);
    Route::post('/sessions/{session}/render', [OutputController::class, 'render']);
    Route::get('/sessions/{session}/outputs', [OutputController::class, 'index']);
    Route::post('/sessions/{session}/complete', [SessionController::class, 'complete']);
});