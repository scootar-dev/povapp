<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('frames', function (Blueprint $table) {
            if (!Schema::hasColumn('frames', 'overlay_path')) {
                $table->string('overlay_path')->nullable()->after('gambar');
            }
            if (!Schema::hasColumn('frames', 'thumbnail_path')) {
                $table->string('thumbnail_path')->nullable()->after('gambar');
            }
        });

        DB::table('frames')->where('id', 2)->update([
            'overlay_path' => 'frames/JgvejHaq3wYtKZvVRRU24Vn5cM9SxImK1KvIl6bN.png',
            'thumbnail_path' => 'frames/JgvejHaq3wYtKZvVRRU24Vn5cM9SxImK1KvIl6bN.png',
        ]);
    }

    public function down(): void
    {
        DB::table('frames')->where('id', 2)->update([
            'overlay_path' => null,
            'thumbnail_path' => null,
        ]);
    }
};