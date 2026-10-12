<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Register - PovStudio</title>

    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
        }

        .main-bg {
            background:
                radial-gradient(circle at 10% 10%, rgba(255, 180, 220, .55), transparent 28%),
                radial-gradient(circle at 90% 20%, rgba(211, 181, 255, .45), transparent 30%),
                radial-gradient(circle at 70% 90%, rgba(255, 194, 225, .55), transparent 30%),
                #fff8fc;
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.72);
            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);
        }

        .form-card {
            background: rgba(255, 255, 255, 0.92);
            box-shadow: 0 15px 45px rgba(145, 88, 135, 0.10);
        }

        .input-box {
            background: linear-gradient(
                90deg,
                rgba(248, 246, 252, 0.95),
                rgba(250, 247, 253, 0.95)
            );

            border: 1px solid #e9e2ef;
            transition: all .2s ease;
        }

        .input-box:focus-within {
            border-color: #ec4899;
            box-shadow: 0 0 0 3px rgba(236, 72, 153, 0.10);
        }

        .input-box input,
        .input-box select {
            background: transparent;
        }

        .register-button {
            background: linear-gradient(
                90deg,
                #d71965,
                #c21f68
            );

            box-shadow: 0 8px 20px rgba(215, 25, 101, .22);
            transition: all .2s ease;
        }

        .register-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 25px rgba(215, 25, 101, .28);
        }

        .google-button {
            background: #f8f7fb;
            border: 1px solid #eeeaf3;
            transition: all .2s ease;
        }

        .google-button:hover {
            background: #f2eff7;
        }

        .pink-text {
            color: #d71965;
        }

        .purple-text {
            color: #68628e;
        }

        .photo-card {
            transform: rotate(-7deg);
            box-shadow: 0 15px 30px rgba(120, 70, 110, .18);
        }

        .photo-card:nth-child(2) {
            transform: rotate(6deg);
        }

        .photo-card:nth-child(3) {
            transform: rotate(-4deg);
        }

        .floating-heart {
            animation: floating 3s ease-in-out infinite;
        }

        @keyframes floating {
            0%, 100% {
                transform: translateY(0);
            }

            50% {
                transform: translateY(-8px);
            }
        }

        .sparkle {
            animation: sparkle 2.5s ease-in-out infinite;
        }

        @keyframes sparkle {
            0%, 100% {
                opacity: .55;
                transform: scale(.9);
            }

            50% {
                opacity: 1;
                transform: scale(1.1);
            }
        }

        .feature-item {
            transition: all .2s ease;
        }

        .feature-item:hover {
            transform: translateX(4px);
        }

        @media (max-width: 900px) {
            .desktop-left {
                display: none;
            }

            .register-wrapper {
                max-width: 650px !important;
            }
        }

        @media (max-width: 640px) {
            .register-wrapper {
                padding: 15px !important;
            }

            .form-card {
                padding: 25px !important;
            }
        }
    </style>

</head>


