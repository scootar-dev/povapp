<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('share_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('session_id')->constrained();
            $table->enum('channel', ['whatsapp', 'email', 'qr_download']);
            $table->string('recipient');
            $table->enum('status', ['queued', 'sent', 'failed'])->default('queued');
            $table->string('provider')->nullable(); // fonnte, mailgun, dst
            $table->text('error_message')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('share_logs');
    }
};
