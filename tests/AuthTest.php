<?php
namespace Tests;

use App\Auth;
use App\Database;
use PHPUnit\Framework\TestCase;

class AuthTest extends TestCase
{
    protected function setUp(): void
    {
        Database::reset();
        Database::getInstance()->migrate();
        // Seed PHP language
        Database::getInstance()->exec(
            "INSERT INTO languages (name,slug,icon,is_active) VALUES ('PHP','php','🐘',1)"
        );
    }

    public function test_generates_guest_token(): void
    {
        $token = Auth::guestToken();
        $this->assertMatchesRegularExpression('/^[a-f0-9]{64}$/', $token);
    }

    public function test_register_creates_user(): void
    {
        $userId = Auth::register('alice', 'alice@example.com', 'secret123');
        $this->assertIsInt($userId);
        $this->assertGreaterThan(0, $userId);
    }

    public function test_login_returns_user_on_valid_credentials(): void
    {
        Auth::register('bob', 'bob@example.com', 'mypassword');
        $user = Auth::attempt('bob@example.com', 'mypassword');
        $this->assertSame('bob', $user['username']);
    }

    public function test_login_returns_null_on_wrong_password(): void
    {
        Auth::register('carol', 'carol@example.com', 'rightpass');
        $user = Auth::attempt('carol@example.com', 'wrongpass');
        $this->assertNull($user);
    }
}
