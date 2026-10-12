@extends('layouts.admin')

@section('title', 'Kelola Stiker - PovStudio')

@section('content')

<style>

/* =========================================================
   KELola STIKER POVSTUDIO
========================================================= */

.sticker-page {
    padding: 20px 15px 35px;
    background: #fff8fc;
    min-height: calc(100vh - 70px);
    color: #27203a;
}


/* ================= HEADER ================= */

.sticker-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 14px;
}

.sticker-title h1 {
    margin: 0;
    font-size: 25px;
    font-weight: 700;
    color: #18152a;
}

.sticker-title p {
    margin-top: 4px;
    font-size: 11px;
    color: #81758e;
}

.add-sticker {
    text-decoration: none;
    background: linear-gradient(90deg, #d01d61, #df3975);
    color: white;
    padding: 11px 21px;
    border-radius: 22px;
    font-size: 11px;
    font-weight: 600;
    box-shadow: 0 7px 18px rgba(207, 29, 97, .18);
    transition: .2s;
}

.add-sticker:hover {
    opacity: .9;
    transform: translateY(-1px);
}


/* ================= STAT CARD ================= */

.sticker-statistics {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
    margin-bottom: 12px;
}

.sticker-stat {
    background: white;
    border: 1px solid #f0e1eb;
    border-radius: 13px;
    padding: 11px;
    height: 57px;
    display: flex;
    align-items: center;
    gap: 10px;
    box-shadow: 0 3px 10px rgba(190, 85, 140, .03);
}

.stat-icon {
    width: 35px;
    height: 35px;
    border-radius: 10px;
    background: #fff0f7;
    color: #df2770;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: 18px;
    flex-shrink: 0;
}

.stat-text {
    line-height: 1.1;
}

.stat-number {
    font-size: 17px;
    font-weight: 700;
    color: #282039;
}

.stat-title {
    font-size: 8px;
    color: #72667d;
    margin-top: 2px;
}

.stat-subtitle {
    font-size: 7px;
    color: #a096a7;
    margin-top: 2px;
}


/* ================= FILTER ================= */

.filter-area {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
}

.filter-buttons {
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
}

.filter-button {
    border: 1px solid #eadde7;
    background: white;
    color: #665b72;
    border-radius: 16px;
    padding: 7px 13px;
    font-size: 9px;
    cursor: pointer;
    transition: .2s;
}

.filter-button:hover {
    border-color: #d62467;
    color: #d62467;
}

.filter-button.active {
    background: #d62467;
    color: white;
    border-color: #d62467;
}

.sort-box {
    border: 1px solid #eadde7;
    background: white;
    border-radius: 17px;
    padding: 8px 13px;
    color: #6c6075;
    font-size: 9px;
    outline: none;
    cursor: pointer;
}


/* ================= CONTENT ================= */

.sticker-content {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 160px;
    gap: 10px;
}


/* ================= STICKER GRID ================= */

.sticker-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 9px;
}


/* ================= EMPTY STATE ================= */

.sticker-empty {
    background: white;
    border: 1px dashed #ead5e2;
    border-radius: 12px;
    min-height: 330px;

    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;

    text-align: center;
}

.empty-icon {
    width: 58px;
    height: 58px;
    border-radius: 16px;

    background: #fff0f7;
    color: #d92368;

    display: flex;
    align-items: center;
    justify-content: center;

    font-size: 27px;

    margin-bottom: 12px;
}

.empty-title {
    font-size: 15px;
    font-weight: 700;
    color: #282038;
    margin-bottom: 5px;
}

.empty-text {
    font-size: 10px;
    color: #938895;
}


/* ================= DETAIL ================= */

.sticker-detail {
    background: white;
    border: 1px solid #eee1e9;
    border-radius: 12px;
    padding: 9px;
    align-self: start;
    min-height: 150px;

    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
}


/* EMPTY DETAIL */

.detail-empty {
    color: #998e9d;
    font-size: 9px;
    line-height: 1.5;
}


/* ================= DETAIL IMAGE ================= */

