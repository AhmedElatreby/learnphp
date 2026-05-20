<?php
declare(strict_types=1);

require_once __DIR__ . '/../vendor/autoload.php';

// Load .env if present
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (str_starts_with(trim($line), '#')) continue;
        if (!str_contains($line, '=')) continue;
        [$key, $value] = explode('=', $line, 2);
        $key   = trim($key);
        $value = trim($value);
        // Strip surrounding quotes from value
        if (preg_match('/^(["\'])(.*)\\1$/', $value, $m)) {
            $value = $m[2];
        }
        putenv("{$key}={$value}");
        $_ENV[$key] = $value;
    }
}

$router = new \App\Router();
$router->dispatch();
