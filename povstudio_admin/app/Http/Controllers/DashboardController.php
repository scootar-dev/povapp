<?php

namespace App\Http\Controllers;

use App\Models\Frame;

class DashboardController extends Controller
{
    public function index()
{
    $totalFrames = \App\Models\Frame::count();

    $activeFrames = \App\Models\Frame::where('status', true)->count();

    $totalUsage = 0;

    $totalCategories = \App\Models\Frame::distinct('kategori')->count('kategori');

    $recentFrames = \App\Models\Frame::latest()->take(5)->get();

    return view('dashboard', compact(
        'totalFrames',
        'activeFrames',
        'totalUsage',
        'totalCategories',
        'recentFrames'
    ));
}
}