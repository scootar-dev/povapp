<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * Menampilkan halaman Kelola Data Pengguna
     */
    public function index(Request $request)
    {
        // Query dasar
        $query = User::query();

        // Filter berdasarkan role
        if ($request->filled('role')) {
            $query->where('role', $request->role);
        }

        // Filter berdasarkan status
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        // Pencarian
        if ($request->filled('search')) {
            $search = $request->search;

            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', '%' . $search . '%')
                  ->orWhere('username', 'like', '%' . $search . '%')
                  ->orWhere('email', 'like', '%' . $search . '%')
                  ->orWhere('phone', 'like', '%' . $search . '%');
            });
        }

        // Data pengguna
        $users = $query
            ->latest()
            ->paginate(10)
            ->withQueryString();

        // Statistik
        $totalUsers = User::count();

        $activeUsers = User::where('status', 'aktif')
            ->count();

        $inactiveUsers = User::where('status', 'nonaktif')
            ->count();

        $newUsers = User::where(
            'created_at',
            '>=',
            now()->subDays(7)
        )->count();

        return view('users.index', compact(
            'users',
            'totalUsers',
            'activeUsers',
            'inactiveUsers',
            'newUsers'
        ));
    }


    /**
     * Halaman Tambah Pengguna
     */
    public function create()
    {
        return view('users.create');
    }


    /**
     * Menyimpan pengguna baru
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => [
                'required',
                'string',
                'max:255'
            ],

            'username' => [
                'required',
                'string',
                'max:50',
                'unique:users,username'
            ],

            'email' => [
                'required',
                'email',
                'max:255',
                'unique:users,email'
            ],

            'password' => [
                'required',
                'string',
                'min:8'
            ],

            'phone' => [
                'nullable',
                'string',
                'max:20'
            ],

            'address' => [
                'nullable',
                'string',
                'max:500'
            ],

            'birth_date' => [
                'nullable',
                'date'
            ],

            'gender' => [
                'nullable',
                'in:Laki-laki,Perempuan'
            ],

            'role' => [
                'required',
                'in:user,admin'
            ],
        ]);

        // Status akun
        if ($request->has('status')) {
            $validated['status'] = 'aktif';
        } else {
            $validated['status'] = 'nonaktif';
        }

        // Simpan pengguna
        User::create($validated);

        return redirect()
            ->route('users.index')
            ->with('success', 'Pengguna berhasil ditambahkan.');
    }


    /**
     * Detail pengguna
     */
    public function show(User $user)
    {
        return view('users.show', compact('user'));
    }


    /**
     * Halaman edit pengguna
     */
    public function edit(User $user)
    {
        return view('users.edit', compact('user'));
    }


    /**
     * Update pengguna
     */
    public function update(Request $request, User $user)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',

            'username' => [
                'required',
                'string',
                'max:50',
                'unique:users,username,' . $user->id
            ],

            'email' => [
                'required',
                'email',
                'max:255',
                'unique:users,email,' . $user->id
            ],

            'phone' => 'nullable|string|max:20',

            'address' => 'nullable|string|max:500',

            'birth_date' => 'nullable|date',

            'gender' => 'nullable|in:Laki-laki,Perempuan',

            'role' => 'required|in:user,admin',
        ]);

        // Password hanya diubah jika diisi
        if ($request->filled('password')) {
            $request->validate([
                'password' => 'string|min:8'
            ]);

            $validated['password'] = $request->password;
        }

        // Status
        $validated['status'] = $request->has('status')
            ? 'aktif'
            : 'nonaktif';

        $user->update($validated);

        return redirect()
            ->route('users.index')
            ->with('success', 'Data pengguna berhasil diperbarui.');
    }


    /**
     * Menghapus pengguna
     */
    public function destroy(User $user)
    {
        $user->delete();

        return redirect()
            ->route('users.index')
            ->with('success', 'Pengguna berhasil dihapus.');
    }
}