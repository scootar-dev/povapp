@extends('layouts.admin')

@section('title', 'Tambah Stiker - PovStudio')

@section('content')

<style>

/* =========================================================
   POVSTUDIO - TAMBAH STIKER
========================================================= */

* {
    box-sizing: border-box;
}

.create-page {
    min-height: calc(100vh - 60px);
    padding: 18px 18px 35px;

    background:
        radial-gradient(
            circle at 90% 10%,
            rgba(255, 177, 220, .20),
            transparent 28%
        ),
        linear-gradient(
            135deg,
            #fffafd 0%,
            #fff7fb 48%,
            #faf7ff 100%
        );
}


/* =========================================================
   HEADER
========================================================= */

.create-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;

    margin-bottom: 15px;
}

.header-left {
    min-width: 0;
}

.back-link {
    display: inline-flex;
    align-items: center;
    gap: 7px;

    color: #29233d;
    text-decoration: none;

    font-size: 12px;
    font-weight: 700;

    margin-bottom: 9px;

    transition: .2s;
}

.back-link:hover {
    color: #d91f61;
}

.back-arrow {
    width: 23px;
    height: 23px;

    border-radius: 50%;

    background: #fff;
    border: 1px solid #eee1eb;

    display: flex;
    align-items: center;
    justify-content: center;

    color: #d91f61;
    font-size: 13px;
}

.create-title {
    margin: 0;

    font-size: 28px;
    line-height: 1.1;

    font-weight: 850;

    color: #141126;
}

.create-subtitle {
    margin: 5px 0 0;

    font-size: 12px;

    color: #8b8198;
}

.create-decoration {
    margin-right: 42px;
    margin-top: 3px;

    color: #f47abb;

    font-size: 15px;
    line-height: 1.25;

    font-style: italic;
    font-weight: 700;

    text-align: center;

    transform: rotate(-4deg);
}


/* =========================================================
   MAIN LAYOUT
========================================================= */

.create-layout {
    display: grid;

    grid-template-columns:
        minmax(520px, 1.62fr)
        minmax(270px, .78fr);

    gap: 15px;

    align-items: start;
}


/* =========================================================
   LEFT CARD
========================================================= */

.create-card {
    background: rgba(255,255,255,.96);

    border: 1px solid #f0e0eb;

    border-radius: 15px;

    padding: 14px;

    box-shadow:
        0 7px 25px rgba(180, 93, 145, .055);
}


/* =========================================================
   FIELD
========================================================= */

.field {
    margin-bottom: 12px;
}

.field-label {
    display: block;

    margin-bottom: 6px;

    font-size: 11px;
    font-weight: 800;

    color: #29233d;
}

.required {
    color: #e12669;
}


/* =========================================================
   UPLOAD AREA
========================================================= */

.upload-wrapper {
    position: relative;
}

.upload-box {
    width: 100%;
    height: 105px;

    border: 1.5px dashed #ff70b3;

    border-radius: 11px;

    background:
        linear-gradient(
            135deg,
            #fff9fc,
            #fff0f8
        );

    display: flex;
    flex-direction: column;

    align-items: center;
    justify-content: center;

    cursor: pointer;

    transition: all .2s ease;
}

.upload-box:hover {
    background: #fff0f7;

    border-color: #d91f61;

    box-shadow:
        0 5px 18px rgba(217,31,97,.08);
}

.upload-icon {
    width: 34px;
    height: 34px;

    margin-bottom: 3px;

    display: flex;
    align-items: center;
    justify-content: center;

    color: #e3266d;

    font-size: 27px;
}

.upload-title {
    color: #c91c5a;

    font-size: 12px;
    font-weight: 800;
}

.upload-subtitle {
    margin-top: 3px;

    color: #958a9c;

    font-size: 10px;
}

#gambar {
    display: none;
}

.upload-info {
    display: flex;
    align-items: center;
    flex-wrap: wrap;

    gap: 7px;

    margin-top: 5px;

    color: #8e8395;

    font-size: 8.5px;
}

.upload-info .info-icon {
    color: #7664db;

    font-size: 10px;
}

.upload-info .separator {
    color: #d7cad5;
}


/* =========================================================
   TWO COLUMN FORM
========================================================= */

.form-row {
    display: grid;

    grid-template-columns: 1fr 1fr;

    gap: 12px;
}


/* =========================================================
   INPUT
========================================================= */

.input-wrapper {
    position: relative;
}

