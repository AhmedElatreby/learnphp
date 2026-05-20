# LearnPHP Platform Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a free PHP learning platform with challenges, diagnostic tests, and a teach-on-wrong-answer system that ensures genuine understanding.

**Architecture:** Plain PHP 8.x front controller with manual routing, SQLite via PDO, HTMX for dynamic updates, php-wasm for in-browser code execution. Single `public/index.php` entry point dispatches to Controllers which render PHP view templates.

**Tech Stack:** PHP 8.x, SQLite3, HTMX (CDN), php-wasm (CDN), Vanilla CSS, Composer (autoloading only)

---

## File Map

```
learnphp/
├── public/
│   ├── index.php              ← front controller
│   └── assets/
│       ├── css/
│       │   ├── main.css       ← base styles, CSS variables, dark theme
│       │   ├── layout.css     ← responsive grid, breakpoints
│       │   └── challenge.css  ← challenge page specific styles
│       └── js/
│           └── runner.js      ← php-wasm integration
├── src/
│   ├── Router.php             ← URL → controller mapping
│   ├── Database.php           ← PDO singleton, query helpers
│   ├── Auth.php               ← session management, login/register/guest token
│   ├── Controllers/
│   │   ├── HomeController.php
│   │   ├── AuthController.php
│   │   ├── TopicController.php
│   │   ├── ChallengeController.php
│   │   ├── DiagnosticController.php
│   │   ├── DashboardController.php
│   │   └── AdminController.php
│   ├── Models/
│   │   ├── User.php
│   │   ├── Topic.php
│   │   ├── Challenge.php
│   │   ├── Progress.php
│   │   └── Tip.php
│   └── Views/
│       ├── layout.php         ← shared HTML shell (nav, head, foot)
│       ├── home.php
│       ├── topics.php
│       ├── topic.php
│       ├── challenge.php
│       ├── diagnostic.php
│       ├── diagnostic-results.php
│       ├── dashboard.php
│       ├── login.php
│       ├── register.php
│       └── admin/
│           └── challenges.php
├── database/
│   ├── schema.sql             ← source of truth
│   ├── seed.sql               ← initial topics + sample challenges
│   └── app.sqlite             ← generated, not committed
├── tests/
│   ├── RouterTest.php
│   ├── DatabaseTest.php
│   ├── AuthTest.php
│   ├── Models/
│   │   ├── ChallengeTest.php
│   │   └── ProgressTest.php
│   └── bootstrap.php
├── composer.json
├── .env.example
└── .gitignore
```

---

## Task 1: Project Bootstrap

**Files:**
- Create: `composer.json`
- Create: `.env.example`
- Create: `.gitignore`
- Create: `public/index.php`

- [ ] **Step 1: Init composer**

```bash
cd "C:/Users/admin/OneDrive/Documents/php"
composer init --name="learnphp/platform" --type="project" --no-interaction
```

- [ ] **Step 2: Configure autoloading — replace composer.json with:**

```json
{
  "name": "learnphp/platform",
  "type": "project",
  "require": {
    "php": ">=8.0"
  },
  "require-dev": {
    "phpunit/phpunit": "^11"
  },
  "autoload": {
    "psr-4": {
      "App\\": "src/"
    }
  },
  "autoload-dev": {
    "psr-4": {
      "Tests\\": "tests/"
    }
  }
}
```

- [ ] **Step 3: Install dependencies**

```bash
composer install
```

Expected: `vendor/` created, `vendor/autoload.php` present.

- [ ] **Step 4: Create `.env.example`**

```ini
APP_ENV=local
APP_URL=http://localhost:8000
DB_PATH=database/app.sqlite
ADMIN_PASSWORD=changeme
```

- [ ] **Step 5: Create `.gitignore`**

```
vendor/
database/app.sqlite
.env
.superpowers/
```

- [ ] **Step 6: Create `public/index.php`**

```php
<?php
declare(strict_types=1);

require_once __DIR__ . '/../vendor/autoload.php';

// Load .env if present
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (str_starts_with(trim($line), '#')) continue;
        [$key, $value] = explode('=', $line, 2);
        $_ENV[trim($key)] = trim($value);
    }
}

$router = new \App\Router();
$router->dispatch();
```

- [ ] **Step 7: Create `tests/bootstrap.php`**

```php
<?php
declare(strict_types=1);
require_once __DIR__ . '/../vendor/autoload.php';

$_ENV['APP_ENV'] = 'test';
$_ENV['DB_PATH'] = ':memory:';
```

- [ ] **Step 8: Create `phpunit.xml`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit bootstrap="tests/bootstrap.php" colors="true">
  <testsuites>
    <testsuite name="LearnPHP">
      <directory>tests</directory>
    </testsuite>
  </testsuites>
</phpunit>
```

- [ ] **Step 9: Commit**

```bash
git init
git add .
git commit -m "chore: bootstrap project structure"
```

---

## Task 2: Database Layer

**Files:**
- Create: `database/schema.sql`
- Create: `src/Database.php`
- Create: `tests/DatabaseTest.php`

- [ ] **Step 1: Write failing test**

Create `tests/DatabaseTest.php`:

```php
<?php
namespace Tests;

use App\Database;
use PHPUnit\Framework\TestCase;

class DatabaseTest extends TestCase
{
    public function test_can_get_instance(): void
    {
        $db = Database::getInstance();
        $this->assertInstanceOf(\PDO::class, $db->getPdo());
    }

    public function test_query_returns_results(): void
    {
        $db = Database::getInstance();
        $db->exec('CREATE TABLE IF NOT EXISTS test_tbl (id INTEGER PRIMARY KEY, name TEXT)');
        $db->exec("INSERT INTO test_tbl (name) VALUES ('hello')");
        $rows = $db->query('SELECT * FROM test_tbl')->fetchAll();
        $this->assertCount(1, $rows);
        $this->assertSame('hello', $rows[0]['name']);
    }
}
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
vendor/bin/phpunit tests/DatabaseTest.php
```

Expected: Error — `Class "App\Database" not found`

- [ ] **Step 3: Create `database/schema.sql`**

```sql
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS languages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    icon TEXT NOT NULL DEFAULT '📄',
    is_active INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS topics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    language_id INTEGER NOT NULL REFERENCES languages(id),
    name TEXT NOT NULL,
    slug TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    sort_order INTEGER NOT NULL DEFAULT 0,
    UNIQUE(language_id, slug)
);

CREATE TABLE IF NOT EXISTS challenges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    title TEXT NOT NULL,
    prompt TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('fill_blank','write_code','spot_bug')),
    difficulty TEXT NOT NULL CHECK(difficulty IN ('beginner','intermediate','advanced')),
    starter_code TEXT NOT NULL DEFAULT '',
    solution TEXT NOT NULL,
    hint TEXT NOT NULL DEFAULT '',
    explanation TEXT NOT NULL,
    is_diagnostic INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS followup_challenges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    challenge_id INTEGER NOT NULL REFERENCES challenges(id),
    prompt TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('fill_blank','write_code','spot_bug')),
    starter_code TEXT NOT NULL DEFAULT '',
    solution TEXT NOT NULL,
    explanation TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS section_tests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    challenge_id INTEGER NOT NULL REFERENCES challenges(id),
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS remediation_challenges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    weakness_tag TEXT NOT NULL,
    prompt TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('fill_blank','write_code','spot_bug')),
    starter_code TEXT NOT NULL DEFAULT '',
    solution TEXT NOT NULL,
    explanation TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS user_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER REFERENCES users(id),
    session_token TEXT NOT NULL,
    challenge_id INTEGER NOT NULL REFERENCES challenges(id),
    passed INTEGER NOT NULL DEFAULT 0,
    attempts INTEGER NOT NULL DEFAULT 0,
    completed_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE(session_token, challenge_id)
);

CREATE TABLE IF NOT EXISTS tips (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    difficulty TEXT NOT NULL CHECK(difficulty IN ('beginner','intermediate','advanced','all')),
    title TEXT NOT NULL,
    content TEXT NOT NULL
);
```

- [ ] **Step 4: Create `src/Database.php`**

```php
<?php
namespace App;

class Database
{
    private static ?Database $instance = null;
    private \PDO $pdo;

    private function __construct()
    {
        $path = $_ENV['DB_PATH'] ?? 'database/app.sqlite';
        $dsn  = $path === ':memory:' ? 'sqlite::memory:' : 'sqlite:' . __DIR__ . '/../' . $path;

        $this->pdo = new \PDO($dsn);
        $this->pdo->setAttribute(\PDO::ATTR_DEFAULT_FETCH_MODE, \PDO::FETCH_ASSOC);
        $this->pdo->setAttribute(\PDO::ATTR_ERRMODE, \PDO::ERRMODE_EXCEPTION);
        $this->pdo->exec('PRAGMA foreign_keys = ON');
    }

    public static function getInstance(): self
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getPdo(): \PDO
    {
        return $this->pdo;
    }

    public function query(string $sql, array $params = []): \PDOStatement
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    }

    public function exec(string $sql): void
    {
        $this->pdo->exec($sql);
    }

    public function lastInsertId(): string
    {
        return $this->pdo->lastInsertId();
    }

    /** Run schema.sql to initialise the database */
    public function migrate(): void
    {
        $schema = file_get_contents(__DIR__ . '/../database/schema.sql');
        $this->pdo->exec($schema);
    }

    /** Reset singleton — test use only */
    public static function reset(): void
    {
        self::$instance = null;
    }
}
```

- [ ] **Step 5: Run test — expect PASS**

```bash
vendor/bin/phpunit tests/DatabaseTest.php
```

Expected: `OK (2 tests, 2 assertions)`

- [ ] **Step 6: Commit**

```bash
git add database/schema.sql src/Database.php tests/DatabaseTest.php phpunit.xml
git commit -m "feat: database layer with SQLite PDO wrapper"
```

---

## Task 3: Router

**Files:**
- Create: `src/Router.php`
- Create: `tests/RouterTest.php`

- [ ] **Step 1: Write failing test**

Create `tests/RouterTest.php`:

```php
<?php
namespace Tests;

use App\Router;
use PHPUnit\Framework\TestCase;

class RouterTest extends TestCase
{
    public function test_matches_exact_route(): void
    {
        $router = new Router();
        $router->get('/', fn() => 'home');
        $result = $router->resolve('GET', '/');
        $this->assertSame('home', $result);
    }

    public function test_matches_parameterised_route(): void
    {
        $router = new Router();
        $router->get('/learn/{lang}/{topic}', fn($lang, $topic) => "$lang:$topic");
        $result = $router->resolve('GET', '/learn/php/arrays');
        $this->assertSame('php:arrays', $result);
    }

    public function test_returns_null_for_unknown_route(): void
    {
        $router = new Router();
        $result = $router->resolve('GET', '/not-found');
        $this->assertNull($result);
    }
}
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
vendor/bin/phpunit tests/RouterTest.php
```

Expected: Error — `Class "App\Router" not found`

- [ ] **Step 3: Create `src/Router.php`**

```php
<?php
namespace App;

class Router
{
    private array $routes = [];

    public function get(string $pattern, callable $handler): void
    {
        $this->routes['GET'][$pattern] = $handler;
    }

