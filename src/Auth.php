<?php
namespace App;

class Auth
{
    public static function guestToken(): string
    {
        return bin2hex(random_bytes(32));
    }

    public static function register(string $username, string $email, string $password): int
    {
        $db   = Database::getInstance();
        $hash = password_hash($password, PASSWORD_BCRYPT);
        $db->query(
            'INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)',
            [$username, $email, $hash]
        );
        return (int) $db->lastInsertId();
    }

    public static function attempt(string $email, string $password): ?array
    {
        $db   = Database::getInstance();
        $row  = $db->query('SELECT * FROM users WHERE email = ?', [$email])->fetch();
        if (!$row || !password_verify($password, $row['password_hash'])) {
            return null;
        }
        // Return only safe fields — never expose password_hash to callers
        return ['id' => $row['id'], 'username' => $row['username'], 'email' => $row['email']];
    }

    public static function user(): ?array
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        return $_SESSION['user'] ?? null;
    }

    public static function login(array $user): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        session_regenerate_id(true);
        $_SESSION['user'] = ['id' => $user['id'], 'username' => $user['username']];
    }

    public static function logout(): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $_SESSION = [];
        session_destroy();
    }

    /**
     * Guard: throws RuntimeException if the current session user is not an admin.
     * Controllers catch this and return 403. Using an exception (not exit) keeps it testable.
     */
    public static function requireAdmin(): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $user = $_SESSION['user'] ?? null;
        if (!$user || empty($user['is_admin'])) {
            throw new \RuntimeException('Forbidden', 403);
        }
    }

    public static function sessionToken(): string
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        if (empty($_SESSION['guest_token'])) {
            $_SESSION['guest_token'] = self::guestToken();
        }
        return $_SESSION['guest_token'];
    }

    /** After register/login: link guest progress to the new user account */
    public static function claimGuestProgress(string $token, int $userId): void
    {
        Database::getInstance()->query(
            'UPDATE user_progress SET user_id = ? WHERE session_token = ? AND user_id IS NULL',
            [$userId, $token]
        );
    }
}
