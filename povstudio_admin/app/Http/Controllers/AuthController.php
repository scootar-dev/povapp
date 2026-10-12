<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // ==============================
    // HALAMAN LOGIN
    // ==============================
    public function showLogin()
    {
        return view('auth.login');
    }

    // ==============================
    // PROSES LOGIN
    // ==============================
    public function login(Request $request)
    {
        $request->validate([
            'login' => 'required',
            'password' => 'required',
        ]);

        $login = $request->login;

        $field = filter_var($login, FILTER_VALIDATE_EMAIL)
            ? 'email'
            : 'username';

        $credentials = [
            $field => $login,
            'password' => $request->password,
        ];

        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();

            return redirect()->route('dashboard');
        }

        return back()
            ->withErrors([
                'login' => 'Email/username atau password salah.',
            ])
            ->withInput();
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