    public function post(string $pattern, callable $handler): void
    {
        $this->routes['POST'][$pattern] = $handler;
    }

    public function resolve(string $method, string $uri): mixed
    {
        $routes = $this->routes[$method] ?? [];
        foreach ($routes as $pattern => $handler) {
            $regex = preg_replace('/\{(\w+)\}/', '(?P<$1>[^/]+)', $pattern);
            $regex = '#^' . $regex . '$#';
            if (preg_match($regex, $uri, $matches)) {
                $params = array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);
                return $handler(...array_values($params));
            }
        }
        return null;
    }

    public function dispatch(): void
    {
        $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
        $uri    = strtok($_SERVER['REQUEST_URI'] ?? '/', '?');

        // Register all routes
        $this->registerRoutes();

        $result = $this->resolve($method, $uri);

        if ($result === null) {
            http_response_code(404);
            echo '<h1>404 Not Found</h1>';
        }
    }

    private function registerRoutes(): void
    {
        $this->get('/',                              [new \App\Controllers\HomeController, 'index']);
        $this->get('/learn/{lang}',                  [new \App\Controllers\TopicController, 'index']);
        $this->get('/learn/{lang}/{topic}',          [new \App\Controllers\TopicController, 'show']);
        $this->get('/learn/{lang}/{topic}/{id}',     [new \App\Controllers\ChallengeController, 'show']);
        $this->post('/learn/{lang}/{topic}/{id}',    [new \App\Controllers\ChallengeController, 'submit']);
        $this->get('/diagnostic',                    [new \App\Controllers\DiagnosticController, 'index']);
        $this->post('/diagnostic',                   [new \App\Controllers\DiagnosticController, 'submit']);
        $this->get('/diagnostic/results',            [new \App\Controllers\DiagnosticController, 'results']);
        $this->get('/dashboard',                     [new \App\Controllers\DashboardController, 'index']);
        $this->get('/login',                         [new \App\Controllers\AuthController, 'loginForm']);
        $this->post('/login',                        [new \App\Controllers\AuthController, 'login']);
        $this->get('/register',                      [new \App\Controllers\AuthController, 'registerForm']);
        $this->post('/register',                     [new \App\Controllers\AuthController, 'register']);
        $this->get('/logout',                        [new \App\Controllers\AuthController, 'logout']);
        $this->get('/admin/challenges',              [new \App\Controllers\AdminController, 'index']);
        $this->post('/admin/challenges',             [new \App\Controllers\AdminController, 'store']);
    }
}
```

- [ ] **Step 4: Run test — expect PASS**

```bash
vendor/bin/phpunit tests/RouterTest.php
```

Expected: `OK (3 tests, 3 assertions)`

- [ ] **Step 5: Commit**

```bash
git add src/Router.php tests/RouterTest.php
git commit -m "feat: URL router with parameterised routes"
```

---

## Task 4: Auth & Session Management

**Files:**
- Create: `src/Auth.php`
- Create: `tests/AuthTest.php`

- [ ] **Step 1: Write failing test**

Create `tests/AuthTest.php`:

```php
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
```

- [ ] **Step 2: Run test — expect FAIL**

```bash
vendor/bin/phpunit tests/AuthTest.php
```

Expected: Error — `Class "App\Auth" not found`

- [ ] **Step 3: Create `src/Auth.php`**

```php
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
        $user = $db->query('SELECT * FROM users WHERE email = ?', [$email])->fetch();
        if (!$user || !password_verify($password, $user['password_hash'])) {
            return null;
        }
        return $user;
    }

    public static function user(): ?array
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        return $_SESSION['user'] ?? null;
    }

    public static function login(array $user): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $_SESSION['user'] = ['id' => $user['id'], 'username' => $user['username']];
    }

    public static function logout(): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        session_destroy();
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
```

- [ ] **Step 4: Run test — expect PASS**

```bash
vendor/bin/phpunit tests/AuthTest.php
```

Expected: `OK (4 tests, 5 assertions)`

- [ ] **Step 5: Commit**

```bash
git add src/Auth.php tests/AuthTest.php
git commit -m "feat: auth — register, login, guest token, progress claim"
```

---

## Task 5: Models

**Files:**
- Create: `src/Models/Topic.php`
- Create: `src/Models/Challenge.php`
- Create: `src/Models/Progress.php`
- Create: `src/Models/Tip.php`
- Create: `tests/Models/ChallengeTest.php`
- Create: `tests/Models/ProgressTest.php`

- [ ] **Step 1: Write failing tests**

Create `tests/Models/ChallengeTest.php`:

```php
<?php
namespace Tests\Models;

use App\Database;
use App\Models\Challenge;
use App\Models\Topic;
use PHPUnit\Framework\TestCase;

class ChallengeTest extends TestCase
{
    protected function setUp(): void
    {
        Database::reset();
        $db = Database::getInstance();
        $db->migrate();
        $db->exec("INSERT INTO languages (name,slug,icon,is_active) VALUES ('PHP','php','🐘',1)");
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order) VALUES (1,'Arrays','arrays','Learn arrays',1)");
    }

    public function test_find_returns_challenge(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
                   VALUES (1,'Test','What is 1+1?','fill_blank','beginner','2','Because math')");
        $c = Challenge::find(1);
        $this->assertSame('Test', $c['title']);
    }

    public function test_for_topic_returns_list(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
                   VALUES (1,'C1','Q1','fill_blank','beginner','a','e'),
                          (1,'C2','Q2','spot_bug','intermediate','b','e')");
        $list = Challenge::forTopic(1);
        $this->assertCount(2, $list);
    }

    public function test_grade_fill_blank_correct(): void
    {
        $this->assertTrue(Challenge::grade(['type' => 'fill_blank', 'solution' => '["a","b"]'], '["a","b"]'));
    }

    public function test_grade_fill_blank_wrong(): void
    {
        $this->assertFalse(Challenge::grade(['type' => 'fill_blank', 'solution' => '["a","b"]'], '["x"]'));
    }

    public function test_grade_normalises_whitespace(): void
    {
        $this->assertTrue(Challenge::grade(['type' => 'fill_blank', 'solution' => '$i++'], '  $i++  '));
    }
}
```

Create `tests/Models/ProgressTest.php`:

```php
<?php
namespace Tests\Models;

use App\Database;
use App\Models\Progress;
use PHPUnit\Framework\TestCase;

class ProgressTest extends TestCase
{
    protected function setUp(): void
    {
        Database::reset();
        $db = Database::getInstance();
        $db->migrate();
        $db->exec("INSERT INTO languages (name,slug,icon,is_active) VALUES ('PHP','php','🐘',1)");
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order) VALUES (1,'Arrays','arrays','',1)");
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
                   VALUES (1,'C1','Q1','fill_blank','beginner','a','e')");
    }

    public function test_record_creates_progress_row(): void
    {
        Progress::record('token123', 1, true, null);
        $row = Database::getInstance()
            ->query('SELECT * FROM user_progress WHERE session_token = ?', ['token123'])
            ->fetch();
        $this->assertSame(1, (int)$row['passed']);
    }

    public function test_record_updates_attempts_on_duplicate(): void
    {
        Progress::record('token123', 1, false, null);
        Progress::record('token123', 1, true, null);
        $row = Database::getInstance()
            ->query('SELECT * FROM user_progress WHERE session_token = ?', ['token123'])
            ->fetch();
        $this->assertSame(2, (int)$row['attempts']);
        $this->assertSame(1, (int)$row['passed']);
    }

    public function test_topic_score_returns_percentage(): void
    {
        // 1 challenge total, 1 passed
        Progress::record('tok', 1, true, null);
        $score = Progress::topicScore('tok', 1, null);
        $this->assertSame(100, $score);
    }
}
```

- [ ] **Step 2: Run tests — expect FAIL**

```bash
vendor/bin/phpunit tests/Models/
```

Expected: Error — model classes not found.

- [ ] **Step 3: Create `src/Models/Topic.php`**

```php
<?php
namespace App\Models;

use App\Database;

class Topic
{
    public static function allForLanguage(string $langSlug): array
    {
        return Database::getInstance()->query(
            'SELECT t.* FROM topics t
             JOIN languages l ON l.id = t.language_id
             WHERE l.slug = ? ORDER BY t.sort_order',
            [$langSlug]
        )->fetchAll();
    }

    public static function findBySlug(string $langSlug, string $topicSlug): ?array
    {
        $row = Database::getInstance()->query(
            'SELECT t.* FROM topics t
             JOIN languages l ON l.id = t.language_id
             WHERE l.slug = ? AND t.slug = ?',
            [$langSlug, $topicSlug]
        )->fetch();
        return $row ?: null;
    }
}
```

- [ ] **Step 4: Create `src/Models/Challenge.php`**

```php
<?php
namespace App\Models;

use App\Database;

class Challenge
{
    public static function find(int $id): ?array
    {
        $row = Database::getInstance()
            ->query('SELECT * FROM challenges WHERE id = ?', [$id])
            ->fetch();
        return $row ?: null;
    }

    public static function forTopic(int $topicId): array
    {
        return Database::getInstance()->query(
            'SELECT * FROM challenges WHERE topic_id = ? ORDER BY
             CASE difficulty WHEN "beginner" THEN 1 WHEN "intermediate" THEN 2 ELSE 3 END,
             sort_order',
            [$topicId]
        )->fetchAll();
    }

    public static function diagnostic(): array
    {
        return Database::getInstance()->query(
            'SELECT c.*, t.slug AS topic_slug, t.name AS topic_name
             FROM challenges c JOIN topics t ON t.id = c.topic_id
             WHERE c.is_diagnostic = 1 ORDER BY RANDOM() LIMIT 15'
        )->fetchAll();
    }

    public static function followups(int $challengeId): array
    {
        return Database::getInstance()->query(
            'SELECT * FROM followup_challenges WHERE challenge_id = ?',
            [$challengeId]
        )->fetchAll();
    }

    public static function sectionTest(int $topicId): array
    {
        return Database::getInstance()->query(
            'SELECT c.* FROM challenges c
             JOIN section_tests st ON st.challenge_id = c.id
             WHERE st.topic_id = ? ORDER BY st.sort_order',
            [$topicId]
        )->fetchAll();
    }

    /**
     * Grade a challenge answer.
     * For write_code type the caller passes expected output vs actual output.
     * For fill_blank and spot_bug we normalise and compare strings.
     */
    public static function grade(array $challenge, string $answer): bool
    {
        $solution = self::normalise($challenge['solution']);
        $answer   = self::normalise($answer);
        return $solution === $answer;
    }

    private static function normalise(string $s): string
    {
        // Trim whitespace, normalise quotes, strip trailing semicolons
        $s = trim($s);
        $s = str_replace('"', "'", $s);
        $s = rtrim($s, ';');
        $s = strtolower($s);
        return $s;
    }
}
```

- [ ] **Step 5: Create `src/Models/Progress.php`**

```php
<?php
namespace App\Models;

use App\Database;

