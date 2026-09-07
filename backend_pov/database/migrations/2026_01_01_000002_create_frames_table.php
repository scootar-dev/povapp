<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('frames', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('category')->nullable(); // strip, 4r, grid4, dst
            $table->string('overlay_path'); // SVG/PNG transparan
            $table->string('thumbnail_path')->nullable();
            $table->unsignedTinyInteger('photo_count'); // jumlah slot foto
            $table->unsignedInteger('output_width_px');
            $table->unsignedInteger('output_height_px');
            $table->unsignedSmallInteger('dpi')->default(300);
            $table->enum('print_size', ['4r', 'strip_2x6'])->default('4r');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('frames');
    }
};
