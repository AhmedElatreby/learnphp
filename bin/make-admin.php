<?php
/**
 * Bootstrap an admin user.
 * Usage: php bin/make-admin.php <email>
 *
 * Example: php bin/make-admin.php you@example.com
 *
 * The user must already be registered. Run php bin/setup.php first.
 */
declare(strict_types=1);
require_once __DIR__ . '/../vendor/autoload.php';

// Load .env
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (str_starts_with(trim($line), '#') || !str_contains($line, '=')) continue;
        [$key, $value] = explode('=', $line, 2);
        $key   = trim($key);
        $value = trim($value);
        if (preg_match('/^(["\'])(.*)\\1$/', $value, $m)) $value = $m[2];
        putenv("{$key}={$value}");
        $_ENV[$key] = $value;
    }
}

$email = trim($argv[1] ?? '');
if ($email === '') {
    echo "Usage: php bin/make-admin.php <email>\n";
    exit(1);
}

$db = \App\Database::getInstance();

$user = $db->query('SELECT id, username, is_admin FROM users WHERE email = ?', [$email])->fetch();
if (!$user) {
    echo "Error: no user found with email '{$email}'.\n";
    echo "Register first at /register, then run this script.\n";
    exit(1);
}

if ((int)$user['is_admin'] === 1) {
    echo "'{$user['username']}' ({$email}) is already an admin.\n";
    exit(0);
}

$db->query('UPDATE users SET is_admin = 1 WHERE email = ?', [$email]);
echo "Done! '{$user['username']}' ({$email}) is now an admin.\n";
echo "Log in and visit /admin/challenges to manage content.\n";
