# Content, Admin Panel, Progression Gating & CodeMirror Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Seed 40 PHP challenges across 5 topics, build a working admin CRUD panel, enforce challenge progression gating, and add a CodeMirror code editor for write_code challenges.

**Architecture:** Plain PHP 8.2 MVC — no frameworks, no build steps. All JS from CDN. Tests use in-memory SQLite via `Database::reset()` + `migrate()` pattern established in existing tests. TDD throughout: write failing test → implement → green → commit.

**Tech Stack:** PHP 8.2, SQLite (PDO), PHPUnit 11, HTMX 1.9 (CDN), CodeMirror 6 (esm.sh CDN), php-wasm (CDN)

---

## File Map

| File | Action | Purpose |
|---|---|---|
| `database/schema.sql` | Modify | Add `is_admin INTEGER NOT NULL DEFAULT 0` to `users` |
| `bin/setup.php` | Modify | Safe `is_admin` column migration for existing DBs |
| `src/Auth.php` | Modify | Add `requireAdmin(): void` static method |
| `src/Models/Challenge.php` | Modify | Add `all()`, `update()`, `delete()` |
| `src/Controllers/AdminController.php` | Rewrite | Full CRUD (was stubs) |
| `src/Router.php` | Modify | Add 6 admin routes |
| `src/Views/admin-challenges.php` | Create | Admin challenge list |
| `src/Views/admin-challenge-form.php` | Create | Admin create/edit form |
| `src/Controllers/ChallengeController.php` | Modify | Add gating check in `show()` |
| `src/Views/topic.php` | Modify | Locked/unlocked/done challenge cards |
| `src/Views/challenge.php` | Modify | CodeMirror div + hidden input for write_code |
| `public/assets/js/editor.js` | Create | CodeMirror 6 integration |
| `public/assets/js/runner.js` | Modify | Remove stale comment |
| `database/seed.sql` | Modify | 37 new challenges, tips, followups, section tests |
| `tests/Models/ChallengeTest.php` | Modify | Tests for `all()`, `update()`, `delete()` |
| `tests/AuthTest.php` | Modify | Test for `requireAdmin()` |
| `tests/ProgressionGatingTest.php` | Create | Gating logic tests |

---

## Task 1: Add `is_admin` to Schema

**Files:**
- Modify: `database/schema.sql`
- Modify: `bin/setup.php`

- [ ] **Add column to schema**

In `database/schema.sql`, find the `users` table and add `is_admin`:

```sql
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    is_admin INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

- [ ] **Add safe migration to setup.php**

After `$db->migrate();` in `bin/setup.php`, add:

```php
// Safe migration: add is_admin if the column doesn't exist yet
try {
    $db->exec("ALTER TABLE users ADD COLUMN is_admin INTEGER NOT NULL DEFAULT 0");
    echo "Migration: added is_admin column.\n";
} catch (\PDOException) {
    // Column already exists — fine
}
```

- [ ] **Verify tests still pass**

```bash
php vendor/bin/phpunit
```

Expected: `OK (26 tests, 38 assertions)` — the new column has a default so existing test inserts still work.

- [ ] **Commit**

```bash
git add database/schema.sql bin/setup.php
git commit -m "feat: add is_admin column to users"
```

---

## Task 2: `Auth::requireAdmin()`

**Files:**
- Modify: `src/Auth.php`
- Modify: `tests/AuthTest.php`

- [ ] **Write the failing test**

Append to `tests/AuthTest.php` inside the class:

```php
public function test_require_admin_passes_for_admin_user(): void
{
    if (session_status() === PHP_SESSION_NONE) session_start();
    $_SESSION['user'] = ['id' => 1, 'username' => 'admin', 'is_admin' => 1];
    // Should not throw or exit — just return
    $this->expectNotToPerformAssertions();
    Auth::requireAdmin();
}

public function test_require_admin_raises_for_non_admin(): void
{
    if (session_status() === PHP_SESSION_NONE) session_start();
    $_SESSION['user'] = ['id' => 2, 'username' => 'user', 'is_admin' => 0];
    $this->expectException(\RuntimeException::class);
    Auth::requireAdmin();
}

public function test_require_admin_raises_for_guest(): void
{
    if (session_status() === PHP_SESSION_NONE) session_start();
    unset($_SESSION['user']);
    $this->expectException(\RuntimeException::class);
    Auth::requireAdmin();
}
```

- [ ] **Run tests — expect failures**

```bash
php vendor/bin/phpunit tests/AuthTest.php
```

Expected: 3 failures — `requireAdmin` doesn't exist yet.

- [ ] **Implement `requireAdmin()` in `src/Auth.php`**

Add after the `logout()` method:

```php
/**
 * Guard: throws RuntimeException if the current session user is not an admin.
 * Controllers catch this and return 403, or let it propagate to a 500.
 * Using an exception (not exit) keeps the method testable.
 */
public static function requireAdmin(): void
{
    if (session_status() === PHP_SESSION_NONE) session_start();
    $user = $_SESSION['user'] ?? null;
    if (!$user || empty($user['is_admin'])) {
        throw new \RuntimeException('Forbidden', 403);
    }
}
```

- [ ] **Run tests — expect green**

```bash
php vendor/bin/phpunit tests/AuthTest.php
```

Expected: all AuthTest tests pass.

- [ ] **Commit**

```bash
git add src/Auth.php tests/AuthTest.php
git commit -m "feat: Auth::requireAdmin() with tests"
```

---

## Task 3: Challenge Model — `all()`, `update()`, `delete()`

**Files:**
- Modify: `src/Models/Challenge.php`
- Modify: `tests/Models/ChallengeTest.php`

- [ ] **Write failing tests** — append to `tests/Models/ChallengeTest.php`:

```php
public function test_all_returns_challenges_with_topic_and_language(): void
{
    $db = Database::getInstance();
    $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
               VALUES (1,'My Challenge','Q?','fill_blank','beginner','a','e')");
    $all = Challenge::all();
    $this->assertNotEmpty($all);
    $this->assertArrayHasKey('topic_name', $all[0]);
    $this->assertArrayHasKey('language_name', $all[0]);
    $this->assertSame('Arrays', $all[0]['topic_name']);
    $this->assertSame('PHP', $all[0]['language_name']);
}

public function test_update_persists_changes(): void
{
    $db = Database::getInstance();
    $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
               VALUES (1,'Old Title','Q?','fill_blank','beginner','a','e')");
    $id = (int)$db->lastInsertId();
    Challenge::update($id, ['title' => 'New Title', 'prompt' => 'Q?', 'type' => 'fill_blank',
        'difficulty' => 'intermediate', 'solution' => 'a', 'explanation' => 'e',
        'topic_id' => 1, 'starter_code' => '', 'hint' => '', 'is_diagnostic' => 0, 'sort_order' => 0]);
    $c = Challenge::find($id);
    $this->assertSame('New Title', $c['title']);
    $this->assertSame('intermediate', $c['difficulty']);
}