class Progress
{
    public static function record(string $token, int $challengeId, bool $passed, ?int $userId): void
    {
        $db = Database::getInstance();
        $existing = $db->query(
            'SELECT id, attempts FROM user_progress WHERE session_token = ? AND challenge_id = ?',
            [$token, $challengeId]
        )->fetch();

        if ($existing) {
            $db->query(
                'UPDATE user_progress SET passed = ?, attempts = ?, completed_at = datetime("now"), user_id = ?
                 WHERE session_token = ? AND challenge_id = ?',
                [(int)$passed, $existing['attempts'] + 1, $userId, $token, $challengeId]
            );
        } else {
            $db->query(
                'INSERT INTO user_progress (user_id, session_token, challenge_id, passed, attempts)
                 VALUES (?, ?, ?, ?, 1)',
                [$userId, $token, $challengeId, (int)$passed]
            );
        }
    }

    public static function topicScore(string $token, int $topicId, ?int $userId): int
    {
        $db = Database::getInstance();
        $total = (int)$db->query(
            'SELECT COUNT(*) FROM challenges WHERE topic_id = ?', [$topicId]
        )->fetchColumn();
        if ($total === 0) return 0;

        $passed = (int)$db->query(
            'SELECT COUNT(*) FROM user_progress
             WHERE session_token = ? AND passed = 1
             AND challenge_id IN (SELECT id FROM challenges WHERE topic_id = ?)',
            [$token, $topicId]
        )->fetchColumn();

        return (int)round(($passed / $total) * 100);
    }

    public static function completedIds(string $token): array
    {
        return array_column(
            Database::getInstance()->query(
                'SELECT challenge_id FROM user_progress WHERE session_token = ? AND passed = 1',
                [$token]
            )->fetchAll(),
            'challenge_id'
        );
    }
}
```

- [ ] **Step 6: Create `src/Models/Tip.php`**

```php
<?php
namespace App\Models;

use App\Database;

