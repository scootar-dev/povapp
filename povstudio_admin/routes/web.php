<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\FrameController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\StickerController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\GoogleAuthController;
use App\Http\Controllers\AuthController;

// ==========================================
// HALAMAN UTAMA
// ==========================================

Route::get('/', function () {
    return redirect()->route('dashboard');
});

// ==========================================
// AUTH
// ==========================================

Route::get('/login', [AuthController::class, 'showLogin'])
    ->name('login');

Route::post('/login', [AuthController::class, 'login'])
    ->name('login.process');

Route::get('/register', [AuthController::class, 'showRegister'])
    ->name('register');

Route::post('/register', [AuthController::class, 'register'])
    ->name('register.process');

Route::post('/logout', [AuthController::class, 'logout'])
    ->name('logout');
// ==========================================
// GOOGLE LOGIN
// ==========================================



// ==========================================
// HALAMAN YANG HARUS LOGIN
// ==========================================

Route::middleware('auth')->group(function () {

    Route::get('/dashboard', [DashboardController::class, 'index'])
        ->name('dashboard');

    Route::resource('frames', FrameController::class);

    Route::get('/stickers', [StickerController::class, 'index'])
        ->name('stickers.index');

    Route::get('/stickers/create', [StickerController::class, 'create'])
        ->name('stickers.create');

    Route::post('/stickers', [StickerController::class, 'store'])
        ->name('stickers.store');

    Route::resource('users', UserController::class);
});