.input-icon {
    position: absolute;

    left: 12px;
    top: 50%;

    transform: translateY(-50%);

    color: #d91f61;

    font-size: 15px;

    pointer-events: none;

    z-index: 2;
}

.input-control {
    width: 100%;
    height: 36px;

    border: 1px solid #e7ddea;

    border-radius: 9px;

    background: #fcf9fd;

    padding: 0 12px 0 37px;

    outline: none;

    color: #29233d;

    font-size: 10.5px;

    transition: .2s;
}

.input-control::placeholder {
    color: #a79baa;
}

.input-control:focus {
    background: #fff;

    border-color: #e42c70;

    box-shadow:
        0 0 0 3px rgba(228,44,112,.07);
}


/* SELECT */

select.input-control {
    appearance: auto;

    cursor: pointer;
}


/* =========================================================
   DESCRIPTION
========================================================= */

.textarea-wrapper {
    position: relative;
}

textarea.input-control {
    height: 62px;

    padding-top: 10px;
    padding-right: 42px;

    resize: none;

    line-height: 1.45;
}

.textarea-icon {
    position: absolute;

    left: 12px;
    top: 11px;

    color: #d91f61;

    font-size: 15px;

    z-index: 2;
}

textarea.input-control.with-icon {
    padding-left: 37px;
}

.counter {
    position: absolute;

    right: 10px;
    bottom: 7px;

    font-size: 8.5px;

    color: #9b8fa0;
}


/* =========================================================
   STATUS
========================================================= */

.status-area {
    height: 36px;

    display: flex;
    align-items: center;

    gap: 9px;
}

.switch {
    position: relative;

    width: 39px;
    height: 21px;

    flex-shrink: 0;
}

.switch input {
    display: none;
}

.slider {
    position: absolute;

    inset: 0;

    background: #d8d5dc;

    border-radius: 20px;

    cursor: pointer;

    transition: .2s;
}

.slider::before {
    content: "";

    position: absolute;

    width: 17px;
    height: 17px;

    left: 2px;
    top: 2px;

    background: #fff;

    border-radius: 50%;

    box-shadow:
        0 1px 4px rgba(0,0,0,.15);

    transition: .2s;
}

.switch input:checked + .slider {
    background: #d91f61;
}

.switch input:checked + .slider::before {
    transform: translateX(18px);
}

.status-text {
    font-size: 11px;

    font-weight: 800;

    color: #29233d;
}

.status-help {
    margin-top: 1px;

    font-size: 8.5px;

    color: #978b9d;
}


/* =========================================================
   BUTTON
========================================================= */

.button-row {
    display: grid;

    grid-template-columns: 1fr 1.15fr;

    gap: 12px;

    margin-top: 13px;
}

.btn {
    height: 37px;

    border: none;

    border-radius: 22px;

    display: flex;
    align-items: center;
    justify-content: center;

    text-decoration: none;

    font-size: 11.5px;
    font-weight: 800;

    cursor: pointer;

    transition: all .2s ease;
}

.btn-cancel {
    background: #fff0f7;

    color: #c91c5a;
}

.btn-cancel:hover {
    background: #ffe2ef;
}

.btn-save {
    color: #fff;

    background:
        linear-gradient(
            90deg,
            #cf185b,
            #e52d73
        );

    box-shadow:
        0 7px 16px rgba(207,24,91,.18);
}

.btn-save:hover {
    transform: translateY(-1px);

    box-shadow:
        0 9px 20px rgba(207,24,91,.25);
}


/* =========================================================
   RIGHT SIDE
========================================================= */

.right-column {
    min-width: 0;
}


/* =========================================================
   PREVIEW CARD
========================================================= */

.preview-card {
    background: #fff2f8;

    border: 1px solid #f1dce8;

    border-radius: 14px;

    padding: 12px;
}

.preview-heading {
    display: flex;
    align-items: flex-start;

    gap: 7px;
}

.preview-icon {
    color: #d91f61;

    font-size: 15px;

    line-height: 1;
}

.preview-title {
    color: #c91c5a;

    font-size: 11px;

    font-weight: 800;
}

.preview-subtitle {
    margin-top: 2px;

    color: #9b8d9e;

    font-size: 8.5px;
}


/* =========================================================
   TRANSPARENT PREVIEW
========================================================= */