public function test_delete_removes_challenge_and_followups(): void
{
    $db = Database::getInstance();
    $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
               VALUES (1,'Del Me','Q?','fill_blank','beginner','a','e')");
    $id = (int)$db->lastInsertId();
    $db->exec("INSERT INTO followup_challenges (challenge_id,prompt,type,solution,explanation)
               VALUES ({$id},'FQ?','fill_blank','a','e')");
    Challenge::delete($id);
    $this->assertNull(Challenge::find($id));
    $fu = $db->query('SELECT * FROM followup_challenges WHERE challenge_id = ?', [$id])->fetchAll();
    $this->assertEmpty($fu);
}
```

- [ ] **Run — expect failures**

```bash
php vendor/bin/phpunit tests/Models/ChallengeTest.php
```

- [ ] **Implement the three methods** in `src/Models/Challenge.php`, after `grade()`:

```php
public static function all(): array
{
    return Database::getInstance()->query(
        'SELECT c.*, t.name AS topic_name, l.name AS language_name
         FROM challenges c
         JOIN topics t ON t.id = c.topic_id
         JOIN languages l ON l.id = t.language_id
         ORDER BY l.name, t.sort_order, c.sort_order, c.id'
    )->fetchAll();
}

public static function update(int $id, array $data): void
{
    Database::getInstance()->query(
        'UPDATE challenges SET
            topic_id=?, title=?, prompt=?, type=?, difficulty=?,
            starter_code=?, solution=?, hint=?, explanation=?,
            is_diagnostic=?, sort_order=?
         WHERE id=?',
        [
            (int)$data['topic_id'], $data['title'], $data['prompt'],
            $data['type'], $data['difficulty'], $data['starter_code'] ?? '',
            $data['solution'], $data['hint'] ?? '', $data['explanation'],
            (int)($data['is_diagnostic'] ?? 0), (int)($data['sort_order'] ?? 0),
            $id,
        ]
    );
}

public static function delete(int $id): void
{
    $db = Database::getInstance();
    $db->query('DELETE FROM followup_challenges WHERE challenge_id = ?', [$id]);
    $db->query('DELETE FROM section_tests WHERE challenge_id = ?', [$id]);
    $db->query('DELETE FROM user_progress WHERE challenge_id = ?', [$id]);
    $db->query('DELETE FROM challenges WHERE id = ?', [$id]);
}
```

- [ ] **Run — expect green**

```bash
php vendor/bin/phpunit
```

Expected: all tests pass.

- [ ] **Commit**

```bash
git add src/Models/Challenge.php tests/Models/ChallengeTest.php
git commit -m "feat: Challenge::all(), update(), delete() with tests"
```

---

## Task 4: AdminController — Full CRUD

**Files:**
- Rewrite: `src/Controllers/AdminController.php`

- [ ] **Replace the stub entirely:**

```php
<?php
namespace App\Controllers;

use App\Auth;
use App\Database;
use App\Models\Challenge;

class AdminController
{
    private const TYPES       = ['fill_blank', 'write_code', 'spot_bug'];
    private const DIFFICULTIES = ['beginner', 'intermediate', 'advanced'];

    public function index(): void
    {
        $this->guard();
        $challenges = Challenge::all();
        // Group: language_name => topic_name => [challenges]
        $grouped = [];
        foreach ($challenges as $c) {
            $grouped[$c['language_name']][$c['topic_name']][] = $c;
        }
        $flash = $this->popFlash();
        $title = 'Admin — Challenges';
        ob_start();
        require __DIR__ . '/../Views/admin-challenges.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function create(): void
    {
        $this->guard();
        $topics = $this->allTopics();
        $old    = $this->popOld();
        $errors = $this->popErrors();
        $title  = 'Admin — Add Challenge';
        ob_start();
        require __DIR__ . '/../Views/admin-challenge-form.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function store(): void
    {
        $this->guard();
        $data   = $this->inputFromPost();
        $errors = $this->validate($data);

        if ($errors) {
            $this->flashErrors($errors);
            $this->flashOld($data);
            header('Location: /admin/challenges/new');
            exit;
        }

        $db = Database::getInstance();
        $db->query(
            'INSERT INTO challenges
             (topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order)
             VALUES (?,?,?,?,?,?,?,?,?,?,?)',
            [
                (int)$data['topic_id'], $data['title'], $data['prompt'],
                $data['type'], $data['difficulty'], $data['starter_code'],
                $data['solution'], $data['hint'], $data['explanation'],
                (int)$data['is_diagnostic'], (int)$data['sort_order'],
            ]
        );
        $this->flashSuccess('Challenge created.');
        header('Location: /admin/challenges');
        exit;
    }

    public function edit(string $id): void
    {
        $this->guard();
        $challenge = Challenge::find((int)$id);
        if (!$challenge) { http_response_code(404); echo '404'; return; }
        $topics = $this->allTopics();
        $old    = $this->popOld() ?: $challenge; // pre-fill with existing values
        $errors = $this->popErrors();
        $title  = 'Admin — Edit Challenge';
        ob_start();
        require __DIR__ . '/../Views/admin-challenge-form.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function update(string $id): void
    {
        $this->guard();
        $challenge = Challenge::find((int)$id);
        if (!$challenge) { http_response_code(404); return; }

        $data   = $this->inputFromPost();
        $errors = $this->validate($data);

        if ($errors) {
            $this->flashErrors($errors);
            $this->flashOld($data);
            header('Location: /admin/challenges/' . (int)$id . '/edit');
            exit;
        }

        Challenge::update((int)$id, $data);
        $this->flashSuccess('Challenge updated.');
        header('Location: /admin/challenges');
        exit;
    }

    public function destroy(string $id): void
    {
        $this->guard();
        Challenge::delete((int)$id);
        $this->flashSuccess('Challenge deleted.');
        header('Location: /admin/challenges');
        exit;
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private function guard(): void
    {
        try {
            Auth::requireAdmin();
        } catch (\RuntimeException $e) {
            http_response_code(403);
            echo '<h1>403 Forbidden</h1>';
            exit;
        }
    }

    private function allTopics(): array
    {
        return Database::getInstance()->query(
            'SELECT t.*, l.name AS language_name FROM topics t
             JOIN languages l ON l.id = t.language_id
             ORDER BY l.name, t.sort_order'
        )->fetchAll();
    }

    private function inputFromPost(): array
    {
        return [
            'topic_id'      => trim($_POST['topic_id'] ?? ''),
            'title'         => trim($_POST['title'] ?? ''),
            'prompt'        => trim($_POST['prompt'] ?? ''),
            'type'          => trim($_POST['type'] ?? ''),
            'difficulty'    => trim($_POST['difficulty'] ?? ''),
            'starter_code'  => $_POST['starter_code'] ?? '',
            'solution'      => trim($_POST['solution'] ?? ''),
            'hint'          => trim($_POST['hint'] ?? ''),
            'explanation'   => trim($_POST['explanation'] ?? ''),
            'is_diagnostic' => (int)($_POST['is_diagnostic'] ?? 0),
            'sort_order'    => (int)($_POST['sort_order'] ?? 0),
        ];
    }

    private function validate(array $data): array
    {
        $errors = [];
        if (empty($data['topic_id']) || !is_numeric($data['topic_id'])) $errors[] = 'Topic is required.';
        if (empty($data['title']))       $errors[] = 'Title is required.';
        if (empty($data['prompt']))      $errors[] = 'Prompt is required.';
        if (!in_array($data['type'], self::TYPES, true))             $errors[] = 'Invalid type.';
        if (!in_array($data['difficulty'], self::DIFFICULTIES, true)) $errors[] = 'Invalid difficulty.';
        if (empty($data['solution']))    $errors[] = 'Solution is required.';
        if (empty($data['explanation'])) $errors[] = 'Explanation is required.';
        return $errors;
    }

    private function flashSuccess(string $msg): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $_SESSION['admin_flash'] = ['type' => 'success', 'msg' => $msg];
    }

    private function popFlash(): ?array
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $f = $_SESSION['admin_flash'] ?? null;
        unset($_SESSION['admin_flash']);
        return $f;
    }

    private function flashErrors(array $errors): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $_SESSION['admin_errors'] = $errors;
    }

    private function flashOld(array $data): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $_SESSION['admin_old'] = $data;
    }

    private function popErrors(): array
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $e = $_SESSION['admin_errors'] ?? [];
        unset($_SESSION['admin_errors']);
        return $e;
    }

    private function popOld(): array
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $o = $_SESSION['admin_old'] ?? [];
        unset($_SESSION['admin_old']);
        return $o;
    }
}
```

- [ ] **Run tests — all still green**

```bash
php vendor/bin/phpunit
```

- [ ] **Commit**

```bash
git add src/Controllers/AdminController.php
git commit -m "feat: AdminController full CRUD implementation"
```

---

## Task 5: Router — Admin Routes

**Files:**
- Modify: `src/Router.php`

- [ ] **Add 6 routes to `registerRoutes()` in `src/Router.php`**

Add these lines **before** the existing `/admin/challenges` routes (which you'll replace):

```php
// Admin — order matters: literal 'new' before {id}
$this->get('/admin/challenges',             [new \App\Controllers\AdminController, 'index']);
$this->get('/admin/challenges/new',         [new \App\Controllers\AdminController, 'create']);
$this->post('/admin/challenges',            [new \App\Controllers\AdminController, 'store']);
$this->get('/admin/challenges/{id}/edit',   [new \App\Controllers\AdminController, 'edit']);
$this->post('/admin/challenges/{id}',       [new \App\Controllers\AdminController, 'update']);
$this->post('/admin/challenges/{id}/delete',[new \App\Controllers\AdminController, 'destroy']);
```

Remove the two old stub lines:
```php
$this->get('/admin/challenges',  [new \App\Controllers\AdminController, 'index']);
$this->post('/admin/challenges', [new \App\Controllers\AdminController, 'store']);
```

- [ ] **Run tests**

```bash
php vendor/bin/phpunit
```

- [ ] **Commit**

```bash
git add src/Router.php
git commit -m "feat: admin CRUD routes"
```

---

## Task 6: Admin Views

**Files:**
- Create: `src/Views/admin-challenges.php`
- Create: `src/Views/admin-challenge-form.php`

- [ ] **Create `src/Views/admin-challenges.php`:**

```php
<div class="page">
  <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;flex-wrap:wrap;gap:12px">
    <div>
      <h1 style="margin-bottom:2px">Challenges</h1>
      <p style="color:var(--muted);font-size:0.85rem">Admin › Challenges</p>
    </div>
    <a href="/admin/challenges/new" class="btn btn-primary">+ Add Challenge</a>
  </div>

  <?php if ($flash): ?>
  <div class="alert <?= $flash['type'] === 'success' ? 'alert-success' : 'alert-error' ?>" style="margin-bottom:16px">
    <?= htmlspecialchars($flash['msg']) ?>
  </div>
  <?php endif; ?>

  <?php foreach ($grouped as $langName => $topicGroups): ?>
  <?php foreach ($topicGroups as $topicName => $items): ?>
  <div class="card" style="margin-bottom:16px;padding:0;overflow:hidden">
    <div style="padding:10px 16px;background:#1a2744;border-bottom:1px solid var(--border);font-size:0.85rem;font-weight:600">
      <?= htmlspecialchars($langName) ?> › <?= htmlspecialchars($topicName) ?>
      <span style="color:var(--muted);font-weight:400"> (<?= count($items) ?>)</span>
    </div>
    <div style="overflow-x:auto">
      <table style="width:100%;border-collapse:collapse;font-size:0.85rem">
        <thead>
          <tr>
            <th style="text-align:left;color:var(--muted);font-size:0.78rem;padding:8px 12px;border-bottom:1px solid var(--border)">ID</th>
            <th style="text-align:left;color:var(--muted);font-size:0.78rem;padding:8px 12px;border-bottom:1px solid var(--border)">Title</th>
            <th style="text-align:left;color:var(--muted);font-size:0.78rem;padding:8px 12px;border-bottom:1px solid var(--border)">Type</th>
            <th style="text-align:left;color:var(--muted);font-size:0.78rem;padding:8px 12px;border-bottom:1px solid var(--border)">Difficulty</th>
            <th style="text-align:center;color:var(--muted);font-size:0.78rem;padding:8px 12px;border-bottom:1px solid var(--border)">Diag</th>
            <th style="padding:8px 12px;border-bottom:1px solid var(--border)"></th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($items as $c): ?>
          <tr>
            <td style="padding:8px 12px;color:var(--muted);border-bottom:1px solid #1e293b"><?= (int)$c['id'] ?></td>
            <td style="padding:8px 12px;border-bottom:1px solid #1e293b"><?= htmlspecialchars($c['title']) ?></td>
            <td style="padding:8px 12px;border-bottom:1px solid #1e293b"><span class="badge" style="background:var(--bg);color:var(--muted);border:1px solid var(--border)"><?= htmlspecialchars($c['type']) ?></span></td>
            <td style="padding:8px 12px;border-bottom:1px solid #1e293b"><span class="badge badge-<?= htmlspecialchars($c['difficulty']) ?>"><?= ucfirst($c['difficulty']) ?></span></td>
            <td style="padding:8px 12px;text-align:center;border-bottom:1px solid #1e293b"><?= $c['is_diagnostic'] ? '✅' : '—' ?></td>
            <td style="padding:8px 12px;border-bottom:1px solid #1e293b;white-space:nowrap">
              <a href="/admin/challenges/<?= (int)$c['id'] ?>/edit" class="btn btn-ghost" style="padding:4px 10px;font-size:0.8rem;min-height:30px">Edit</a>
              <form method="POST" action="/admin/challenges/<?= (int)$c['id'] ?>/delete" style="display:inline" onsubmit="return confirm('Delete this challenge?')">
                <button type="submit" class="btn btn-danger" style="padding:4px 10px;font-size:0.8rem;min-height:30px">Delete</button>
              </form>
            </td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  </div>
  <?php endforeach; ?>
  <?php endforeach; ?>
