<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
   public function up(): void
{
    Schema::table('frames', function (Blueprint $table) {
        $table->string('kategori')->nullable()->after('gambar');
        $table->text('deskripsi')->nullable()->after('kategori');
        $table->string('tag')->nullable()->after('deskripsi');
        $table->integer('total_penggunaan')->default(0)->after('tag');
    });
}

    /**
     * Reverse the migrations.
     */
   public function down(): void
{
    Schema::table('frames', function (Blueprint $table) {
        $table->dropColumn([
            'kategori',
            'deskripsi',
            'tag',
            'total_penggunaan',
        ]);
    });
}
};
