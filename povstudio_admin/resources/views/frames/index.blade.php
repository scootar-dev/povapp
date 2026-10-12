@extends('layouts.admin')

@section('title', 'Kelola Frame - PovStudio')

@section('content')

<style>

* {
    box-sizing: border-box;
}

/* =========================================
   HALAMAN
========================================= */

.frame-page {
    padding: 20px 16px 30px;
    background: #fff8fc;
    min-height: calc(100vh - 72px);
}


/* =========================================
   HEADER
========================================= */

.frame-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 17px;
}

.frame-header-left h1 {
    margin: 0;
    font-size: 27px;
    line-height: 1.1;
    color: #171326;
    font-weight: 700;
}

.frame-header-left p {
    margin: 5px 0 0;
    color: #8c8198;
    font-size: 12px;
}

.btn-add-frame {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 7px;

    min-width: 151px;
    height: 38px;

    background: linear-gradient(
        90deg,
        #c91e61,
        #df3976
    );

    color: white;
    text-decoration: none;

    border-radius: 22px;

    font-size: 11px;
    font-weight: 700;

    box-shadow:
        0 6px 16px rgba(210, 35, 100, .18);

    transition: .2s;
}

.btn-add-frame:hover {
    transform: translateY(-2px);
}


/* =========================================
   STATISTIC
========================================= */

.frame-stats {
    display: grid;
    grid-template-columns:
        repeat(4, minmax(0, 1fr));

    gap: 12px;

    margin-bottom: 14px;
}

.frame-stat {
    background: white;

    border: 1px solid #f1e3eb;

    border-radius: 13px;

    min-height: 76px;

    padding: 12px 14px;

    box-shadow:
        0 3px 12px rgba(180, 100, 150, .04);
}

.frame-stat-top {
    display: flex;
    align-items: center;
    gap: 9px;
}

.frame-stat-icon {
    width: 32px;
    height: 32px;

    flex-shrink: 0;

    border-radius: 9px;

    background: #fff0f7;

    color: #df286f;

    display: flex;
    align-items: center;
    justify-content: center;

    font-size: 15px;
}

.frame-stat small {
    color: #777080;
    font-size: 10px;
}

.frame-stat h2 {
    margin: 4px 0 0 41px;

    color: #211a34;

    font-size: 21px;
    line-height: 1;
}


/* =========================================
   FILTER
========================================= */

.frame-filter {
    display: flex;
    align-items: center;
    justify-content: space-between;

    margin-bottom: 12px;

    gap: 10px;
}

.category-filter {
    display: flex;
    align-items: center;

    gap: 6px;

    flex-wrap: wrap;
}

.filter-btn {
    border: 1px solid #eee5ed;

    background: white;

    color: #62576d;

    padding: 7px 13px;

    border-radius: 18px;

    font-family: inherit;
    font-size: 10px;

    cursor: pointer;

    transition: .2s;
}

.filter-btn:hover {
    border-color: #d52969;
    color: #d52969;
}

.filter-btn.active {
    background: #d52969;

    border-color: #d52969;

    color: white;
}

.sort-box {
    height: 30px;

    padding: 0 12px;

    background: white;

    border: 1px solid #eee5ed;

    border-radius: 18px;

    color: #665b70;

    font-family: inherit;
    font-size: 10px;

    outline: none;

    cursor: pointer;
}


/* =========================================
   CONTENT
========================================= */

.frame-content {
    display: grid;

    grid-template-columns:
        minmax(0, 1fr)
        220px;

    gap: 12px;

    align-items: start;
}


/* =========================================
   FRAME GRID
========================================= */

.frame-grid {
    display: grid;

    grid-template-columns:
        repeat(4, minmax(0, 1fr));

    gap: 11px;

    min-width: 0;
}

.frame-card {
    background: white;

    border: 1px solid #eee4eb;

    border-radius: 13px;

    padding: 8px;

    cursor: pointer;

    box-shadow:
        0 3px 12px rgba(180, 100, 150, .035);

    transition: .2s;
}

.frame-card:hover {
    transform: translateY(-2px);

    box-shadow:
        0 7px 18px rgba(180, 100, 150, .10);
}