.preview-area {
    width: 100%;
    height: 214px;

    margin-top: 10px;

    border-radius: 9px;

    overflow: hidden;

    display: flex;
    align-items: center;
    justify-content: center;

    background-color: #fff;

    background-image:
        linear-gradient(
            45deg,
            #eeeeee 25%,
            transparent 25%
        ),
        linear-gradient(
            -45deg,
            #eeeeee 25%,
            transparent 25%
        ),
        linear-gradient(
            45deg,
            transparent 75%,
            #eeeeee 75%
        ),
        linear-gradient(
            -45deg,
            transparent 75%,
            #eeeeee 75%
        );

    background-size: 18px 18px;

    background-position:
        0 0,
        0 9px,
        9px -9px,
        -9px 0;
}

.preview-placeholder {
    display: flex;
    flex-direction: column;

    align-items: center;
    justify-content: center;

    text-align: center;

    color: #aaa0aa;

    font-size: 10px;
}

.preview-placeholder-icon {
    width: 43px;
    height: 43px;

    margin-bottom: 6px;

    display: flex;
    align-items: center;
    justify-content: center;

    font-size: 34px;
}

#previewImage {
    display: none;

    max-width: 82%;
    max-height: 82%;

    object-fit: contain;

    filter:
        drop-shadow(
            0 5px 10px rgba(217,31,97,.10)
        );
}


/* =========================================================
   INFORMATION CARD
========================================================= */

.info-card {
    margin-top: 11px;

    padding: 11px;

    border-radius: 11px;

    background:
        linear-gradient(
            135deg,
            #f0efff,
            #f4f2ff
        );
}

.info-heading {
    display: flex;
    align-items: center;

    gap: 7px;

    margin-bottom: 5px;

    color: #3d3772;

    font-size: 10px;
    font-weight: 800;
}

.info-heading-icon {
    font-size: 12px;
}

.info-list {
    margin: 0;

    padding-left: 17px;

    color: #77718d;

    font-size: 8.5px;

    line-height: 1.65;
}


/* =========================================================
   ERROR
========================================================= */

.error {
    margin-top: 4px;

    color: #d52260;

    font-size: 9px;
}


/* =========================================================
   FILE NAME
========================================================= */

.file-selected {
    display: none;

    margin-top: 6px;

    padding: 5px 9px;

    border-radius: 7px;

    background: #fff0f7;

    color: #c91c5a;

    font-size: 9px;

    font-weight: 600;
}


/* =========================================================
   RESPONSIVE
========================================================= */

@media (max-width: 1000px) {

    .create-layout {
        grid-template-columns: 1fr;
    }

    .create-decoration {
        display: none;
    }

    .right-column {
        width: 100%;
    }

}


@media (max-width: 650px) {

    .create-page {
        padding: 15px 12px 30px;
    }

    .create-title {
        font-size: 24px;
    }

    .form-row {
        grid-template-columns: 1fr;
    }

    .button-row {
        grid-template-columns: 1fr;
    }

    .upload-info {
        font-size: 8px;
    }

}


/* =========================================================
   DRAG ACTIVE
========================================================= */

.upload-box.dragging {
    border-color: #d91f61;

    background: #ffeaf5;

    transform: scale(1.01);
}

</style>


