<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('frames', function (Blueprint $table) {
            $table->unsignedTinyInteger('photo_count')->default(1)->after('total_penggunaan');
            $table->unsignedInteger('output_width_px')->default(1200)->after('photo_count');
            $table->unsignedInteger('output_height_px')->default(1800)->after('output_width_px');
            $table->unsignedSmallInteger('dpi')->default(300)->after('output_height_px');
            $table->string('print_size')->default('4r')->after('dpi');
            $table->boolean('is_active')->default(true)->after('print_size');
        });
    }

    public function down(): void
    {
        Schema::table('frames', function (Blueprint $table) {
            $table->dropColumn([
                'photo_count', 'output_width_px', 'output_height_px',
                'dpi', 'print_size', 'is_active'
            ]);
        });
    }
};