.frame-card.selected {
    border: 2px solid #e22d72;

    padding: 7px;
}


/* =========================================
   FRAME IMAGE
========================================= */

.frame-image-box {
    width: 100%;
    height: 125px;

    background: #faf7fa;

    border-radius: 9px;

    overflow: hidden;

    display: flex;
    align-items: center;
    justify-content: center;
}

.frame-image {
    width: 100%;
    height: 100%;

    object-fit: contain;
}

.no-image {
    color: #aaa;
    font-size: 10px;
}


/* =========================================
   FRAME INFO
========================================= */

.frame-info {
    padding: 7px 3px 2px;
}

.frame-name {
    color: #282136;

    font-size: 11px;
    font-weight: 700;

    margin-bottom: 5px;

    white-space: nowrap;

    overflow: hidden;

    text-overflow: ellipsis;
}

.frame-meta {
    display: flex;

    align-items: center;
    justify-content: space-between;

    gap: 4px;
}

.frame-category {
    display: inline-block;

    padding: 3px 7px;

    background: #f2eaff;

    color: #8c60db;

    border-radius: 10px;

    font-size: 8px;
}

.frame-usage {
    color: #9a8fa2;

    font-size: 8px;
}

.frame-bottom {
    display: flex;

    align-items: center;
    justify-content: space-between;

    margin-top: 7px;
}


/* =========================================
   TOGGLE
========================================= */

.toggle {
    width: 28px;
    height: 15px;

    position: relative;

    border-radius: 20px;

    background: #d62b69;
}

.toggle::after {
    content: "";

    position: absolute;

    width: 11px;
    height: 11px;

    top: 2px;
    right: 2px;

    border-radius: 50%;

    background: white;
}

.toggle.off {
    background: #d9d3d8;
}

.toggle.off::after {
    right: auto;
    left: 2px;
}

.dots {
    color: #655a70;

    font-size: 16px;

    line-height: 10px;
}


/* =========================================
   DETAIL
========================================= */

.frame-detail {
    width: 220px;

    background: white;

    border: 1px solid #eee3eb;

    border-radius: 14px;

    padding: 10px;

    position: sticky;

    top: 15px;

    box-shadow:
        0 3px 12px rgba(180, 100, 150, .035);
}

.detail-image-box {
    width: 100%;
    height: 190px;

    background: #faf7fa;

    border-radius: 10px;

    overflow: hidden;

    display: flex;
    align-items: center;
    justify-content: center;

    margin-bottom: 10px;
}

.detail-image {
    width: 100%;
    height: 100%;

    object-fit: contain;
}


/* =========================================
   DETAIL TITLE
========================================= */

.detail-title-row {
    display: flex;

    align-items: center;
    justify-content: space-between;

    gap: 5px;

    margin-bottom: 12px;
}

.detail-title {
    color: #292238;

    font-size: 14px;

    font-weight: 700;

    white-space: nowrap;

    overflow: hidden;

    text-overflow: ellipsis;
}

.active-badge {
    background: #dff8e9;

    color: #28a565;

    padding: 4px 8px;

    border-radius: 9px;

    font-size: 8px;

    flex-shrink: 0;
}

.inactive-badge {
    background: #eeeeee;

    color: #888;

    padding: 4px 8px;

    border-radius: 9px;

    font-size: 8px;

    flex-shrink: 0;
}


/* =========================================
   DETAIL INFO
========================================= */

.detail-info {
    display: flex;

    flex-direction: column;

    gap: 9px;

    margin-bottom: 15px;
}

.detail-row {
    display: flex;

    align-items: center;

    gap: 7px;

    font-size: 9px;
}

.detail-icon {
    width: 18px;

    color: #7566a0;

    text-align: center;

    flex-shrink: 0;
}

.detail-label {
    color: #9a8fa1;

    flex: 1;
}

.detail-value {
    color: #70657c;

    text-align: right;

    white-space: nowrap;
}


/* =========================================
   BUTTON DETAIL
========================================= */

.btn-edit {
    width: 100%;

    display: block;

    text-align: center;

    text-decoration: none;

    background: #d62b69;

    color: white;

    padding: 9px;

    border-radius: 18px;

    font-size: 10px;

    font-weight: 700;

    margin-bottom: 7px;

    transition: .2s;
}

