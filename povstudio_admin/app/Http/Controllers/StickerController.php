<?php

namespace App\Http\Controllers;

use App\Models\Sticker;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class StickerController extends Controller
{
    public function index()
    {
        $stickers = Sticker::latest()->get();

        $totalStickers = Sticker::count();

        $activeStickers = Sticker::whereIn('status', [1, '1', 'Aktif'])->count();

        $totalCategories = Sticker::whereNotNull('kategori')
            ->where('kategori', '!=', '')
            ->distinct('kategori')
            ->count('kategori');

        $popularSticker = Sticker::orderByDesc('penggunaan')
            ->first();

        return view('stickers.index', compact(
            'stickers',
            'totalStickers',
            'activeStickers',
            'totalCategories',
            'popularSticker'
        ));
    }

    public function create()
    {
        $categories = [
            'Emoji',
            'Teks',
            'Karakter',
            'Dekorasi',
            'Event',
            'Seasonal'
        ];

        return view('stickers.create', compact('categories'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'gambar' => 'required|image|mimes:png,jpg,jpeg|max:2048',
            'nama' => 'required|string|max:255',
            'kategori' => 'required|string|max:100',
            'deskripsi' => 'nullable|string|max:200',
            'tag' => 'nullable|string|max:255',
            'status' => 'required|in:Aktif,Nonaktif',
        ]);

        $gambar = $request->file('gambar')
            ->store('stickers', 'public');

        Sticker::create([
            'nama' => $request->nama,
            'gambar' => $gambar,
            'kategori' => $request->kategori,
            'deskripsi' => $request->deskripsi,
            'tag' => $request->tag,
            'status' => $request->status === 'Aktif' ? 1 : 0,
            'penggunaan' => 0,
        ]);

        return redirect()
            ->route('stickers.index')
            ->with('success', 'Stiker berhasil ditambahkan.');
    }
}