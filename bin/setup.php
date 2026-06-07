<?php
declare(strict_types=1);
require_once __DIR__ . '/../vendor/autoload.php';

// Load .env
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (str_starts_with(trim($line), '#')) continue;
        if (!str_contains($line, '=')) continue;
        [$key, $value] = explode('=', $line, 2);
        $key   = trim($key);
        $value = trim($value);
        if (preg_match('/^(["\'])(.*)\\1$/', $value, $m)) {
            $value = $m[2];
        }
        putenv("{$key}={$value}");
        $_ENV[$key] = $value;
    }
}

$db = \App\Database::getInstance();
echo "Running schema...\n";
$db->migrate();

// Safe migration: add is_admin if the column doesn't exist yet
try {
    $db->exec("ALTER TABLE users ADD COLUMN is_admin INTEGER NOT NULL DEFAULT 0");
    echo "Migration: added is_admin column.\n";
} catch (\PDOException) {
    // Column already exists — fine
}

// Only seed if the database is empty (safe to re-run)
$count = (int) $db->query('SELECT COUNT(*) FROM languages')->fetchColumn();
if ($count === 0) {
    echo "Running seed...\n";
    $db->exec(file_get_contents(__DIR__ . '/../database/seed.sql'));
    echo "Running extended seed (topics 6–28)...\n";
    $db->exec(file_get_contents(__DIR__ . '/../database/seed_topics_6_28.sql'));
    echo "Done! Database ready at: " . ($_ENV['DB_PATH'] ?? 'database/app.sqlite') . "\n";
} else {
    // Apply the extended seed incrementally (INSERT OR IGNORE is safe to re-run)
    echo "Applying extended seed (topics 6–28)...\n";
    $db->exec(file_get_contents(__DIR__ . '/../database/seed_topics_6_28.sql'));
    echo "Done.\n";
}

// Seed admin user from env vars — safe to re-run on every deploy
$adminEmail    = $_ENV['ADMIN_EMAIL']    ?? getenv('ADMIN_EMAIL')    ?: null;
$adminPassword = $_ENV['ADMIN_PASSWORD'] ?? getenv('ADMIN_PASSWORD') ?: null;
if ($adminEmail && $adminPassword) {
    $hash = password_hash($adminPassword, PASSWORD_BCRYPT);
    $db->prepare('INSERT OR IGNORE INTO users (username, email, password_hash, is_admin) VALUES (?, ?, ?, 1)')
       ->execute(['admin', $adminEmail, $hash]);
    $db->prepare('UPDATE users SET is_admin=1, password_hash=? WHERE email=?')
       ->execute([$hash, $adminEmail]);
    echo "Admin user seeded: $adminEmail\n";
}