.btn-edit:hover {
    background: #c4215c;
}

.btn-delete {
    width: 100%;

    border: none;

    background: #fde5ee;

    color: #df2768;

    padding: 9px;

    border-radius: 18px;

    font-size: 10px;

    font-weight: 700;

    cursor: pointer;

    transition: .2s;
}

.btn-delete:hover {
    background: #fbd4e2;
}


/* =========================================
   EMPTY
========================================= */

.empty-frame {
    grid-column: 1 / -1;

    min-height: 330px;

    background: white;

    border: 1px dashed #e5d4df;

    border-radius: 15px;

    display: flex;

    flex-direction: column;

    align-items: center;

    justify-content: center;

    text-align: center;
}

.empty-frame-icon {
    font-size: 40px;

    margin-bottom: 10px;
}

.empty-frame h3 {
    color: #332943;

    font-size: 15px;

    margin: 0 0 5px;
}

.empty-frame p {
    color: #999;

    font-size: 11px;

    margin: 0;
}


/* =========================================
   FILTER EMPTY
========================================= */

.filter-empty {
    display: none;

    grid-column: 1 / -1;

    min-height: 250px;

    background: white;

    border: 1px dashed #e5d4df;

    border-radius: 15px;

    align-items: center;

    justify-content: center;

    flex-direction: column;

    text-align: center;
}

.filter-empty.show {
    display: flex;
}


/* =========================================
   RESPONSIVE
========================================= */

@media(max-width: 1250px) {

    .frame-grid {
        grid-template-columns:
            repeat(3, minmax(0, 1fr));
    }

}

@media(max-width: 1050px) {

    .frame-content {
        grid-template-columns:
            minmax(0, 1fr)
            200px;
    }

    .frame-detail {
        width: 200px;
    }

    .frame-grid {
        grid-template-columns:
            repeat(3, minmax(0, 1fr));
    }

}

@media(max-width: 850px) {

    .frame-stats {
        grid-template-columns:
            repeat(2, 1fr);
    }

    .frame-content {
        grid-template-columns: 1fr;
    }

    .frame-detail {
        width: 100%;

        position: static;
    }

    .frame-grid {
        grid-template-columns:
            repeat(2, minmax(0, 1fr));
    }

}

@media(max-width: 600px) {

    .frame-header {
        flex-direction: column;

        align-items: flex-start;

        gap: 12px;
    }

    .btn-add-frame {
        width: 100%;
    }

    .frame-stats {
        grid-template-columns: 1fr;
    }

    .frame-filter {
        flex-direction: column;

        align-items: flex-start;
    }

    .frame-grid {
        grid-template-columns: 1fr;
    }

}

</style>


@php

    $totalFrames = $frames->count();

    $activeFrames = $frames
        ->where('status', true)
        ->count();

    $popularFrames = $frames->count();

    $categories = $frames
        ->map(function ($frame) {
            return $frame->kategori ?? 'Classic';
        })
        ->filter()
        ->unique()
        ->count();

@endphp


