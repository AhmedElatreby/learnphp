<?php
declare(strict_types=1);
require_once __DIR__ . '/../vendor/autoload.php';

$_ENV['APP_ENV'] = 'test';
$_ENV['DB_PATH'] = ':memory:';
