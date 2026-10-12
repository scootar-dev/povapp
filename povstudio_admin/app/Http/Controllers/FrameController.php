<?php

namespace App\Http\Controllers;

use App\Models\Frame;
use Illuminate\Http\Request;

class FrameController extends Controller
{
    public function index()
    {
        $frames = Frame::latest()->get();

        return view('frames.index', compact('frames'));
    }


    public function create()
    {
        return view('frames.create');
    }


    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required|string|max:255',
            'gambar' => 'required|image|mimes:png,jpg,jpeg|max:5120',
            'kategori' => 'required|string|max:100',
            'deskripsi' => 'nullable|string',
            'tag' => 'nullable|string|max:255',
            'status' => 'required|boolean',
        ]);


        $gambar = null;

        if ($request->hasFile('gambar')) {
            $gambar = $request->file('gambar')
                ->store('frames', 'public');
        }


        Frame::create([
            'nama' => $request->nama,
            'gambar' => $gambar,
            'kategori' => $request->kategori,
            'deskripsi' => $request->deskripsi,
            'tag' => $request->tag,
            'status' => $request->status,
            'total_penggunaan' => 0,
        ]);


        return redirect()
            ->route('frames.index')
            ->with('success', 'Frame berhasil ditambahkan.');
    }


    public function edit(Frame $frame)
    {
        return view('frames.edit', compact('frame'));
    }


    public function update(Request $request, Frame $frame)
    {
        $request->validate([
            'nama' => 'required|string|max:255',
            'gambar' => 'nullable|image|mimes:png,jpg,jpeg|max:5120',
            'kategori' => 'required|string|max:100',
            'deskripsi' => 'nullable|string',
            'tag' => 'nullable|string|max:255',
            'status' => 'required|boolean',
        ]);


        $data = [
            'nama' => $request->nama,
            'kategori' => $request->kategori,
            'deskripsi' => $request->deskripsi,
            'tag' => $request->tag,
            'status' => $request->status,
        ];


        if ($request->hasFile('gambar')) {

            $data['gambar'] = $request->file('gambar')
                ->store('frames', 'public');

        }


        $frame->update($data);


        return redirect()
            ->route('frames.index')
            ->with('success', 'Frame berhasil diperbarui.');
    }


    public function destroy(Frame $frame)
    {
        $frame->delete();

        return redirect()
            ->route('frames.index')
            ->with('success', 'Frame berhasil dihapus.');
    }
}