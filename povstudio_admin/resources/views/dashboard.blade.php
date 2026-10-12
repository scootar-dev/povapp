@extends('layouts.admin')

@section('title', 'Dashboard - PovStudio')

@section('content')

<style>
    .dashboard-page {
        padding: 28px 30px 40px;
    }

    /* =========================
       WELCOME BANNER
    ========================= */

    .welcome-banner {
        background: linear-gradient(100deg, #fde8f3, #f4e8ff);
        border-radius: 18px;
        padding: 22px 28px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 18px;
        min-height: 115px;
        overflow: hidden;
    }

    .welcome-text h1 {
        font-size: 28px;
        margin-bottom: 6px;
        color: #211b35;
    }

    .welcome-text p {
        color: #71677f;
        font-size: 13px;
        margin-bottom: 4px;
    }

    .welcome-decoration {
        text-align: center;
        color: #ed5eaa;
        font-size: 14px;
        font-weight: bold;
        font-style: italic;
        line-height: 1.3;
        margin-right: 20px;
    }

    /* =========================
       STAT CARD
    ========================= */

    .dashboard-stats {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 12px;
        margin-bottom: 18px;
    }

    .dashboard-stat {
        background: white;
        border: 1px solid #f2e4ed;
        border-radius: 15px;
        padding: 15px;
        min-height: 88px;
        box-shadow: 0 3px 12px rgba(180, 100, 150, .05);
    }

    .stat-top {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .stat-icon {
        width: 35px;
        height: 35px;
        border-radius: 10px;
        background: #fff0f7;
        display: flex;
        align-items: center;
        justify-content: center;
        color: #e72b76;
        font-size: 17px;
    }

    .dashboard-stat small {
        color: #746a82;
        font-size: 11px;
    }

    .dashboard-stat h2 {
        margin-top: 5px;
        font-size: 21px;
        color: #201a34;
    }

    .stat-change {
        color: #32a76d;
        font-size: 10px;
        margin-left: 7px;
    }

    /* =========================
       DASHBOARD GRID
    ========================= */

    .dashboard-grid {
        display: grid;
        grid-template-columns: 1.55fr 1fr;
        gap: 15px;
        margin-bottom: 15px;
    }

    .dashboard-card {
        background: white;
        border: 1px solid #f0e2eb;
        border-radius: 15px;
        padding: 16px;
        box-shadow: 0 3px 12px rgba(180, 100, 150, .04);
    }

    .dashboard-card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
    }

    .dashboard-card-title {
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: bold;
        font-size: 13px;
    }

    .title-icon {
        width: 28px;
        height: 28px;
        border-radius: 8px;
        background: #fff0f7;
        color: #df2671;
        display: flex;
        justify-content: center;
        align-items: center;
    }

    .period {
        display: flex;
        gap: 5px;
    }

    .period span {
        padding: 7px 10px;
        border-radius: 10px;
        background: #faf5fa;
        color: #8a7f94;
        font-size: 10px;
    }

    .period .active {
        background: #d52a68;
        color: white;
    }

    /* =========================
       BAR CHART
    ========================= */

    .chart {
        height: 150px;
        display: flex;
        align-items: flex-end;
        justify-content: space-around;
        padding: 10px 5px 0;
        border-bottom: 1px solid #eee5ec;
        position: relative;
    }

    .bar-wrapper {
        height: 100%;
        width: 9%;
        display: flex;
        flex-direction: column;
        justify-content: flex-end;
        align-items: center;
        gap: 7px;
    }

    .bar {
        width: 100%;
        max-width: 32px;
        background: linear-gradient(to top, #efa1c9, #f6c4dc);
        border-radius: 7px 7px 0 0;
    }

    .bar.highlight {
        background: linear-gradient(to top, #8d6be8, #b79bf4);
    }

    .bar-label {
        font-size: 9px;
        color: #8f8498;
    }

    /* =========================
       DONUT
    ========================= */

    .favorite-content {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 22px;
        min-height: 165px;
    }

    .donut {
        width: 125px;
        height: 125px;
        border-radius: 50%;
        background:
            conic-gradient(
                #f16ba9 0 48%,
                #8b61e8 48% 70%,
                #73a8ed 70% 84%,
                #82b9ef 84% 94%,
                #b7bce0 94% 100%
            );
        display: flex;
        justify-content: center;
        align-items: center;
    }

    .donut-center {
        width: 72px;
        height: 72px;
        background: white;
        border-radius: 50%;
        display: flex;
        justify-content: center;
        align-items: center;
        flex-direction: column;
    }

    .donut-center strong {
        font-size: 16px;
    }

    .donut-center span {
        font-size: 9px;
        color: #888;
    }

    .legend {
        display: flex;
        flex-direction: column;
        gap: 9px;
    }

    .legend-item {
        display: flex;
        align-items: center;
        gap: 7px;
        font-size: 10px;
        color: #665b73;
    }

    .legend-dot {
        width: 9px;
        height: 9px;
        border-radius: 50%;
        background: #ef6cab;
    }

    .legend-percent {
        margin-left: auto;
        font-weight: bold;
        color: #55466e;
    }

    /* =========================
       BOTTOM
    ========================= */

    .bottom-grid {
        display: grid;
        grid-template-columns: .9fr 1.1fr;
        gap: 15px;
    }

    /* AKTIVITAS */

    .activity-list {
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .activity {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .activity-avatar {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: #f6d8e8;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 14px;
    }

    .activity-info {
        flex: 1;
    }

    .activity-info strong {
        display: block;
        font-size: 10px;
        color: #383044;
    }

    .activity-info span {
        display: block;
        font-size: 9px;
        color: #9a8fa1;
        margin-top: 2px;
    }

    .activity-time {
        font-size: 9px;
        color: #a095a5;
    }

    .see-all {
        color: #d72869;
        font-size: 10px;
        text-decoration: none;
    }

    /* FRAME TERBARU */

    .recent-frames {
        display: grid;
        grid-template-columns: repeat(5, 1fr);
        gap: 9px;
    }

    .recent-frame {
        text-align: center;
    }

    .recent-frame-image {
        width: 100%;
        height: 95px;
        background: #faf6f9;
        border-radius: 9px;
        object-fit: contain;
        border: 1px solid #f1e6ed;
    }

    .recent-frame strong {
        display: block;
        margin-top: 6px;
        font-size: 9px;
        color: #403649;
    }

    .recent-frame span {
        font-size: 8px;
        color: #9a8fa1;
    }

    /* RESPONSIVE */

    @media(max-width: 1200px) {
        .dashboard-stats {
            grid-template-columns: repeat(3, 1fr);
        }

        .recent-frames {
            grid-template-columns: repeat(3, 1fr);
        }
    }

    @media(max-width: 900px) {
        .dashboard-grid,
        .bottom-grid {
            grid-template-columns: 1fr;
        }

        .dashboard-stats {
            grid-template-columns: repeat(2, 1fr);
        }
    }
</style>


<div class="dashboard-page">

    {{-- =========================
         WELCOME
    ========================== --}}

    <div class="welcome-banner">

        <div class="welcome-text">
            <h1>Halo, Admin! 👋</h1>

            <p>
                Kelola studio photobooth PovStudio dengan mudah.
            </p>

            <p>
                Buat pengalaman foto yang lebih seru untuk semua pengguna!
            </p>
        </div>

        <div class="welcome-decoration">
            Capture<br>
            Create<br>
            Happiest Moments<br>
            Together! ♡
        </div>

    </div>


    {{-- =========================
         STATISTIK
    ========================== --}}

    <div class="dashboard-stats">

        <div class="dashboard-stat">
            <div class="stat-top">
                <div class="stat-icon">📷</div>
                <small>Total Foto Hari Ini</small>
            </div>

            <h2>1,420 <span class="stat-change">↑ 12%</span></h2>
        </div>


        <div class="dashboard-stat">
            <div class="stat-top">
                <div class="stat-icon">👤</div>
                <small>Total Pengguna</small>
            </div>

            <h2>892 <span class="stat-change">↑ 8%</span></h2>
        </div>


        <div class="dashboard-stat">
            <div class="stat-top">
                <div class="stat-icon">▦</div>
                <small>Total Frame</small>
            </div>

            <h2>{{ $totalFrames ?? 0 }} <span class="stat-change">↑ 2</span></h2>
        </div>


        <div class="dashboard-stat">
            <div class="stat-top">
                <div class="stat-icon">☺</div>
                <small>Total Stiker</small>
            </div>

            <h2>125 <span class="stat-change">↑ 5</span></h2>
        </div>


        <div class="dashboard-stat">
            <div class="stat-top">
                <div class="stat-icon">⭐</div>
                <small>Frame Aktif</small>
            </div>

            <h2>{{ $activeFrames ?? 0 }}</h2>
        </div>

    </div>


    {{-- =========================
         CHART + FAVORIT
    ========================== --}}

    <div class="dashboard-grid">

        {{-- Statistik Penggunaan --}}

        <div class="dashboard-card">

            <div class="dashboard-card-header">

                <div class="dashboard-card-title">
                    <div class="title-icon">▥</div>
                    Statistik Penggunaan
                </div>

                <div class="period">
                    <span class="active">7 Hari</span>
                    <span>30 Hari</span>
                    <span>12 Bulan</span>
                </div>

            </div>


            <div class="chart">

                <div class="bar-wrapper">
                    <div class="bar" style="height:45%;"></div>
                    <span class="bar-label">10 Feb</span>
                </div>

                <div class="bar-wrapper">
                    <div class="bar" style="height:58%;"></div>
                    <span class="bar-label">11 Feb</span>
                </div>

                <div class="bar-wrapper">
                    <div class="bar" style="height:67%;"></div>
                    <span class="bar-label">12 Feb</span>
                </div>

                <div class="bar-wrapper">
                    <div class="bar" style="height:52%;"></div>
                    <span class="bar-label">13 Feb</span>
                </div>

                <div class="bar-wrapper">
                    <div class="bar" style="height:76%;"></div>
                    <span class="bar-label">14 Feb</span>
                </div>

                <div class="bar-wrapper">
                    <div class="bar" style="height:60%;"></div>
                    <span class="bar-label">15 Feb</span>
                </div>

                <div class="bar-wrapper">
                    <div class="bar highlight" style="height:88%;"></div>
                    <span class="bar-label">16 Feb</span>
                </div>

            </div>

        </div>


        {{-- Mode Foto Favorit --}}

        <div class="dashboard-card">

            <div class="dashboard-card-header">

                <div class="dashboard-card-title">
                    <div class="title-icon">◕</div>
                    Mode Foto Favorit
                </div>

            </div>


            <div class="favorite-content">

                <div class="donut">

                    <div class="donut-center">
                        <strong>1,420</strong>
                        <span>Total</span>
                    </div>

                </div>


                <div class="legend">

                    <div class="legend-item">
                        <span class="legend-dot"></span>
                        4-Cut
                        <span class="legend-percent">48%</span>
                    </div>

                    <div class="legend-item">
                        <span class="legend-dot"></span>
                        2-Cut
                        <span class="legend-percent">22%</span>
                    </div>

                    <div class="legend-item">
                        <span class="legend-dot"></span>
                        6-Grid
                        <span class="legend-percent">14%</span>
                    </div>

                    <div class="legend-item">
                        <span class="legend-dot"></span>
                        Polaroid
                        <span class="legend-percent">10%</span>
                    </div>

                    <div class="legend-item">
                        <span class="legend-dot"></span>
                        Lainnya
                        <span class="legend-percent">6%</span>
                    </div>

                </div>

            </div>

        </div>

    </div>


    {{-- =========================
         AKTIVITAS + FRAME
    ========================== --}}

    <div class="bottom-grid">


        {{-- Aktivitas Terbaru --}}

        <div class="dashboard-card">

            <div class="dashboard-card-header">

                <div class="dashboard-card-title">
                    <div class="title-icon">◷</div>
                    Aktivitas Terbaru
                </div>

                <a href="#" class="see-all">
                    Lihat Semua
                </a>

            </div>


            <div class="activity-list">

                <div class="activity">
                    <div class="activity-avatar">👩</div>

                    <div class="activity-info">
                        <strong>Luna putri</strong>
                        <span>Mengambil foto booth 08 (4-Cut)</span>
                    </div>

                    <div class="activity-time">
                        2 menit yang lalu
                    </div>
                </div>


                <div class="activity">
                    <div class="activity-avatar">👩</div>

                    <div class="activity-info">
                        <strong>Rizky Aditya</strong>
                        <span>Menggunakan frame Retro Y2K</span>
                    </div>

                    <div class="activity-time">
                        5 menit yang lalu
                    </div>
                </div>


                <div class="activity">
                    <div class="activity-avatar">👩</div>

                    <div class="activity-info">
                        <strong>Nabila Sari</strong>
                        <span>Mendaftar sebagai pengguna baru</span>
                    </div>

                    <div class="activity-time">
                        12 menit yang lalu
                    </div>
                </div>


                <div class="activity">
                    <div class="activity-avatar">👨</div>

                    <div class="activity-info">
                        <strong>Dimas Pratama</strong>
                        <span>Mengambil foto booth 03 (Polaroid)</span>
                    </div>

                    <div class="activity-time">
                        18 menit yang lalu
                    </div>
                </div>

            </div>

        </div>


        {{-- Frame Terbaru --}}

        <div class="dashboard-card">

            <div class="dashboard-card-header">

                <div class="dashboard-card-title">
                    <div class="title-icon">▦</div>
                    Frame Terbaru
                </div>

                <a href="{{ route('frames.index') }}" class="see-all">
                    Lihat Semua
                </a>

            </div>


            <div class="recent-frames">

                @forelse(($recentFrames ?? []) as $frame)

                    <div class="recent-frame">

                        @if($frame->gambar)

                            <img
                                src="{{ asset('storage/' . $frame->gambar) }}"
                                class="recent-frame-image"
                                alt="{{ $frame->nama }}"
                            >

                        @else

                            <div class="recent-frame-image"></div>

                        @endif

                        <strong>{{ $frame->nama }}</strong>

                        <span>
                            {{ $frame->created_at?->format('d M Y') }}
                        </span>

                    </div>

                @empty

                    <div style="grid-column:1/-1;text-align:center;padding:35px;color:#999;font-size:12px;">
                        Belum ada frame terbaru.
                    </div>

                @endforelse

            </div>

        </div>

    </div>

</div>

@endsection