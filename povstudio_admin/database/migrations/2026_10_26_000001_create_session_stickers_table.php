<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('session_stickers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('session_id')->constrained()->cascadeOnDelete();
            $table->foreignId('sticker_id')->constrained()->cascadeOnDelete();
            $table->decimal('x', 8, 6)->default(0.5);
            $table->decimal('y', 8, 6)->default(0.5);
            $table->decimal('size', 8, 6)->default(0.18);
            $table->decimal('rotation', 5, 2)->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('session_stickers');
    }
};