<div class="create-page">

    {{-- =====================================================
         HEADER
    ====================================================== --}}

    <div class="create-header">

        <div class="header-left">

            <a
                href="{{ route('stickers.index') }}"
                class="back-link"
            >

                <span class="back-arrow">
                    ←
                </span>

                Kembali ke Kelola Stiker

            </a>


            <h1 class="create-title">
                Tambah Stiker
            </h1>

            <p class="create-subtitle">
                Upload dan atur stiker baru untuk studio photobooth PovStudio.
            </p>

        </div>


        <div class="create-decoration">

            Same People<br>

            More Memories ♡

        </div>

    </div>



    {{-- =====================================================
         FORM
    ====================================================== --}}

    <form
        action="{{ route('stickers.store') }}"
        method="POST"
        enctype="multipart/form-data"
    >

        @csrf


        <div class="create-layout">


            {{-- =================================================
                 LEFT
            ================================================== --}}

            <div class="create-card">


                {{-- ===============================
                     GAMBAR STIKER
                ================================ --}}

                <div class="field">

                    <label class="field-label">

                        Gambar Stiker

                        <span class="required">
                            *
                        </span>

                    </label>


                    <div class="upload-wrapper">

                        <label
                            for="gambar"
                            class="upload-box"
                            id="uploadBox"
                        >

                            <div class="upload-icon">
                                ☁️
                            </div>

                            <div class="upload-title">
                                Drag & drop gambar stiker di sini
                            </div>

                            <div class="upload-subtitle">
                                atau klik untuk memilih file
                            </div>

                        </label>


                        <input
                            type="file"
                            id="gambar"
                            name="gambar"
                            accept="image/png,image/jpeg,image/webp"
                            onchange="previewSticker(event)"
                        >


                        <div
                            class="file-selected"
                            id="fileSelected"
                        ></div>


                        <div class="upload-info">

                            <span class="info-icon">
                                ⓘ
                            </span>

                            <span>
                                Format yang didukung: PNG (transparan)
                            </span>

                            <span class="separator">
                                |
                            </span>

                            <span>
                                Ukuran maksimal: 2 MB
                            </span>

                            <span class="separator">
                                |
                            </span>

                            <span>
                                Rekomendasi: 512 × 512 px
                            </span>

                        </div>


                        @error('gambar')

                            <div class="error">
                                {{ $message }}
                            </div>

                        @enderror

                    </div>

                </div>



                {{-- ===============================
                     NAMA + KATEGORI
                ================================ --}}

                <div class="form-row">


                    {{-- NAMA --}}

                    <div class="field">

                        <label class="field-label">

                            Nama Stiker

                            <span class="required">
                                *
                            </span>

                        </label>


                        <div class="input-wrapper">

                            <span class="input-icon">
                                ☺
                            </span>

                            <input
                                type="text"
                                name="nama"
                                class="input-control"
                                placeholder="Masukkan nama stiker"
                                value="{{ old('nama') }}"
                            >

                        </div>


                        @error('nama')

                            <div class="error">
                                {{ $message }}
                            </div>

                        @enderror

                    </div>



                    {{-- KATEGORI --}}

                    <div class="field">

                        <label class="field-label">

                            Kategori

                            <span class="required">
                                *
                            </span>

                        </label>


                        <div class="input-wrapper">

                            <span class="input-icon">
                                ▱
                            </span>

                            <select
                                name="kategori"
                                class="input-control"
                            >

                                <option value="">
                                    Pilih kategori
                                </option>


                                @foreach($categories as $category)

                                    <option
                                        value="{{ $category }}"
                                        {{ old('kategori') == $category ? 'selected' : '' }}
                                    >
                                        {{ $category }}
                                    </option>

                                @endforeach

                            </select>

                        </div>


                        @error('kategori')

                            <div class="error">
                                {{ $message }}
                            </div>

                        @enderror

                    </div>

                </div>



                {{-- ===============================
                     DESKRIPSI
                ================================ --}}

                <div class="field">

                    <label class="field-label">
                        Deskripsi (Opsional)
                    </label>


                    <div class="textarea-wrapper">

                        <span class="textarea-icon">
                            ✎
                        </span>


                        <textarea
                            name="deskripsi"
                            id="deskripsi"
                            class="input-control with-icon"
                            maxlength="200"
                            placeholder="Tambahkan deskripsi stiker..."
                            oninput="updateCounter()"
                        >{{ old('deskripsi') }}</textarea>


                        <div class="counter">

                            <span id="counter">
                                0
                            </span>

                            /200

                        </div>

                    </div>

                </div>



                {{-- ===============================
                     TAG + STATUS
                ================================ --}}

                <div class="form-row">


                    {{-- TAG --}}

                    <div class="field">

                        <label class="field-label">
                            Tag (Pisahkan dengan koma)
                        </label>


                        <div class="input-wrapper">

                            <span class="input-icon">
                                🏷️
                            </span>

                            <input
                                type="text"
                                name="tag"
                                class="input-control"
                                placeholder="misal: cute, love, pastel, kpop"
                                value="{{ old('tag') }}"
                            >

                        </div>

                    </div>



                    {{-- STATUS --}}

                    <div class="field">

                        <label class="field-label">
                            Status Stiker
                        </label>


                        <div class="status-area">


                            <label class="switch">

                                <input
                                    type="checkbox"
                                    id="statusSwitch"
                                    checked
                                    onchange="changeStatus()"
                                >

                                <span class="slider"></span>

                            </label>


                            <div>

                                <div
                                    class="status-text"
                                    id="statusText"
                                >
                                    Aktif
                                </div>


                                <div class="status-help">
                                    Stiker akan tersedia di aplikasi
                                </div>

                            </div>

                        </div>


                        <input
                            type="hidden"
                            name="status"
                            id="status"
                            value="Aktif"
                        >

                    </div>

                </div>



                {{-- ===============================
                     BUTTON
                ================================ --}}

                <div class="button-row">


                    <a
                        href="{{ route('stickers.index') }}"
                        class="btn btn-cancel"
                    >
                        Batal
                    </a>


                    <button
                        type="submit"
                        class="btn btn-save"
                    >

                        ＋

                        <span style="margin-left: 7px;">
                            Simpan Stiker
                        </span>

                    </button>

                </div>


            </div>



            {{-- =================================================
                 RIGHT
            ================================================== --}}

            <div class="right-column">


                {{-- ===============================
                     PREVIEW
                ================================ --}}

                <div class="preview-card">


                    <div class="preview-heading">

                        <div class="preview-icon">
                            ◉
                        </div>


                        <div>

                            <div class="preview-title">
                                Preview Stiker
                            </div>

                            <div class="preview-subtitle">
                                Tampilan stiker setelah diunggah
                            </div>

                        </div>

                    </div>


                    <div
                        class="preview-area"
                        id="previewArea"
                    >


                        <div
                            class="preview-placeholder"
                            id="previewPlaceholder"
                        >

                            <div class="preview-placeholder-icon">
                                🖼️
                            </div>

                            <div>
                                Belum ada gambar
                            </div>

                        </div>


                        <img
                            id="previewImage"
                            src=""
                            alt="Preview Stiker"
                        >

                    </div>

                </div>



                {{-- ===============================
                     INFO
                ================================ --}}

                <div class="info-card">


                    <div class="info-heading">

                        <span class="info-heading-icon">
                            💡
                        </span>

                        Pastikan gambar:

                    </div>


                    <ul class="info-list">

                        <li>
                            Menggunakan format PNG dengan background transparan
                        </li>

                        <li>
                            Resolusi yang disarankan 512 × 512 px
                        </li>

                        <li>
                            Ukuran file maksimal 2 MB
                        </li>

                        <li>
                            Desain sesuai tema dan tidak melanggar hak cipta
                        </li>

                        <li>
                            Stiker akan digunakan oleh pengguna di aplikasi
                        </li>

                    </ul>

                </div>


            </div>


        </div>

    </form>

