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

    public function test_claim_guest_progress_links_token_to_user(): void
    {
        // Set up: a challenge to link progress to
        $db = Database::getInstance();
        $db->query('INSERT INTO topics (language_id,name,slug,description,sort_order) VALUES (1,"Arrays","arrays","",1)');
        $db->query('INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation) VALUES (1,"C","Q","fill_blank","beginner","a","e")');

        // Create guest progress row
        $db->query('INSERT INTO user_progress (session_token,challenge_id,passed,attempts) VALUES ("guesttoken123",1,1,1)');

        // Register user and claim progress
        $userId = Auth::register('dave', 'dave@example.com', 'pass123');
        Auth::claimGuestProgress('guesttoken123', $userId);

        // Verify progress row now has user_id
        $row = $db->query('SELECT user_id FROM user_progress WHERE session_token = ?', ['guesttoken123'])->fetch();
        $this->assertSame($userId, (int)$row['user_id']);
    }
}