<body class="main-bg min-h-screen">

    <!-- MAIN WRAPPER -->
    <div class="register-wrapper max-w-[1400px] mx-auto min-h-screen p-6 md:p-8">

        <!-- TOP BAR -->
        <div class="flex items-center justify-between mb-5 px-2 md:px-8">

            <!-- LOGO -->
            <div class="flex items-center gap-3">

                <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-pink-400 to-purple-400
                            flex items-center justify-center shadow-md">

                    <i data-lucide="camera"
                       class="text-white"
                       width="32"
                       height="32">
                    </i>

                </div>

                <div>

                    <h1 class="text-3xl md:text-4xl font-extrabold pink-text">
                        PovStudio
                    </h1>

                    <p class="text-xs md:text-sm tracking-[5px] font-semibold purple-text">
                        ADMIN PANEL
                    </p>

                </div>

            </div>


            <!-- KEMBALI -->
            <a href="{{ route('login') }}"
               class="flex items-center gap-2 purple-text font-medium hover:text-pink-600 transition">

                <i data-lucide="arrow-left" width="25"></i>

                <span class="hidden sm:inline">
                    Kembali ke Beranda
                </span>

            </a>

        </div>


        <!-- MAIN CARD -->
        <div class="glass-card rounded-[30px] border border-white/70
                    overflow-hidden min-h-[850px]">

            <div class="grid grid-cols-1 lg:grid-cols-[42%_58%]">


                <!-- ================================================= -->
                <!-- LEFT SIDE -->
                <!-- ================================================= -->

                <div class="desktop-left relative p-10 lg:p-12 overflow-hidden">

                    <!-- BACKGROUND DECORATION -->

                    <div class="absolute -top-32 -left-20 w-96 h-96
                                bg-pink-200/40 rounded-full blur-3xl">
                    </div>

                    <div class="absolute bottom-0 -left-20 w-96 h-96
                                bg-purple-200/40 rounded-full blur-3xl">
                    </div>


                    <!-- CONTENT -->

                    <div class="relative z-10">

                        <!-- BADGE -->

                        <div class="inline-flex items-center px-5 py-2
                                    rounded-full bg-pink-100
                                    text-pink-600 font-bold tracking-widest text-sm">

                            JOIN POVSTUDIO

                        </div>


                        <!-- TITLE -->

                        <h2 class="mt-5 text-5xl font-extrabold
                                   text-[#17153e] leading-[1.05]">

                            Mulai<br>
                            Bersama Kami!

                        </h2>


                        <p class="mt-5 text-lg text-[#77739d]
                                  max-w-md leading-relaxed">

                            Daftar sekarang dan kelola studio
                            photobooth PovStudio dengan mudah.

                        </p>


                        <!-- PHOTO AREA -->

                        <div class="relative mt-8 h-[470px]">

                            <!-- PHOTO 1 -->
                            <div class="photo-card absolute
                                        left-4 top-4
                                        w-[235px]
                                        bg-white p-3 rounded-xl">

                                <div class="h-[300px] rounded-lg overflow-hidden
                                            bg-gradient-to-br from-pink-100 to-purple-100">

                                    <img
                                        src="https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80"
                                        class="w-full h-full object-cover"
                                        alt="PovStudio">

                                </div>

                                <p class="text-center text-pink-400
                                          font-medium mt-3 italic">

                                    Capture<br>
                                    Create<br>
                                    Happiest Moments Together! ♡

                                </p>

                            </div>


                            <!-- HEART -->

                            <div class="floating-heart absolute
                                        left-[235px] top-[220px]
                                        w-16 h-16 bg-white rounded-full
                                        shadow-lg flex items-center justify-center
                                        z-20">

                                <i data-lucide="heart"
                                   class="text-pink-500 fill-pink-500"
                                   width="30">
                                </i>

                            </div>


                            <!-- PHOTO 2 -->

                            <div class="photo-card absolute
                                        left-[205px] top-[210px]
                                        w-[190px]
                                        bg-white p-3 rounded-xl
                                        z-10">

                                <div class="h-[245px] rounded-lg overflow-hidden
                                            bg-gradient-to-br from-purple-100 to-pink-100">

                                    <img
                                        src="https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=500&q=80"
                                        class="w-full h-full object-cover"
                                        alt="PovStudio">

                                </div>

                                <p class="text-center text-pink-400
                                          font-semibold mt-2">

                                    SNAP! ♥

                                </p>

                            </div>


                            <!-- SPARKLES -->

                            <div class="sparkle absolute top-16 right-8
                                        text-pink-400 text-4xl">
                                ✦
                            </div>

                            <div class="sparkle absolute top-48 right-2
                                        text-purple-400 text-3xl">
                                ✦
                            </div>

                            <div class="sparkle absolute bottom-8 left-2
                                        text-pink-400 text-3xl">
                                ✦
                            </div>

                        </div>


                        <!-- FEATURES -->

                        <div class="bg-white/75 rounded-3xl p-5
                                    shadow-sm">

                            <!-- FEATURE 1 -->

                            <div class="feature-item flex items-center gap-4 mb-4">

                                <div class="w-12 h-12 rounded-xl bg-pink-100
                                            flex items-center justify-center">

                                    <i data-lucide="camera"
                                       class="text-pink-500">
                                    </i>

                                </div>

                                <div>

                                    <h3 class="font-semibold text-[#29254e]">
                                        Kelola Frame
                                    </h3>

                                    <p class="text-sm text-[#8b87a8]">
                                        Tambah frame sesuai tema
                                    </p>

                                </div>

                            </div>


                            <!-- FEATURE 2 -->

                            <div class="feature-item flex items-center gap-4 mb-4">

                                <div class="w-12 h-12 rounded-xl bg-pink-100
                                            flex items-center justify-center">

                                    <i data-lucide="smile"
                                       class="text-pink-500">
                                    </i>

                                </div>

                                <div>

                                    <h3 class="font-semibold text-[#29254e]">
                                        Kelola Stiker
                                    </h3>

                                    <p class="text-sm text-[#8b87a8]">
                                        Buat studio semakin seru
                                    </p>

                                </div>

                            </div>


                            <!-- FEATURE 3 -->

                            <div class="feature-item flex items-center gap-4 mb-4">

                                <div class="w-12 h-12 rounded-xl bg-pink-100
                                            flex items-center justify-center">

                                    <i data-lucide="image"
                                       class="text-pink-500">
                                    </i>

                                </div>

                                <div>

                                    <h3 class="font-semibold text-[#29254e]">
                                        Kelola Foto
                                    </h3>

                                    <p class="text-sm text-[#8b87a8]">
                                        Simpan dan atur hasil foto
                                    </p>

                                </div>

                            </div>


                            <!-- FEATURE 4 -->

                            <div class="feature-item flex items-center gap-4">

                                <div class="w-12 h-12 rounded-xl bg-pink-100
                                            flex items-center justify-center">

                                    <i data-lucide="users"
                                       class="text-pink-500">
                                    </i>

                                </div>

                                <div>

                                    <h3 class="font-semibold text-[#29254e]">
                                        Kelola Pengguna
                                    </h3>

                                    <p class="text-sm text-[#8b87a8]">
                                        Atur data operator & admin
                                    </p>

                                </div>

                            </div>

                        </div>


                        <!-- QUOTE -->

                        <p class="mt-8 text-pink-400 text-2xl italic">
                            Let's Create<br>
                            Together! ♡
                        </p>

                    </div>

                </div>


                <!-- ================================================= -->
                <!-- RIGHT SIDE / FORM -->
                <!-- ================================================= -->

                <div class="flex items-center justify-center p-5 md:p-10">

                    <div class="form-card w-full max-w-[600px]
                                rounded-[30px] p-7 md:p-10">


                        <!-- ICON -->

                        <div class="flex justify-center mb-3">

                            <div class="w-20 h-20 rounded-3xl
                                        bg-gradient-to-br from-pink-50 to-purple-50
                                        flex items-center justify-center">

                                <i data-lucide="camera"
                                   class="text-pink-500"
                                   width="40"
                                   height="40">
                                </i>

                            </div>

                        </div>


                        <!-- LOGO -->

                        <div class="text-center">

                            <h2 class="text-3xl font-extrabold pink-text">
                                PovStudio
                            </h2>

                            <p class="tracking-[5px] text-sm
                                      purple-text font-semibold">

                                ADMIN PANEL

                            </p>

                        </div>


                        <!-- TITLE -->

                        <div class="text-center mt-6 mb-7">

                            <h3 class="text-3xl font-extrabold
                                       text-[#17153e]">

                                Buat Akun Admin

                            </h3>

                            <p class="text-[#8580a5] mt-2">

                                Lengkapi data berikut untuk mulai mengelola
                                studio photobooth PovStudio.

                            </p>

                        </div>


                        <!-- ERROR -->

                        @if ($errors->any())

                            <div class="bg-red-50 border border-red-100
                                        text-red-600 rounded-xl p-4 mb-5 text-sm">

                                @foreach ($errors->all() as $error)

                                    <p class="mb-1">
                                        {{ $error }}
                                    </p>

                                @endforeach

                            </div>

                        @endif


                        <!-- FORM -->

                        <form
                            action="{{ route('register.process') }}"
                            method="POST"
                        >

                            @csrf


                            <!-- NAMA -->

                            <div class="mb-4">

                                <label class="block text-sm
                                              font-semibold text-[#66628c]
                                              mb-2">

                                    Nama Lengkap

                                </label>

                                <div class="input-box rounded-xl
                                            flex items-center px-4">

                                    <i data-lucide="user"
                                       class="text-purple-800 flex-shrink-0"
                                       width="22">
                                    </i>

                                    <input
                                        type="text"
                                        name="name"
                                        value="{{ old('name') }}"
                                        placeholder="Masukkan nama lengkap"
                                        required
                                        class="w-full px-4 py-3.5
                                               outline-none
                                               text-[#29254e]"
                                    >

                                </div>

                            </div>


                            <!-- EMAIL -->

                            <div class="mb-4">

                                <label class="block text-sm
                                              font-semibold text-[#66628c]
                                              mb-2">

                                    Email

                                </label>

                                <div class="input-box rounded-xl
                                            flex items-center px-4">

                                    <i data-lucide="mail"
                                       class="text-purple-800 flex-shrink-0"
                                       width="22">
                                    </i>

                                    <input
                                        type="email"
                                        name="email"
                                        value="{{ old('email') }}"
                                        placeholder="Masukkan alamat email"
                                        required
                                        class="w-full px-4 py-3.5
                                               outline-none
                                               text-[#29254e]"
                                    >

                                </div>

                            </div>


                            <!-- USERNAME -->

                            <div class="mb-4">

                                <label class="block text-sm
                                              font-semibold text-[#66628c]
                                              mb-2">

                                    Username

                                </label>

                                <div class="input-box rounded-xl
                                            flex items-center px-4">

                                    <i data-lucide="user-round"
                                       class="text-purple-800 flex-shrink-0"
                                       width="22">
                                    </i>

                                    <input
                                        type="text"
                                        name="username"
                                        value="{{ old('username') }}"
                                        placeholder="Masukkan username"
                                        required
                                        minlength="4"
                                        class="w-full px-4 py-3.5
                                               outline-none
                                               text-[#29254e]"
                                    >

                                </div>

                                <p class="text-xs text-[#8a86aa] mt-1">
                                    Gunakan minimal 4 karakter
                                </p>

                            </div>


                            <!-- PASSWORD -->

                            <div class="mb-4">

                                <label class="block text-sm
                                              font-semibold text-[#66628c]
                                              mb-2">

                                    Password

                                </label>

                                <div class="input-box rounded-xl
                                            flex items-center px-4">

                                    <i data-lucide="lock-keyhole"
                                       class="text-purple-800 flex-shrink-0"
                                       width="22">
                                    </i>

                                    <input
                                        id="password"
                                        type="password"
                                        name="password"
                                        placeholder="Masukkan password"
                                        required
                                        minlength="8"
                                        class="w-full px-4 py-3.5
                                               outline-none
                                               text-[#29254e]"
                                    >

                                    <button
                                        type="button"
                                        onclick="togglePassword('password', 'eyePassword')"
                                        class="text-purple-800">

                                        <i data-lucide="eye"
                                           id="eyePassword"
                                           width="21">
                                        </i>

                                    </button>

                                </div>

                                <p class="text-xs text-[#8a86aa] mt-1">
                                    Minimal 8 karakter dengan kombinasi huruf,
                                    angka, dan simbol
                                </p>

                            </div>


                            <!-- KONFIRMASI PASSWORD -->

                            <div class="mb-4">

                                <label class="block text-sm
                                              font-semibold text-[#66628c]
                                              mb-2">

                                    Konfirmasi Password

                                </label>

                                <div class="input-box rounded-xl
                                            flex items-center px-4">

                                    <i data-lucide="lock-keyhole"
                                       class="text-purple-800 flex-shrink-0"
                                       width="22">
                                    </i>

                                    <input
                                        id="password_confirmation"
                                        type="password"
                                        name="password_confirmation"
                                        placeholder="Ulangi password"
                                        required
                                        class="w-full px-4 py-3.5
                                               outline-none
                                               text-[#29254e]"
                                    >

                                    <button
                                        type="button"
                                        onclick="togglePassword('password_confirmation', 'eyeConfirmation')"
                                        class="text-purple-800">

                                        <i data-lucide="eye"
                                           id="eyeConfirmation"
                                           width="21">
                                        </i>

                                    </button>

                                </div>

                            </div>


                            <!-- ROLE -->

                            <div class="mb-5">

                                <label class="block text-sm
                                              font-semibold text-[#66628c]
                                              mb-2">

                                    Role

                                </label>

                                <div class="input-box rounded-xl
                                            flex items-center px-4">

                                    <i data-lucide="crown"
                                       class="text-pink-500 flex-shrink-0"
                                       width="22">
                                    </i>

                                    <select
                                        name="role"
                                        class="w-full px-4 py-3.5
                                               outline-none
                                               text-[#29254e]"
                                    >

                                        <option value="admin">
                                            Admin
                                        </option>

                                    </select>

                                    <i data-lucide="chevron-down"
                                       class="text-purple-800"
                                       width="20">
                                    </i>

                                </div>

                            </div>


                            <!-- TERMS -->

                            <div class="flex items-start gap-3 mb-6">

                                <input
                                    type="checkbox"
                                    id="terms"
                                    required
                                    class="mt-1 w-5 h-5 accent-pink-600"
                                >

                                <label
                                    for="terms"
                                    class="text-sm text-[#77739d] leading-relaxed"
                                >

                                    Saya setuju dengan

                                    <span class="text-pink-600 font-semibold">
                                        Syarat & Ketentuan
                                    </span>

                                    yang berlaku.

                                </label>

                            </div>


                            <!-- REGISTER BUTTON -->

                            <button
                                type="submit"
                                class="register-button w-full
                                       text-white py-4 rounded-full
                                       text-lg font-semibold
                                       flex items-center justify-center gap-3"
                            >

                                Daftar Sekarang

                                <i data-lucide="arrow-right"
                                   width="22">
                                </i>

                            </button>

                        </form>


                        <!-- DIVIDER -->

                        <div class="flex items-center gap-4 my-6">

                            <div class="h-px bg-gray-200 flex-1"></div>

                            <span class="text-[#9995b2] text-sm">
                                atau daftar dengan
                            </span>

                            <div class="h-px bg-gray-200 flex-1"></div>

                        </div>


                        <!-- GOOGLE -->

                        <a
                            href="{{ route('google.login') }}"
                            class="google-button w-full py-4
                                   rounded-full
                                   flex items-center justify-center
                                   gap-3 text-[#66628c]
                                   font-medium"
                        >

                            <!-- GOOGLE LOGO -->
                            <svg
                                width="22"
                                height="22"
                                viewBox="0 0 24 24"
                            >

                                <path
                                    fill="#4285F4"
                                    d="M21.35 12.27c0-.79-.07-1.55-.23-2.27H12v4.3h5.23a4.47 4.47 0 0 1-1.94 2.93v2.44h3.14c1.84-1.69 2.92-4.18 2.92-7.4z"
                                />

                                <path
                                    fill="#34A853"
                                    d="M12 21.7c2.63 0 4.84-.87 6.45-2.36l-3.14-2.44c-.87.58-1.98.92-3.31.92-2.54 0-4.69-1.72-5.46-4.03H3.29v2.52A9.75 9.75 0 0 0 12 21.7z"
                                />

                                <path
                                    fill="#FBBC05"
                                    d="M6.54 13.79a5.86 5.86 0 0 1 0-3.58V7.69H3.29a9.76 9.76 0 0 0 0 8.62l3.25-2.52z"
                                />

                                <path
                                    fill="#EA4335"
                                    d="M12 6.18c1.43 0 2.71.49 3.72 1.45l2.79-2.79C16.84 3.27 14.63 2.3 12 2.3a9.75 9.75 0 0 0-8.71 5.39l3.25 2.52C6.85 7.9 9 6.18 12 6.18z"
                                />

                            </svg>

                            Daftar dengan Google

                        </a>


                        <!-- LOGIN -->

                        <div class="text-center mt-6 text-sm">

                            <span class="text-[#8580a5]">
                                Sudah punya akun?
                            </span>

                            <a
                                href="{{ route('login') }}"
                                class="text-pink-600 font-semibold ml-1
                                       hover:underline"
                            >
                                Masuk di sini
                            </a>

                        </div>

                    </div>

                </div>

            </div>

        </div>


        <!-- FOOTER -->

        <div class="text-center mt-5 text-sm text-[#8580a5]">

            PovStudio v2.4.1
            <span class="mx-2">•</span>
            Admin Panel
            <span class="mx-2">•</span>
            Made with ♡

        </div>

    </div>


    <!-- INITIALIZE ICONS -->

    <script>
        lucide.createIcons();


        function togglePassword(inputId, iconId) {

            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);

            if (input.type === "password") {

                input.type = "text";

                icon.setAttribute("data-lucide", "eye-off");

            } else {

                input.type = "password";

                icon.setAttribute("data-lucide", "eye");

            }

            lucide.createIcons();
        }
    </script>

</body>

</html>