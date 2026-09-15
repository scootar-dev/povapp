<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('studios', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('location')->nullable();
            $table->enum('camera_source', ['internal', 'dslr'])->default('internal');
            $table->string('printer_driver')->nullable(); // 'epson_airprint' | 'epson_windows'
            $table->string('welcome_overlay_path')->nullable(); // Overlay desain khusus welcome screen
            $table->string('device_token')->unique(); // dipakai auth:studio-token
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('studios');
    }
};