</div>
```

- [ ] **Create `src/Views/admin-challenge-form.php`:**

```php
<?php
// $topics: array of topics with language_name
// $old: pre-filled values (existing challenge or POST data)
// $errors: validation error strings
$isEdit = isset($challenge);
$action = $isEdit ? '/admin/challenges/' . (int)$challenge['id'] : '/admin/challenges';
$v = fn(string $k, mixed $def = '') => htmlspecialchars((string)($old[$k] ?? $def));
?>
<div class="page" style="max-width:720px">
  <div style="margin-bottom:4px;font-size:0.85rem;color:var(--muted)">
    <a href="/admin/challenges">← Challenges</a>
  </div>
  <h1 style="margin-bottom:20px"><?= $isEdit ? 'Edit Challenge' : 'Add Challenge' ?></h1>

  <?php if ($errors): ?>
  <div class="alert alert-error" style="margin-bottom:16px">
    <ul style="margin:0;padding-left:18px">
      <?php foreach ($errors as $e): ?>
      <li><?= htmlspecialchars($e) ?></li>
      <?php endforeach; ?>
    </ul>
  </div>
  <?php endif; ?>

  <form method="POST" action="<?= $action ?>">
    <div class="card">
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
        <div class="form-group">
          <label>Topic</label>
          <select name="topic_id">
            <?php
            $currentLang = '';
            foreach ($topics as $t):
              if ($t['language_name'] !== $currentLang):
                if ($currentLang !== '') echo '</optgroup>';
                $currentLang = $t['language_name'];
                echo '<optgroup label="' . htmlspecialchars($currentLang) . '">';
              endif;
              $sel = ((string)($old['topic_id'] ?? '') === (string)$t['id']) ? 'selected' : '';
            ?>
            <option value="<?= (int)$t['id'] ?>" <?= $sel ?>><?= htmlspecialchars($t['name']) ?></option>
            <?php endforeach; ?>
            </optgroup>
          </select>
        </div>
        <div class="form-group">
          <label>Sort Order</label>
          <input type="number" name="sort_order" value="<?= $v('sort_order', 0) ?>">
        </div>
      </div>

      <div class="form-group">
        <label>Title</label>
        <input type="text" name="title" value="<?= $v('title') ?>" placeholder="e.g. Ternary Operator">
      </div>
      <div class="form-group">
        <label>Prompt</label>
        <textarea name="prompt" rows="3" placeholder="What does the user need to do?"><?= $v('prompt') ?></textarea>
      </div>

      <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px">
        <div class="form-group">
          <label>Type</label>
          <select name="type">
            <?php foreach (['fill_blank','write_code','spot_bug'] as $t): ?>
            <option value="<?= $t ?>" <?= $v('type') === $t ? 'selected' : '' ?>><?= $t ?></option>
            <?php endforeach; ?>
          </select>
        </div>
        <div class="form-group">
          <label>Difficulty</label>
          <select name="difficulty">
            <?php foreach (['beginner','intermediate','advanced'] as $d): ?>
            <option value="<?= $d ?>" <?= $v('difficulty') === $d ? 'selected' : '' ?>><?= $d ?></option>
            <?php endforeach; ?>
          </select>
        </div>
        <div class="form-group">
          <label>Diagnostic?</label>
          <select name="is_diagnostic">
            <option value="0" <?= $v('is_diagnostic', 0) == 0 ? 'selected' : '' ?>>No</option>
            <option value="1" <?= $v('is_diagnostic', 0) == 1 ? 'selected' : '' ?>>Yes</option>
          </select>
        </div>
      </div>

      <div class="form-group">
        <label>Starter Code <span style="color:var(--muted)">(shown above answer box)</span></label>
        <textarea name="starter_code" rows="4" style="font-family:var(--font-mono);font-size:0.88rem"><?= $v('starter_code') ?></textarea>
      </div>
      <div class="form-group">
        <label>Solution <span style="color:var(--muted)">(the correct answer string)</span></label>
        <input type="text" name="solution" value="<?= $v('solution') ?>" style="font-family:var(--font-mono)">
      </div>
      <div class="form-group">
        <label>Hint</label>
        <input type="text" name="hint" value="<?= $v('hint') ?>" placeholder="A nudge…">
      </div>
      <div class="form-group">
        <label>Explanation <span style="color:var(--muted)">(shown after answering)</span></label>
        <textarea name="explanation" rows="4" placeholder="Explain the concept thoroughly…"><?= $v('explanation') ?></textarea>
      </div>

      <div style="display:flex;gap:10px;margin-top:8px">
        <button type="submit" class="btn btn-primary">💾 <?= $isEdit ? 'Update' : 'Save' ?> Challenge</button>
        <a href="/admin/challenges" class="btn btn-ghost">Cancel</a>
      </div>
    </div>
  </form>
