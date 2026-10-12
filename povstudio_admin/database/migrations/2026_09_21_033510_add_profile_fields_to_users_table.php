<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {

            if (!Schema::hasColumn('users', 'username')) {
                $table->string('username', 50)
                    ->unique()
                    ->after('name');
            }

            if (!Schema::hasColumn('users', 'phone')) {
                $table->string('phone', 20)
                    ->nullable()
                    ->after('email');
            }

            if (!Schema::hasColumn('users', 'address')) {
                $table->text('address')
                    ->nullable()
                    ->after('phone');
            }

            if (!Schema::hasColumn('users', 'birth_date')) {
                $table->date('birth_date')
                    ->nullable()
                    ->after('address');
            }

            if (!Schema::hasColumn('users', 'gender')) {
                $table->enum('gender', [
                    'Laki-laki',
                    'Perempuan'
                ])
                ->nullable()
                ->after('birth_date');
            }

            if (!Schema::hasColumn('users', 'role')) {
                $table->enum('role', [
                    'user',
                    'admin'
                ])
                ->default('user')
                ->after('gender');
            }

            if (!Schema::hasColumn('users', 'status')) {
                $table->enum('status', [
                    'aktif',
                    'nonaktif'
                ])
                ->default('aktif')
                ->after('role');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {

            $columns = [
                'username',
                'phone',
                'address',
                'birth_date',
                'gender',
                'role',
                'status'
            ];

            foreach ($columns as $column) {
                if (Schema::hasColumn('users', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }
};