class Tip
{
    public static function forTopic(int $topicId, string $difficulty): array
    {
        return Database::getInstance()->query(
            'SELECT * FROM tips WHERE topic_id = ? AND (difficulty = ? OR difficulty = "all") LIMIT 3',
            [$topicId, $difficulty]
        )->fetchAll();
    }
}
```

- [ ] **Step 7: Run tests — expect PASS**

```bash
vendor/bin/phpunit tests/Models/
```

Expected: `OK (7 tests, 9 assertions)`

- [ ] **Step 8: Commit**

```bash
git add src/Models/ tests/Models/
git commit -m "feat: Topic, Challenge, Progress, Tip models"
```

---

## Task 6: Shared Layout & CSS

**Files:**
- Create: `src/Views/layout.php`
- Create: `public/assets/css/main.css`
- Create: `public/assets/css/layout.css`
- Create: `public/assets/css/challenge.css`

- [ ] **Step 1: Create `public/assets/css/main.css`**

```css
:root {
  --bg:        #0f172a;
  --bg-card:   #1e293b;
  --bg-input:  #0f172a;
  --border:    #334155;
  --text:      #e2e8f0;
  --muted:     #94a3b8;
  --primary:   #3b82f6;
  --success:   #4ade80;
  --error:     #ef4444;
  --warning:   #f59e0b;
  --font-mono: 'Courier New', Courier, monospace;
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

body {
  background: var(--bg);
  color: var(--text);
  font-family: system-ui, sans-serif;
  font-size: 16px;
  line-height: 1.6;
  min-height: 100vh;
}

a { color: var(--primary); text-decoration: none; }
a:hover { text-decoration: underline; }

code, pre, .mono { font-family: var(--font-mono); }

pre { overflow-x: auto; padding: 12px; background: #1a1a2e; border-radius: 6px; }

.btn {
  display: inline-flex; align-items: center; justify-content: center;
  padding: 10px 20px; border-radius: 6px; border: none;
  font-size: 0.95rem; font-weight: 600; cursor: pointer;
  min-height: 44px; min-width: 44px;
  transition: opacity 0.15s;
}
.btn:hover { opacity: 0.85; }
.btn-primary  { background: var(--primary); color: #fff; }
.btn-ghost    { background: transparent; color: var(--muted); border: 1px solid var(--border); }
.btn-success  { background: #166534; color: var(--success); }
.btn-danger   { background: #450a0a; color: #fca5a5; }

.card {
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: 8px;
  padding: 20px;
}

.badge {
  display: inline-block; padding: 2px 8px; border-radius: 12px;
  font-size: 0.75rem; font-weight: 600;
}
.badge-beginner     { background: #052e16; color: #6ee7b7; }
.badge-intermediate { background: #451a03; color: #fcd34d; }
.badge-advanced     { background: #450a0a; color: #fca5a5; }

.alert { padding: 12px 16px; border-radius: 6px; margin-bottom: 16px; }
.alert-success { background: #052e16; border: 1px solid #166534; color: var(--success); }
.alert-error   { background: #450a0a; border: 1px solid #7f1d1d; color: #fca5a5; }
.alert-info    { background: #1e3a5f; border: 1px solid #1d4ed8; color: #93c5fd; }

.progress-bar { background: var(--border); border-radius: 20px; height: 8px; overflow: hidden; }
.progress-bar__fill { background: var(--primary); height: 100%; border-radius: 20px; }

input, textarea, select {
  background: var(--bg-input); color: var(--text);
  border: 1px solid var(--border); border-radius: 6px;
  padding: 10px 14px; font-size: 1rem; width: 100%;
  min-height: 44px;
}
input:focus, textarea:focus { outline: 2px solid var(--primary); border-color: var(--primary); }
label { display: block; color: var(--muted); font-size: 0.85rem; margin-bottom: 4px; }
.form-group { margin-bottom: 16px; }

.nav {
  background: var(--bg-card); border-bottom: 1px solid var(--border);
  padding: 0 24px; height: 56px;
  display: flex; align-items: center; justify-content: space-between;
}
.nav__logo { font-weight: 700; color: var(--text); font-size: 1.1rem; }
.nav__links { display: flex; gap: 20px; align-items: center; }

.page { max-width: 1100px; margin: 0 auto; padding: 32px 24px; }
.page-sm { max-width: 480px; margin: 0 auto; padding: 48px 24px; }
```

- [ ] **Step 2: Create `public/assets/css/layout.css`**

```css
/* Responsive grid */
.grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
.grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }

@media (max-width: 768px) {
  .grid-2, .grid-3 { grid-template-columns: 1fr; }
  .nav__links a:not(.btn) { display: none; }
  .page { padding: 20px 16px; }
}

/* Topic grid */
.topic-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 16px;
}
```

- [ ] **Step 3: Create `public/assets/css/challenge.css`**

```css
.challenge-layout {
  display: grid;
  grid-template-columns: 1fr 300px;
  gap: 20px;
  align-items: start;
}

@media (max-width: 768px) {
  .challenge-layout { grid-template-columns: 1fr; }
  .challenge-tips { order: 2; }
}

.challenge-topbar {
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: 8px 8px 0 0;
  padding: 10px 16px;
  display: flex; justify-content: space-between; align-items: center;
  font-size: 0.85rem; color: var(--muted);
}

.code-block {
  background: #1a1a2e;
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 14px;
  font-family: var(--font-mono);
  font-size: 0.9rem;
  overflow-x: auto;
  white-space: pre;
}

.code-input {
  font-family: var(--font-mono) !important;
  font-size: 0.9rem !important;
  min-height: 120px;
  resize: vertical;
  white-space: pre;
}

.tip-card {
  background: var(--bg-card);
  border-left: 3px solid var(--primary);
  border-radius: 6px;
  padding: 12px;
  margin-bottom: 10px;
  font-size: 0.85rem;
}
.tip-card h4 { color: #93c5fd; margin-bottom: 4px; font-size: 0.85rem; }
.tip-card p  { color: var(--muted); line-height: 1.5; }
.tip-card.tip-warning { border-left-color: var(--warning); }
.tip-card.tip-warning h4 { color: #fcd34d; }

.challenge-actions { display: flex; gap: 8px; flex-wrap: wrap; margin-top: 12px; }

/* Mobile: make code-input readable on phone keyboards */
@media (max-width: 768px) {
  .code-input { font-size: 14px !important; }
  .challenge-actions .btn { flex: 1; }
}
```

- [ ] **Step 4: Create `src/Views/layout.php`**

```php
<?php
// Variables expected: $title (string), $content (string)
$user = \App\Auth::user();
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?= htmlspecialchars($title ?? 'LearnPHP') ?> — LearnPHP</title>
  <link rel="stylesheet" href="/assets/css/main.css">
  <link rel="stylesheet" href="/assets/css/layout.css">
  <link rel="stylesheet" href="/assets/css/challenge.css">
  <script src="https://unpkg.com/htmx.org@1.9.12" defer></script>
</head>
<body>
  <nav class="nav">
    <a class="nav__logo" href="/">🐘 LearnPHP</a>
    <div class="nav__links">
      <a href="/learn/php">Topics</a>
      <a href="/diagnostic">Diagnostic Test</a>
      <?php if ($user): ?>
        <a href="/dashboard">Dashboard</a>
        <a href="/logout">Logout</a>
      <?php else: ?>
        <a href="/login">Login</a>
        <a href="/register" class="btn btn-primary" style="padding:6px 14px;font-size:0.85rem">Sign Up</a>
      <?php endif; ?>
    </div>
  </nav>
  <main>
    <?= $content ?>
  </main>
</body>
</html>
```

- [ ] **Step 5: Commit**

```bash
git add public/assets/ src/Views/layout.php
git commit -m "feat: CSS design system and shared layout"
```

---

## Task 7: Database Seed & Setup Script

**Files:**
- Create: `database/seed.sql`
- Create: `bin/setup.php`

- [ ] **Step 1: Create `database/seed.sql`**

```sql
-- Language
INSERT INTO languages (name, slug, icon, is_active) VALUES ('PHP', 'php', '🐘', 1);

-- Topics (first 5 for initial seed — rest added incrementally)
INSERT INTO topics (language_id, name, slug, description, sort_order) VALUES
(1, 'Variables & Data Types', 'variables', 'Learn how PHP stores data in variables and the types of values they can hold.', 1),
(1, 'Operators', 'operators', 'Arithmetic, comparison, and logical operators in PHP.', 2),
(1, 'Strings', 'strings', 'Working with text in PHP — string functions, interpolation, and manipulation.', 3),
(1, 'Arrays', 'arrays', 'Indexed and associative arrays — the workhorse of PHP data structures.', 4),
(1, 'Conditionals', 'conditionals', 'if, else, elseif, and switch — controlling the flow of your program.', 5);

-- Sample challenges for Arrays topic (topic_id = 4)
INSERT INTO challenges (topic_id, title, prompt, type, difficulty, starter_code, solution, hint, explanation, is_diagnostic, sort_order) VALUES
(4, 'Create an Array', 'Fill in the blank to create an array containing the strings "apple", "banana", and "cherry".',
 'fill_blank',
 'beginner',
 '$fruits = ______;',
 '["apple","banana","cherry"]',
 'Use square brackets [ ] with quoted strings separated by commas.',
 'In PHP, arrays are created with square bracket syntax: $arr = ["item1", "item2"]. The old array() function also works but [] is the modern standard.',
 1, 1),

(4, 'Access Array Element', 'Spot the bug — this code should print "banana" but it doesn''t.',
 'spot_bug',
 'beginner',
 '$fruits = ["apple", "banana", "cherry"];' || char(10) || 'echo $fruits[2];',
 'echo $fruits[1];',
 'PHP arrays start at index 0, not 1.',
 'Array indexes start at 0. So $fruits[0] = "apple", $fruits[1] = "banana", $fruits[2] = "cherry". To get "banana" you need index 1.',
 0, 2),

(4, 'Count Array Items', 'Write PHP code that counts how many items are in the $colors array and stores the result in $total.',
 'write_code',
 'beginner',
 '$colors = ["red", "green", "blue", "yellow"];' || char(10) || '// Your code here:' || char(10) || '$total = ',
 'count($colors)',
 'PHP has a built-in function specifically for counting array elements.',
 'count() is the standard PHP function for getting array length. $total = count($colors) stores 4 in $total.',
 0, 3);

-- Follow-up for challenge 1 (wrong answer teaching)
INSERT INTO followup_challenges (challenge_id, prompt, type, starter_code, solution, explanation) VALUES
(1, 'Which of these correctly creates a PHP array? Fill in the correct syntax: $items = ______;',
 'fill_blank',
 '$items = ______;',
 '["x","y"]',
 'Square brackets with quoted, comma-separated strings is the correct modern PHP array syntax.');

-- Tips for Arrays topic
INSERT INTO tips (topic_id, difficulty, title, content) VALUES
(4, 'all', 'Array Basics', 'Arrays store multiple values in one variable. Access items with their index starting at 0: $arr[0] is the first item.'),
(4, 'beginner', 'Quick Reference', '$a = ["x","y","z"]; // create' || char(10) || '$a[0]       // "x"' || char(10) || 'count($a)   // 3' || char(10) || '$a[] = "w"; // append'),
(4, 'beginner', 'Common Mistake', 'Arrays start at index 0, not 1. $arr[1] gives the SECOND item, not the first.');

-- Section test for Arrays (uses challenge IDs 1, 2, 3)
INSERT INTO section_tests (topic_id, challenge_id, sort_order) VALUES (4, 1, 1), (4, 2, 2), (4, 3, 3);
```

- [ ] **Step 2: Create `bin/setup.php`**

```php
<?php
declare(strict_types=1);
require_once __DIR__ . '/../vendor/autoload.php';

// Load .env
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    foreach (file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (str_starts_with(trim($line), '#')) continue;
        [$key, $value] = explode('=', $line, 2);
        $_ENV[trim($key)] = trim($value);
    }
}

$db = \App\Database::getInstance();
echo "Running schema...\n";
$db->migrate();
echo "Running seed...\n";
$db->exec(file_get_contents(__DIR__ . '/../database/seed.sql'));
echo "Done! Database ready at: " . ($_ENV['DB_PATH'] ?? 'database/app.sqlite') . "\n";
```

- [ ] **Step 3: Create `.env` from example**

```bash
cp .env.example .env
```

- [ ] **Step 4: Run setup**

```bash
php bin/setup.php
```

Expected output:
```
Running schema...
Running seed...
Done! Database ready at: database/app.sqlite
```

- [ ] **Step 5: Commit**

```bash
git add database/seed.sql bin/setup.php .env.example
git commit -m "feat: database seed and setup script"
```

---

## Task 8: Home & Topic Controllers + Views

**Files:**
- Create: `src/Controllers/HomeController.php`
- Create: `src/Controllers/TopicController.php`
- Create: `src/Views/home.php`
- Create: `src/Views/topics.php`
- Create: `src/Views/topic.php`

- [ ] **Step 1: Create `src/Controllers/HomeController.php`**

```php
<?php
namespace App\Controllers;

class HomeController
{
    public function index(): void
    {
        $title = 'Learn PHP for Free';
        ob_start();
        require __DIR__ . '/../Views/home.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }
}
```

- [ ] **Step 2: Create `src/Controllers/TopicController.php`**

```php
<?php
namespace App\Controllers;

use App\Models\Topic;
use App\Models\Challenge;
use App\Models\Progress;
use App\Models\Tip;
use App\Auth;

class TopicController
{
    public function index(string $lang): void
    {
        $topics = Topic::allForLanguage($lang);
        $token  = Auth::sessionToken();
        foreach ($topics as &$t) {
            $t['score'] = Progress::topicScore($token, $t['id'], Auth::user()['id'] ?? null);
        }
        $title = strtoupper($lang) . ' Topics';
        ob_start();
        require __DIR__ . '/../Views/topics.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function show(string $lang, string $topicSlug): void
    {
        $topic      = Topic::findBySlug($lang, $topicSlug);
        if (!$topic) { http_response_code(404); echo '404'; return; }
        $challenges = Challenge::forTopic($topic['id']);
        $token      = Auth::sessionToken();
        $completed  = Progress::completedIds($token);
        $tips       = Tip::forTopic($topic['id'], 'beginner');
        $title      = $topic['name'];
        ob_start();
        require __DIR__ . '/../Views/topic.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }
}
```

- [ ] **Step 3: Create `src/Views/home.php`**

```php
<div class="page">
  <div style="text-align:center;padding:60px 0 40px">
    <div style="font-size:3rem;margin-bottom:12px">🐘</div>
    <h1 style="font-size:2.2rem;font-weight:800;margin-bottom:12px">Learn PHP — for free</h1>
    <p style="color:var(--muted);font-size:1.1rem;max-width:520px;margin:0 auto 28px">
      Challenges, instant feedback, and a learning plan built around <em>you</em>.
      Take the diagnostic test to find your gaps, then fix them — one challenge at a time.
    </p>
    <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap">
      <a href="/diagnostic" class="btn btn-primary" style="font-size:1rem;padding:12px 28px">
        🧪 Take the Diagnostic Test
      </a>
      <a href="/learn/php" class="btn btn-ghost" style="font-size:1rem;padding:12px 28px">
        Browse PHP Topics
      </a>
    </div>
  </div>

  <div class="grid-3" style="margin-top:20px">
    <div class="card">
      <div style="font-size:1.8rem;margin-bottom:8px">🎯</div>
      <h3 style="margin-bottom:6px">Targeted Challenges</h3>
      <p style="color:var(--muted);font-size:0.9rem">Fill-in-the-blank, write code, and spot-the-bug exercises that build real PHP skills.</p>
    </div>
    <div class="card">
      <div style="font-size:1.8rem;margin-bottom:8px">💡</div>
      <h3 style="margin-bottom:6px">Teach on Mistakes</h3>
      <p style="color:var(--muted);font-size:0.9rem">Get something wrong? The site explains why, then checks you actually understood before moving on.</p>
    </div>
    <div class="card">
      <div style="font-size:1.8rem;margin-bottom:8px">📊</div>
      <h3 style="margin-bottom:6px">Personalised Plan</h3>
      <p style="color:var(--muted);font-size:0.9rem">The diagnostic test finds exactly what you know and don't. Your learning plan focuses on what matters.</p>
    </div>
  </div>
</div>
```

- [ ] **Step 4: Create `src/Views/topics.php`**

```php
<div class="page">
  <h1 style="margin-bottom:6px">PHP Topics</h1>
  <p style="color:var(--muted);margin-bottom:24px">28 topics from beginner to advanced. Work through them all, or jump to what you need.</p>

  <div class="topic-grid">
    <?php foreach ($topics as $t): ?>
    <a href="/learn/php/<?= htmlspecialchars($t['slug']) ?>" style="text-decoration:none">
      <div class="card" style="cursor:pointer;transition:border-color 0.15s" onmouseover="this.style.borderColor='var(--primary)'" onmouseout="this.style.borderColor='var(--border)'">
        <h3 style="margin-bottom:4px;font-size:1rem"><?= htmlspecialchars($t['name']) ?></h3>
        <p style="color:var(--muted);font-size:0.82rem;margin-bottom:10px"><?= htmlspecialchars($t['description']) ?></p>
        <?php if ($t['score'] > 0): ?>
        <div class="progress-bar">
          <div class="progress-bar__fill" style="width:<?= $t['score'] ?>%"></div>
        </div>
        <div style="color:var(--muted);font-size:0.75rem;margin-top:4px"><?= $t['score'] ?>% complete</div>
        <?php endif; ?>
      </div>
    </a>
    <?php endforeach; ?>
  </div>
</div>
```

- [ ] **Step 5: Create `src/Views/topic.php`**

```php
<div class="page">
  <div style="margin-bottom:6px;color:var(--muted);font-size:0.85rem">
    <a href="/learn/php">PHP</a> › <?= htmlspecialchars($topic['name']) ?>
  </div>
  <h1 style="margin-bottom:8px"><?= htmlspecialchars($topic['name']) ?></h1>
  <p style="color:var(--muted);margin-bottom:28px"><?= htmlspecialchars($topic['description']) ?></p>

  <div style="display:flex;flex-direction:column;gap:10px">
    <?php foreach ($challenges as $c): ?>
    <?php $done = in_array($c['id'], $completed); ?>
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/<?= $c['id'] ?>" style="text-decoration:none">
      <div class="card" style="display:flex;align-items:center;gap:16px;cursor:pointer">
        <div style="font-size:1.2rem"><?= $done ? '✅' : '○' ?></div>
        <div style="flex:1">
          <div style="font-weight:600;margin-bottom:2px"><?= htmlspecialchars($c['title']) ?></div>
          <div style="color:var(--muted);font-size:0.85rem"><?= htmlspecialchars($c['prompt']) ?></div>
        </div>
        <div>
          <span class="badge badge-<?= $c['difficulty'] ?>"><?= ucfirst($c['difficulty']) ?></span>
        </div>
      </div>
    </a>
    <?php endforeach; ?>
  </div>
</div>
```

- [ ] **Step 6: Start PHP dev server and verify home page loads**

```bash
php -S localhost:8000 -t public
```

Open `http://localhost:8000` — expect the home page with nav, hero, and 3 feature cards.  
Open `http://localhost:8000/learn/php` — expect the topics grid.

- [ ] **Step 7: Commit**

```bash
git add src/Controllers/HomeController.php src/Controllers/TopicController.php src/Views/home.php src/Views/topics.php src/Views/topic.php
git commit -m "feat: home page, topics list, and topic detail pages"
```

---

## Task 9: Challenge Page & Grading

**Files:**
- Create: `src/Controllers/ChallengeController.php`
- Create: `src/Views/challenge.php`
- Create: `public/assets/js/runner.js`

- [ ] **Step 1: Create `src/Controllers/ChallengeController.php`**

```php
<?php
namespace App\Controllers;

use App\Models\Topic;
use App\Models\Challenge;
use App\Models\Progress;
use App\Models\Tip;
use App\Auth;

class ChallengeController
{
    public function show(string $lang, string $topicSlug, string $id): void
    {
        $topic     = Topic::findBySlug($lang, $topicSlug);
        $challenge = Challenge::find((int)$id);
        if (!$topic || !$challenge) { http_response_code(404); echo '404'; return; }

        $tips      = Tip::forTopic($topic['id'], $challenge['difficulty']);
        $token     = Auth::sessionToken();
        $completed = Progress::completedIds($token);
        $allForTopic = Challenge::forTopic($topic['id']);
        $position  = array_search($challenge['id'], array_column($allForTopic, 'id')) + 1;
        $total     = count($allForTopic);

        $title = $challenge['title'];
        ob_start();
        require __DIR__ . '/../Views/challenge.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function submit(string $lang, string $topicSlug, string $id): void
    {
        $challenge = Challenge::find((int)$id);
        $topic     = Topic::findBySlug($lang, $topicSlug);
        if (!$challenge || !$topic) { http_response_code(404); return; }

        $answer  = trim($_POST['answer'] ?? '');
        $passed  = Challenge::grade($challenge, $answer);
        $token   = Auth::sessionToken();
        $user    = Auth::user();
        $userId  = $user['id'] ?? null;

        Progress::record($token, $challenge['id'], $passed, $userId);

        // HTMX: return only the feedback fragment
        if ($passed) {
            echo $this->renderFeedbackCorrect($challenge, $lang, $topicSlug, $challenge['id'], $topic, $token);
        } else {
            $followups = Challenge::followups($challenge['id']);
            echo $this->renderFeedbackWrong($challenge, $followups, $answer);
        }
    }

    private function renderFeedbackCorrect(array $c, string $lang, string $topicSlug, int $id, array $topic, string $token): string
    {
        $allForTopic = Challenge::forTopic($topic['id']);
        $ids = array_column($allForTopic, 'id');
        $pos = array_search($id, $ids);
        $nextId = $ids[$pos + 1] ?? null;

        $next = $nextId
            ? "<a href='/learn/{$lang}/{$topicSlug}/{$nextId}' class='btn btn-success'>→ Next Challenge</a>"
            : "<a href='/learn/{$lang}/{$topicSlug}' class='btn btn-success'>✅ Topic Complete</a>";

        $exp = htmlspecialchars($c['explanation']);
        return <<<HTML
<div class="alert alert-success">
  <strong>✅ Correct!</strong>
  <p style="margin-top:6px">{$exp}</p>
  <div style="margin-top:10px">{$next}</div>
</div>
HTML;
    }

    private function renderFeedbackWrong(array $c, array $followups, string $answer): string
    {
        $exp  = htmlspecialchars($c['explanation']);
        $sol  = htmlspecialchars($c['solution']);
        $fu   = '';
        if (!empty($followups)) {
            $f   = $followups[0];
            $fId = $f['id'];
            $fPrompt = htmlspecialchars($f['prompt']);
            $fStarter = htmlspecialchars($f['starter_code']);
            $fu = <<<HTML
<div class="card" style="margin-top:16px">
  <h4 style="color:var(--warning);margin-bottom:8px">🔍 Quick Check — did you get it?</h4>
  <p style="margin-bottom:10px">{$fPrompt}</p>
  <form hx-post="/followup/{$fId}" hx-target="#followup-result" hx-swap="outerHTML">
    <input type="text" name="answer" placeholder="Your answer..." autocomplete="off" style="margin-bottom:8px">
    <button type="submit" class="btn btn-primary">Check →</button>
  </form>
  <div id="followup-result"></div>
</div>
HTML;
        }

        return <<<HTML
<div class="alert alert-error">
  <strong>✗ Not quite right</strong>
  <p style="margin-top:6px">Your answer: <code>{$answer}</code></p>
</div>
<div class="alert alert-info">
  <strong>📖 Let's understand this</strong>
  <p style="margin-top:6px">{$exp}</p>
  <p style="margin-top:6px">Correct answer: <code>{$sol}</code></p>
</div>
{$fu}
HTML;
    }
}
```

- [ ] **Step 2: Create `src/Views/challenge.php`**

```php
<div class="page">
  <!-- Topbar -->
  <div class="challenge-topbar" style="margin-bottom:16px">
    <span>
      <a href="/learn/php" style="color:var(--muted)">PHP</a>
      › <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>" style="color:var(--muted)"><?= htmlspecialchars($topic['name']) ?></a>
      › Challenge <?= $position ?> of <?= $total ?>
    </span>
    <div style="display:flex;gap:8px">
      <span class="badge badge-<?= $challenge['difficulty'] ?>"><?= ucfirst($challenge['difficulty']) ?></span>
      <span class="badge" style="background:var(--bg-card);color:var(--muted)"><?= ucfirst(str_replace('_',' ',$challenge['type'])) ?></span>
    </div>
  </div>

  <div class="challenge-layout">
    <!-- Left: Challenge -->
    <div>
      <div class="card" style="margin-bottom:16px">
        <h2 style="font-size:1.1rem;margin-bottom:6px"><?= htmlspecialchars($challenge['title']) ?></h2>
        <p style="color:var(--muted);margin-bottom:14px"><?= htmlspecialchars($challenge['prompt']) ?></p>

        <?php if ($challenge['starter_code']): ?>
        <div class="code-block" style="margin-bottom:14px"><?= htmlspecialchars($challenge['starter_code']) ?></div>
        <?php endif; ?>

        <form hx-post="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/<?= $challenge['id'] ?>"
              hx-target="#feedback"
              hx-swap="innerHTML">
          <div class="form-group">
            <label>Your answer:</label>
            <?php if ($challenge['type'] === 'write_code'): ?>
            <textarea name="answer" class="code-input" placeholder="Write your PHP code here..."
                      rows="6"></textarea>
            <?php else: ?>
            <input type="text" name="answer" placeholder="Type your answer..." autocomplete="off">
            <?php endif; ?>
          </div>
          <div class="challenge-actions">
            <button type="submit" class="btn btn-primary">✓ Check Answer</button>
            <button type="button" class="btn btn-ghost"
                    onclick="document.getElementById('hint').style.display='block';this.style.display='none'">
              💡 Hint
            </button>
            <?php if ($challenge['type'] === 'write_code'): ?>
            <button type="button" class="btn btn-ghost" onclick="runCode()">▶ Run Code</button>
            <?php endif; ?>
          </div>
        </form>

        <div id="hint" style="display:none;margin-top:12px" class="alert alert-info">
          <?= htmlspecialchars($challenge['hint']) ?>
        </div>
      </div>

      <div id="feedback"></div>

      <?php if ($challenge['type'] === 'write_code'): ?>
      <div id="runner-output" style="display:none" class="card" style="margin-top:12px">
        <div style="color:var(--muted);font-size:0.8rem;margin-bottom:6px">Output:</div>
        <pre id="runner-pre" style="margin:0"></pre>
      </div>
      <script src="/assets/js/runner.js" defer></script>
      <?php endif; ?>
    </div>

    <!-- Right: Tips -->
    <div class="challenge-tips">
      <div class="card">
        <div style="color:var(--muted);font-size:0.75rem;text-transform:uppercase;letter-spacing:1px;margin-bottom:12px">💡 Learning Tips</div>
        <?php foreach ($tips as $tip): ?>
        <div class="tip-card <?= $tip['title'] === 'Common Mistake' ? 'tip-warning' : '' ?>">
          <h4><?= htmlspecialchars($tip['title']) ?></h4>
          <p><?= nl2br(htmlspecialchars($tip['content'])) ?></p>
        </div>
        <?php endforeach; ?>

        <div style="margin-top:16px;padding-top:14px;border-top:1px solid var(--border)">
          <div style="color:var(--muted);font-size:0.75rem;text-transform:uppercase;letter-spacing:1px;margin-bottom:8px">Progress</div>
          <div style="color:var(--text);font-size:0.85rem;margin-bottom:6px"><?= htmlspecialchars($topic['name']) ?></div>
          <div class="progress-bar">
            <div class="progress-bar__fill" style="width:<?= round(($position-1)/$total*100) ?>%"></div>
          </div>
          <div style="color:var(--muted);font-size:0.78rem;margin-top:4px"><?= $position - 1 ?> of <?= $total ?> done</div>
        </div>
      </div>
    </div>
  </div>
</div>
```

- [ ] **Step 3: Create `public/assets/js/runner.js`**

```js
// php-wasm in-browser PHP runner
// Loaded only on write_code challenges

async function runCode() {
  const answer = document.querySelector('textarea[name="answer"]').value;
  const output = document.getElementById('runner-output');
  const pre    = document.getElementById('runner-pre');

  output.style.display = 'block';
  pre.textContent = 'Running...';

  try {
    // php-wasm CDN
    const { PhpWeb } = await import('https://cdn.jsdelivr.net/npm/php-wasm/PhpWeb.mjs');
    const php = new PhpWeb();
    const code = answer.trim().startsWith('<?php') ? answer : '<?php\n' + answer;
    const result = await php.run(code);
    pre.textContent = result.output || '(no output)';
  } catch (e) {
    pre.textContent = 'Error: ' + e.message;
  }
}
```

- [ ] **Step 4: Add followup route to Router**

In `src/Router.php`, add inside `registerRoutes()`:

```php
$this->post('/followup/{id}', [new \App\Controllers\ChallengeController, 'submitFollowup']);
```

- [ ] **Step 5: Add `submitFollowup` to ChallengeController**

```php
public function submitFollowup(string $id): void
{
    $db = \App\Database::getInstance();
    $fu = $db->query('SELECT * FROM followup_challenges WHERE id = ?', [(int)$id])->fetch();
    if (!$fu) { http_response_code(404); return; }

    $answer = trim($_POST['answer'] ?? '');
    $passed = \App\Models\Challenge::grade([
        'type'     => $fu['type'],
        'solution' => $fu['solution'],
    ], $answer);

    if ($passed) {
        $exp = htmlspecialchars($fu['explanation']);
        echo <<<HTML
<div id="followup-result" class="alert alert-success" style="margin-top:8px">
  ✅ Correct! {$exp}
  <p style="margin-top:8px;color:var(--muted)">You can now continue to the next challenge.</p>
</div>
HTML;
    } else {
        $sol = htmlspecialchars($fu['solution']);
        $exp = htmlspecialchars($fu['explanation']);
        echo <<<HTML
<div id="followup-result" class="alert alert-error" style="margin-top:8px">
  ✗ Not yet. The answer is <code>{$sol}</code>. {$exp}
</div>
HTML;
    }
}
```

- [ ] **Step 6: Test in browser**

Visit `http://localhost:8000/learn/php/arrays/1`  
- Submit wrong answer → expect error + mini-lesson + follow-up question  
- Submit correct answer → expect green success + explanation + Next button

- [ ] **Step 7: Commit**

```bash
git add src/Controllers/ChallengeController.php src/Views/challenge.php public/assets/js/runner.js src/Router.php
git commit -m "feat: challenge page with grading, teach-on-wrong, and follow-up questions"
```

---

## Task 10: Auth Controllers & Views

**Files:**
- Create: `src/Controllers/AuthController.php`
- Create: `src/Views/login.php`
- Create: `src/Views/register.php`

- [ ] **Step 1: Create `src/Controllers/AuthController.php`**

```php
<?php
namespace App\Controllers;

use App\Auth;

class AuthController
{
    public function loginForm(): void
    {
        $title = 'Login';
        $error = $_SESSION['auth_error'] ?? null;
        unset($_SESSION['auth_error']);
        ob_start(); require __DIR__ . '/../Views/login.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function login(): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $email    = trim($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';
        $user     = Auth::attempt($email, $password);

        if (!$user) {
            $_SESSION['auth_error'] = 'Invalid email or password.';
            header('Location: /login'); exit;
        }

        $token = Auth::sessionToken();
        Auth::login($user);
        Auth::claimGuestProgress($token, $user['id']);
        header('Location: /dashboard'); exit;
    }

    public function registerForm(): void
    {
        $title = 'Create Account';
        $error = $_SESSION['auth_error'] ?? null;
        unset($_SESSION['auth_error']);
        ob_start(); require __DIR__ . '/../Views/register.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function register(): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $username = trim($_POST['username'] ?? '');
        $email    = trim($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';

        if (strlen($username) < 2 || strlen($password) < 6) {
            $_SESSION['auth_error'] = 'Username must be 2+ chars, password 6+ chars.';
            header('Location: /register'); exit;
        }

        try {
            $token  = Auth::sessionToken();
            $userId = Auth::register($username, $email, $password);
            $user   = ['id' => $userId, 'username' => $username];
            Auth::login($user);
            Auth::claimGuestProgress($token, $userId);
            header('Location: /dashboard'); exit;
        } catch (\PDOException $e) {
            $_SESSION['auth_error'] = 'Email or username already taken.';
            header('Location: /register'); exit;
        }
    }

    public function logout(): void
    {
        Auth::logout();
        header('Location: /'); exit;
    }
}
```

- [ ] **Step 2: Create `src/Views/login.php`**

```php
<div class="page-sm">
  <h1 style="margin-bottom:4px">Welcome back</h1>
  <p style="color:var(--muted);margin-bottom:24px">Log in to continue your learning journey.</p>

  <?php if ($error): ?>
  <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
  <?php endif; ?>

  <form method="POST" action="/login">
    <div class="form-group">
      <label>Email</label>
      <input type="email" name="email" required autofocus>
    </div>
    <div class="form-group">
      <label>Password</label>
      <input type="password" name="password" required>
    </div>
    <button type="submit" class="btn btn-primary" style="width:100%">Log In</button>
  </form>

  <p style="text-align:center;margin-top:20px;color:var(--muted)">
    No account? <a href="/register">Create one free</a>
  </p>
</div>
```

- [ ] **Step 3: Create `src/Views/register.php`**

```php
<div class="page-sm">
  <h1 style="margin-bottom:4px">Create your account</h1>
  <p style="color:var(--muted);margin-bottom:24px">Free forever. Save your progress and get a personalised learning plan.</p>

  <?php if ($error): ?>
  <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
  <?php endif; ?>

  <form method="POST" action="/register">
    <div class="form-group">
      <label>Username</label>
      <input type="text" name="username" required minlength="2" autofocus>
    </div>
    <div class="form-group">
      <label>Email</label>
      <input type="email" name="email" required>
    </div>
    <div class="form-group">
      <label>Password</label>
      <input type="password" name="password" required minlength="6">
    </div>
    <button type="submit" class="btn btn-primary" style="width:100%">Create Account</button>
  </form>

  <p style="text-align:center;margin-top:20px;color:var(--muted)">
    Already have an account? <a href="/login">Log in</a>
  </p>
</div>
```

- [ ] **Step 4: Test in browser**

Visit `http://localhost:8000/register` — register a new account. Expect redirect to `/dashboard` (404 for now — that's fine).  
Visit `http://localhost:8000/login` — log in. Expect redirect to `/dashboard`.

- [ ] **Step 5: Commit**

```bash
git add src/Controllers/AuthController.php src/Views/login.php src/Views/register.php
git commit -m "feat: auth pages — login, register, logout, guest progress claim"
```

---

## Task 11: Diagnostic Test

**Files:**
- Create: `src/Controllers/DiagnosticController.php`
- Create: `src/Views/diagnostic.php`
- Create: `src/Views/diagnostic-results.php`

- [ ] **Step 1: Create `src/Controllers/DiagnosticController.php`**

```php
<?php
namespace App\Controllers;

use App\Models\Challenge;
use App\Models\Progress;
use App\Models\Topic;
use App\Auth;

class DiagnosticController
{
    public function index(): void
    {
        $challenges = Challenge::diagnostic();
        $title = 'PHP Diagnostic Test';
        ob_start(); require __DIR__ . '/../Views/diagnostic.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function submit(): void
    {
        $challenges = Challenge::diagnostic();
        $token      = Auth::sessionToken();
        $user       = Auth::user();
        $userId     = $user['id'] ?? null;

        foreach ($challenges as $c) {
            $answer = trim($_POST['answer_' . $c['id']] ?? '');
            $passed = Challenge::grade($c, $answer);
            Progress::record($token, $c['id'], $passed, $userId);
        }

        header('Location: /diagnostic/results'); exit;
    }

    public function results(): void
    {
        $token  = Auth::sessionToken();
        $user   = Auth::user();
        $userId = $user['id'] ?? null;
        $topics = Topic::allForLanguage('php');

        $results = [];
        foreach ($topics as $t) {
            $score = Progress::topicScore($token, $t['id'], $userId);
            $results[] = [
                'topic'  => $t,
                'score'  => $score,
                'status' => $score >= 80 ? 'strong' : ($score >= 40 ? 'review' : 'weak'),
            ];
        }

        // Sort: weak first, then review, then strong
        usort($results, fn($a, $b) => ['weak'=>0,'review'=>1,'strong'=>2][$a['status']] <=> ['weak'=>0,'review'=>1,'strong'=>2][$b['status']]);

        $title = 'Your Diagnostic Results';
        ob_start(); require __DIR__ . '/../Views/diagnostic-results.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }
}
```

- [ ] **Step 2: Create `src/Views/diagnostic.php`**

```php
<div class="page" style="max-width:720px">
  <h1 style="margin-bottom:6px">PHP Diagnostic Test</h1>
  <p style="color:var(--muted);margin-bottom:28px">
    ~15 quick challenges across all PHP topics. Take your time — no timer.
    At the end we'll show you exactly what to study.
  </p>

  <form method="POST" action="/diagnostic">
    <?php foreach ($challenges as $i => $c): ?>
    <div class="card" style="margin-bottom:16px">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
        <span style="color:var(--muted);font-size:0.8rem">Question <?= $i+1 ?> of <?= count($challenges) ?> · <?= htmlspecialchars($c['topic_name']) ?></span>
        <span class="badge badge-<?= $c['difficulty'] ?>"><?= ucfirst($c['difficulty']) ?></span>
      </div>
      <p style="margin-bottom:10px;font-weight:500"><?= htmlspecialchars($c['prompt']) ?></p>
      <?php if ($c['starter_code']): ?>
      <div class="code-block" style="margin-bottom:10px"><?= htmlspecialchars($c['starter_code']) ?></div>
      <?php endif; ?>
      <?php if ($c['type'] === 'write_code'): ?>
      <textarea name="answer_<?= $c['id'] ?>" class="code-input" placeholder="Write your answer..." rows="4"></textarea>
      <?php else: ?>
      <input type="text" name="answer_<?= $c['id'] ?>" placeholder="Your answer...">
      <?php endif; ?>
    </div>
    <?php endforeach; ?>

    <button type="submit" class="btn btn-primary" style="width:100%;padding:14px;font-size:1rem">
      Submit Diagnostic →
    </button>
  </form>
</div>
```

- [ ] **Step 3: Create `src/Views/diagnostic-results.php`**

```php
<div class="page" style="max-width:720px">
  <h1 style="margin-bottom:4px">Your Diagnostic Results</h1>
  <p style="color:var(--muted);margin-bottom:24px">Here's where you stand across PHP topics.</p>

  <?php
  $strong = array_filter($results, fn($r) => $r['status'] === 'strong');
  $review = array_filter($results, fn($r) => $r['status'] === 'review');
  $weak   = array_filter($results, fn($r) => $r['status'] === 'weak');
  ?>

  <!-- Summary cards -->
  <div class="grid-3" style="margin-bottom:24px">
    <div class="card" style="text-align:center">
      <div style="color:var(--success);font-size:1.8rem;font-weight:700"><?= count($strong) ?></div>
      <div style="color:var(--muted);font-size:0.85rem">Strong Topics</div>
    </div>
    <div class="card" style="text-align:center">
      <div style="color:var(--warning);font-size:1.8rem;font-weight:700"><?= count($review) ?></div>
      <div style="color:var(--muted);font-size:0.85rem">Need Review</div>
    </div>
    <div class="card" style="text-align:center">
      <div style="color:var(--error);font-size:1.8rem;font-weight:700"><?= count($weak) ?></div>
      <div style="color:var(--muted);font-size:0.85rem">Weak Areas</div>
    </div>
  </div>

  <!-- Topic breakdown -->
  <div class="card" style="margin-bottom:20px">
    <h3 style="margin-bottom:14px">Topic Breakdown</h3>
    <?php foreach ($results as $r): ?>
    <?php $colors = ['strong'=>'var(--success)','review'=>'var(--warning)','weak'=>'var(--error)']; ?>
    <?php $labels = ['strong'=>'✓ Strong','review'=>'Review','weak'=>'⚠ Weak']; ?>
    <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px">
      <span style="width:160px;font-size:0.85rem"><?= htmlspecialchars($r['topic']['name']) ?></span>
      <div style="flex:1" class="progress-bar">
        <div class="progress-bar__fill" style="width:<?= max($r['score'],3) ?>%;background:<?= $colors[$r['status']] ?>"></div>
      </div>
      <span style="color:<?= $colors[$r['status']] ?>;font-size:0.8rem;width:35px;text-align:right"><?= $r['score'] ?>%</span>
      <span class="badge" style="background:var(--bg);color:<?= $colors[$r['status']] ?>;min-width:60px;text-align:center"><?= $labels[$r['status']] ?></span>
    </div>
    <?php endforeach; ?>
  </div>

  <!-- Recommended plan -->
  <?php $plan = array_filter($results, fn($r) => $r['status'] !== 'strong'); ?>
  <?php if (!empty($plan)): ?>
  <div class="card" style="margin-bottom:20px">
    <h3 style="margin-bottom:14px">📋 Your Recommended Learning Plan</h3>
    <?php $i = 1; foreach ($plan as $r): ?>
    <a href="/learn/php/<?= htmlspecialchars($r['topic']['slug']) ?>" style="text-decoration:none">
      <div style="display:flex;align-items:center;gap:12px;padding:10px;background:var(--bg);border-radius:6px;margin-bottom:8px;border-left:3px solid <?= $colors[$r['status']] ?>">
        <span style="color:var(--muted);font-size:0.85rem;min-width:20px"><?= $i++ ?></span>
        <span style="flex:1;color:var(--text);font-size:0.9rem"><?= htmlspecialchars($r['topic']['name']) ?></span>
        <span style="color:<?= $colors[$r['status']] ?>;font-size:0.8rem"><?= $r['status'] === 'weak' ? 'Priority' : 'Review' ?></span>
      </div>
    </a>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>

  <div style="display:flex;gap:10px;flex-wrap:wrap">
    <?php if (!empty($plan)): ?>
    <a href="/learn/php/<?= htmlspecialchars(array_values($plan)[0]['topic']['slug']) ?>" class="btn btn-primary" style="flex:1;min-width:200px">
      🚀 Start My Learning Plan
    </a>
    <?php endif; ?>
    <a href="/learn/php" class="btn btn-ghost">Browse All Topics</a>
    <?php if (!\App\Auth::user()): ?>
    <a href="/register" class="btn btn-ghost">💾 Save Progress</a>
    <?php endif; ?>
  </div>
</div>
```

- [ ] **Step 4: Test in browser**

Visit `http://localhost:8000/diagnostic` — submit the form. Expect redirect to results page with topic breakdown and learning plan.

- [ ] **Step 5: Commit**

```bash
git add src/Controllers/DiagnosticController.php src/Views/diagnostic.php src/Views/diagnostic-results.php
git commit -m "feat: diagnostic test and personalised results page"
```

---

## Task 12: Dashboard

**Files:**
- Create: `src/Controllers/DashboardController.php`
- Create: `src/Views/dashboard.php`

- [ ] **Step 1: Create `src/Controllers/DashboardController.php`**

```php
<?php
namespace App\Controllers;

use App\Models\Topic;
use App\Models\Progress;
use App\Auth;

class DashboardController
{
    public function index(): void
    {
        $user = Auth::user();
        if (!$user) { header('Location: /login'); exit; }

        $token  = Auth::sessionToken();
        $topics = Topic::allForLanguage('php');
        $userId = $user['id'];

        $topicData = [];
        foreach ($topics as $t) {
            $score = Progress::topicScore($token, $t['id'], $userId);
            $topicData[] = ['topic' => $t, 'score' => $score];
        }

        $completed = count(array_filter($topicData, fn($td) => $td['score'] >= 70));
        $inProgress = count(array_filter($topicData, fn($td) => $td['score'] > 0 && $td['score'] < 70));

        // Find last active topic
        $lastTopic = null;
        foreach (array_reverse($topicData) as $td) {
            if ($td['score'] > 0 && $td['score'] < 100) {
                $lastTopic = $td['topic'];
                break;
            }
        }

        $title = 'Dashboard';
        ob_start(); require __DIR__ . '/../Views/dashboard.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }
}
```

- [ ] **Step 2: Create `src/Views/dashboard.php`**

```php
<div class="page">
  <h1 style="margin-bottom:4px">Welcome back, <?= htmlspecialchars($user['username']) ?> 👋</h1>
  <p style="color:var(--muted);margin-bottom:28px">Here's your PHP learning progress.</p>

  <div class="grid-3" style="margin-bottom:28px">
    <div class="card" style="text-align:center">
      <div style="color:var(--success);font-size:1.8rem;font-weight:700"><?= $completed ?></div>
      <div style="color:var(--muted);font-size:0.85rem">Topics Mastered</div>
    </div>
    <div class="card" style="text-align:center">
      <div style="color:var(--warning);font-size:1.8rem;font-weight:700"><?= $inProgress ?></div>
      <div style="color:var(--muted);font-size:0.85rem">In Progress</div>
    </div>
    <div class="card" style="text-align:center">
      <div style="color:var(--primary);font-size:1.8rem;font-weight:700"><?= count($topicData) - $completed ?></div>
      <div style="color:var(--muted);font-size:0.85rem">Topics Left</div>
    </div>
  </div>

  <?php if ($lastTopic): ?>
  <div class="card" style="margin-bottom:28px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px">
    <div>
      <div style="color:var(--muted);font-size:0.8rem;margin-bottom:4px">Continue where you left off</div>
      <div style="font-weight:600"><?= htmlspecialchars($lastTopic['name']) ?></div>
    </div>
    <a href="/learn/php/<?= htmlspecialchars($lastTopic['slug']) ?>" class="btn btn-primary">Continue →</a>
  </div>
  <?php endif; ?>

  <h3 style="margin-bottom:14px">All Topics</h3>
  <div class="topic-grid">
    <?php foreach ($topicData as $td): ?>
    <a href="/learn/php/<?= htmlspecialchars($td['topic']['slug']) ?>" style="text-decoration:none">
      <div class="card" style="cursor:pointer">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px">
          <span style="font-size:0.9rem;font-weight:600"><?= htmlspecialchars($td['topic']['name']) ?></span>
          <?php if ($td['score'] >= 70): ?>
          <span style="color:var(--success)">✅</span>
          <?php elseif ($td['score'] > 0): ?>
          <span style="color:var(--warning)">⏳</span>
          <?php endif; ?>
        </div>
        <div class="progress-bar">
          <div class="progress-bar__fill" style="width:<?= $td['score'] ?>%"></div>
        </div>
        <div style="color:var(--muted);font-size:0.75rem;margin-top:4px"><?= $td['score'] ?>%</div>
      </div>
    </a>
    <?php endforeach; ?>
  </div>
</div>
```

- [ ] **Step 3: Commit**

```bash
git add src/Controllers/DashboardController.php src/Views/dashboard.php
git commit -m "feat: user dashboard with progress overview"
```

---

## Task 13: Admin Panel

**Files:**
- Create: `src/Controllers/AdminController.php`
- Create: `src/Views/admin/challenges.php`

- [ ] **Step 1: Create `src/Controllers/AdminController.php`**

```php
<?php
namespace App\Controllers;

use App\Database;
use App\Models\Topic;

class AdminController
{
    private function guard(): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $pass = $_ENV['ADMIN_PASSWORD'] ?? 'changeme';
        if (($_SESSION['admin'] ?? false) !== true) {
            if (($_POST['password'] ?? '') === $pass) {
                $_SESSION['admin'] = true;
            } else {
                $this->showLogin();
                exit;
            }
        }
    }

    private function showLogin(): void
    {
        echo '<!DOCTYPE html><html><body style="background:#0f172a;color:#e2e8f0;font-family:system-ui;display:flex;align-items:center;justify-content:center;min-height:100vh">
        <form method="POST" style="background:#1e293b;padding:32px;border-radius:8px">
          <h2 style="margin-bottom:16px">Admin Access</h2>
          <input type="password" name="password" placeholder="Password" style="display:block;padding:10px;margin-bottom:12px;background:#0f172a;border:1px solid #334155;color:#e2e8f0;border-radius:6px;width:240px">
          <button type="submit" style="background:#3b82f6;color:#fff;border:none;padding:10px 20px;border-radius:6px;cursor:pointer">Enter</button>
        </form></body></html>';
    }

    public function index(): void
    {
        $this->guard();
        $topics     = Topic::allForLanguage('php');
        $challenges = Database::getInstance()->query(
            'SELECT c.*, t.name AS topic_name FROM challenges c JOIN topics t ON t.id = c.topic_id ORDER BY t.sort_order, c.sort_order'
        )->fetchAll();
        $title = 'Admin — Challenges';
        ob_start(); require __DIR__ . '/../Views/admin/challenges.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function store(): void
    {
        $this->guard();
        $db = Database::getInstance();
        $db->query(
            'INSERT INTO challenges (topic_id, title, prompt, type, difficulty, starter_code, solution, hint, explanation, is_diagnostic, sort_order)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
                (int)$_POST['topic_id'],
                trim($_POST['title']),
                trim($_POST['prompt']),
                $_POST['type'],
                $_POST['difficulty'],
                trim($_POST['starter_code'] ?? ''),
                trim($_POST['solution']),
                trim($_POST['hint'] ?? ''),
                trim($_POST['explanation']),
                isset($_POST['is_diagnostic']) ? 1 : 0,
                (int)($_POST['sort_order'] ?? 0),
            ]
        );
        header('Location: /admin/challenges?saved=1'); exit;
    }
}
```

- [ ] **Step 2: Create `src/Views/admin/challenges.php`**

```php
<div class="page">
  <h1 style="margin-bottom:4px">Admin — Challenges</h1>
  <?php if (isset($_GET['saved'])): ?>
  <div class="alert alert-success" style="margin-bottom:16px">Challenge saved!</div>
  <?php endif; ?>

  <div class="grid-2" style="align-items:start">
    <!-- Add form -->
    <div class="card">
      <h3 style="margin-bottom:16px">Add Challenge</h3>
      <form method="POST" action="/admin/challenges">
        <div class="form-group">
          <label>Topic</label>
          <select name="topic_id">
            <?php foreach ($topics as $t): ?>
            <option value="<?= $t['id'] ?>"><?= htmlspecialchars($t['name']) ?></option>
            <?php endforeach; ?>
          </select>
        </div>
        <div class="form-group">
          <label>Title</label>
          <input type="text" name="title" required>
        </div>
        <div class="form-group">
          <label>Prompt (the question)</label>
          <textarea name="prompt" required rows="3"></textarea>
        </div>
        <div class="form-group">
          <label>Type</label>
          <select name="type">
            <option value="fill_blank">Fill in the Blank</option>
            <option value="write_code">Write Code</option>
            <option value="spot_bug">Spot the Bug</option>
          </select>
        </div>
        <div class="form-group">
          <label>Difficulty</label>
          <select name="difficulty">
            <option value="beginner">Beginner</option>
            <option value="intermediate">Intermediate</option>
            <option value="advanced">Advanced</option>
          </select>
        </div>
        <div class="form-group">
          <label>Starter Code (shown to user)</label>
          <textarea name="starter_code" class="code-input" rows="4"></textarea>
        </div>
        <div class="form-group">
          <label>Solution (correct answer)</label>
          <input type="text" name="solution" required>
        </div>
        <div class="form-group">
          <label>Hint</label>
          <input type="text" name="hint">
        </div>
        <div class="form-group">
          <label>Explanation (shown after submit)</label>
          <textarea name="explanation" required rows="3"></textarea>
        </div>
        <div class="form-group" style="display:flex;align-items:center;gap:8px">
          <input type="checkbox" name="is_diagnostic" id="diag" style="width:auto;min-height:auto">
          <label for="diag" style="margin:0">Include in diagnostic test</label>
        </div>
        <div class="form-group">
          <label>Sort Order</label>
          <input type="number" name="sort_order" value="0">
        </div>
        <button type="submit" class="btn btn-primary">Save Challenge</button>
      </form>
    </div>

    <!-- Existing challenges list -->
    <div>
      <h3 style="margin-bottom:12px">Existing Challenges (<?= count($challenges) ?>)</h3>
      <?php foreach ($challenges as $c): ?>
      <div class="card" style="margin-bottom:8px;font-size:0.85rem">
        <div style="display:flex;justify-content:space-between;margin-bottom:4px">
          <strong><?= htmlspecialchars($c['title']) ?></strong>
          <span class="badge badge-<?= $c['difficulty'] ?>"><?= ucfirst($c['difficulty']) ?></span>
        </div>
        <div style="color:var(--muted)"><?= htmlspecialchars($c['topic_name']) ?> · <?= $c['type'] ?></div>
      </div>
      <?php endforeach; ?>
    </div>
  </div>
</div>
```

- [ ] **Step 3: Commit**

```bash
git add src/Controllers/AdminController.php src/Views/admin/
git commit -m "feat: password-protected admin panel for adding challenges"
```

---

## Task 14: Section Completion Test

**Files:**
- Modify: `src/Controllers/ChallengeController.php`
- Create: `src/Views/section-test.php`
- Create: `src/Views/section-results.php`

- [ ] **Step 1: Add section test routes to Router**

In `src/Router.php`, inside `registerRoutes()`, add:

```php
$this->get('/learn/{lang}/{topic}/test',  [new \App\Controllers\ChallengeController, 'sectionTest']);
$this->post('/learn/{lang}/{topic}/test', [new \App\Controllers\ChallengeController, 'sectionTestSubmit']);
```

- [ ] **Step 2: Add methods to ChallengeController**

```php
public function sectionTest(string $lang, string $topicSlug): void
{
    $topic      = \App\Models\Topic::findBySlug($lang, $topicSlug);
    if (!$topic) { http_response_code(404); echo '404'; return; }
    $challenges = \App\Models\Challenge::sectionTest($topic['id']);
    $title      = $topic['name'] . ' — Section Test';
    ob_start(); require __DIR__ . '/../Views/section-test.php';
    $content = ob_get_clean();
    require __DIR__ . '/../Views/layout.php';
}

public function sectionTestSubmit(string $lang, string $topicSlug): void
{
    $topic      = \App\Models\Topic::findBySlug($lang, $topicSlug);
    if (!$topic) { http_response_code(404); return; }
    $challenges = \App\Models\Challenge::sectionTest($topic['id']);
    $token      = \App\Auth::sessionToken();
    $userId     = \App\Auth::user()['id'] ?? null;

    $passed = 0;
    $results = [];
    foreach ($challenges as $c) {
        $answer  = trim($_POST['answer_' . $c['id']] ?? '');
        $correct = \App\Models\Challenge::grade($c, $answer);
        if ($correct) $passed++;
        \App\Models\Progress::record($token, $c['id'], $correct, $userId);
        $results[] = ['challenge' => $c, 'answer' => $answer, 'correct' => $correct];
    }

    $score   = count($challenges) > 0 ? (int)round($passed / count($challenges) * 100) : 0;
    $mastered = $score >= 70;
    $title   = $topic['name'] . ' — Test Results';
    ob_start(); require __DIR__ . '/../Views/section-results.php';
    $content = ob_get_clean();
    require __DIR__ . '/../Views/layout.php';
}
```

- [ ] **Step 3: Create `src/Views/section-test.php`**

```php
<div class="page" style="max-width:700px">
  <h1 style="margin-bottom:4px">Section Test: <?= htmlspecialchars($topic['name']) ?></h1>
  <p style="color:var(--muted);margin-bottom:6px"><?= count($challenges) ?> questions — score 70% or more to unlock the next topic.</p>
  <div class="alert alert-info" style="margin-bottom:20px">
    💡 This tests what you learned in this topic. Take your time.
  </div>

  <form method="POST">
    <?php foreach ($challenges as $i => $c): ?>
    <div class="card" style="margin-bottom:16px">
      <div style="color:var(--muted);font-size:0.8rem;margin-bottom:8px">Question <?= $i+1 ?></div>
      <p style="font-weight:500;margin-bottom:10px"><?= htmlspecialchars($c['prompt']) ?></p>
      <?php if ($c['starter_code']): ?>
      <div class="code-block" style="margin-bottom:10px"><?= htmlspecialchars($c['starter_code']) ?></div>
      <?php endif; ?>
      <?php if ($c['type'] === 'write_code'): ?>
      <textarea name="answer_<?= $c['id'] ?>" class="code-input" rows="4" placeholder="Your code..."></textarea>
      <?php else: ?>
      <input type="text" name="answer_<?= $c['id'] ?>" placeholder="Your answer...">
      <?php endif; ?>
    </div>
    <?php endforeach; ?>
    <button type="submit" class="btn btn-primary" style="width:100%;padding:14px">Submit Test →</button>
  </form>
</div>
```

- [ ] **Step 4: Create `src/Views/section-results.php`**

```php
<div class="page" style="max-width:700px">
  <h1 style="margin-bottom:4px"><?= htmlspecialchars($topic['name']) ?> — Test Results</h1>

  <?php if ($mastered): ?>
  <div class="alert alert-success" style="margin-bottom:20px">
    <strong>🎉 Topic Mastered! Score: <?= $score ?>%</strong>
    <p style="margin-top:4px">You can now move on to the next topic.</p>
  </div>
  <?php else: ?>
  <div class="alert alert-error" style="margin-bottom:20px">
    <strong>Score: <?= $score ?>% — Not quite yet (need 70%)</strong>
    <p style="margin-top:4px">Review the questions below, then try the topic challenges again.</p>
  </div>
  <?php endif; ?>

  <?php foreach ($results as $r): ?>
  <div class="card" style="margin-bottom:12px;border-left:3px solid <?= $r['correct'] ? 'var(--success)' : 'var(--error)' ?>">
    <div style="display:flex;justify-content:space-between;margin-bottom:6px">
      <strong style="font-size:0.9rem"><?= htmlspecialchars($r['challenge']['title']) ?></strong>
      <span style="color:<?= $r['correct'] ? 'var(--success)' : 'var(--error)' ?>"><?= $r['correct'] ? '✅' : '✗' ?></span>
    </div>
    <?php if (!$r['correct']): ?>
    <div style="color:var(--muted);font-size:0.85rem">Your answer: <code><?= htmlspecialchars($r['answer']) ?></code></div>
    <div style="color:var(--success);font-size:0.85rem;margin-top:2px">Correct: <code><?= htmlspecialchars($r['challenge']['solution']) ?></code></div>
    <div style="color:var(--muted);font-size:0.82rem;margin-top:4px"><?= htmlspecialchars($r['challenge']['explanation']) ?></div>
    <?php endif; ?>
  </div>
  <?php endforeach; ?>

  <div style="display:flex;gap:10px;margin-top:20px;flex-wrap:wrap">
    <?php if ($mastered): ?>
    <a href="/learn/php" class="btn btn-primary">Browse Next Topic →</a>
    <?php else: ?>
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>" class="btn btn-primary">Review Topic Again</a>
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/test" class="btn btn-ghost">Retry Test</a>
    <?php endif; ?>
  </div>
</div>
```

- [ ] **Step 5: Link to section test from topic page**

In `src/Views/topic.php`, after the challenges list, add:

```php
<?php $allDone = count(array_diff(array_column($challenges, 'id'), $completed)) === 0; ?>
<?php if ($allDone && count($challenges) > 0): ?>
<div class="card" style="margin-top:20px;text-align:center">
  <h3 style="margin-bottom:8px">🏁 All challenges complete!</h3>
  <p style="color:var(--muted);margin-bottom:16px">Take the section test to confirm your understanding and unlock the next topic.</p>
  <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/test" class="btn btn-primary">Start Section Test →</a>
</div>
<?php endif; ?>
```

- [ ] **Step 6: Test in browser**

Complete all challenges in the Arrays topic, then visit the section test. Submit answers. Verify pass/fail screens show correctly.

- [ ] **Step 7: Commit**

```bash
git add src/Controllers/ChallengeController.php src/Views/section-test.php src/Views/section-results.php src/Views/topic.php src/Router.php
git commit -m "feat: section completion test with 70% pass threshold"
```

---

## Task 15: Run Full Test Suite & Final Checks

- [ ] **Step 1: Run all tests**

```bash
vendor/bin/phpunit --testdox
```

Expected: All tests pass. Fix any failures before continuing.

- [ ] **Step 2: Smoke test all pages**

With server running (`php -S localhost:8000 -t public`), visit each URL:

| URL | Expected |
|-----|---------|
| `http://localhost:8000/` | Home page loads |
| `http://localhost:8000/learn/php` | Topics grid |
| `http://localhost:8000/learn/php/arrays` | Arrays topic with challenges |
| `http://localhost:8000/learn/php/arrays/1` | Challenge page |
| `http://localhost:8000/diagnostic` | Diagnostic test |
| `http://localhost:8000/register` | Register form |
| `http://localhost:8000/login` | Login form |
| `http://localhost:8000/admin/challenges` | Admin password prompt |

- [ ] **Step 3: Mobile check**

Open Chrome DevTools → Toggle Device Toolbar (Ctrl+Shift+M). Set to iPhone 12.  
Verify: challenge layout stacks vertically, buttons are tap-sized, code blocks scroll horizontally.

- [ ] **Step 4: Add remaining 23 PHP topics to seed.sql**

Add `INSERT INTO topics` rows for topics 6–28 (Loops, Functions, Form Handling, File Inclusion, Array Functions, Date & Time, Math Functions, Regular Expressions, File System, Error Handling, Sessions & Cookies, JSON Handling, APIs, Input Validation, OOP Classes, OOP Inheritance, OOP Traits, Namespaces, PDO, Security, REST APIs, Composer, PHP 8.x Features).

Each topic needs at minimum:
- 1 row in `topics`
- 3+ rows in `challenges` (1 per difficulty minimum)
- 1 `is_diagnostic = 1` challenge
- 2–3 rows in `tips`
- 3 rows in `section_tests`

Re-run `php bin/setup.php` after updating seed.sql (delete `database/app.sqlite` first).

- [ ] **Step 5: Final commit**

```bash
git add .
git commit -m "feat: complete PHP learning platform — all 28 topics seeded"
```

---

## Task 16: Deploy to Railway (free)

- [ ] **Step 1: Push to GitHub**

```bash
git remote add origin https://github.com/YOUR_USERNAME/learnphp.git
git push -u origin main
```

- [ ] **Step 2: Create Railway project**

1. Go to [railway.app](https://railway.app) → New Project → Deploy from GitHub
2. Select your repo
3. Railway auto-detects PHP

- [ ] **Step 3: Set environment variables in Railway dashboard**

```
APP_ENV=production
DB_PATH=database/app.sqlite
ADMIN_PASSWORD=your-secure-password
```

- [ ] **Step 4: Add `Procfile` to project root**

```
web: php -S 0.0.0.0:$PORT -t public
```

- [ ] **Step 5: Add database init on deploy — create `bin/deploy.php`**

```php
<?php
require_once __DIR__ . '/../vendor/autoload.php';

// Load env
foreach (file(__DIR__ . '/../.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
    if (str_starts_with(trim($line), '#')) continue;
    if (!str_contains($line, '=')) continue;
    [$k, $v] = explode('=', $line, 2);
    $_ENV[trim($k)] = trim($v);
}

$db = \App\Database::getInstance();
$db->migrate();
// Only seed if languages table is empty
$count = $db->query('SELECT COUNT(*) FROM languages')->fetchColumn();
if ((int)$count === 0) {
    $db->exec(file_get_contents(__DIR__ . '/../database/seed.sql'));
    echo "Seeded.\n";
} else {
    echo "Already seeded — skipping.\n";
}
echo "Deploy complete.\n";
```

Update `Procfile`:
```
web: php bin/deploy.php && php -S 0.0.0.0:$PORT -t public
```

- [ ] **Step 6: Push and verify**

```bash
git add Procfile bin/deploy.php
git commit -m "chore: Railway deployment config"
git push origin main
```

Visit your Railway URL. The site should be live.