.detail-preview {
    width: 100%;
    height: 115px;
    border-radius: 8px;

    background-color: #fafafa;

    background-image:
        linear-gradient(45deg, #eeeeee 25%, transparent 25%),
        linear-gradient(-45deg, #eeeeee 25%, transparent 25%),
        linear-gradient(45deg, transparent 75%, #eeeeee 75%),
        linear-gradient(-45deg, transparent 75%, #eeeeee 75%);

    background-size: 14px 14px;

    background-position:
        0 0,
        0 7px,
        7px -7px,
        -7px 0px;

    display: flex;
    justify-content: center;
    align-items: center;

    position: relative;
}

.detail-emoji {
    font-size: 66px;
}


/* ================= RESPONSIVE ================= */

@media(max-width: 1100px) {

    .sticker-grid {
        grid-template-columns: repeat(3, 1fr);
    }

}


@media(max-width: 850px) {

    .sticker-statistics {
        grid-template-columns: repeat(2, 1fr);
    }

    .sticker-content {
        grid-template-columns: 1fr;
    }

    .sticker-detail {
        display: none;
    }

}


@media(max-width: 600px) {

    .sticker-grid {
        grid-template-columns: repeat(2, 1fr);
    }

    .filter-area {
        flex-direction: column;
        align-items: flex-start;
        gap: 8px;
    }

    .sort-box {
        width: 100%;
    }

}

</style>


<div class="sticker-page">


    {{-- =====================================================
         HEADER
    ====================================================== --}}

    <div class="sticker-header">

        <div class="sticker-title">

            <h1>
                Kelola Stiker
            </h1>

            <p>
                Tambah, edit, atau hapus stiker untuk digunakan di studio photobooth PovStudio.
            </p>

        </div>


        <a href="{{ route('stickers.create') }}" class="add-sticker">
            ＋ &nbsp; Tambah Stiker
        </a>

    </div>



    {{-- =====================================================
         STATISTIK
    ====================================================== --}}

    <div class="sticker-statistics">


        {{-- TOTAL STIKER --}}

        <div class="sticker-stat">

            <div class="stat-icon">
                🖼️
            </div>

            <div class="stat-text">

                    {{ $popularSticker?->nama ?? '-' }}
                    {{ $totalStickers ?? 0 }}
                </div>

                    Terpopuler
                    Total Stiker
                </div>

            </div>

        </div>



        {{-- KATEGORI --}}

        <div class="sticker-stat">

            <div class="stat-icon">
                📚
            </div>

            <div class="stat-text">

                <div class="stat-number">
                    {{ $totalCategories ?? 0 }}
                </div>

                <div class="stat-title">
                    Kategori
                </div>

            </div>

        </div>



        {{-- POPULER --}}

        <div class="sticker-stat">

            <div class="stat-icon">
                ☆
            </div>

            <div class="stat-text">

                <div class="stat-number">
                    {{ $popularSticker?->nama ?? '-' }}
                </div>

                <div class="stat-title">
                    Stiker Populer
                </div>

                <div class="stat-subtitle">
                    paling banyak digunakan
                </div>

            </div>

        </div>



        {{-- AKTIF --}}

        <div class="sticker-stat">

            <div class="stat-icon">
                🔵
            </div>

            <div class="stat-text">

                <div class="stat-number">
                    {{ $activeStickers ?? 0 }}
                </div>

                <div class="stat-title">
                    Stiker Aktif
                </div>

                <div class="stat-subtitle">
                    dari {{ $totalStickers ?? 0 }} stiker
                </div>

            </div>

        </div>

    </div>



    {{-- =====================================================
         FILTER
    ====================================================== --}}

    <div class="filter-area">


        <div class="filter-buttons">

            <button
                type="button"
                class="filter-button active"
                onclick="filterSticker(this, 'all')">
                Semua Stiker
            </button>

            <button
                type="button"
                class="filter-button"
                onclick="filterSticker(this, 'Emoji')">
                Emoji
            </button>

            <button
                type="button"
                class="filter-button"
                onclick="filterSticker(this, 'Teks')">
                Teks
            </button>

            <button
                type="button"
                class="filter-button"
                onclick="filterSticker(this, 'Karakter')">
                Karakter
            </button>

            <button
                type="button"
                class="filter-button"
                onclick="filterSticker(this, 'Dekorasi')">
                Dekorasi
            </button>

            <button
                type="button"
                class="filter-button"
                onclick="filterSticker(this, 'Event')">
                Event
            </button>

            <button
                type="button"
                class="filter-button"
                onclick="filterSticker(this, 'Seasonal')">
                Seasonal
            </button>

        </div>



        <select class="sort-box" id="sortSticker">

            <option value="newest">
                Urutkan: Terbaru
            </option>

            <option value="oldest">
                Urutkan: Terlama
            </option>

            <option value="popular">
                Urutkan: Terpopuler
            </option>

            <option value="name">
                Urutkan: Nama
            </option>

        </select>

    </div>



    {{-- =====================================================
         CONTENT
    ====================================================== --}}

    <div class="sticker-content">


        {{-- =================================================
             GRID STIKER

             KOSONG DULU
             TIDAK ADA STIKER CONTOH
        ================================================== --}}

        <div class="sticker-grid">

            <div class="sticker-empty">

                <div class="empty-icon">
                    🖼️
                </div>

                <div class="empty-title">
                    Belum ada stiker
                </div>

                <div class="empty-text">
                    Silakan tambahkan stiker pertama.
                </div>

            </div>

        </div>



        {{-- =================================================
             DETAIL KANAN
        ================================================== --}}

        <div class="sticker-detail">

            <div class="detail-empty">

                <div style="font-size: 28px; margin-bottom: 7px;">
                    😊
                </div>

                Belum ada stiker.

            </div>

        </div>


    </div>


</div>



<script>

/* =========================================================
   FILTER STIKER
========================================================= */

function filterSticker(button, category) {

    const buttons =
        document.querySelectorAll('.filter-button');

    buttons.forEach(function(item) {

        item.classList.remove('active');

    });

    button.classList.add('active');


    /*
     * Untuk sekarang data stiker masih kosong.
     *
     * Nanti setelah data dari database ditampilkan,
     * bagian filter ini bisa digunakan untuk menyaring
     * stiker berdasarkan kategori.
     */

}


/* =========================================================
   SORT STIKER
========================================================= */

document
    .getElementById('sortSticker')
    .addEventListener('change', function() {

        /*
         * Sorting akan digunakan ketika data stiker
         * dari database sudah ditampilkan.
         */

    });

</script>


@endsection