<div class="frame-page">


    {{-- =====================================
         HEADER
    ====================================== --}}

    <div class="frame-header">

        <div class="frame-header-left">

            <h1>
                Kelola Frame
            </h1>

            <p>
                Tambah, edit, atau hapus frame untuk studio photobooth PovStudio.
            </p>

        </div>


        <a
            href="{{ route('frames.create') }}"
            class="btn-add-frame"
        >
            ＋ Tambah Frame
        </a>

    </div>


    {{-- =====================================
         STATISTIK
    ====================================== --}}

    <div class="frame-stats">


        <div class="frame-stat">

            <div class="frame-stat-top">

                <div class="frame-stat-icon">
                    ▧
                </div>

                <small>
                    Total Frame
                </small>

            </div>

            <h2>
                {{ $totalFrames }}
            </h2>

        </div>


        <div class="frame-stat">

            <div class="frame-stat-top">

                <div class="frame-stat-icon">
                    ◈
                </div>

                <small>
                    Kategori
                </small>

            </div>

            <h2>
                {{ $categories }}
            </h2>

        </div>


        <div class="frame-stat">

            <div class="frame-stat-top">

                <div class="frame-stat-icon">
                    ☆
                </div>

                <small>
                    Frame Populer
                </small>

            </div>

            <h2>
                {{ $popularFrames }}
            </h2>

        </div>


        <div class="frame-stat">

            <div class="frame-stat-top">

                <div class="frame-stat-icon">
                    ◉
                </div>

                <small>
                    Frame Aktif
                </small>

            </div>

            <h2>
                {{ $activeFrames }}
            </h2>

        </div>

    </div>


    {{-- =====================================
         FILTER
    ====================================== --}}

    <div class="frame-filter">

        <div class="category-filter">

            <button
                type="button"
                class="filter-btn active"
                data-filter="all"
            >
                Semua Frame
            </button>

            <button
                type="button"
                class="filter-btn"
                data-filter="Classic"
            >
                Classic
            </button>

            <button
                type="button"
                class="filter-btn"
                data-filter="Y2K"
            >
                Y2K
            </button>

            <button
                type="button"
                class="filter-btn"
                data-filter="Valentine"
            >
                Valentine
            </button>

            <button
                type="button"
                class="filter-btn"
                data-filter="Film"
            >
                Film
            </button>

            <button
                type="button"
                class="filter-btn"
                data-filter="Polaroid"
            >
                Polaroid
            </button>

            <button
                type="button"
                class="filter-btn"
                data-filter="Seasonal"
            >
                Seasonal
            </button>

        </div>


        <select
            id="sortFrame"
            class="sort-box"
        >

            <option value="newest">
                Urutkan: Terbaru
            </option>

            <option value="oldest">
                Urutkan: Terlama
            </option>

            <option value="name">
                Urutkan: Nama
            </option>

        </select>

    </div>


    {{-- =====================================
         CONTENT
    ====================================== --}}

    <div class="frame-content">


        {{-- =================================
             GRID FRAME
        ================================== --}}

        <div
            class="frame-grid"
            id="frameGrid"
        >

            @forelse($frames as $frame)

                @php

                    $category =
                        $frame->kategori ?? 'Classic';

                    $image =
                        $frame->gambar
                            ? asset('storage/' . $frame->gambar)
                            : '';

                    $status =
                        (bool) $frame->status;

                @endphp


                <div
                    class="frame-card
                        {{ $loop->first ? 'selected' : '' }}"

                    data-id="{{ $frame->id }}"

                    data-name="{{ $frame->nama }}"

                    data-category="{{ $category }}"

                    data-image="{{ $image }}"

                    data-date="
                        {{ $frame->created_at?->format('d M Y') }}
                    "

                    data-status="
                        {{ $status ? 'Aktif' : 'Nonaktif' }}
                    "

                    onclick="selectFrame(this)"
                >


                    <div class="frame-image-box">

                        @if($image)

                            <img
                                src="{{ $image }}"
                                alt="{{ $frame->nama }}"
                                class="frame-image"
                            >

                        @else

                            <span class="no-image">
                                Belum ada gambar
                            </span>

                        @endif

                    </div>


                    <div class="frame-info">

                        <div class="frame-name">

                            {{ $frame->nama }}

                        </div>


                        <div class="frame-meta">

                            <span class="frame-category">

                                {{ $category }}

                            </span>

                            <span class="frame-usage">

                                0 penggunaan

                            </span>

                        </div>


                        <div class="frame-bottom">

                            <div
                                class="
                                    toggle
                                    {{ !$status ? 'off' : '' }}
                                "
                            ></div>

                            <div class="dots">
                                ⋮
                            </div>

                        </div>

                    </div>

                </div>


            @empty

                <div class="empty-frame">

                    <div class="empty-frame-icon">
                        🖼️
                    </div>

                    <h3>
                        Belum ada frame
                    </h3>

                    <p>
                        Silakan tambahkan frame pertama.
                    </p>

                </div>

            @endforelse


            <div
                class="filter-empty"
                id="filterEmpty"
            >

                <div style="font-size:35px;">
                    🔍
                </div>

                <h3>
                    Frame tidak ditemukan
                </h3>

                <p>
                    Tidak ada frame pada kategori ini.
                </p>

            </div>

        </div>


        {{-- =================================
             DETAIL KANAN
        ================================== --}}

        @php

            $selectedFrame =
                $frames->first();

        @endphp


        <div
            class="frame-detail"
            id="frameDetail"
        >

            @if($selectedFrame)

                @php

                    $selectedCategory =
                        $selectedFrame->kategori
                        ?? 'Classic';

                    $selectedImage =
                        $selectedFrame->gambar
                            ? asset(
                                'storage/' .
                                $selectedFrame->gambar
                            )
                            : '';

                    $selectedStatus =
                        (bool)
                        $selectedFrame->status;

                @endphp


                <div class="detail-image-box">

                    @if($selectedImage)

                        <img
                            id="detailImage"
                            src="{{ $selectedImage }}"
                            alt="{{ $selectedFrame->nama }}"
                            class="detail-image"
                        >

                    @else

                        <span
                            id="detailNoImage"
                            class="no-image"
                        >
                            Belum ada gambar
                        </span>

                    @endif

                </div>


                <div class="detail-title-row">

                    <div
                        class="detail-title"
                        id="detailName"
                    >
                        {{ $selectedFrame->nama }}
                    </div>


                    <span
                        id="detailStatus"
                        class="
                            {{
                                $selectedStatus
                                ? 'active-badge'
                                : 'inactive-badge'
                            }}
                        "
                    >
                        {{
                            $selectedStatus
                            ? 'Aktif'
                            : 'Nonaktif'
                        }}
                    </span>

                </div>


                <div class="detail-info">


                    <div class="detail-row">

                        <div class="detail-icon">
                            ◈
                        </div>

                        <div class="detail-label">
                            Kategori
                        </div>

                        <div
                            class="detail-value"
                            id="detailCategory"
                        >
                            {{ $selectedCategory }}
                        </div>

                    </div>


                    <div class="detail-row">

                        <div class="detail-icon">
                            ▣
                        </div>

                        <div class="detail-label">
                            Tanggal Dibuat
                        </div>

                        <div
                            class="detail-value"
                            id="detailDate"
                        >
                            {{
                                $selectedFrame
                                    ->created_at
                                    ?->format('d M Y')
                            }}
                        </div>

                    </div>


                    <div class="detail-row">

                        <div class="detail-icon">
                            ▥
                        </div>

                        <div class="detail-label">
                            Total Penggunaan
                        </div>

                        <div class="detail-value">
                            0 kali
                        </div>

                    </div>


                    <div class="detail-row">

                        <div class="detail-icon">
                            ▧
                        </div>

                        <div class="detail-label">
                            Resolusi
                        </div>

                        <div class="detail-value">
                            1200 × 1800 px
                        </div>

                    </div>


                    <div class="detail-row">

                        <div class="detail-icon">
                            ▤
                        </div>

                        <div class="detail-label">
                            Ukuran File
                        </div>

                        <div
                            class="detail-value"
                            id="detailSize"
                        >
                            -
                        </div>

                    </div>

                </div>


                {{-- EDIT --}}

                <a
                    id="editFrameButton"
                    href="{{ route(
                        'frames.edit',
                        $selectedFrame->id
                    ) }}"
                    class="btn-edit"
                >
                    ✎ Edit Frame
                </a>


                {{-- DELETE --}}

                <form
                    id="deleteFrameForm"

                    action="{{ route(
                        'frames.destroy',
                        $selectedFrame->id
                    ) }}"

                    method="POST"

                    onsubmit="
                        return confirm(
                            'Yakin ingin menghapus frame ini?'
                        )
                    "
                >

                    @csrf

                    @method('DELETE')

                    <button
                        type="submit"
                        class="btn-delete"
                    >
                        🗑 Hapus Frame
                    </button>

                </form>


            @else

                <div
                    style="
                        text-align:center;
                        padding:45px 10px;
                        color:#999;
                        font-size:10px;
                    "
                >
                    Belum ada frame.
                </div>

            @endif

        </div>

    </div>