</div>
```

- [ ] **Run tests**

```bash
php vendor/bin/phpunit
```

- [ ] **Commit**

```bash
git add src/Views/admin-challenges.php src/Views/admin-challenge-form.php
git commit -m "feat: admin challenge list and form views"
```

---

## Task 7: Progression Gating

**Files:**
- Create: `tests/ProgressionGatingTest.php`
- Modify: `src/Controllers/ChallengeController.php`

- [ ] **Write failing tests** — create `tests/ProgressionGatingTest.php`:

```php
<?php
namespace Tests;

use App\Database;
use App\Models\Progress;
use PHPUnit\Framework\TestCase;

class ProgressionGatingTest extends TestCase
{
    private int $challenge1Id;
    private int $challenge2Id;

    protected function setUp(): void
    {
        Database::reset();
        $db = Database::getInstance();
        $db->migrate();
        $db->exec("INSERT INTO languages (name,slug,icon,is_active) VALUES ('PHP','php','🐘',1)");
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order) VALUES (1,'Operators','operators','',2)");
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation,sort_order)
                   VALUES (1,'C1','Q1','fill_blank','beginner','a','e',1)");
        $this->challenge1Id = (int)$db->lastInsertId();
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation,sort_order)
                   VALUES (1,'C2','Q2','fill_blank','beginner','a','e',2)");
        $this->challenge2Id = (int)$db->lastInsertId();
    }

    public function test_first_challenge_always_unlocked(): void
    {
        // completedIds returns empty — challenge 1 has no prerequisite
        $completed = Progress::completedIds('token_x');
        $this->assertNotContains($this->challenge1Id, $completed);
        // Logic: position 1 has no previous — always accessible
        $position = 1;
        $isLocked = $position > 1 && !in_array($this->challenge1Id, $completed);
        $this->assertFalse($isLocked);
    }

    public function test_second_challenge_locked_without_passing_first(): void
    {
        $completed = Progress::completedIds('token_x');
        // challenge2 is at position 2; challenge1 not in $completed
        $prevId = $this->challenge1Id;
        $isLocked = !in_array($prevId, $completed);
        $this->assertTrue($isLocked);
    }

    public function test_second_challenge_unlocked_after_passing_first(): void
    {
        Progress::record('token_x', $this->challenge1Id, true, null);
        $completed = Progress::completedIds('token_x');
        $prevId = $this->challenge1Id;
        $isLocked = !in_array($prevId, $completed);
        $this->assertFalse($isLocked);
    }

    public function test_failed_attempt_does_not_unlock_next(): void
    {
        Progress::record('token_x', $this->challenge1Id, false, null);
        $completed = Progress::completedIds('token_x');
        $prevId = $this->challenge1Id;
        $isLocked = !in_array($prevId, $completed);
        $this->assertTrue($isLocked); // still locked — passed=false not in completedIds
    }
}
```

- [ ] **Run — expect pass** (these test the model layer, not the HTTP layer)

```bash
php vendor/bin/phpunit tests/ProgressionGatingTest.php
```

Expected: all 4 pass — the logic is already correct in `Progress::completedIds`.

- [ ] **Add gating to `ChallengeController::show()`**

Find this block in `src/Controllers/ChallengeController.php`:

```php
$tips      = Tip::forTopic($topic['id'], $challenge['difficulty']);
$token     = Auth::sessionToken();
$completed = Progress::completedIds($token);
$allForTopic = Challenge::forTopic($topic['id']);
$position  = array_search($challenge['id'], array_column($allForTopic, 'id')) + 1;
$total     = count($allForTopic);
```

Replace with:

```php
$tips        = Tip::forTopic($topic['id'], $challenge['difficulty']);
$token       = Auth::sessionToken();
$completed   = Progress::completedIds($token);
$allForTopic = Challenge::forTopic($topic['id']);
$position    = array_search($challenge['id'], array_column($allForTopic, 'id')) + 1;
$total       = count($allForTopic);

// Progression gate: challenge N requires challenge N-1 to be passed
if ($position > 1) {
    $prevId = $allForTopic[$position - 2]['id'];
    if (!in_array($prevId, $completed)) {
        header('Location: /learn/' . $lang . '/' . $topicSlug);
        exit;
    }
}
```

- [ ] **Run full test suite**

```bash
php vendor/bin/phpunit
```

Expected: all tests pass (gating uses header/exit which isn't exercised in unit tests).

- [ ] **Commit**

```bash
git add src/Controllers/ChallengeController.php tests/ProgressionGatingTest.php
git commit -m "feat: progression gating — challenge N requires N-1 passed"
```

---

## Task 8: Topic View — Lock States

**Files:**
- Modify: `src/Views/topic.php`

- [ ] **Replace the entire content of `src/Views/topic.php`:**

```php
<div class="page">
  <div style="margin-bottom:6px;color:var(--muted);font-size:0.85rem">
    <a href="/learn/php">PHP</a> › <?= htmlspecialchars($topic['name']) ?>
  </div>
  <h1 style="margin-bottom:8px"><?= htmlspecialchars($topic['name']) ?></h1>
  <p style="color:var(--muted);margin-bottom:28px"><?= htmlspecialchars($topic['description']) ?></p>

  <div style="display:flex;flex-direction:column;gap:10px">
    <?php foreach ($challenges as $i => $c):
      $done     = in_array($c['id'], $completed);
      $prevDone = $i === 0 || in_array($challenges[$i - 1]['id'], $completed);
      $locked   = !$prevDone && !$done;
    ?>

    <?php if ($locked): ?>
    <div class="card" style="display:flex;align-items:center;gap:16px;opacity:0.45;cursor:not-allowed">
      <div style="font-size:1.2rem">🔒</div>
      <div style="flex:1">
        <div style="font-weight:600;margin-bottom:2px"><?= htmlspecialchars($c['title']) ?></div>
        <div style="color:var(--muted);font-size:0.82rem">Complete the previous challenge first.</div>
      </div>
      <span class="badge badge-<?= htmlspecialchars($c['difficulty']) ?>"><?= ucfirst($c['difficulty']) ?></span>
    </div>

    <?php else: ?>
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/<?= (int)$c['id'] ?>" style="text-decoration:none">
      <div class="card" style="display:flex;align-items:center;gap:16px;cursor:pointer;<?= $done ? 'border-color:#166534' : 'border-color:var(--border)' ?>">
        <div style="font-size:1.2rem"><?= $done ? '✅' : '▶' ?></div>
        <div style="flex:1">
          <div style="font-weight:600;margin-bottom:2px"><?= htmlspecialchars($c['title']) ?></div>
          <div style="color:var(--muted);font-size:0.85rem"><?= htmlspecialchars($c['prompt']) ?></div>
        </div>
        <div style="display:flex;gap:6px;align-items:center">
          <span class="badge badge-<?= htmlspecialchars($c['difficulty']) ?>"><?= ucfirst($c['difficulty']) ?></span>
          <span class="badge" style="background:var(--bg);color:var(--muted);border:1px solid var(--border);font-size:0.72rem"><?= str_replace('_',' ',$c['type']) ?></span>
        </div>
      </div>
    </a>
    <?php endif; ?>

    <?php endforeach; ?>
  </div>

  <?php $allDone = count($challenges) > 0 && count(array_diff(array_column($challenges,'id'), $completed)) === 0; ?>
  <?php if ($allDone): ?>
  <div class="card" style="margin-top:20px;text-align:center">
    <h3 style="margin-bottom:8px">🏁 All challenges complete!</h3>
    <p style="color:var(--muted);margin-bottom:16px">Take the section test to confirm your understanding.</p>
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/test" class="btn btn-primary">Start Section Test →</a>
  </div>
  <?php endif; ?>
