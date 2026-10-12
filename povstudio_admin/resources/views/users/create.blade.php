@extends('layouts.admin')

@section('title', 'Tambah Pengguna')

@section('content')

<style>

    .create-page {
        padding: 18px 26px 40px;
        background: #fff8fc;
        min-height: calc(100vh - 60px);
    }

    .back-link {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
        color: #701c63;
        font-size: 11px;
        font-weight: 600;
        margin-bottom: 18px;
    }

    .back-link:hover {
        color: #d21b63;
    }

    .create-heading {
        margin-bottom: 15px;
    }

    .create-heading h1 {
        font-size: 26px;
        font-weight: 800;
        color: #15132d;
        margin-bottom: 3px;
    }

    .create-heading p {
        color: #887b9a;
        font-size: 11px;
    }


    .form-card {
        background: white;
        border: 1px solid #f0dce8;
        border-radius: 15px;
        padding: 20px;
        box-shadow: 0 5px 16px rgba(190, 70, 130, .05);
        max-width: 950px;
    }

    .form-title {
        display: flex;
        align-items: center;
        gap: 10px;
        color: #26203a;
        font-size: 14px;
        margin-bottom: 18px;
    }

    .form-title-icon {
        width: 34px;
        height: 34px;
        background: #fff0f7;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #d21d63;
        font-size: 18px;
    }


    .form-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 15px;
    }

    .form-group {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }

    label {
        color: #31263f;
        font-size: 10px;
        font-weight: 700;
    }

    label span {
        color: #d51d63;
    }


    input,
    select {
        width: 100%;
        border: 1px solid #e7dce9;
        background: #fcf8fc;
        border-radius: 9px;
        padding: 10px 12px;
        outline: none;
        color: #43374d;
        font-size: 11px;
        font-family: Arial, Helvetica, sans-serif;
    }

    input:focus,
    select:focus {
        border-color: #dd3b7a;
        box-shadow: 0 0 0 3px rgba(220, 50, 115, .08);
    }

    .error {
        color: #df315d;
        font-size: 9px;
    }


    /* STATUS */

    .status-row {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-top: 5px;
    }

    .status-switch {
        position: relative;
        width: 39px;
        height: 22px;
    }

    .status-switch input {
        display: none;
    }

    .slider {
        position: absolute;
        inset: 0;
        background: #d4ccd5;
        border-radius: 20px;
        cursor: pointer;
        transition: .2s;
    }

    .slider:before {
        content: "";
        position: absolute;
        width: 16px;
        height: 16px;
        left: 3px;
        top: 3px;
        background: white;
        border-radius: 50%;
        transition: .2s;
    }

    .status-switch input:checked + .slider {
        background: #d51f65;
    }

    .status-switch input:checked + .slider:before {
        transform: translateX(17px);
    }

    .status-text strong {
        display: block;
        font-size: 11px;
        color: #30263d;
    }

    .status-text small {
        color: #9b8ca5;
        font-size: 9px;
    }


    /* BUTTON */

    .form-actions {
        display: flex;
        gap: 10px;
        margin-top: 20px;
    }

    .btn-cancel,
    .btn-save {
        flex: 1;
        padding: 11px;
        border-radius: 22px;
        font-size: 11px;
        font-weight: 700;
        text-align: center;
        cursor: pointer;
        transition: .2s;
    }

    .btn-cancel {
        background: #fff0f6;
        color: #cb205e;
        text-decoration: none;
    }

    .btn-save {
        border: none;
        background: linear-gradient(90deg, #cb155b, #df3474);
        color: white;
    }

    .btn-save:hover,
    .btn-cancel:hover {
        transform: translateY(-1px);
    }


    @media(max-width: 750px) {

        .form-grid {
            grid-template-columns: 1fr;
        }

    }

</style>


<div class="create-page">

    {{-- KEMBALI --}}

    <a
        href="{{ route('users.index') }}"
        class="back-link"
    >
        ← Kembali ke Data Pengguna
    </a>


    {{-- JUDUL --}}

    <div class="create-heading">

        <h1>
            Tambah Pengguna
        </h1>

        <p>
            Tambahkan pengguna baru ke dalam aplikasi PovStudio.
        </p>

    </div>


    {{-- FORM CARD --}}

    <div class="form-card">

        <div class="form-title">

            <div class="form-title-icon">
                👤
            </div>

            <strong>
                Informasi Pengguna
            </strong>

        </div>


        <form
            action="{{ route('users.store') }}"
            method="POST"
        >

            @csrf


            <div class="form-grid">


                {{-- NAMA --}}

                <div class="form-group">

                    <label>
                        Nama Lengkap <span>*</span>
                    </label>

                    <input
                        type="text"
                        name="name"
                        value="{{ old('name') }}"
                        placeholder="Masukkan nama lengkap"
                        required
                    >

                    @error('name')
                        <div class="error">
                            {{ $message }}
                        </div>
                    @enderror

                </div>


                {{-- USERNAME --}}

                <div class="form-group">

                    <label>
                        Username <span>*</span>
                    </label>

                    <input
                        type="text"
                        name="username"
                        value="{{ old('username') }}"
                        placeholder="Masukkan username"
                        required
                    >

                    @error('username')
                        <div class="error">
                            {{ $message }}
                        </div>
                    @enderror

                </div>


                {{-- EMAIL --}}

                <div class="form-group">

                    <label>
                        Email <span>*</span>
                    </label>

                    <input
                        type="email"
                        name="email"
                        value="{{ old('email') }}"
                        placeholder="contoh: user@gmail.com"
                        required
                    >

                    @error('email')
                        <div class="error">
                            {{ $message }}
                        </div>
                    @enderror

                </div>


                {{-- PASSWORD --}}

                <div class="form-group">

                    <label>
                        Password <span>*</span>
                    </label>

                    <input
                        type="password"
                        name="password"
                        placeholder="Masukkan password"
                        required
                    >

                    @error('password')
                        <div class="error">
                            {{ $message }}
                        </div>
                    @enderror

                </div>


                {{-- TELEPON --}}

                <div class="form-group">

                    <label>
                        Nomor Telepon
                    </label>

                    <input
                        type="text"
                        name="phone"
                        value="{{ old('phone') }}"
                        placeholder="Contoh: 081234567890"
                    >

                </div>


                {{-- ALAMAT --}}

                <div class="form-group">

                    <label>
                        Alamat
                    </label>

                    <input
                        type="text"
                        name="address"
                        value="{{ old('address') }}"
                        placeholder="Masukkan alamat lengkap"
                    >

                </div>


                {{-- TANGGAL LAHIR --}}

                <div class="form-group">

                    <label>
                        Tanggal Lahir
                    </label>

                    <input
                        type="date"
                        name="birth_date"
                        value="{{ old('birth_date') }}"
                    >

                </div>


                {{-- JENIS KELAMIN --}}

                <div class="form-group">

                    <label>
                        Jenis Kelamin
                    </label>

                    <select name="gender">

                        <option value="">
                            Pilih jenis kelamin
                        </option>

                        <option
                            value="Laki-laki"
                            {{ old('gender') == 'Laki-laki' ? 'selected' : '' }}
                        >
                            Laki-laki
                        </option>

                        <option
                            value="Perempuan"
                            {{ old('gender') == 'Perempuan' ? 'selected' : '' }}
                        >
                            Perempuan
                        </option>

                    </select>

                </div>


                {{-- ROLE --}}

                <div class="form-group">

                    <label>
                        Role Pengguna
                    </label>

                    <select name="role">

                        <option
                            value="user"
                            {{ old('role', 'user') == 'user' ? 'selected' : '' }}
                        >
                            👤 User
                        </option>

                        <option
                            value="admin"
                            {{ old('role') == 'admin' ? 'selected' : '' }}
                        >
                            👑 Admin
                        </option>

                    </select>

                </div>


                {{-- STATUS --}}

                <div class="form-group">

                    <label>
                        Status Akun
                    </label>

                    <div class="status-row">

                        <label class="status-switch">

                            <input
                                type="checkbox"
                                name="status"
                                value="aktif"
                                checked
                            >

                            <span class="slider"></span>

                        </label>

                        <div class="status-text">

                            <strong>
                                Aktif
                            </strong>

                            <small>
                                Pengguna dapat mengakses aplikasi
                            </small>

                        </div>

                    </div>

                </div>


            </div>


            {{-- BUTTON --}}

            <div class="form-actions">

                <a
                    href="{{ route('users.index') }}"
                    class="btn-cancel"
                >
                    Batal
                </a>

                <button
                    type="submit"
                    class="btn-save"
                >
                    ＋ &nbsp; Simpan Pengguna
                </button>

            </div>


        </form>

    </div>

</div>

@endsection