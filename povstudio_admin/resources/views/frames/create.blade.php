@extends('layouts.admin')

@section('title', 'Tambah Frame - PovStudio')

@section('content')

<style>

/* =========================================================
   RESET
========================================================= */

.create-frame-page,
.create-frame-page * {
    box-sizing: border-box;
}

.create-frame-page {
    min-height: calc(100vh - 72px);
    background: #fff8fc;
    padding: 18px 16px 30px;
    color: #211936;
    font-family: inherit;
}


/* =========================================================
   TOP / BACK
========================================================= */

.create-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 10px;
}

.back-link {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    text-decoration: none;
    color: #4c205d;
    font-size: 11px;
    font-weight: 700;
    transition: .2s ease;
}

.back-link:hover {
    color: #d6296b;
}

.back-arrow {
    font-size: 20px;
    line-height: 1;
}


/* =========================================================
   HEADER
========================================================= */

.create-header {
    margin-bottom: 12px;
}

.header-title-row {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
}

.create-header h1 {
    margin: 0 0 3px;
    color: #171326;
    font-size: 25px;
    line-height: 1.15;
    font-weight: 800;
}

.create-header p {
    margin: 0;
    color: #8b8198;
    font-size: 11px;
}


/* =========================================================
   DECORATIVE STICKER
========================================================= */

.create-decoration {
    position: relative;
    width: 145px;
    margin-right: 65px;
    margin-top: -3px;
    color: #f36aaa;
    font-size: 14px;
    line-height: 1.08;
    font-weight: 600;
    font-style: italic;
    text-align: center;
    transform: rotate(-5deg);
    user-select: none;
}

.create-decoration::before {
    content: "✦";
    position: absolute;
    left: 2px;
    top: 6px;
    font-size: 10px;
    color: #e879bc;
}

.create-decoration::after {
    content: "♡";
    position: absolute;
    right: 2px;
    bottom: -9px;
    font-size: 20px;
    color: #ed6eaf;
}


/* =========================================================
   MAIN LAYOUT
========================================================= */

.create-layout {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 265px;
    gap: 13px;
    align-items: start;
}


/* =========================================================
   FORM CARD
========================================================= */

.create-form-card {
    background: #ffffff;
    border: 1px solid #eee2eb;
    border-radius: 13px;
    padding: 13px;
    box-shadow: 0 4px 15px rgba(180, 100, 150, .045);
}


/* =========================================================
   FORM GROUP
========================================================= */

.form-group {
    margin-bottom: 11px;
}

.form-label {
    display: block;
    margin-bottom: 5px;
    color: #292238;
    font-size: 10px;
    font-weight: 700;
}

.required {
    color: #ed286d;
}


/* =========================================================
   UPLOAD
========================================================= */

.upload-box {
    width: 100%;
    height: 92px;
    border: 1.5px dashed #ff70a9;
    border-radius: 10px;

    background:
        linear-gradient(
            180deg,
            #fff9fc,
            #fffafd
        );

    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;

    cursor: pointer;
    transition: .2s ease;
    position: relative;
}

.upload-box:hover {
    background: #fff1f8;
    border-color: #d52969;
}

.upload-box.dragging {
    background: #fff0f7;
    border-color: #d52969;
    transform: scale(1.005);
}


/* =========================================================
   UPLOAD ICON
========================================================= */

.upload-icon {
    width: 33px;
    height: 33px;
    margin-bottom: 4px;

    border-radius: 50%;
    background: #fff0f7;
    color: #ed286d;

    display: flex;
    align-items: center;
    justify-content: center;

    font-size: 21px;
    font-weight: 700;
}

.upload-icon svg {
    width: 21px;
    height: 21px;
    stroke: #ed286d;
}


/* =========================================================
   UPLOAD TEXT
========================================================= */

.upload-title {
    color: #9e345e;
    font-size: 10px;
    font-weight: 700;
    margin-bottom: 2px;
}

.upload-subtitle {
    color: #9a8fa2;
    font-size: 9px;
}

.upload-input {
    display: none;
}


/* =========================================================
   UPLOAD INFO
========================================================= */

.upload-info {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 9px;

    margin-top: 4px;

    color: #9a8fa2;
    font-size: 8px;
    text-align: center;
}

.upload-info span {
    position: relative;
}

.upload-info span:not(:last-child)::after {
    content: "|";
    margin-left: 9px;
    color: #d7cbd4;
}


/* =========================================================
   TWO COLUMN
========================================================= */