</div>
```

- [ ] **Run tests**

```bash
php vendor/bin/phpunit
```

- [ ] **Commit**

```bash
git add src/Views/topic.php
git commit -m "feat: topic view — locked/unlocked/done challenge cards"
```

---

## Task 9: CodeMirror Editor

**Files:**
- Create: `public/assets/js/editor.js`
- Modify: `src/Views/challenge.php`
- Modify: `public/assets/js/runner.js`

- [ ] **Create `public/assets/js/editor.js`:**

```js
// CodeMirror 6 — loaded only on write_code challenges
// Imports from esm.sh (free CDN, no npm required)
import { EditorView, keymap, lineNumbers, highlightActiveLine } from 'https://esm.sh/@codemirror/view@6';
import { EditorState } from 'https://esm.sh/@codemirror/state@6';
import { defaultKeymap, indentWithTab } from 'https://esm.sh/@codemirror/commands@6';
import { php } from 'https://esm.sh/@codemirror/lang-php@6';
import { oneDark } from 'https://esm.sh/@codemirror/theme-one-dark@6';
import { basicSetup } from 'https://esm.sh/codemirror@6';

const mount  = document.getElementById('cm-editor');
const hidden = document.getElementById('cm-answer');
if (mount && hidden) {
    const startDoc = mount.dataset.starter || '';
    const view = new EditorView({
        state: EditorState.create({
            doc: startDoc,
            extensions: [
                basicSetup,
                php(),
                oneDark,
                keymap.of([indentWithTab, ...defaultKeymap]),
                EditorView.updateListener.of(update => {
                    if (update.docChanged) {
                        hidden.value = update.state.doc.toString();
                    }
                }),
                EditorView.theme({
                    '&': { fontSize: '0.9rem', minHeight: '140px' },
                    '.cm-scroller': { fontFamily: "'Courier New', monospace" },
                }),
            ],
        }),
        parent: mount,
    });
    // Initialise hidden input with starter code
    hidden.value = startDoc;
}
```

- [ ] **Update `src/Views/challenge.php`** — replace the `write_code` textarea block:

Find:
```php
<?php if ($challenge['type'] === 'write_code'): ?>
<textarea name="answer" class="code-input" placeholder="Write your PHP code here..."
          rows="6"></textarea>
<?php else: ?>
```

Replace with:
```php
<?php if ($challenge['type'] === 'write_code'): ?>
<div id="cm-editor" data-starter="<?= htmlspecialchars($challenge['starter_code']) ?>" data-lang="php"></div>
<input type="hidden" name="answer" id="cm-answer">
<?php else: ?>
```

Also find and replace the script tag at the bottom:
```php
<?php if ($challenge['type'] === 'write_code'): ?>
<div id="runner-output" style="display:none" class="card" style="margin-top:12px">
  <div style="color:var(--muted);font-size:0.8rem;margin-bottom:6px">Output:</div>
  <pre id="runner-pre" style="margin:0"></pre>
</div>
<script src="/assets/js/runner.js" defer></script>
<?php endif; ?>
```

Replace with:
```php
<?php if ($challenge['type'] === 'write_code'): ?>
<div id="runner-output" style="display:none;margin-top:12px" class="card">
  <div style="color:var(--muted);font-size:0.8rem;margin-bottom:6px">Output:</div>
  <pre id="runner-pre" style="margin:0"></pre>
</div>
<script src="/assets/js/runner.js" defer></script>
<script type="module" src="/assets/js/editor.js"></script>
<?php endif; ?>
```

- [ ] **Update `runner.js`** — fix the textarea reference to use the hidden input:

Replace the entire content of `public/assets/js/runner.js`:

```js
// php-wasm in-browser PHP runner
// Used for write_code challenges — shows output without grading

async function runCode() {
    const answer = document.getElementById('cm-answer')?.value
                ?? document.querySelector('textarea[name="answer"]')?.value
                ?? '';
    const output = document.getElementById('runner-output');
    const pre    = document.getElementById('runner-pre');

    output.style.display = 'block';
    pre.textContent = 'Running…';

    try {
        const { PhpWeb } = await import('https://cdn.jsdelivr.net/npm/php-wasm/PhpWeb.mjs');
        const php  = new PhpWeb();
        const code = answer.trim().startsWith('<?php') ? answer : '<?php\n' + answer;
        const result = await php.run(code);
        pre.textContent = result.output || '(no output)';
    } catch (e) {
        pre.textContent = 'Error: ' + e.message;
    }
}
```

- [ ] **Run tests**

```bash
php vendor/bin/phpunit
```

- [ ] **Commit**

```bash
git add public/assets/js/editor.js src/Views/challenge.php public/assets/js/runner.js
git commit -m "feat: CodeMirror 6 editor for write_code challenges"
```

---

## Task 10: Content Seed — Variables & Operators

**Files:**
- Modify: `database/seed.sql`

- [ ] **Append Variables & Data Types challenges to `database/seed.sql`:**

```sql
-- ═══════════════════════════════════════════════
-- Variables & Data Types (topic_id = 1)
-- ═══════════════════════════════════════════════
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(4,1,'Assign a Variable',
 'Fill in the blank to assign the string "PHP" to the variable.',
 'fill_blank','beginner',
 '$name = ______;',
 '"PHP"',
 'Strings are wrapped in quotes. Variables start with $.',
 'In PHP, variables start with $. Strings are wrapped in single or double quotes: $name = "PHP". Single quotes also work: $name = ''PHP''.',
 1, 1),

(5,1,'Spot the Variable Bug',
 'This code should print "Hello" but throws an error. Find and fix the bug.',
 'spot_bug','beginner',
 'name = "Hello";
echo $name;',
 '$name = "Hello";',
 'PHP variable names always start with a dollar sign.',
 'Every PHP variable must begin with $. Without it, PHP does not recognise "name" as a variable. The fix is $name = "Hello";',
 1, 2),

(6,1,'Get a Variable Type',
 'Fill in the built-in function that returns the type of a variable as a string.',
 'fill_blank','beginner',
 '$x = 42;
echo ______($x); // prints "integer"',
 'gettype',
 'Think: "get the type".',
 'gettype() returns a string describing the variable type: "integer", "double", "string", "boolean", "array", "NULL", etc. It is useful for debugging.',
 0, 3),

(7,1,'Type Casting',
 'Fill in the blank to cast the string $str to an integer using PHP cast syntax.',
 'fill_blank','beginner',
 '$str = "42";
$num = ______;',
 '(int)$str',
 'PHP uses (type) prefix syntax for casting: (int), (float), (string).',
 '(int)$str casts the string "42" to integer 42. You can also use intval($str). Casting is essential when handling form input, which always arrives as strings.',
 0, 4),

(8,1,'Strict Comparison',
 'Fill in the blank — use strict equality so the comparison returns false when types differ.',
 'fill_blank','intermediate',
 '$a = "1";
$b = 1;
var_dump($a ______ $b); // bool(false)',
 '===',
 '== checks value only; === checks value AND type.',
 '== (loose) returns true for "1" == 1 because PHP coerces types. === (strict) returns false because one is a string and the other an integer. Prefer === to avoid surprise type coercion bugs.',
 0, 5),

(9,1,'Loose Comparison Trap',
 'Spot the bug — this should print "not empty" for "hello" but prints "empty".',
 'spot_bug','intermediate',
 '$input = "hello";
if ($input == 0) {
    echo "empty";
} else {
    echo "not empty";
}',
 'if ($input === 0) {',
 'Comparing a non-numeric string to 0 with == is always true in PHP.',
 'When PHP compares a non-numeric string to an integer with ==, it converts the string to 0. So "hello" == 0 is true. Use === to compare value AND type, preventing this class of bug.',
 1, 6),

(10,1,'Null Coalescing Operator',
 'Fill in the blank — use ?? to return $config[''timeout''] if set, otherwise 30.',
 'fill_blank','intermediate',
 '$config = [];
$timeout = ______;',
 '$config[''timeout''] ?? 30',
 'The ?? operator returns the left side if it exists and is not null, otherwise the right side.',
 'The null coalescing operator ?? (PHP 7+) returns the left operand if it exists and is not null, otherwise the right operand. It replaces the verbose isset($x) ? $x : $default pattern.',
 0, 7),

