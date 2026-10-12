@extends('layouts.admin')

@section('title', 'Kelola Data Pengguna')

@section('content')

<style>

    .users-page {
        padding: 24px 26px 40px;
        background: #fff8fc;
        min-height: calc(100vh - 60px);
    }

    /* HEADER */

    .page-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }

    .page-title h1 {
        font-size: 27px;
        color: #161329;
        font-weight: 800;
        margin-bottom: 4px;
    }

    .page-title p {
        color: #887b9a;
        font-size: 12px;
    }

    .btn-add {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        background: linear-gradient(90deg, #ca155c, #df3475);
        color: white;
        text-decoration: none;
        padding: 11px 20px;
        border-radius: 24px;
        font-size: 13px;
        font-weight: 700;
        box-shadow: 0 7px 16px rgba(207, 31, 99, .20);
        transition: .2s;
    }

    .btn-add:hover {
        transform: translateY(-1px);
    }


    /* STATISTICS */

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 12px;
        margin-bottom: 18px;
    }

    .stat-card {
        background: white;
        border: 1px solid #f1dce8;
        border-radius: 15px;
        padding: 14px;
        display: flex;
        align-items: center;
        gap: 12px;
        box-shadow: 0 3px 12px rgba(180, 70, 130, .04);
    }

    .stat-icon {
        width: 42px;
        height: 42px;
        border-radius: 11px;
        display: flex;
        justify-content: center;
        align-items: center;
        background: #fff0f7;
        font-size: 20px;
        color: #d61c65;
        flex-shrink: 0;
    }

    .stat-info small {
        display: block;
        color: #8b8097;
        font-size: 10px;
        margin-bottom: 3px;
    }

    .stat-info strong {
        font-size: 20px;
        color: #17142d;
    }

    .stat-info span {
        display: block;
        font-size: 9px;
        color: #23a86b;
        margin-top: 2px;
    }


    /* TOOLBAR */

    .toolbar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 15px;
        margin-bottom: 14px;
    }

    .filters {
        display: flex;
        gap: 7px;
        flex-wrap: wrap;
    }

    .filter-btn {
        border: 1px solid #eadbe7;
        background: white;
        color: #67566e;
        padding: 8px 14px;
        border-radius: 18px;
        font-size: 11px;
        cursor: pointer;
        text-decoration: none;
    }

    .filter-btn:hover {
        border-color: #d62268;
        color: #d62268;
    }

    .filter-btn.active {
        background: #d52067;
        border-color: #d52067;
        color: white;
    }

    .search-input {
        border: 1px solid #eadbe7;
        background: white;
        padding: 8px 13px;
        border-radius: 18px;
        color: #67566e;
        outline: none;
        font-size: 11px;
        width: 190px;
    }

    .search-input:focus {
        border-color: #d52067;
        box-shadow: 0 0 0 3px rgba(213, 32, 103, .08);
    }


    /* TABLE */

    .users-card {
        background: white;
        border: 1px solid #f0dce8;
        border-radius: 16px;
        overflow: hidden;
        box-shadow: 0 4px 15px rgba(180, 70, 130, .04);
    }

    .table-header {
        padding: 15px 18px;
        border-bottom: 1px solid #f2e4ec;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .table-header h2 {
        font-size: 14px;
        color: #27203b;
    }

    .table-header span {
        color: #9b8ca5;
        font-size: 10px;
    }

    table {
        width: 100%;
        border-collapse: collapse;
    }

    th {
        text-align: left;
        padding: 11px 15px;
        background: #fff8fc;
        color: #88798f;
        font-size: 10px;
        font-weight: 600;
        border-bottom: 1px solid #f1e3eb;
    }

    td {
        padding: 12px 15px;
        border-bottom: 1px solid #f5eaf0;
        font-size: 11px;
        color: #44384c;
        vertical-align: middle;
    }

    tr:hover td {
        background: #fffafd;
    }


    /* USER */

    .user-box {
        display: flex;
        align-items: center;
        gap: 9px;
    }

    .user-avatar {
        width: 34px;
        height: 34px;
        border-radius: 50%;
        background: linear-gradient(135deg, #f9d6e9, #eadbfa);
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 17px;
    }

    .user-name strong {
        display: block;
        color: #30253c;
        font-size: 11px;
    }

    .user-name small {
        color: #9b8ca6;
        font-size: 9px;
    }


    /* BADGES */

    .badge {
        display: inline-flex;
        align-items: center;
        padding: 4px 8px;
        border-radius: 12px;
        font-size: 9px;
        font-weight: 600;
    }

    .badge-active {
        background: #e6f8ef;
        color: #1a9b61;
    }

    .badge-inactive {
        background: #f1edf2;
        color: #8b7d8d;
    }

    .badge-user {
        background: #eee9ff;
        color: #7552db;
    }

    .badge-admin {
        background: #ffe6f0;
        color: #d21c62;
    }


    /* ACTION */

    .action-buttons {
        display: flex;
        gap: 5px;
    }

    .action-btn {
        width: 29px;
        height: 29px;
        border-radius: 8px;
        border: none;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        text-decoration: none;
        font-size: 13px;
        transition: .2s;
    }

    .edit-btn {
        background: #fff0f6;
        color: #d21b63;
    }

    .delete-btn {
        background: #ffe9ef;
        color: #e32958;
    }

    .action-btn:hover {
        transform: translateY(-1px);
    }


    /* EMPTY */

    .empty {
        padding: 65px 20px;
        text-align: center;
    }

    .empty-icon {
        font-size: 42px;
        margin-bottom: 10px;
    }

    .empty h3 {
        font-size: 16px;
        color: #30263c;
        margin-bottom: 5px;
    }

    .empty p {
        color: #9a8ca0;
        font-size: 11px;
    }


    /* PAGINATION */

    .pagination-area {
        padding: 14px 18px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .pagination-info {
        color: #9a8ca0;
        font-size: 10px;
    }

    .pagination {
        display: flex;
        gap: 5px;
    }

    .pagination nav {
        display: flex;
        gap: 5px;
    }

    .pagination a,
    .pagination span {
        min-width: 28px;
        height: 28px;
        padding: 0 8px;
        border-radius: 7px;
        border: 1px solid #eadde7;
        display: flex;
        align-items: center;
        justify-content: center;
        text-decoration: none;
        font-size: 10px;
        color: #66566f;
    }

    .pagination .active span {
        background: #d52067;
        border-color: #d52067;
        color: white;
    }


    /* SUCCESS */

    .success-message {
        background: #e9f9f0;
        border: 1px solid #c8efd9;
        color: #21935b;
        padding: 10px 14px;
        border-radius: 10px;
        margin-bottom: 15px;
        font-size: 11px;
    }


    /* RESPONSIVE */

    @media(max-width: 1000px) {

        .stats-grid {
            grid-template-columns: repeat(2, 1fr);
        }

        .users-card {
            overflow-x: auto;
        }

        table {
            min-width: 950px;
        }
    }

    @media(max-width: 700px) {

        .page-header {
            flex-direction: column;
            align-items: flex-start;
            gap: 12px;
        }

        .stats-grid {
            grid-template-columns: 1fr;
        }

        .toolbar {
            flex-direction: column;
            align-items: flex-start;
        }
    }

</style>


<div class="users-page">

    {{-- HEADER --}}

    <div class="page-header">

        <div class="page-title">

            <h1>Kelola Data Pengguna</h1>

            <p>
                Tambah, edit, atau hapus pengguna yang terdaftar di aplikasi PovStudio.
            </p>

        </div>

        <a href="{{ route('users.create') }}" class="btn-add">
            ＋ Tambah Pengguna
        </a>

    </div>


    {{-- SUCCESS MESSAGE --}}

    @if(session('success'))

        <div class="success-message">
            ✓ {{ session('success') }}
        </div>

    @endif


    {{-- STATISTICS --}}

    <div class="stats-grid">

        <div class="stat-card">

            <div class="stat-icon">
                👥
            </div>

            <div class="stat-info">

                <small>Total Pengguna</small>

                <strong>{{ $totalUsers }}</strong>

                <span>↑ pengguna terdaftar</span>

            </div>

        </div>


        <div class="stat-card">

            <div class="stat-icon">
                🟢
            </div>

            <div class="stat-info">

                <small>Pengguna Aktif</small>

                <strong>{{ $activeUsers }}</strong>

                <span>akun aktif</span>

            </div>

        </div>


        <div class="stat-card">

            <div class="stat-icon">
                ⭐
            </div>

            <div class="stat-info">

                <small>Pengguna Baru</small>

                <strong>{{ $newUsers }}</strong>

                <span>7 hari terakhir</span>

            </div>

        </div>


        <div class="stat-card">

            <div class="stat-icon">
                🔒
            </div>

            <div class="stat-info">

                <small>Nonaktif</small>

                <strong>{{ $inactiveUsers }}</strong>

                <span>akun nonaktif</span>

            </div>

        </div>

    </div>


    {{-- FILTER --}}

    <div class="toolbar">

        <div class="filters">

            <a
                href="{{ route('users.index') }}"
                class="filter-btn {{ !request('role') && !request('status') ? 'active' : '' }}"
            >
                Semua Pengguna
            </a>

            <a
                href="{{ route('users.index', ['role' => 'user']) }}"
                class="filter-btn {{ request('role') == 'user' ? 'active' : '' }}"
            >
                👤 User
            </a>

            <a
                href="{{ route('users.index', ['role' => 'admin']) }}"
                class="filter-btn {{ request('role') == 'admin' ? 'active' : '' }}"
            >
                👑 Admin
            </a>

            <a
                href="{{ route('users.index', ['status' => 'aktif']) }}"
                class="filter-btn {{ request('status') == 'aktif' ? 'active' : '' }}"
            >
                🟢 Aktif
            </a>

            <a
                href="{{ route('users.index', ['status' => 'nonaktif']) }}"
                class="filter-btn {{ request('status') == 'nonaktif' ? 'active' : '' }}"
            >
                ⚪ Nonaktif
            </a>

        </div>


        <form method="GET" action="{{ route('users.index') }}">

            @if(request('role'))
                <input
                    type="hidden"
                    name="role"
                    value="{{ request('role') }}"
                >
            @endif

            @if(request('status'))
                <input
                    type="hidden"
                    name="status"
                    value="{{ request('status') }}"
                >
            @endif

            <input
                type="text"
                name="search"
                value="{{ request('search') }}"
                placeholder="🔍 Cari pengguna..."
                class="search-input"
            >

        </form>

    </div>


    {{-- TABLE --}}

    <div class="users-card">

        <div class="table-header">

            <h2>
                👥 Daftar Pengguna
            </h2>

            <span>
                {{ $users->total() }} pengguna
            </span>

        </div>


        @if($users->count() > 0)

            <table>

                <thead>

                    <tr>

                        <th>Pengguna</th>

                        <th>Email</th>

                        <th>No. Telepon</th>

                        <th>Jenis Kelamin</th>

                        <th>Role</th>

                        <th>Status</th>

                        <th>Tanggal Daftar</th>

                        <th>Aksi</th>

                    </tr>

                </thead>


                <tbody>

                    @foreach($users as $user)

                        <tr>

                            <td>

                                <div class="user-box">

                                    <div class="user-avatar">
                                        👤
                                    </div>

                                    <div class="user-name">

                                        <strong>
                                            {{ $user->name }}
                                        </strong>

                                        <small>
                                            @{{ $user->username }}
                                        </small>

                                    </div>

                                </div>

                            </td>


                            <td>
                                {{ $user->email }}
                            </td>


                            <td>
                                {{ $user->phone ?: '-' }}
                            </td>


                            <td>
                                {{ $user->gender ?: '-' }}
                            </td>


                            <td>

                                @if($user->role === 'admin')

                                    <span class="badge badge-admin">
                                        👑 Admin
                                    </span>

                                @else

                                    <span class="badge badge-user">
                                        👤 User
                                    </span>

                                @endif

                            </td>


                            <td>

                                @if($user->status === 'aktif')

                                    <span class="badge badge-active">
                                        ● Aktif
                                    </span>

                                @else

                                    <span class="badge badge-inactive">
                                        ● Nonaktif
                                    </span>

                                @endif

                            </td>


                            <td>
                                {{ $user->created_at?->format('d M Y') }}
                            </td>


                            <td>

                                <div class="action-buttons">

                                    <a
                                        href="{{ route('users.edit', $user) }}"
                                        class="action-btn edit-btn"
                                        title="Edit"
                                    >
                                        ✎
                                    </a>


                                    <form
                                        action="{{ route('users.destroy', $user) }}"
                                        method="POST"
                                        onsubmit="return confirm('Yakin ingin menghapus pengguna ini?')"
                                        style="display:inline;"
                                    >

                                        @csrf

                                        @method('DELETE')

                                        <button
                                            type="submit"
                                            class="action-btn delete-btn"
                                            title="Hapus"
                                        >
                                            🗑
                                        </button>

                                    </form>

                                </div>

                            </td>

                        </tr>

                    @endforeach

                </tbody>

            </table>


            <div class="pagination-area">

                <div class="pagination-info">

                    Menampilkan
                    {{ $users->firstItem() ?? 0 }}
                    -
                    {{ $users->lastItem() ?? 0 }}
                    dari
                    {{ $users->total() }}
                    pengguna

                </div>

                <div class="pagination">

                    {{ $users->links() }}

                </div>

            </div>


        @else

            <div class="empty">

                <div class="empty-icon">
                    👥
                </div>

                <h3>
                    Belum ada pengguna
                </h3>

                <p>
                    Silakan tambahkan pengguna pertama.
                </p>

            </div>

        @endif

    </div>

</div>

@endsection