.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
}


/* =========================================================
   INPUT
========================================================= */

.input-with-icon {
    position: relative;
}

.input-icon {
    position: absolute;
    left: 10px;
    top: 50%;
    transform: translateY(-50%);
    color: #8d55bf;
    pointer-events: none;
    display: flex;
    align-items: center;
}

.input-icon svg {
    width: 14px;
    height: 14px;
    stroke-width: 2;
}

.input-with-icon .form-control {
    padding-left: 31px;
}

.form-control {
    width: 100%;
    height: 32px;
    padding: 0 10px;

    border: 1px solid #e9dfeb;
    border-radius: 8px;

    outline: none;
    background: #fbf9fd;
    color: #40354b;

    font-family: inherit;
    font-size: 9px;

    transition: .2s ease;
}

.form-control::placeholder {
    color: #aaa1ad;
}

.form-control:focus {
    border-color: #df3976;
    background: white;
    box-shadow: 0 0 0 3px rgba(223, 57, 118, .06);
}

select.form-control {
    cursor: pointer;
}


/* =========================================================
   TEXTAREA
========================================================= */

.textarea-wrapper {
    position: relative;
}

textarea.form-control {
    height: 53px;
    padding: 9px 10px;
    resize: none;
}

.textarea-counter {
    position: absolute;
    right: 9px;
    bottom: 7px;
    color: #a99eaa;
    font-size: 8px;
}


/* =========================================================
   THEME
========================================================= */

.theme-input-wrapper {
    position: relative;
}

.theme-icon {
    position: absolute;
    left: 10px;
    top: 50%;

    transform: translateY(-50%);

    color: #8d55bf;

    pointer-events: none;

    display: flex;
    align-items: center;
}

.theme-icon svg {
    width: 14px;
    height: 14px;
}

.theme-input {
    padding-left: 31px;
}

.theme-help {
    margin-top: 4px;
    color: #9a8fa2;
    font-size: 8px;
}


/* =========================================================
   STATUS
========================================================= */

.status-wrapper {
    display: flex;
    align-items: center;
    gap: 8px;
    height: 32px;
}

.status-toggle {
    width: 31px;
    height: 18px;

    border-radius: 20px;

    background: #d62b69;

    position: relative;
    cursor: pointer;

    transition: .2s ease;
}

.status-toggle::after {
    content: "";

    position: absolute;

    width: 14px;
    height: 14px;

    top: 2px;
    right: 2px;

    background: white;
    border-radius: 50%;

    transition: .2s ease;
}

.status-toggle.off {
    background: #d5cfd4;
}

.status-toggle.off::after {
    right: auto;
    left: 2px;
}

.status-text {
    color: #62576d;
    font-size: 9px;
    font-weight: 600;
}

.status-description {
    margin-top: -3px;
    color: #9a8fa2;
    font-size: 8px;
}


/* =========================================================
   BUTTON
========================================================= */

.form-actions {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    margin-top: 14px;
}

.btn-cancel {
    height: 35px;

    display: flex;
    align-items: center;
    justify-content: center;

    border-radius: 20px;

    background: #fff0f6;
    color: #d52b68;

    text-decoration: none;

    font-size: 10px;
    font-weight: 700;

    transition: .2s ease;
}

.btn-cancel:hover {
    background: #fde0eb;
}

.btn-save {
    height: 35px;

    border: none;
    border-radius: 20px;

    background:
        linear-gradient(
            90deg,
            #c91e61,
            #df3976
        );

    color: white;

    font-family: inherit;
    font-size: 10px;
    font-weight: 700;

    cursor: pointer;

    box-shadow:
        0 5px 15px rgba(210, 35, 100, .18);

    transition: .2s ease;
}

.btn-save:hover {
    transform: translateY(-1px);

    box-shadow:
        0 7px 18px rgba(210, 35, 100, .25);
}

.button-plus {
    font-size: 17px;
    line-height: 0;
    vertical-align: middle;
    margin-right: 4px;
}


/* =========================================================
   PREVIEW CARD
========================================================= */

.preview-card {
    background:
        linear-gradient(
            180deg,
            #fff0f8,
            #fff7fb
        );

    border: 1px solid #f1dfea;
    border-radius: 12px;

    padding: 13px;

    min-height: 385px;
}

.preview-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 10px;
}

.preview-icon {
    width: 28px;
    height: 28px;

    border-radius: 50%;

    background: white;
    color: #ed286d;

    display: flex;
    align-items: center;
    justify-content: center;

    font-size: 14px;
}

