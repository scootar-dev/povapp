<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>@yield('title', 'PovStudio Admin')</title>

    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: Arial, Helvetica, sans-serif;
            background: #fff8fc;
            color: #29233d;
        }

        /* =================================
           WRAPPER
        ================================= */

        .admin-wrapper {
            display: flex;
            min-height: 100vh;
            overflow-x: hidden;
        }


        /* =================================
           SIDEBAR
        ================================= */

        .sidebar {
            width: 185px;
            min-width: 185px;
            height: 100vh;

            background: #ffffff;

            border-right: 1px solid #f0dce9;

            position: fixed;
            left: 0;
            top: 0;
            bottom: 0;

            padding: 18px 14px;

            overflow: hidden;
            z-index: 100;
        }


        /* =================================
           LOGO
        ================================= */

        .logo-area {
            padding-left: 10px;
            margin-bottom: 25px;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 7px;

            font-size: 21px;
            font-weight: 700;

            color: #d71962;
        }

        .logo-camera {
            font-size: 21px;
        }

        .logo-subtitle {
            margin-left: 25px;
            margin-top: 1px;

            font-size: 9px;
            font-weight: 700;

            letter-spacing: 2px;

            color: #9b8ca8;
        }


        /* =================================
           MENU
        ================================= */

        .menu {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .menu a {
            position: relative;

            display: flex;
            align-items: center;

            gap: 10px;

            width: 100%;

            padding: 10px 11px;

            border-radius: 11px;

            text-decoration: none;

            color: #633452;

            font-size: 12px;
            font-weight: 500;

            transition: .2s;
        }

        .menu-icon {
            width: 20px;

            text-align: center;

            font-size: 16px;
        }

        .menu a:hover {
            background: #fff0f6;
            color: #d31960;
        }

        .menu a.active {
            background: linear-gradient(
                90deg,
                #c9155b,
                #dc3474
            );

            color: white;

            box-shadow: 0 5px 12px rgba(205, 30, 99, .18);
        }


        /* =================================
           PEMBATAS
        ================================= */

        .sidebar-divider {
            width: 100%;
            height: 1px;

            background: #f1dfe9;

            margin: 16px 0;
        }


        /* =================================
           DEKORASI SIDEBAR
        ================================= */

        .sidebar-decoration {
            position: absolute;

            left: -45px;
            bottom: 105px;

            width: 210px;
            height: 230px;

            pointer-events: none;
        }

        .bubble-one {
            position: absolute;

            left: -30px;
            bottom: 65px;

            width: 145px;
            height: 105px;

            background: #f4c9e4;

            border-radius: 70px 70px 0 0;

            opacity: .75;
        }

        .bubble-two {
            position: absolute;

            left: 55px;
            bottom: 0;

            width: 125px;
            height: 100px;

            background: #efd9fa;

            border-radius: 60px 60px 0 0;

            opacity: .65;
        }

        .decor-text-one {
            position: absolute;

            left: 80px;
            bottom: 105px;

            width: 120px;

            color: #a66bea;

            font-size: 10px;

            line-height: 1.3;

            transform: rotate(-8deg);
        }

        .decor-text-two {
            position: absolute;

            left: 75px;
            bottom: 28px;

            width: 120px;

            color: #a66bea;

            font-size: 11px;

            line-height: 1.35;

            transform: rotate(-5deg);
        }

        .decor-star {
            position: absolute;

            color: #b76df2;

            font-size: 14px;
        }

        .star-one {
            left: 70px;
            bottom: 150px;
        }

        .star-two {
            left: 35px;
            bottom: 65px;
        }

        .star-three {
            left: 145px;
            bottom: 85px;
        }


        /* =================================
           LOGOUT
        ================================= */

        .logout {
            position: absolute;

            left: 14px;
            right: 14px;
            bottom: 20px;

            z-index: 5;
        }

        .logout a {
            display: flex;
            align-items: center;
            gap: 9px;

            padding: 10px 12px;

            border-radius: 12px;

            background: rgba(255,255,255,.88);

            color: #c7195c;

            text-decoration: none;

            font-size: 12px;
            font-weight: 600;

            box-shadow: 0 3px 12px rgba(190, 80, 140, .05);
        }

        .logout a:hover {
            background: #fff0f6;
        }

        .logout-icon {
            font-size: 17px;
        }


        /* =================================
           CONTENT
        ================================= */

        .content {
            margin-left: 185px;

            width: calc(100% - 185px);

            min-height: 100vh;
        }


        /* =================================
           TOPBAR
        ================================= */

        .topbar {
            height: 60px;

            background: white;

            border-bottom: 1px solid #f1e3ec;

            display: flex;

            align-items: center;

            justify-content: space-between;

            padding: 0 25px;
        }


        /* SEARCH */

        .search-wrapper {
            position: relative;
        }

        .search-icon {
            position: absolute;

            left: 13px;
            top: 50%;

            transform: translateY(-50%);

            color: #8c8294;

            font-size: 13px;
        }

        .search {
            width: 315px;

            padding: 9px 15px 9px 35px;

            border: none;

            background: #faf3fa;

            border-radius: 22px;

            outline: none;

            color: #555;
            font-size: 11px;
        }

        .search::placeholder {
            color: #a49aa8;
        }


        /* =================================
           PROFILE
        ================================= */

        .topbar-right {
            display: flex;
            align-items: center;
            gap: 17px;
        }

        .notification {
            width: 32px;
            height: 32px;

            display: flex;
            align-items: center;
            justify-content: center;

            border-radius: 50%;

            background: #fff6fa;

            color: #d52569;

            font-size: 17px;
        }

        .admin-profile {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .avatar {
            width: 35px;
            height: 35px;

            border-radius: 50%;

            background: #f4d7e8;

            display: flex;
            align-items: center;
            justify-content: center;

            font-size: 17px;
        }

        .admin-info strong {
            display: block;

            font-size: 11px;

            color: #30273d;
        }

        .admin-info small {
            display: block;

            margin-top: 2px;

            font-size: 9px;

            color: #928699;
        }

        .profile-arrow {
            margin-left: 5px;

            color: #685870;

            font-size: 11px;
        }


        /* =================================
           RESPONSIVE
        ================================= */

        @media(max-width: 1100px) {

            .sidebar {
                width: 175px;
                min-width: 175px;
            }

            .content {
                margin-left: 175px;
                width: calc(100% - 175px);
            }

            .search {
                width: 250px;
            }
        }

        @media(max-width: 800px) {

            .sidebar {
                width: 70px;
                min-width: 70px;

                padding: 15px 8px;
            }

            .content {
                margin-left: 70px;
                width: calc(100% - 70px);
            }

            .logo {
                justify-content: center;
            }

            .logo-text,
            .logo-subtitle,
            .menu-text,
            .decor-text-one,
            .decor-text-two {
                display: none;
            }

            .menu a {
                justify-content: center;
            }

            .logout a {
                justify-content: center;
            }

            .search {
                width: 200px;
            }
        }

    </style>
</head>


<body>

<div class="admin-wrapper">


    {{-- ==========================================
         SIDEBAR
    =========================================== --}}

    <aside class="sidebar">


        {{-- LOGO --}}

        <div class="logo-area">

            <div class="logo">

                <span class="logo-camera">📸</span>

                <span class="logo-text">
                    PovStudio
                </span>

            </div>

            <div class="logo-subtitle">
                ADMIN PANEL
            </div>

        </div>


        {{-- MENU --}}

        <nav class="menu">


            {{-- DASHBOARD --}}

            <a href="{{ route('dashboard') }}"
               class="{{ request()->routeIs('dashboard') ? 'active' : '' }}">

                <span class="menu-icon">⌂</span>

                <span class="menu-text">
                    Dashboard
                </span>

            </a>


            {{-- FRAME --}}

            <a href="{{ route('frames.index') }}"
               class="{{ request()->routeIs('frames.*') ? 'active' : '' }}">

                <span class="menu-icon">▦</span>

                <span class="menu-text">
                    Kelola Frame
                </span>

            </a>


            {{-- STIKER --}}

<a href="{{ route('stickers.index') }}"
   class="{{ request()->routeIs('stickers.*') ? 'active' : '' }}">

    <span class="menu-icon">☺</span>

    <span class="menu-text">
        Kelola Stiker
    </span>

</a>


            {{-- USER --}}

<a href="{{ route('users.index') }}"
   class="{{ request()->routeIs('users.*') ? 'active' : '' }}">

    <span class="menu-icon">♟</span>

    <span class="menu-text">
        Data Pengguna
    </span>

</a>


        </nav>


        {{-- PEMBATAS --}}

        <div class="sidebar-divider"></div>


        {{-- DEKORASI --}}

        <div class="sidebar-decoration">

            <div class="bubble-one"></div>

            <div class="bubble-two"></div>

            <div class="decor-text-one">
                Good Photos<br>
                Happier People ♡
            </div>

            <div class="decor-text-two">
                Let's<br>
                Create<br>
                Together! ♡
            </div>

            <span class="decor-star star-one">✦</span>
            <span class="decor-star star-two">✦</span>
            <span class="decor-star star-three">✦</span>

        </div>


        {{-- LOGOUT --}}

        <div class="logout">

           <div class="mt-auto">

    <form action="{{ route('logout') }}" method="POST">
        @csrf

        <button
            type="submit"
            class="w-full flex items-center gap-3 px-5 py-4
                   rounded-2xl bg-pink-50 text-pink-600
                   font-semibold hover:bg-pink-100 transition"
        >
            <span class="text-xl">➜</span>
            <span>Logout</span>
        </button>
    </form>

</div>

        </div>

    </aside>



    {{-- ==========================================
         MAIN CONTENT
    =========================================== --}}

    <main class="content">


        {{-- TOPBAR --}}

        <header class="topbar">


            {{-- SEARCH --}}

            <div class="search-wrapper">

                <span class="search-icon">
                    🔍
                </span>

                <input
                    type="text"
                    class="search"
                    placeholder="Cari pengguna, frame, stiker, atau foto..."
                >

            </div>


            {{-- PROFILE --}}

            <div class="topbar-right">


                <div class="notification">
                    🔔
                </div>


                <div class="admin-profile">

                    <div class="avatar">
                        👩
                    </div>


                    <div class="admin-info">

                        <strong>
                            Admin PovStudio
                        </strong>

                        <small>
                            Super Admin
                        </small>

                    </div>


                    <span class="profile-arrow">
                        ▼
                    </span>

                </div>

            </div>

        </header>


        {{-- ISI HALAMAN --}}

        @yield('content')


    </main>

</div>

</body>
</html>