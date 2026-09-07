<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sessions', function (Blueprint $table) {
            $table->id();
            $table->uuid('session_code')->unique(); // dipakai di QR code & public download
            $table->foreignId('studio_id')->constrained();
            $table->foreignId('frame_id')->nullable()->constrained();
            $table->string('filter_applied')->default('original');
            $table->unsignedTinyInteger('retake_quota')->default(2);
            $table->unsignedTinyInteger('retake_used')->default(0);
            $table->enum('status', [
                'started', 'shooting', 'reviewing', 'rendering',
                'printed', 'shared', 'completed', 'abandoned'
            ])->default('started');
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sessions');
    }
};
