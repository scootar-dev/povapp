<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('frame_slots', function (Blueprint $table) {
            $table->id();
            $table->foreignId('frame_id')->constrained()->cascadeOnDelete();
            $table->unsignedTinyInteger('slot_index');
            $table->unsignedInteger('x');
            $table->unsignedInteger('y');
            $table->unsignedInteger('width');
            $table->unsignedInteger('height');
            $table->decimal('rotation', 5, 2)->default(0);
            $table->timestamps();

            $table->unique(['frame_id', 'slot_index']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('frame_slots');
    }
};
