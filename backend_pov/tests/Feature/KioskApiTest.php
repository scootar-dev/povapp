<?php

namespace Tests\Feature;

use App\Models\Frame;
use App\Models\Studio;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class KioskApiTest extends TestCase
{
    use RefreshDatabase;

    protected Studio $studio;
    protected string $token;

    protected function setUp(): void
    {
        parent::setUp();

        $this->token = 'test-device-token-12345';
        $this->studio = Studio::create([
            'name' => 'Studio Test',
            'location' => 'Jakarta',
            'camera_source' => 'internal',
            'device_token' => $this->token,
            'is_active' => true,
        ]);
    }

    public function test_cannot_access_kiosk_without_valid_token(): void
    {
        $response = $this->getJson('/api/kiosk/frames');

        $response->assertStatus(401);
    }

    public function test_can_list_active_frames(): void
    {
        Frame::create([
            'name' => 'Frame 4R Strip',
            'category' => 'Classic',
            'overlay_path' => 'frames/overlay1.png',
            'photo_count' => 3,
            'output_width_px' => 1200,
            'output_height_px' => 1800,
            'dpi' => 300,
            'print_size' => '4r',
            'is_active' => true,
        ]);

        $response = $this->withHeader('Authorization', 'Bearer ' . $this->token)
            ->getJson('/api/kiosk/frames');

        $response->assertStatus(200)
            ->assertJsonCount(1, 'data');
    }

    public function test_can_create_session(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer ' . $this->token)
            ->postJson('/api/kiosk/sessions', [
                'retake_quota' => 3,
            ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.status', 'started')
            ->assertJsonPath('data.retake_quota', 3);
    }
}
