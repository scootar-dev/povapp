<?php

namespace App\Console\Commands;

use App\Models\Studio;
use Illuminate\Console\Command;
use Illuminate\Support\Str;

class GenerateStudioToken extends Command
{
    protected $signature = 'studio:token {name : Nama studio} {--camera=internal : internal | dslr}';

    protected $description = 'Buat studio baru dan cetak device_token sekali untuk dipakai app kiosk/mobile.';

    public function handle(): int
    {
        $name = (string) $this->argument('name');
        $camera = (string) $this->option('camera');
        if (! in_array($camera, ['internal', 'dslr'], true)) {
            $this->error('--camera hanya boleh internal atau dslr.');

            return self::FAILURE;
        }

        $token = Str::random(64);
        $studio = Studio::create([
            'name' => $name,
            'camera_source' => $camera,
            'device_token' => $token,
            'is_active' => true,
        ]);

        $this->info("Studio '{$studio->name}' dibuat (id={$studio->id}).");
        $this->warn('Simpan token ini — hanya ditampilkan sekali:');
        $this->line($token);

        return self::SUCCESS;
    }
}