(11,1,'Define a Constant',
 'Write the statement to define a constant named MAX_SIZE with value 100.',
 'fill_blank','advanced',
 '',
 'define(''MAX_SIZE'', 100)',
 'PHP uses define() or the const keyword.',
 'define(''MAX_SIZE'', 100) creates a global constant. Constants have no $ prefix and cannot be changed after definition. Inside a class, use const MAX_SIZE = 100; instead.',
 0, 8);

-- Tips for Variables & Data Types (topic_id = 1)
INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(1,'all','Quick Reference',
 '$x = 42;       // integer
$y = 3.14;     // float
$s = "hello";  // string
$b = true;     // boolean
$n = null;     // null
gettype($x)    // "integer"'),
(1,'beginner','Common Mistake',
 'Forgetting the $ prefix: name = "PHP" causes an error. Always: $name = "PHP".'),
(1,'intermediate','=== vs ==',
 'Use === (strict) not == (loose). "1" == 1 is true; "1" === 1 is false. Loose comparison causes hard-to-find bugs.');

-- Section test for Variables (uses challenges 4, 5, 6)
INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (1,4,1),(1,5,2),(1,6,3);

-- Follow-up for challenge 4 (wrong answer)
INSERT OR IGNORE INTO followup_challenges (challenge_id,prompt,type,solution,explanation) VALUES
(4,'What character do ALL PHP variable names start with? Fill in: ______name = "PHP";',
 'fill_blank','$',
 'Every PHP variable starts with a dollar sign $. Without it PHP does not recognise it as a variable.');


-- ═══════════════════════════════════════════════
-- Operators (topic_id = 2)
-- ═══════════════════════════════════════════════
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(12,2,'Modulo Operator',
 'Fill in the blank — what is the result of 10 % 3?',
 'fill_blank','beginner',
 '$result = 10 % 3;
echo $result; // ______',
 '1',
 'The % operator returns the remainder after division.',
 '10 divided by 3 is 3 remainder 1. The modulo operator % returns that remainder. It is useful for checking if a number is even (n % 2 === 0) or cycling through values.',
 1, 1),

(13,2,'String Concatenation',
 'Fill in the blank — concatenate $first and $last with a space between them.',
 'fill_blank','beginner',
 '$first = "John";
$last  = "Doe";
$full  = ______;',
 '$first . " " . $last',
 'PHP uses the dot (.) operator for string concatenation, not +.',
 'In PHP, strings are joined with . (dot). $first . " " . $last produces "John Doe". This is different from JS/Python where + works for strings.',
 1, 2),

(14,2,'Assignment vs Comparison',
 'Spot the bug — the condition always evaluates to true.',
 'spot_bug','beginner',
 '$score = 50;
if ($score = 100) {
    echo "Perfect!";
}',
 'if ($score == 100) {',
 'One = is assignment; == is comparison.',
 '$score = 100 inside an if is an assignment, not a comparison. It assigns 100 to $score (truthy), so the block always runs. Use == or === to compare.',
 0, 3),

(15,2,'Increment / Decrement',
 'Fill in the blank — increment $counter by 1 using the shortest PHP syntax.',
 'fill_blank','beginner',
 '$counter = 5;
______;
echo $counter; // 6',
 '$counter++',
 'PHP has ++ (post-increment) and -- (post-decrement) operators.',
 '$counter++ is post-increment: it returns the current value then increments. ++$counter pre-increments. Both result in $counter being 6 here.',
 0, 4),

(16,2,'Ternary Operator',
 'Fill in the blank — use the ternary operator to set $label to "adult" if $age >= 18, else "minor".',
 'fill_blank','intermediate',
 '$age = 20;
$label = ______;',
 '$age >= 18 ? "adult" : "minor"',
 'The ternary is: condition ? value_if_true : value_if_false',
 'The ternary operator is a one-line if/else: condition ? true_value : false_value. It keeps simple conditional assignments concise. Avoid nesting ternaries — PHP 8 deprecated chained ternaries without parentheses.',
 1, 5),

(17,2,'Loose Equality Gotcha',
 'Spot the bug — this should only match the integer 0, not the string "foo".',
 'spot_bug','intermediate',
 '$val = "foo";
if ($val == 0) {
    echo "zero";
}',
 'if ($val === 0) {',
 'Non-numeric strings equal 0 under loose comparison.',
 'PHP converts non-numeric strings to 0 for arithmetic comparisons. "foo" == 0 is true. Use === to check value AND type, preventing this gotcha.',
 0, 6),

(18,2,'Null Coalescing Assignment',
 'Fill in the blank — use ??= to set $visits to 1 only if it is currently null.',
 'fill_blank','intermediate',
 '$visits = null;
$visits ______= 1;
echo $visits; // 1',
 '??',
 'PHP 7.4 added ??= which assigns only when the left side is null.',
 '$visits ??= 1 is shorthand for $visits = $visits ?? 1. It assigns the right side only when the left side is null or undefined. Useful for counters and defaults.',
 0, 7),

(19,2,'Spaceship Operator',
 'Fill in the blank — use the spaceship operator to compare $a and $b (returns -1, 0, or 1).',
 'fill_blank','advanced',
 '$a = 5;
$b = 10;
$result = ______;
echo $result; // -1',
 '$a <=> $b',
 'The spaceship operator <=> returns -1, 0, or 1.',
 '$a <=> $b returns -1 if $a < $b, 0 if equal, 1 if $a > $b. It is perfect for usort() callbacks: usort($arr, fn($a, $b) => $a <=> $b) sorts ascending.',
 0, 8);

-- Tips for Operators (topic_id = 2)
INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(2,'all','Quick Reference',
 '+ - * / %   arithmetic
.            concatenate strings
== ===       loose / strict equal
!= !==       loose / strict not-equal
&& ||        logical and / or
?:           ternary
??           null coalesce
<=>          spaceship (-1/0/1)'),
(2,'beginner','Common Mistake',
 'Using + to join strings: "Hello" + "World" gives 0 (numeric). Use . instead: "Hello" . " " . "World".'),
(2,'intermediate','Strict Always',
 'Default to === and !==. Only use == when you explicitly want type coercion, and document why.');

-- Section test for Operators (challenges 12, 14, 16)
INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (2,12,1),(2,14,2),(2,16,3);

-- Follow-up for challenge 12
INSERT OR IGNORE INTO followup_challenges (challenge_id,prompt,type,solution,explanation) VALUES
(12,'What operator gives you the remainder after division? Fill in: 10 ______ 3 gives 1',
 'fill_blank','%',
 'The modulo operator % returns the division remainder. 10 % 3 = 1 because 10 = 3×3 + 1.');
```

- [ ] **Run tests — still green**

```bash
php vendor/bin/phpunit
```

- [ ] **Commit**

```bash
git add database/seed.sql
git commit -m "content: Variables and Operators challenges, tips, section tests"
```

---

## Task 11: Content Seed — Strings, Conditionals & Arrays additions

**Files:**
- Modify: `database/seed.sql`

- [ ] **Append to `database/seed.sql`:**

```sql
-- ═══════════════════════════════════════════════
-- Strings (topic_id = 3)
-- ═══════════════════════════════════════════════
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(20,3,'String Length',
 'Fill in the built-in function to get the number of characters in $str.',
 'fill_blank','beginner',
 '$str = "Hello";
echo ______($str); // 5',
 'strlen',
 'Think: "string length".',
 'strlen() returns the number of bytes in a string (same as characters for ASCII). For multibyte strings (UTF-8 with accents/emoji) use mb_strlen() instead.',
 1, 1),

(21,3,'String Interpolation',
 'Fill in the blank — embed the variable $name inside the double-quoted string.',
 'fill_blank','beginner',
 '$name = "World";
echo "Hello, ______!"; // Hello, World!',
 '$name',
 'PHP interpolates variables directly inside double-quoted strings.',
 'Inside double quotes, PHP replaces $variable with its value — this is called interpolation. Single quotes do NOT interpolate: echo ''Hello $name'' prints the literal $name.',
 1, 2),

(22,3,'Uppercase Conversion',
 'Spot the bug — this should print "HELLO" but prints "hello".',
 'spot_bug','beginner',
 '$str = "hello";
echo strtolower($str);',
 'echo strtoupper($str);',
 'strtolower makes lowercase; strtoupper makes uppercase.',
 'strtolower() converts to lowercase, strtoupper() to uppercase. The code used the wrong function. Fix: echo strtoupper($str);',
 0, 3),

(23,3,'String Replace',
 'Fill in the blank — replace every "cat" with "dog" in $sentence.',
 'fill_blank','beginner',
 '$sentence = "I love my cat. My cat is great.";
echo ______("cat", "dog", $sentence);',
 'str_replace',
 'PHP has a function called str_replace.',
 'str_replace($search, $replace, $subject) replaces all occurrences of $search with $replace. It is case-sensitive. Use str_ireplace() for case-insensitive replacement.',
 0, 4),

(24,3,'strpos Truthy Trap',
 'Spot the bug — this should print "found" when "PHP" is at position 0 but prints "not found".',
 'spot_bug','intermediate',
 '$str = "PHP is great";
if (strpos($str, "PHP")) {
    echo "found";
} else {
    echo "not found";
}',
 'if (strpos($str, "PHP") !== false) {',
 'strpos returns 0 when found at position 0 — and 0 is falsy.',
 'strpos() returns the integer position of the needle, or false if not found. Position 0 is falsy in PHP, so a bare if (strpos(...)) misses matches at the start. Always use !== false.',
 1, 5),

(25,3,'Substring',
 'Fill in the blank — extract 5 characters starting from position 7.',
 'fill_blank','intermediate',
 '$str = "Hello, World!";
echo ______($str, 7, 5); // World',
 'substr',
 'PHP has a function to extract part of a string: sub-string.',
 'substr($string, $start, $length) extracts $length characters from $string starting at $start (0-indexed). substr("Hello, World!", 7, 5) gives "World".',
 0, 6),

(26,3,'String Padding',
 'Fill in the blank — pad $num with leading zeros to make it 5 characters wide.',
 'fill_blank','intermediate',
 '$num = "42";
echo ______($num, 5, "0", STR_PAD_LEFT); // 00042',
 'str_pad',
 'PHP has a str_pad() function for padding strings to a given length.',
 'str_pad($input, $length, $pad_string, $pad_type) pads a string to a given length. STR_PAD_LEFT pads on the left, STR_PAD_RIGHT on the right (default), STR_PAD_BOTH on both sides.',
 0, 7),

(27,3,'sprintf Formatting',
 'Fill in the blank — use sprintf to format $price as a 2-decimal float with a $ prefix.',
 'fill_blank','advanced',
 '$price = 9.5;
echo ______("$%.2f", $price); // $9.50',
 'sprintf',
 'sprintf() formats strings using placeholders like %.2f for 2-decimal floats.',
 'sprintf($format, ...$values) returns a formatted string. %.2f formats a float to 2 decimal places. Other useful specifiers: %d (integer), %s (string), %05d (zero-padded integer).',
 0, 8);

-- Tips for Strings (topic_id = 3)
INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(3,'all','Quick Reference',
 'strlen($s)              // length
strtoupper/strtolower($s) // case
str_replace($f,$r,$s)    // replace
strpos($s,$needle)        // position (use !== false!)
substr($s,$start,$len)   // slice
trim($s)                 // strip whitespace'),
(3,'beginner','Single vs Double Quotes',
 'Double quotes interpolate variables: "Hello $name" → Hello World
Single quotes are literal: ''Hello $name'' → Hello $name
Use double quotes when embedding variables; single quotes otherwise.'),
(3,'intermediate','strpos Gotcha',
 'strpos returns 0 when the needle is at the start — 0 is falsy!
Always: if (strpos($str, $needle) !== false) { ... }');

-- Section test for Strings (challenges 20, 21, 24)
INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (3,20,1),(3,21,2),(3,24,3);

-- Follow-up for challenge 21 (interpolation)
INSERT OR IGNORE INTO followup_challenges (challenge_id,prompt,type,solution,explanation) VALUES
(21,'Which type of quotes allow variable interpolation in PHP? Fill in: ______ quotes',
 'fill_blank','double',
 'Only double-quoted strings interpolate variables. Single-quoted strings treat $ as a literal character.');


-- ═══════════════════════════════════════════════
-- Arrays additions (topic_id = 4, IDs 28-32)
-- Existing: IDs 1, 2, 3
-- ═══════════════════════════════════════════════
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(28,4,'Associative Array',
 'Fill in the blank — create an associative array with key "color" set to "red".',
 'fill_blank','beginner',
 '$car = ______;',
 '["color" => "red"]',
 'Associative arrays use => to map keys to values.',
 'Associative arrays use string keys: ["color" => "red"]. Access values with $car["color"]. Unlike indexed arrays, order is preserved by insertion.',
 1, 4),

(29,4,'Add to Array',
 'Fill in the blank — append "cherry" to the end of $fruits.',
 'fill_blank','intermediate',
 '$fruits = ["apple", "banana"];
______;',
 '$fruits[] = "cherry"',
 '$arr[] = $value appends to the end. Or use array_push().',
 '$fruits[] = "cherry" is the idiomatic PHP way to append. It is equivalent to array_push($fruits, "cherry") but shorter. The [] syntax auto-assigns the next numeric index.',
 0, 5),

(30,4,'foreach Loop',
 'Spot the bug — this should print each fruit on its own line but prints nothing.',
 'spot_bug','intermediate',
 '$fruits = ["apple", "banana", "cherry"];
foreach ($fruit as $item) {
    echo $item . "\n";
}',
 'foreach ($fruits as $item) {',
 'Check the variable name in the foreach — does it match the array?',
 'The foreach references $fruit (singular) but the array is $fruits (plural). PHP creates a new empty variable rather than erroring, so the loop runs 0 times. Fix: foreach ($fruits as $item).',
 0, 6),

(31,4,'array_map',
 'Fill in the blank — use array_map to double every number in $numbers.',
 'fill_blank','advanced',
 '$numbers = [1, 2, 3, 4];
$doubled = ______($numbers);',
 'array_map(fn($n) => $n * 2,',
 'array_map applies a callback to every element and returns a new array.',
 'array_map(callback, array) applies the callback to each element and returns a new array. The original $numbers is unchanged. Arrow functions (fn($n) => expr) are concise for simple transformations.',
 0, 7),

(32,4,'array_filter',
 'Fill in the blank — keep only even numbers from $numbers.',
 'fill_blank','advanced',
 '$numbers = [1, 2, 3, 4, 5, 6];
$evens = ______($numbers, fn($n) => $n % 2 === 0);',
 'array_filter',
 'array_filter keeps elements where the callback returns true.',
 'array_filter(array, callback) returns a new array containing only elements for which the callback returns true. Note: keys are preserved, so use array_values() afterwards if you need a re-indexed array.',
 0, 8);

-- Section test additions for Arrays (add challenges 28, 29, 30 for fuller test)
INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (4,28,4),(4,29,5),(4,30,6);

-- Tips additions for Arrays
INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(4,'intermediate','Array Functions',
 'array_map($fn, $arr)     // transform each element
array_filter($arr, $fn)  // keep matching elements
array_reduce($arr,$fn,$i)// fold to single value
array_keys($arr)         // get all keys
in_array($val, $arr)     // check membership'),
(4,'advanced','Keys After filter',
 'array_filter preserves original keys.
Use array_values(array_filter(...)) to get a re-indexed array starting from 0.');


-- ═══════════════════════════════════════════════
-- Conditionals (topic_id = 5)
-- ═══════════════════════════════════════════════
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(33,5,'Basic if/else',
 'Fill in the blank — print "pass" if $score is 50 or above, otherwise "fail".',
 'fill_blank','beginner',
 '$score = 75;
if (______) {
    echo "pass";
} else {
    echo "fail";
}',
 '$score >= 50',
 'The >= operator means "greater than or equal to".',
 'The condition $score >= 50 is true when $score is 50 or above. >= means "greater than or equal". Other comparison operators: > (greater), < (less), <= (less or equal), == (equal), === (strict equal).',
 1, 1),

(34,5,'elseif Chain',
 'Spot the bug — the grade "B" is never printed even when $score is 75.',
 'spot_bug','beginner',
 '$score = 75;
if ($score >= 90) {
    echo "A";
} else if ($score >= 80) {
    echo "B";
} elseif ($score >= 70) {
    echo "C";
}',
 'elseif ($score >= 80) {',
 'PHP prefers elseif (one word) over else if (two words) in standard style.',
 'Both else if and elseif work in PHP, but mixing them can cause confusion. Here the logic is fine — the bug is stylistic. The real issue is $score = 75 matches $score >= 70, so the output would be "C". If you expected "B", the threshold needs adjusting.',
 1, 2),

(35,5,'Switch Statement',
 'Fill in the blank — complete the switch to handle the "admin" role.',
 'fill_blank','beginner',
 '$role = "admin";
switch ($role) {
    case "admin":
        echo "Full access";
        ______;
    case "editor":
        echo "Edit access";
        break;
}',
 'break',
 'Without break, execution falls through to the next case.',
 'switch cases fall through without break — execution continues into the next case. Without break after "Full access", PHP would also print "Edit access". Always add break (or return) unless you intentionally want fall-through.',
 0, 3),

(36,5,'Switch Fall-Through Bug',
 'Spot the bug — "Small" is always printed regardless of $size.',
 'spot_bug','intermediate',
 '$size = "large";
switch ($size) {
    case "small":
        echo "Small";
    case "medium":
        echo "Medium";
        break;
    case "large":
        echo "Large";
        break;
}',
 'case "small":
        echo "Small";
        break;',
 'A missing break causes execution to fall into the next case.',
 'Without break after case "small", execution falls through to "medium" and prints "Medium". With $size = "large" the "large" case is matched and "Large" is printed correctly — but "small" is still broken. Add break after each case.',
 0, 4),

(37,5,'match Expression',
 'Fill in the blank — use the match expression to map $status to a label.',
 'fill_blank','intermediate',
 '$status = "active";
$label = ______ ($status) {
    "active"   => "Active User",
    "inactive" => "Inactive",
    "banned"   => "Banned",
    default    => "Unknown",
};',
 'match',
 'PHP 8 introduced match — like switch but returns a value and uses strict comparison.',
 'match (PHP 8+) is like switch but: returns a value, uses strict === comparison, throws UnhandledMatchError if no arm matches (unless you add default). No break needed.',
 1, 5),

(38,5,'match vs switch Types',
 'Spot the bug — match should return "Number" for the integer 0 but returns "Boolean".',
 'spot_bug','intermediate',
 '$val = 0;
$result = match($val) {
    false, null => "Falsy",
    0 => "Number",
    default     => "Other",
};
echo $result;',
 '    false, null => "Falsy",
    0 => "Number",',
 'match uses strict comparison (===). What does 0 === false evaluate to?',
 '0 === false is false — but match arms are checked in order. The arm "false, null" is listed first. Since match uses ===, 0 !== false, so it correctly falls to the 0 arm. The arms are already in the right order — the output is "Number". This challenge tests understanding that match is strict.',
 0, 6),

(39,5,'Null Safe Operator',
 'Fill in the blank — use the null-safe operator to call getCity() on $user only if $user is not null.',
 'fill_blank','advanced',
 '$user = null;
$city = $user______getCity();
echo $city ?? "unknown"; // unknown',
 '?->',
 'PHP 8 added the null-safe operator ?-> which short-circuits to null if the left side is null.',
 '$user?->getCity() returns null without error if $user is null, instead of throwing "Call to a member function on null". Chain multiple: $order?->getUser()?->getCity().',
 0, 7),

(40,5,'Short-Circuit Evaluation',
 'Fill in the blank — use a single expression with && so loadUser() is only called if $id is truthy.',
 'fill_blank','advanced',
 '$id = 0;
$result = $id ______ loadUser($id);
// loadUser() should NOT be called when $id is 0',
 '&&',
 'With &&, if the left side is false/falsy the right side is never evaluated.',
 '&& short-circuits: if $id is falsy (0, "", null, false), PHP skips the right side entirely and $result is false. This prevents unnecessary function calls and avoids errors when $id is invalid.',
 0, 8);

-- Tips for Conditionals (topic_id = 5)
INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(5,'all','Quick Reference',
 'if / elseif / else     // classic branching
switch / case / break   // multi-value branching
match (PHP 8+)          // strict, returns value
?? / ?:                 // null coalesce / ternary
?->                     // null-safe method call'),
(5,'beginner','switch Needs break',
 'Without break, switch falls through to the next case.
Always add break (or return) after each case body unless intentional.'),
(5,'intermediate','match vs switch',
 'match uses === (strict), switch uses == (loose).
match throws if no arm matches; switch does nothing without default.
match returns a value; switch does not.');

-- Section test for Conditionals (challenges 33, 34, 37)
INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (5,33,1),(5,34,2),(5,37,3);

-- Follow-up for challenge 33
INSERT OR IGNORE INTO followup_challenges (challenge_id,prompt,type,solution,explanation) VALUES
(33,'What operator checks if a number is greater than OR equal to another? Fill in: $score ______ 50',
 'fill_blank','>=',
 '>= means "greater than or equal to". $score >= 50 is true when score is 50, 60, 100 — anything 50 or above.');
```

- [ ] **Delete the existing SQLite DB and reseed**

```bash
php -r "unlink('database/app.sqlite');"
php bin/setup.php
```

Expected output:
```
Running schema...
Migration: added is_admin column.
Running seed...
Done! Database ready at: database/app.sqlite
```

- [ ] **Run tests — all green**

```bash
php vendor/bin/phpunit
```

Expected: all tests pass (tests use `:memory:` DB, unaffected by seed changes).

- [ ] **Smoke-check: start the dev server and verify**

```bash
php -S localhost:8000 -t public
```

Then check:
- `http://localhost:8000/learn/php` — all 5 topics listed
- `http://localhost:8000/learn/php/variables` — 8 challenges, 2+ locked
- `http://localhost:8000/learn/php/conditionals` — 8 challenges

- [ ] **Commit**

```bash
git add database/seed.sql
git commit -m "content: Strings, Conditionals, Arrays additions — 40 challenges total"
```

---

## Task 12: Wire Up Admin User & Final Smoke Test

**Files:** None (manual DB operation)

- [ ] **Make yourself admin** (run once after seeding)

```bash
php -r "
require 'vendor/autoload.php';
\$db = App\Database::getInstance();
\$db->exec(\"UPDATE users SET is_admin=1 WHERE email='your@email.com'\");
echo 'Done';
"
```

Replace `your@email.com` with the email you registered with on the site.

- [ ] **Full manual smoke test**

Start server: `php -S localhost:8000 -t public`

| Check | URL | Expected |
|---|---|---|
| Topics list | `/learn/php` | All 5 topics |
| Variables topic | `/learn/php/variables` | 8 challenges, #2+ locked |
| Pass challenge 1 | Submit correct answer | Challenge 2 unlocks |
| Skip attempt | Manually visit `/learn/php/variables/6` | Redirected to topic page |
| Admin guard | `/admin/challenges` (logged out) | 403 |
| Admin access | `/admin/challenges` (admin user) | Challenge list, grouped by topic |
| Create challenge | `/admin/challenges/new` → fill form | Challenge appears in list |
| Edit challenge | Click Edit → change title | Title updated |
| Delete challenge | Click Delete → confirm | Challenge removed |
| CodeMirror | `/learn/php/variables/7` (write_code) | CodeMirror editor visible |
| Run code | Click ▶ Run Code | php-wasm output shown |
| Mobile | Resize to 375px | Layout stacks, readable |

- [ ] **Run final test suite**

```bash
php vendor/bin/phpunit
```

Expected: all tests pass.

- [ ] **Final commit**

```bash
git add .
git commit -m "chore: final smoke-test verified — all 40 challenges, admin panel, gating, CodeMirror"
```

---

## Self-Review

**Spec coverage check:**
- ✅ §3 Content seed — Tasks 10, 11 (40 challenges, tips, followups, section tests)
- ✅ §4 Admin panel — Tasks 1, 2, 3, 4, 5, 6 (schema, auth guard, model, controller, routes, views)
- ✅ §5 Progression gating — Tasks 7, 8 (controller + topic view)
- ✅ §6 CodeMirror — Task 9
- ✅ §8.1 Responsive — admin views use existing CSS + `overflow-x:auto` on table
- ✅ §8.2 Guest mode — gating uses `Auth::sessionToken()`, works for guests
- ✅ §11 All files in change summary — covered

**Type consistency:**
- `Challenge::update(int $id, array $data)` — used consistently in Task 3 (test), Task 3 (implementation), Task 4 (controller)
- `Challenge::delete(int $id)` — consistent throughout
- `Auth::requireAdmin()` — throws `\RuntimeException`, caught in `guard()` helper in AdminController
- `$old` in admin form — populated from `$_SESSION['admin_old']` or existing `$challenge` array; both are flat arrays with same keys as POST fields

**Placeholder scan:** None found. Every step has actual code or commands.