</div>


<script>

/* =========================================
   PILIH FRAME
========================================= */

function selectFrame(card) {

    document
        .querySelectorAll('.frame-card')
        .forEach(function(item) {

            item.classList.remove('selected');

        });


    card.classList.add('selected');


    const id =
        card.dataset.id;

    const name =
        card.dataset.name;

    const category =
        card.dataset.category;

    const image =
        card.dataset.image;

    const date =
        card.dataset.date.trim();

    const status =
        card.dataset.status.trim();


    /* Nama */

    const detailName =
        document.getElementById(
            'detailName'
        );

    if (detailName) {

        detailName.textContent =
            name;

    }


    /* Kategori */

    const detailCategory =
        document.getElementById(
            'detailCategory'
        );

    if (detailCategory) {

        detailCategory.textContent =
            category;

    }


    /* Tanggal */

    const detailDate =
        document.getElementById(
            'detailDate'
        );

    if (detailDate) {

        detailDate.textContent =
            date;

    }


    /* Status */

    const detailStatus =
        document.getElementById(
            'detailStatus'
        );

    if (detailStatus) {

        detailStatus.textContent =
            status;

        detailStatus.className =
            status === 'Aktif'
                ? 'active-badge'
                : 'inactive-badge';

    }


    /* Gambar */

    const detailImage =
        document.getElementById(
            'detailImage'
        );

    const detailNoImage =
        document.getElementById(
            'detailNoImage'
        );


    if (image) {

        if (detailImage) {

            detailImage.src =
                image;

            detailImage.style.display =
                'block';

        }

        if (detailNoImage) {

            detailNoImage.style.display =
                'none';

        }

    } else {

        if (detailImage) {

            detailImage.style.display =
                'none';

        }

        if (detailNoImage) {

            detailNoImage.style.display =
                'block';

        }

    }


    /* Tombol Edit */

    const editButton =
        document.getElementById(
            'editFrameButton'
        );

    if (editButton) {

        editButton.href =
            '/frames/' + id + '/edit';

    }


    /* Tombol Delete */

    const deleteForm =
        document.getElementById(
            'deleteFrameForm'
        );

    if (deleteForm) {

        deleteForm.action =
            '/frames/' + id;

    }

}


