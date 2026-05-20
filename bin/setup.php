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
echo "Running seed...\n";
$db->exec(file_get_contents(__DIR__ . '/../database/seed.sql'));
echo "Done! Database ready at: " . ($_ENV['DB_PATH'] ?? 'database/app.sqlite') . "\n";
