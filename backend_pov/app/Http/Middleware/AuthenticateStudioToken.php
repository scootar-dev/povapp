<?php

namespace App\Http\Middleware;

use App\Models\Studio;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Autentikasi sederhana berbasis token per-perangkat (bukan login user).
 * Daftarkan sebagai alias 'auth:studio-token' di bootstrap/app.php (Laravel 11+)
 * atau app/Http/Kernel.php (Laravel 10).
 *
 * Header yang diharapkan: Authorization: Bearer <device_token>
 */
class AuthenticateStudioToken
{
    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->bearerToken();

        $studio = $token ? Studio::where('device_token', $token)->where('is_active', true)->first() : null;

        if (! $studio) {
            return response()->json(['message' => 'Token studio tidak valid.'], 401);
        }

        $request->attributes->set('studio_id', $studio->id);
        $request->attributes->set('studio', $studio);

        return $next($request);
    }
}