/* =========================================
   FILTER
========================================= */

document
    .querySelectorAll('.filter-btn')
    .forEach(function(button) {

        button.addEventListener(
            'click',
            function() {

                document
                    .querySelectorAll('.filter-btn')
                    .forEach(function(btn) {

                        btn.classList.remove(
                            'active'
                        );

                    });


                this.classList.add(
                    'active'
                );


                const filter =
                    this.dataset.filter;

                let count = 0;


                document
                    .querySelectorAll('.frame-card')
                    .forEach(function(card) {

                        const category =
                            card.dataset.category;


                        if (
                            filter === 'all' ||
                            category === filter
                        ) {

                            card.style.display =
                                'block';

                            count++;

                        } else {

                            card.style.display =
                                'none';

                        }

                    });


                const empty =
                    document.getElementById(
                        'filterEmpty'
                    );


                if (empty) {

                    if (count === 0) {

                        empty.classList.add(
                            'show'
                        );

                    } else {

                        empty.classList.remove(
                            'show'
                        );

                    }

                }

            }
        );

    });


/* =========================================
   SORT
========================================= */

const sortFrame =
    document.getElementById(
        'sortFrame'
    );


if (sortFrame) {

    sortFrame.addEventListener(
        'change',
        function() {

            const grid =
                document.getElementById(
                    'frameGrid'
                );


            const cards =
                Array.from(
                    grid.querySelectorAll(
                        '.frame-card'
                    )
                );


            if (this.value === 'name') {

                cards.sort(function(a, b) {

                    return a.dataset.name
                        .localeCompare(
                            b.dataset.name
                        );

                });

            }

            else if (
                this.value === 'oldest'
            ) {

                cards.sort(function(a, b) {

                    return (
                        Number(a.dataset.id) -
                        Number(b.dataset.id)
                    );

                });

            }

            else {

                cards.sort(function(a, b) {

                    return (
                        Number(b.dataset.id) -
                        Number(a.dataset.id)
                    );

                });

            }


            cards.forEach(function(card) {

                grid.appendChild(card);

            });

        }
    );

}

</script>

@endsection