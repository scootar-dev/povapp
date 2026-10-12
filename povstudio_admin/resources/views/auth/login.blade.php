
<!DOCTYPE html>

<html lang="id">

<head>

    <meta charset="UTF-8">

    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Login - PovStudio</title>

    <script src="https://cdn.tailwindcss.com"></script>

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            margin: 0;
        }

        /* BACKGROUND */
        .main-bg {
            min-height: 100vh;
            background:
                radial-gradient(circle at 15% 10%, rgba(255, 182, 218, 0.45), transparent 25%),
                radial-gradient(circle at 90% 20%, rgba(194, 173, 255, 0.30), transparent 25%),
                radial-gradient(circle at 50% 100%, rgba(255, 198, 230, 0.35), transparent 35%),
                #fff7fb;
            overflow: hidden;
        }

        /* CONTAINER */
        .main-container {
            width: 94%;
            max-width: 1450px;
            min-height: 92vh;
            margin: 4vh auto;
            background: rgba(255, 255, 255, 0.55);
            border: 1px solid rgba(255, 255, 255, 0.9);
            border-radius: 28px;
            box-shadow: 0 15px 50px rgba(116, 78, 130, 0.10);
            position: relative;
            overflow: hidden;
        }

        /* DECORATION */
        .blob {
            position: absolute;
            border-radius: 50%;
            filter: blur(1px);
            pointer-events: none;
        }

        .blob-one {
            width: 500px;
            height: 300px;
            background: rgba(255, 188, 222, 0.35);
            top: -170px;
            left: -100px;
            transform: rotate(-15deg);
        }

        .blob-two {
            width: 400px;
            height: 250px;
            background: rgba(213, 196, 255, 0.25);
            right: -150px;
            bottom: -100px;
        }

        /* TOP NAV */
        .top-nav {
            position: absolute;
            right: 35px;
            top: 30px;
            z-index: 20;
        }

        .back-link {
            color: #27144d;
            font-size: 17px;
            font-weight: 500;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 10px;
            transition: 0.2s;
        }

        .back-link:hover {
            color: #d21868;
            transform: translateX(-3px);
        }

        .back-arrow {
            font-size: 34px;
            line-height: 20px;
        }

        /* CONTENT */
        .content {
            min-height: 92vh;
            display: grid;
            grid-template-columns: 48% 52%;
            position: relative;
            z-index: 5;
        }

        /* LEFT */
        .left-section {
            padding: 38px 45px 30px 55px;
            position: relative;
        }

        /* LOGO */
        .logo-area {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo-icon {
            width: 68px;
            height: 68px;
            border-radius: 20px;
            background: linear-gradient(135deg, #ff9bd0, #8f70ff);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 35px;
            box-shadow: 0 8px 20px rgba(214, 92, 172, 0.18);
        }

        .logo-name {
            color: #cf1168;
            font-size: 38px;
            font-weight: 800;
            line-height: 1;
        }

        .logo-subtitle {
            color: #74719a;
            font-size: 18px;
            letter-spacing: 5px;
            margin-top: 6px;
        }

        /* HERO */
        .hero-title {
            margin-top: 55px;
            font-size: 48px;
            line-height: 0.98;
            color: #10153e;
            font-weight: 800;
            max-width: 430px;
        }

        .hero-description {
            margin-top: 20px;
            color: #7d7ba8;
            font-size: 18px;
            line-height: 1.5;
            max-width: 430px;
        }

        /* POLAROID AREA */
        .photo-area {
            position: relative;
            height: 530px;
            margin-top: 20px;
        }

        .polaroid {
            position: absolute;
            background: white;
            padding: 12px 12px 35px;
            border-radius: 5px;
            box-shadow: 0 12px 30px rgba(65, 38, 83, 0.16);
            width: 210px;
        }

        .polaroid img {
            width: 100%;
            height: 210px;
            object-fit: cover;
            display: block;
        }

        .polaroid-one {
            left: 0;
            top: 10px;
            transform: rotate(-10deg);
        }

        .polaroid-two {
            left: 180px;
            top: 170px;
            transform: rotate(7deg);
        }

        .polaroid-three {
            left: 315px;
            top: 310px;
            transform: rotate(12deg);
        }

        .photo-text {
            position: absolute;
            left: 220px;
            top: 35px;
            color: #ff63b7;
            font-family: cursive;
            font-size: 23px;
            line-height: 1.15;
            transform: rotate(-7deg);
            z-index: 4;
        }

        .heart {
            color: #ff5eae;
            font-size: 50px;
            position: absolute;
            z-index: 8;
        }

        .heart-one {
            right: 25px;
            top: 0;
            transform: rotate(-12deg);
        }

        .heart-two {
            left: 165px;
            bottom: 60px;
            font-size: 35px;
        }

        .sparkle {
            position: absolute;
            color: #a77bff;
            font-size: 34px;
        }

        .sparkle-one {
            right: 70px;
            top: 120px;
        }

        .sparkle-two {
            left: 20px;
            bottom: 40px;
        }

        /* RIGHT */
        .right-section {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 90px 50px 50px;
        }

        /* LOGIN CARD */
        .login-card {
            width: 100%;
            max-width: 560px;
            background: rgba(255, 255, 255, 0.88);
            border-radius: 28px;
            padding: 40px 45px 42px;
            box-shadow: 0 18px 45px rgba(89, 55, 105, 0.10);
            border: 1px solid rgba(255, 255, 255, 0.95);
        }

        /* LOGIN LOGO */
        .login-logo {
            text-align: center;
            margin-bottom: 25px;
        }

        .login-logo-icon {
            width: 105px;
            height: 105px;
            margin: auto;
            border-radius: 28px;
            background: linear-gradient(135deg, #fff, #fff5fb);
            box-shadow: 0 8px 25px rgba(100, 55, 120, 0.10);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 55px;
        }

        .login-logo-name {
            color: #cf1168;
            font-size: 38px;
            font-weight: 800;
            margin-top: 10px;
        }

        .login-logo-subtitle {
            color: #74719a;
            font-size: 17px;
            letter-spacing: 5px;
        }

        .login-title {
            text-align: center;
            color: #11153f;
            font-size: 31px;
            font-weight: 800;
            margin-top: 28px;
        }

        .login-description {
            text-align: center;
            color: #8886a8;
            font-size: 16px;
            margin-top: 8px;
            margin-bottom: 30px;
        }

        /* LABEL */
        .form-label {
            display: block;
            color: #535276;
            font-size: 16px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        /* INPUT */
        .input-wrapper {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 18px;
            top: 50%;
            transform: translateY(-50%);
            color: #7d5a91;
            font-size: 22px;
        }

        .form-input {
            width: 100%;
            height: 58px;
            border-radius: 15px;
            border: 1px solid #e3ddec;
            background: #faf8fc;
            padding: 0 18px 0 52px;
            font-size: 16px;
            color: #393650;
            outline: none;
            transition: 0.2s;
        }

        .form-input:focus {
            border-color: #ec74b0;
            box-shadow: 0 0 0 4px rgba(236, 116, 176, 0.12);
            background: white;
        }

        /* OPTIONS */
        .options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 15px 0 24px;
        }

        .remember {
            display: flex;
            align-items: center;
            gap: 9px;
            color: #777592;
            font-size: 15px;
        }

        .remember input {
            width: 20px;
            height: 20px;
            accent-color: #d9166a;
        }

        .forgot {
            color: #dc176c;
            text-decoration: none;
            font-weight: 600;
        }

        .forgot:hover {
            text-decoration: underline;
        }

        /* LOGIN BUTTON */
        .login-button {
            width: 100%;
            height: 62px;
            border: none;
            border-radius: 32px;
            background: linear-gradient(90deg, #d81467, #d52a72);
            color: white;
            font-size: 18px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 8px 20px rgba(210, 20, 103, 0.20);
            transition: 0.2s;
        }

        .login-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 25px rgba(210, 20, 103, 0.25);
        }

        /* REGISTER */
        .register {
            text-align: center;
            margin-top: 28px;
            color: #777592;
            font-size: 15px;
        }

        .register a {
            color: #dc176c;
            font-weight: 700;
            text-decoration: none;
            margin-left: 5px;
        }

        .register a:hover {
            text-decoration: underline;
        }

        /* ERROR */
        .error-box {
            background: #fff0f3;
            border: 1px solid #ffc9d7;
            color: #d52b5f;
            border-radius: 15px;
            padding: 12px 15px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        /* FOOTER */
        .footer {
            position: absolute;
            bottom: 22px;
            left: 55px;
            color: #8b89a7;
            font-size: 14px;
            z-index: 10;
        }

        /* RESPONSIVE */
        @media (max-width: 1000px) {

            .main-container {
                margin: 20px;
                width: calc(100% - 40px);
            }

            .content {
                grid-template-columns: 1fr;
            }

            .left-section {
                display: none;
            }

            .right-section {
                min-height: 90vh;
                padding: 70px 25px 40px;
            }

            .top-nav {
                right: 25px;
            }

            .footer {
                display: none;
            }
        }

        @media (max-width: 550px) {

            .login-card {
                padding: 30px 22px;
            }

            .login-title {
                font-size: 26px;
            }

            .login-logo-name {
                font-size: 32px;
            }

            .login-logo-icon {
                width: 85px;
                height: 85px;
            }

            .right-section {
                padding: 65px 12px 30px;
            }
        }

    </style>

</head>

<body>

<div class="main-bg">

    <div class="main-container">

        <!-- DECORATIVE BACKGROUND -->
        <div class="blob blob-one"></div>
        <div class="blob blob-two"></div>


        <!-- KEMBALI -->
        <div class="top-nav">
            <a href="{{ url('/') }}" class="back-link">
                <span class="back-arrow">←</span>
                <span>Kembali ke Beranda</span>
            </a>
        </div>


        <div class="content">

            <!-- ================================================= -->
            <!-- BAGIAN KIRI -->
            <!-- ================================================= -->

            <div class="left-section">

                <!-- LOGO -->
                <div class="logo-area">

                    <div class="logo-icon">
                        📸
                    </div>

                    <div>
                        <div class="logo-name">
                            PovStudio
                        </div>

                        <div class="logo-subtitle">
                            ADMIN PANEL
                        </div>
                    </div>

                </div>


                <!-- HERO -->
                <h1 class="hero-title">
                    Good<br>
                    Photos<br>
                    Happier People
                </h1>


                <p class="hero-description">
                    Kelola studio photobooth PovStudio
                    dengan mudah, cepat, dan menyenangkan.
                </p>


                <!-- FOTO POLAROID -->
                <div class="photo-area">

                    <!-- FOTO 1 -->
                    <div class="polaroid polaroid-one">

                        <img
                            src="https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=500&q=80"
                            alt="PovStudio Photo"
                        >

                    </div>


                    <!-- FOTO 2 -->
                    <div class="polaroid polaroid-two">

                        <img
                            src="https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=500&q=80"
                            alt="PovStudio Photo"
                        >

                    </div>


                    <!-- FOTO 3 -->
                    <div class="polaroid polaroid-three">

                        <img
                            src="https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=500&q=80"
                            alt="PovStudio Photo"
                        >

                    </div>


                    <!-- TEKS DEKORASI -->
                    <div class="photo-text">
                        Capture<br>
                        Create<br>
                        Happiest<br>
                        Moments<br>
                        Together! ♥
                    </div>


                    <div class="heart heart-one">
                        ♡
                    </div>

                    <div class="heart heart-two">
                        ♥
                    </div>

                    <div class="sparkle sparkle-one">
                        ✦
                    </div>

                    <div class="sparkle sparkle-two">
                        ✦
                    </div>

                </div>

            </div>


            <!-- ================================================= -->
            <!-- BAGIAN KANAN -->
            <!-- ================================================= -->

            <div class="right-section">

                <div class="login-card">


                    <!-- LOGO LOGIN -->
                    <div class="login-logo">

                        <div class="login-logo-icon">
                            📸
                        </div>

                        <div class="login-logo-name">
                            PovStudio
                        </div>

                        <div class="login-logo-subtitle">
                            ADMIN PANEL
                        </div>

                    </div>


                    <!-- JUDUL -->
                    <h2 class="login-title">
                        Masuk ke Akun Admin
                    </h2>

                    <p class="login-description">
                        Silakan masukkan email/username dan password
                        untuk melanjutkan ke dashboard.
                    </p>


                    <!-- ERROR -->
                    @if ($errors->any())

                        <div class="error-box">

                            @foreach ($errors->all() as $error)

                                <p>{{ $error }}</p>

                            @endforeach

                        </div>

                    @endif


                    <!-- FORM -->
                    <form action="{{ route('login.process') }}" method="POST">

                        @csrf


                        <!-- EMAIL / USERNAME -->
                        <div class="mb-5">

                            <label class="form-label">
                                Email atau Username
                            </label>

                            <div class="input-wrapper">

                                <span class="input-icon">
                                    ✉
                                </span>

                                <input
                                    type="text"
                                    name="login"
                                    value="{{ old('login') }}"
                                    placeholder="Masukkan email atau username"
                                    required
                                    class="form-input"
                                >

                            </div>

                        </div>


                        <!-- PASSWORD -->
                        <div>

                            <label class="form-label">
                                Password
                            </label>

                            <div class="input-wrapper">

                                <span class="input-icon">
                                    🔒
                                </span>

                                <input
                                    id="password"
                                    type="password"
                                    name="password"
                                    placeholder="Masukkan password"
                                    required
                                    class="form-input"
                                >

                                <button
                                    type="button"
                                    onclick="togglePassword()"
                                    style="
                                        position:absolute;
                                        right:18px;
                                        top:50%;
                                        transform:translateY(-50%);
                                        border:none;
                                        background:none;
                                        cursor:pointer;
                                        font-size:20px;
                                    "
                                >
                                    👁
                                </button>

                            </div>

                        </div>


                        <!-- REMEMBER + FORGOT -->
                        <div class="options">

                            <label class="remember">

                                <input
                                    type="checkbox"
                                    name="remember"
                                >

                                <span>
                                    Ingat saya
                                </span>

                            </label>


                            <a
                                href="#"
                                class="forgot"
                            >
                                Lupa password?
                            </a>

                        </div>


                        <!-- LOGIN -->
                        <button
                            type="submit"
                            class="login-button"
                        >
                            Masuk ke Dashboard
                            <span style="font-size:25px; margin-left:8px;">
                                →
                            </span>
                        </button>


                    </form>


                    <!-- REGISTER -->
                    <div class="register">

                        Belum punya akun admin?

                        <a href="{{ route('register') }}">
                            Daftar sekarang
                        </a>

                    </div>

                </div>

            </div>

        </div>


        <!-- FOOTER -->
        <div class="footer">

            PovStudio v2.4.1
            <span style="margin: 0 10px;">•</span>
            Admin Panel
            <span style="margin: 0 10px;">•</span>
            Made with ♡

        </div>

    </div>

</div>


<!-- PASSWORD TOGGLE -->
<script>

    function togglePassword() {

        const password = document.getElementById('password');

        if (password.type === 'password') {

            password.type = 'text';

        } else {

            password.type = 'password';

        }

    }

</script>

</body>

</html>