</div>



<script>

/* =========================================================
   PREVIEW STIKER
========================================================= */

function previewSticker(event) {

    const file = event.target.files[0];

    if (!file) {
        return;
    }


    const preview = document.getElementById('previewImage');

    const placeholder =
        document.getElementById('previewPlaceholder');

    const fileSelected =
        document.getElementById('fileSelected');


    /* CEK UKURAN */

    const maxSize = 2 * 1024 * 1024;

    if (file.size > maxSize) {

        alert('Ukuran file maksimal 2 MB.');

        event.target.value = '';

        return;
    }


    /* CEK FORMAT */

    const allowedTypes = [
        'image/png',
        'image/jpeg',
        'image/webp'
    ];

    if (!allowedTypes.includes(file.type)) {

        alert(
            'Format gambar harus PNG, JPG/JPEG, atau WEBP.'
        );

        event.target.value = '';

        return;
    }


    /* NAMA FILE */

    fileSelected.innerText =
        '📎 ' + file.name;

    fileSelected.style.display =
        'block';


    /* PREVIEW */

    const reader = new FileReader();


    reader.onload = function(e) {

        preview.src =
            e.target.result;

        preview.style.display =
            'block';

        placeholder.style.display =
            'none';

    };


    reader.readAsDataURL(file);

}



/* =========================================================
   DESCRIPTION COUNTER
========================================================= */

function updateCounter() {

    const textarea =
        document.getElementById('deskripsi');

    const counter =
        document.getElementById('counter');


    counter.innerText =
        textarea.value.length;

}



/* =========================================================
   STATUS
========================================================= */

function changeStatus() {

    const checkbox =
        document.getElementById('statusSwitch');

    const status =
        document.getElementById('status');

    const text =
        document.getElementById('statusText');


    if (checkbox.checked) {

        status.value =
            'Aktif';

        text.innerText =
            'Aktif';

    } else {

        status.value =
            'Nonaktif';

        text.innerText =
            'Nonaktif';

    }

}



/* =========================================================
   DRAG & DROP
========================================================= */

const uploadBox =
    document.getElementById('uploadBox');

const gambarInput =
    document.getElementById('gambar');


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


        if (files.length > 0) {

            gambarInput.files =
                files;

            previewSticker({
                target: gambarInput
            });

        }

    }
);



/* =========================================================
   PAGE LOAD
========================================================= */

document.addEventListener(
    'DOMContentLoaded',
    function() {

        updateCounter();

        changeStatus();

    }
);

</script>

@endsection