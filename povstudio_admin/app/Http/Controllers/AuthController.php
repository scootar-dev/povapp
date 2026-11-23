<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;

class AuthController extends Controller
{
    // ==============================
    // HALAMAN LOGIN
    // ==============================
    public function showLogin()
    {
        return view('auth.login', [
            'recaptchaSiteKey' => config('services.recaptcha.site_key'),
        ]);
    }

    // ==============================
    // PROSES LOGIN
    // ==============================
    public function login(Request $request)
    {
        $request->validate([
            'login' => 'required',
            'password' => 'required',
            'g-recaptcha-response' => 'required',
        ], [
            'g-recaptcha-response.required' => 'Silakan centang verifikasi CAPTCHA terlebih dahulu.',
        ]);

        $captcha = $this->verifyRecaptcha(
            (string) $request->input('g-recaptcha-response'),
            $request->ip()
        );

        if (! $captcha['success']) {
            return back()
                ->withErrors(['captcha' => $captcha['message']])
                ->withInput();
        }

        $login = $request->login;

        $field = filter_var($login, FILTER_VALIDATE_EMAIL)
            ? 'email'
            : 'username';

        $credentials = [
            $field => $login,
            'password' => $request->password,
        ];

        if (Auth::attempt($credentials, $request->boolean('remember'))) {
            $request->session()->regenerate();

            return redirect()->route('dashboard');
        }

        return back()
            ->withErrors([
                'login' => 'Email/username atau password salah.',
            ])
            ->withInput();
    }

    private function verifyRecaptcha(string $token, ?string $ip): array
    {
        $secret = config('services.recaptcha.secret_key');

        if (empty($secret)) {
            return [
                'success' => false,
                'message' => 'CAPTCHA belum dikonfigurasi. Hubungi administrator.',
            ];
        }

        try {
            $response = Http::asForm()
                ->timeout(10)
                ->post(config('services.recaptcha.verify_url'), [
                    'secret' => $secret,
                    'response' => $token,
                    'remoteip' => $ip,
                ]);
        } catch (\Throwable $e) {
            return [
                'success' => false,
                'message' => 'Tidak dapat menghubungi server CAPTCHA. Periksa koneksi internet Anda lalu coba lagi.',
            ];
        }

        if (! $response->successful()) {
            return [
                'success' => false,
                'message' => 'Verifikasi CAPTCHA gagal. Silakan coba lagi.',
            ];
        }

        $body = $response->json();

        if (($body['success'] ?? false) === true) {
            return ['success' => true, 'message' => null];
        }

        return [
            'success' => false,
            'message' => $this->mapCaptchaError($body['error-codes'] ?? []),
        ];
    }

    private function mapCaptchaError(array $codes): string
    {
        if (in_array('missing-input-secret', $codes) || in_array('invalid-input-secret', $codes)) {
            return 'Konfigurasi CAPTCHA tidak valid. Hubungi administrator.';
        }

        if (in_array('missing-input-response', $codes)) {
            return 'Silakan centang verifikasi CAPTCHA terlebih dahulu.';
        }

        if (in_array('invalid-input-response', $codes)) {
            return 'Verifikasi CAPTCHA tidak valid. Silakan coba lagi.';
        }

        if (in_array('timeout-or-duplicate', $codes)) {
            return 'CAPTCHA kedaluwarsa atau sudah digunakan. Silakan centang ulang.';
        }

        if (in_array('bad-request', $codes)) {
            return 'Permintaan CAPTCHA tidak valid. Silakan coba lagi.';
        }

        return 'Verifikasi CAPTCHA gagal. Silakan coba lagi.';
    }

    // ==============================
    // HALAMAN REGISTER
    // ==============================
    public function showRegister()
    {
        return view('auth.register');
    }

    // ==============================
    // PROSES REGISTER
    // ==============================
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'username' => 'required|string|min:4|unique:users,username',
            'password' => 'required|min:8|confirmed',
        ]);

        $user = User::create([
    'name' => $request->name,
    'email' => $request->email,
    'username' => $request->username,
    'password' => Hash::make($request->password),
    'role' => 'admin',
    'status' => 'aktif',
]);

        Auth::login($user);

        return redirect()->route('dashboard');
    }

    // ==============================
    // LOGOUT
    // ==============================
    // ==============================
// LOGOUT
// ==============================
public function logout(Request $request)
{
    Auth::logout();

    $request->session()->invalidate();
    $request->session()->regenerateToken();

    return redirect()->route('login');
}
}