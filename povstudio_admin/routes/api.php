<?php

use App\Http\Controllers\Api\FrameController;
use App\Http\Controllers\Api\StickerController;
use Illuminate\Support\Facades\Route;

Route::prefix('kiosk')->group(function () {
    Route::get('/frames', [FrameController::class, 'index']);
    Route::get('/frames/{frame}', [FrameController::class, 'show']);
    
    Route::get('/stickers', [StickerController::class, 'index']);
    Route::get('/stickers/{sticker}', [StickerController::class, 'show']);
});