.preview-icon svg {
    width: 16px;
    height: 16px;
    stroke: #ed286d;
}

.preview-title {
    color: #b92763;
    font-size: 10px;
    font-weight: 700;
}

.preview-subtitle {
    margin-top: 2px;
    color: #9b8fa1;
    font-size: 8px;
}


/* =========================================================
   PREVIEW IMAGE
========================================================= */

.preview-image-box {
    width: 100%;
    height: 220px;

    border-radius: 10px;

    display: flex;
    align-items: center;
    justify-content: center;

    overflow: hidden;

    background:
        linear-gradient(45deg, #eeeeee 25%, transparent 25%),
        linear-gradient(-45deg, #eeeeee 25%, transparent 25%),
        linear-gradient(45deg, transparent 75%, #eeeeee 75%),
        linear-gradient(-45deg, transparent 75%, #eeeeee 75%);

    background-size: 20px 20px;

    background-position:
        0 0,
        0 10px,
        10px -10px,
        -10px 0;
}

.preview-image {
    max-width: 100%;
    max-height: 100%;

    object-fit: contain;

    display: none;
}

.preview-placeholder {
    color: #b4a8b5;
    text-align: center;
    font-size: 10px;
}

.preview-placeholder-icon {
    font-size: 35px;
    margin-bottom: 6px;
}


/* =========================================================
   INFO CARD
========================================================= */

.info-card {
    margin-top: 10px;

    background:
        linear-gradient(
            180deg,
            #f5f1ff,
            #faf8ff
        );

    border-radius: 10px;

    padding: 11px;
}

.info-title {
    display: flex;
    align-items: center;
    gap: 6px;

    color: #3d3561;

    font-size: 9px;
    font-weight: 700;

    margin-bottom: 6px;
}

.info-icon {
    width: 16px;
    height: 16px;

    display: flex;
    align-items: center;
    justify-content: center;

    color: #7664db;
}

.info-icon svg {
    width: 13px;
    height: 13px;
}

.info-list {
    margin: 0;
    padding-left: 14px;

    color: #7d7391;

    font-size: 8px;
    line-height: 1.7;
}


/* =========================================================
   ERROR
========================================================= */

.form-error {
    margin-top: 4px;
    color: #df2868;
    font-size: 8px;
}


/* =========================================================
   FILE NAME
========================================================= */

.file-selected {
    margin-top: 5px;
    color: #c42b69;
    font-size: 8px;
    text-align: center;
}


/* =========================================================
   RESPONSIVE
========================================================= */

@media(max-width: 1050px) {

    .create-layout {
        grid-template-columns:
            minmax(0, 1fr)
            235px;
    }

    .preview-image-box {
        height: 200px;
    }

    .create-decoration {
        margin-right: 20px;
    }
}


@media(max-width: 850px) {

    .create-layout {
        grid-template-columns: 1fr;
    }

    .preview-card {
        min-height: auto;
    }

    .preview-image-box {
        height: 300px;
    }

    .create-decoration {
        display: none;
    }
}


@media(max-width: 600px) {

    .create-frame-page {
        padding: 15px;
    }

    .form-row {
        grid-template-columns: 1fr;
    }

    .form-actions {
        grid-template-columns: 1fr;
    }

    .upload-info {
        flex-direction: column;
        gap: 2px;
    }

    .upload-info span:not(:last-child)::after {
        display: none;
    }
}

</style>


<div class="create-frame-page">


    {{-- =====================================================
         KEMBALI
    ====================================================== --}}

    <div class="create-top">

        <a
            href="{{ route('frames.index') }}"
            class="back-link"
        >

            <span class="back-arrow">
                ←
            </span>

            Kembali ke Kelola Frame

        </a>

    </div>


    {{-- =====================================================
         HEADER
    ====================================================== --}}

    <div class="create-header">

        <div class="header-title-row">

            <div>

                <h1>
                    Tambah Frame
                </h1>

                <p>
                    Upload dan atur frame baru untuk studio photobooth PovStudio.
                </p>

            </div>


            {{-- STIKER --}}
            <div class="create-decoration">
                Let's<br>
                Create<br>
                Together! ♡
            </div>

        </div>

    </div>


    {{-- =====================================================
         MAIN LAYOUT
    ====================================================== --}}

    <div class="create-layout">


        {{-- =================================================
             FORM KIRI
        ================================================== --}}

        <div class="create-form-card">

            <form
                action="{{ route('frames.store') }}"
                method="POST"
                enctype="multipart/form-data"
            >

                @csrf


                {{-- =================================================
                     GAMBAR FRAME
                ================================================== --}}

                <div class="form-group">

                    <label class="form-label">

                        Gambar Frame
                        <span class="required">*</span>

                    </label>


                    <label
                        for="gambar"
                        class="upload-box"
                        id="uploadBox"
                    >

                        <div class="upload-icon">

                            {{-- ICON UPLOAD --}}
                            <svg
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2"
                                stroke-linecap="round"
                                stroke-linejoin="round"
                            >

                                <path d="M12 16V4"></path>

                                <path d="M7 9l5-5 5 5"></path>

                                <path d="M5 20h14"></path>

                            </svg>

                        </div>


                        <div class="upload-title">

                            Drag & drop gambar frame di sini

                        </div>


                        <div class="upload-subtitle">

                            atau klik untuk memilih file

                        </div>

                    </label>


                    <input
                        type="file"
                        name="gambar"
                        id="gambar"
                        class="upload-input"
                        accept="image/png,image/jpeg"
                        required
                    >


                    <div class="upload-info">

                        <span>
                            Format yang didukung: PNG (transparan)
                        </span>

                        <span>
                            Ukuran maksimal: 5 MB
                        </span>

                        <span>
                            Rekomendasi: 1200 × 1800 px
                        </span>

                    </div>


                    <div
                        id="fileSelected"
                        class="file-selected"
                        style="display:none;"
                    ></div>


                    @error('gambar')

                        <div class="form-error">
                            {{ $message }}
                        </div>

                    @enderror

                </div>


                {{-- =================================================
                     NAMA + KATEGORI
                ================================================== --}}

                <div class="form-row">


                    {{-- NAMA --}}

                    <div class="form-group">

                        <label class="form-label">

                            Nama Frame
                            <span class="required">*</span>

                        </label>


                        <div class="input-with-icon">

                            <span class="input-icon">

                                <svg
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                >

                                    <rect
                                        x="3"
                                        y="3"
                                        width="18"
                                        height="18"
                                        rx="2"
                                    ></rect>

                                    <circle
                                        cx="8.5"
                                        cy="8.5"
                                        r="1.5"
                                    ></circle>

                                    <path
                                        d="M21 15l-5-5L5 21"
                                    ></path>

                                </svg>

                            </span>


                            <input
                                type="text"
                                name="nama"
                                class="form-control"
                                placeholder="Masukkan nama frame"
                                value="{{ old('nama') }}"
                                required
                            >

                        </div>


                        @error('nama')

                            <div class="form-error">
                                {{ $message }}
                            </div>

                        @enderror

                    </div>


                    {{-- KATEGORI --}}

                    <div class="form-group">

                        <label class="form-label">

                            Kategori
                            <span class="required">*</span>

                        </label>


                        <div class="input-with-icon">

                            <span class="input-icon">

                                <svg
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                >

                                    <path
                                        d="M20 13V6a2 2 0 0 0-2-2h-7"
                                    ></path>

                                    <path
                                        d="M3 17l7-7"
                                    ></path>

                                    <path
                                        d="M3 17v4h4"
                                    ></path>

                                    <path
                                        d="M13 3l8 8-10 10-8-8L13 3z"
                                    ></path>

                                </svg>

                            </span>


                            <select
                                name="kategori"
                                class="form-control"
                                required
                            >

                                <option value="">
                                    Pilih kategori
                                </option>

                                <option
                                    value="Classic"
                                    {{ old('kategori') == 'Classic' ? 'selected' : '' }}
                                >
                                    Classic
                                </option>

                                <option
                                    value="Y2K"
                                    {{ old('kategori') == 'Y2K' ? 'selected' : '' }}
                                >
                                    Y2K
                                </option>

                                <option
                                    value="Valentine"
                                    {{ old('kategori') == 'Valentine' ? 'selected' : '' }}
                                >
                                    Valentine
                                </option>

                                <option
                                    value="Film"
                                    {{ old('kategori') == 'Film' ? 'selected' : '' }}
                                >
                                    Film
                                </option>

                                <option
                                    value="Polaroid"
                                    {{ old('kategori') == 'Polaroid' ? 'selected' : '' }}
                                >
                                    Polaroid
                                </option>

                                <option
                                    value="Seasonal"
                                    {{ old('kategori') == 'Seasonal' ? 'selected' : '' }}
                                >
                                    Seasonal
                                </option>

                            </select>

                        </div>


                        @error('kategori')

                            <div class="form-error">
                                {{ $message }}
                            </div>

                        @enderror

                    </div>

                </div>


                {{-- =================================================
                     DESKRIPSI
                ================================================== --}}

                <div class="form-group">

                    <label class="form-label">
                        Deskripsi (Opsional)
                    </label>


                    <div class="textarea-wrapper">

                        <textarea
                            name="deskripsi"
                            id="deskripsi"
                            class="form-control"
                            maxlength="200"
                            placeholder="Tambahkan deskripsi frame..."
                        >{{ old('deskripsi') }}</textarea>


                        <span
                            class="textarea-counter"
                            id="counter"
                        >
                            0/200
                        </span>

                    </div>

                </div>


                {{-- =================================================
                     TEMA + STATUS
                ================================================== --}}

                <div class="form-row">


                    {{-- TEMA --}}

                    <div class="form-group">

                        <label class="form-label">
                            Tema / Tag
                        </label>


                        <div class="theme-input-wrapper">

                            <span class="theme-icon">

                                <svg
                                    viewBox="0 0 24 24"
                                    fill="none"
                                    stroke="currentColor"
                                    stroke-width="2"
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                >

                                    <path
                                        d="M20.59 13.41L11 3H4v7l9.59 9.59a2 2 0 0 0 2.82 0l4.18-4.18a2 2 0 0 0 0-2.82z"
                                    ></path>

                                    <circle
                                        cx="7.5"
                                        cy="7.5"
                                        r="1"
                                    ></circle>

                                </svg>

                            </span>


                            <input
                                type="text"
                                name="tema"
                                class="form-control theme-input"
                                placeholder="Tambahkan tag (misal: valentine, cute, retro)"
                                value="{{ old('tema') }}"
                            >

                        </div>


                        <div class="theme-help">
                            Pisahkan dengan koma (,)
                        </div>

                    </div>


                    {{-- STATUS --}}

                    <div class="form-group">

                        <label class="form-label">
                            Status Frame
                        </label>


                        <div class="status-wrapper">

                            <div
                                class="status-toggle"
                                id="statusToggle"
                            ></div>


                            <span class="status-text">
                                Aktif
                            </span>

                        </div>


                        <div class="status-description">
                            Frame akan ditampilkan di aplikasi
                        </div>


                        <input
                            type="hidden"
                            name="status"
                            id="statusInput"
                            value="1"
                        >

                    </div>

                </div>


                {{-- =================================================
                     BUTTON
                ================================================== --}}

                <div class="form-actions">


                    <a
                        href="{{ route('frames.index') }}"
                        class="btn-cancel"
                    >
                        Batal
                    </a>


                    <button
                        type="submit"
                        class="btn-save"
                    >

                        <span class="button-plus">
                            ＋
                        </span>

                        Simpan Frame

                    </button>

                </div>


            </form>

        </div>


        {{-- =================================================
             PREVIEW KANAN
        ================================================== --}}

        <div>


            {{-- =================================================
                 PREVIEW CARD
            ================================================== --}}

            <div class="preview-card">

                <div class="preview-header">


                    <div class="preview-icon">

                        {{-- EYE ICON --}}

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >

                            <path
                                d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6-10-6-10-6z"
                            ></path>

                            <circle
                                cx="12"
                                cy="12"
                                r="2.5"
                            ></circle>

                        </svg>

                    </div>


                    <div>

                        <div class="preview-title">
                            Preview Frame
                        </div>

                        <div class="preview-subtitle">
                            Tampilan frame setelah diunggah
                        </div>

                    </div>

                </div>


                <div
                    class="preview-image-box"
                    id="previewBox"
                >

                    <img
                        id="previewImage"
                        class="preview-image"
                        alt="Preview Frame"
                    >


                    <div
                        class="preview-placeholder"
                        id="previewPlaceholder"
                    >

                        <div class="preview-placeholder-icon">
                            🖼️
                        </div>

                        Preview gambar akan muncul di sini

                    </div>

                </div>

            </div>


            {{-- =================================================
                 INFO
            ================================================== --}}

            <div class="info-card">


                <div class="info-title">

                    <span class="info-icon">

                        {{-- INFO ICON --}}

                        <svg
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                            stroke-linejoin="round"
                        >

                            <circle
                                cx="12"
                                cy="12"
                                r="9"
                            ></circle>

                            <line
                                x1="12"
                                y1="10"
                                x2="12"
                                y2="16"
                            ></line>

                            <line
                                x1="12"
                                y1="7"
                                x2="12.01"
                                y2="7"
                            ></line>

                        </svg>

                    </span>


                    Pastikan gambar:

                </div>


                <ul class="info-list">

                    <li>
                        Menggunakan format PNG dengan background transparan
                    </li>

                    <li>
                        Resolusi yang disarankan 1200 × 1800 px
                    </li>

                    <li>
                        Desain sesuai tema dan tidak melanggar hak cipta
                    </li>

                    <li>
                        Area tengah transparan untuk hasil foto
                    </li>

                </ul>

            </div>


        </div>


    </div>


</div>


<script>

/* =========================================================
   ELEMENT
========================================================= */

const gambarInput =
    document.getElementById('gambar');

const previewImage =
    document.getElementById('previewImage');

const previewPlaceholder =
    document.getElementById('previewPlaceholder');

const uploadBox =
    document.getElementById('uploadBox');

const fileSelected =
    document.getElementById('fileSelected');


/* =========================================================
   PREVIEW GAMBAR
========================================================= */

if (gambarInput) {

    gambarInput.addEventListener(
        'change',
        function(event) {

            const file =
                event.target.files[0];

            if (!file) {

                previewImage.style.display =
                    'none';

                previewPlaceholder.style.display =
                    'block';

                fileSelected.style.display =
                    'none';

                return;
            }


            /* Validasi tipe */

            if (
                file.type !== 'image/png' &&
                file.type !== 'image/jpeg'
            ) {

                alert(
                    'File harus berupa PNG atau JPG.'
                );

                gambarInput.value = '';

                return;
            }


            /* Validasi ukuran */

            if (
                file.size >
                5 * 1024 * 1024
            ) {

                alert(
                    'Ukuran file maksimal 5 MB.'
                );

                gambarInput.value = '';

                return;
            }


            /* Nama file */

            fileSelected.textContent =
                '✓ ' + file.name;

            fileSelected.style.display =
                'block';


            /* Preview */

            const reader =
                new FileReader();


            reader.onload =
                function(e) {

                    previewImage.src =
                        e.target.result;

                    previewImage.style.display =
                        'block';

                    previewPlaceholder.style.display =
                        'none';

                };


            reader.readAsDataURL(file);

        }
    );

}


/* =========================================================
   DRAG & DROP
========================================================= */

if (uploadBox) {


    uploadBox.addEventListener(
        'dragover',
        function(e) {

            e.preventDefault();

            uploadBox.classList.add(
                'dragging'
            );

        }
    );


    uploadBox.addEventListener(
        'dragleave',
        function() {

            uploadBox.classList.remove(
                'dragging'
            );

        }
    );


    uploadBox.addEventListener(
        'drop',
        function(e) {

            e.preventDefault();

            uploadBox.classList.remove(
                'dragging'
            );


            const files =
                e.dataTransfer.files;


            if (
                files &&
                files.length > 0
            ) {

                try {

                    gambarInput.files =
                        files;

                } catch (error) {

                    console.log(error);

                }


                gambarInput.dispatchEvent(
                    new Event(
                        'change',
                        {
                            bubbles: true
                        }
                    )
                );

            }

        }
    );

}


/* =========================================================
   DESKRIPSI COUNTER
========================================================= */

const description =
    document.getElementById(
        'deskripsi'
    );

const counter =
    document.getElementById(
        'counter'
    );


if (
    description &&
    counter
) {

    function updateCounter() {

        counter.textContent =
            description.value.length +
            '/200';

    }


    description.addEventListener(
        'input',
        updateCounter
    );


    updateCounter();

}


/* =========================================================
   STATUS TOGGLE
========================================================= */

const statusToggle =
    document.getElementById(
        'statusToggle'
    );

const statusInput =
    document.getElementById(
        'statusInput'
    );

const statusText =
    document.querySelector(
        '.status-text'
    );


if (statusToggle) {

    statusToggle.addEventListener(
        'click',
        function() {

            const active =
                statusInput.value === '1';


            if (active) {

                statusInput.value =
                    '0';

                statusToggle.classList.add(
                    'off'
                );

                statusText.textContent =
                    'Nonaktif';

            } else {

                statusInput.value =
                    '1';

                statusToggle.classList.remove(
                    'off'
                );

                statusText.textContent =
                    'Aktif';

            }

        }
    );

}

</script>

@endsection