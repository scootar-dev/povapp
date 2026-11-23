<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class AuthLoginTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        config([
            'services.recaptcha.site_key' => 'test-site-key',
            'services.recaptcha.secret_key' => 'test-secret-key',
        ]);

        Schema::dropIfExists('users');
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('username', 50)->unique();
            $table->string('email')->unique();
            $table->string('password');
            $table->string('role')->default('user');
            $table->string('status')->default('aktif');
            $table->rememberToken();
            $table->timestamps();
        });
    }

    private function createAdmin(): User
    {
        return User::create([
            'name' => 'Admin PovStudio',
            'username' => 'adminpov',
            'email' => 'admin@povstudio.test',
            'password' => Hash::make('password123'),
            'role' => 'admin',
            'status' => 'aktif',
        ]);
    }

    private function fakeCaptcha(bool $success, array $errorCodes = []): void
    {
        $body = ['success' => $success];

        if ($errorCodes !== []) {
            $body['error-codes'] = $errorCodes;
        }

        Http::fake([
            '*' => Http::response($body),
        ]);
    }

    public function test_login_page_displays_recaptcha_widget(): void
    {
        $response = $this->get('/login');

        $response->assertOk();
        $response->assertSee('g-recaptcha');
        $response->assertSee('test-site-key');
    }

    public function test_login_requires_captcha_token(): void
    {
        $this->createAdmin();
        $this->fakeCaptcha(true);

        $response = $this->post('/login', [
            'login' => 'admin@povstudio.test',
            'password' => 'password123',
        ]);

        $response->assertSessionHasErrors('g-recaptcha-response');
        $this->assertGuest();
    }

    public function test_login_fails_when_captcha_invalid(): void
    {
        $this->createAdmin();
        $this->fakeCaptcha(false, ['invalid-input-response']);

        $response = $this->post('/login', [
            'login' => 'admin@povstudio.test',
            'password' => 'password123',
            'g-recaptcha-response' => 'bad-token',
        ]);

        $response->assertSessionHasErrors('captcha');
        $this->assertGuest();
    }

    public function test_login_fails_when_captcha_expired(): void
    {
        $this->createAdmin();
        $this->fakeCaptcha(false, ['timeout-or-duplicate']);

        $response = $this->post('/login', [
            'login' => 'admin@povstudio.test',
            'password' => 'password123',
            'g-recaptcha-response' => 'expired-token',
        ]);

        $response->assertSessionHasErrors('captcha');
        $this->assertGuest();
    }

    public function test_login_fails_when_captcha_not_configured(): void
    {
        config(['services.recaptcha.secret_key' => null]);
        $this->createAdmin();

        $response = $this->post('/login', [
            'login' => 'admin@povstudio.test',
            'password' => 'password123',
            'g-recaptcha-response' => 'some-token',
        ]);

        $response->assertSessionHasErrors('captcha');
        $this->assertGuest();
    }

    public function test_login_succeeds_with_valid_captcha_and_credentials(): void
    {
        $this->createAdmin();
        $this->fakeCaptcha(true);

        $response = $this->post('/login', [
            'login' => 'admin@povstudio.test',
            'password' => 'password123',
            'g-recaptcha-response' => 'valid-token',
        ]);

        $response->assertRedirect(route('dashboard'));
        $this->assertAuthenticated();
    }

    public function test_login_fails_with_wrong_password_even_with_valid_captcha(): void
    {
        $this->createAdmin();
        $this->fakeCaptcha(true);

        $response = $this->post('/login', [
            'login' => 'admin@povstudio.test',
            'password' => 'wrong-password',
            'g-recaptcha-response' => 'valid-token',
        ]);

        $response->assertSessionHasErrors('login');
        $this->assertGuest();
    }

    public function test_login_is_rate_limited_after_five_attempts(): void
    {
        $this->createAdmin();
        $this->fakeCaptcha(true);

        $payload = [
            'login' => 'admin@povstudio.test',
            'password' => 'wrong-password',
            'g-recaptcha-response' => 'valid-token',
        ];

        for ($i = 0; $i < 5; $i++) {
            $this->post('/login', $payload);
        }

        $response = $this->post('/login', $payload);

        $response->assertSessionHasErrors([
            'login' => 'Terlalu banyak percobaan login. Silakan coba lagi dalam 1 menit.',
        ]);
        $this->assertGuest();
    }
}
