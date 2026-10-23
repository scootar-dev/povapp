<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('print_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('session_id')->constrained()->cascadeOnDelete();
            $table->foreignId('output_id')->constrained()->cascadeOnDelete();
            $table->string('printer')->nullable();
            $table->enum('status', ['pending', 'printing', 'completed', 'failed'])->default('pending');
            $table->unsignedSmallInteger('copies')->default(1);
            $table->text('error_message')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('print_logs');
    }
};
