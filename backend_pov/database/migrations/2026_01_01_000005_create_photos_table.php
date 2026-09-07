<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('photos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('session_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('slot_index'); // relasi ke frame_slots.slot_index
            $table->string('file_path');
            $table->boolean('is_selected')->default(true); // false kalau di-retake & dibuang
            $table->unsignedTinyInteger('attempt_number')->default(1);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('photos');
    }
};
