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
            $table->string('event_type')->default('general'); // wedding, corporate, birthday, general
            $table->unsignedInteger('shoot_countdown_seconds')->default(5);
            $table->unsignedInteger('prep_timer_seconds')->default(10);
            $table->unsignedTinyInteger('retake_quota')->default(2);
            $table->string('kiosk_pin_code')->default('1234');
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
