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
        // This migration is a duplicate of 2019_12_14_000001_create_personal_access_tokens_table.
        // Keep it as a no-op so existing databases can mark it as migrated without trying
        // to create the Sanctum table twice.
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // No-op: the real Sanctum table is managed by
        // 2019_12_14_000001_create_personal_access_tokens_table.
    }
};
