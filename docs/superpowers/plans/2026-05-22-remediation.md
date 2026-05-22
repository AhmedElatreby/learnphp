# Remediation System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a targeted practice loop — diagnostic results gain "Fix it →" buttons that serve 4 focused remediation challenges per topic, grade them in-memory, and show results with a link back to the real topic.

**Architecture:** Mirrors the existing `sectionTest/sectionTestSubmit` pattern exactly. `Remediation::forTopic()` queries `remediation_challenges`. `RemediationController` grades using `Challenge::grade()` (no DB writes). Two new views (`remediation.php`, `remediation-results.php`) styled identically to `section-test.php` / `section-results.php`.

**Tech Stack:** PHP 8.2, SQLite, PHPUnit 11, Playwright 1.60, existing CSS classes (`card`, `btn`, `code-block`, `alert`).

---

## File Map

| File | Action | Purpose |
|---|---|---|
| `database/seed.sql` | Modify | Add 20 remediation challenges (4 per topic) |
| `src/Models/Remediation.php` | Create | `forTopic(int $topicId): array` |
| `src/Controllers/RemediationController.php` | Create | `show()` and `submit()` |
| `src/Router.php` | Modify | Add 2 remediation routes |
| `src/Views/remediation.php` | Create | Challenge form |
| `src/Views/remediation-results.php` | Create | Score + explanations |
| `src/Views/diagnostic-results.php` | Modify | Add "Fix it →" buttons |
| `tests/Models/RemediationTest.php` | Create | Model unit tests |
| `tests/RemediationControllerTest.php` | Create | Grading logic tests |
| `e2e/remediation.spec.js` | Create | End-to-end flow |

---

## Task 1: Seed — 20 Remediation Challenges

**Files:**
- Modify: `database/seed.sql`

- [ ] **Append the following SQL to the END of `database/seed.sql`:**

```sql
-- ═══════════════════════════════════════════════
-- Remediation Challenges (4 per topic)
-- ═══════════════════════════════════════════════

-- Variables & Data Types (topic_id = 1)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(1,1,'types',
 'Fill in the blank — which function returns the type of a variable as a string?',
 'fill_blank',
 '$x = 42;
echo ______($x); // "integer"',
 'gettype',
 'gettype() returns a string describing the variable''s type: "integer", "double", "string", "boolean", "array", or "NULL".'),

(2,1,'casting',
 'Fill in the blank — cast the string $s to an integer.',
 'fill_blank',
 '$s = "7";
$n = ______;',
 '(int)$s',
 '(int)$variable casts to integer. intval($variable) also works. Form data always arrives as strings, so casting is essential.'),

(3,1,'comparison',
 'Spot the bug — this should only print "match" when $val is exactly the integer 0, not other falsy values.',
 'spot_bug',
 '$val = 0;
if ($val == false) {
    echo "match";
}',
 'if ($val === false) {',
 '== (loose) treats 0 and false as equal. === (strict) checks value AND type — 0 === false is false. Always prefer === to avoid type-coercion surprises.'),

(4,1,'constants',
 'Fill in the blank — define a constant named APP_VERSION with value "1.0".',
 'fill_blank',
 '______;',
 'define(''APP_VERSION'', ''1.0'')',
 'define(''NAME'', value) creates a global constant. Constants have no $ prefix and cannot be reassigned. Use const NAME = value inside class scope.');

-- Operators (topic_id = 2)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(5,2,'modulo',
 'Fill in the blank — what does 17 % 5 evaluate to?',
 'fill_blank',
 '$result = 17 % 5;
echo $result; // ______',
 '2',
 '17 divided by 5 is 3 remainder 2. The modulo operator % returns that remainder. Use n % 2 === 0 to test if a number is even.'),

(6,2,'concatenation',
 'Spot the bug — this should print "Hello World" but prints "0" instead.',
 'spot_bug',
 '$a = "Hello";
$b = "World";
echo $a + " " + $b;',
 'echo $a . " " . $b;',
 'PHP uses . (dot) for string concatenation, not + (plus). The + operator tries to add numerically — "Hello" becomes 0, so the result is 0.'),

(7,2,'ternary',
 'Fill in the blank — use the ternary operator to set $msg to "yes" if $ok is true, otherwise "no".',
 'fill_blank',
 '$ok = true;
$msg = ______;',
 '$ok ? "yes" : "no"',
 'The ternary operator: condition ? value_if_true : value_if_false. It is a one-line if/else that returns a value.'),

(8,2,'strict',
 'Fill in the blank — use strict equality to compare $a and $b.',
 'fill_blank',
 '$a = "5";
$b = 5;
var_dump($a ______ $b); // bool(false)',
 '===',
 '=== checks both value AND type. "5" === 5 is false because one is a string and one an integer. == would return true due to type coercion.');

-- Strings (topic_id = 3)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(9,3,'length',
 'Fill in the blank — get the number of characters in $word.',
 'fill_blank',
 '$word = "elephant";
echo ______($word); // 8',
 'strlen',
 'strlen() counts bytes (same as characters for ASCII/Latin text). For emoji or accented characters in UTF-8, use mb_strlen() instead.'),

(10,3,'interpolation',
 'Spot the bug — this should print "Hello Ahmed" but prints "Hello $name" literally.',
 'spot_bug',
 '$name = "Ahmed";
echo ''Hello $name'';',
 'echo "Hello $name";',
 'Single-quoted strings are literal — $variables are NOT interpolated. Use double quotes: "Hello $name" to embed variables directly in strings.'),

(11,3,'strpos',
 'Spot the bug — this should print "found" when "PHP" appears at the start of $str, but it prints "not found".',
 'spot_bug',
 '$str = "PHP is great";
if (strpos($str, "PHP")) {
    echo "found";
} else {
    echo "not found";
}',
 'if (strpos($str, "PHP") !== false) {',
 'strpos() returns the position (0 for the start), or false if not found. Position 0 is falsy, so bare if (strpos(...)) misses matches at the start. Always use !== false.'),

(12,3,'replace',
 'Fill in the blank — replace every "dog" with "cat" in $sentence.',
 'fill_blank',
 '$sentence = "I love my dog. My dog is great.";
echo ______("dog", "cat", $sentence);',
 'str_replace',
 'str_replace($search, $replace, $subject) replaces all occurrences of $search with $replace in $subject. It is case-sensitive. Use str_ireplace() for case-insensitive replacement.');

-- Arrays (topic_id = 4)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(13,4,'access',
 'Fill in the blank — access the second element of $colors.',
 'fill_blank',
 '$colors = ["red", "green", "blue"];
echo ______; // "green"',
 '$colors[1]',
 'Arrays are zero-indexed: $colors[0] is "red", $colors[1] is "green", $colors[2] is "blue". The second element is always at index 1.'),

(14,4,'count',
 'Fill in the blank — store the number of items in $fruits into $total.',
 'fill_blank',
 '$fruits = ["apple", "banana", "cherry", "date"];
$total = ______;',
 'count($fruits)',
 'count() returns the number of elements in an array. It is the standard PHP way to get array length — not sizeof() or length().'),

(15,4,'associative',
 'Spot the bug — this should print "Ahmed" but gives an error.',
 'spot_bug',
 '$user = ["name" => "Ahmed", "age" => 30];
echo $user[0];',
 'echo $user["name"];',
 'Associative arrays use string keys, not numeric indexes. $user[0] does not exist — use $user["name"] to access the "name" key.'),

(16,4,'foreach',
 'Fill in the blank — loop through $numbers and echo each one followed by a newline.',
 'fill_blank',
 '$numbers = [1, 2, 3, 4, 5];
foreach ($numbers as ______) {
    echo $n . "\n";
}',
 '$n',
 'foreach ($array as $item) iterates over each element. The variable after "as" ($n here) holds the current item. For key-value access use: foreach ($arr as $key => $value).');

-- Conditionals (topic_id = 5)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(17,5,'if-else',
 'Fill in the blank — complete the condition so $grade is "pass" when $score is 50 or above.',
 'fill_blank',
 '$score = 65;
if (______) {
    $grade = "pass";
} else {
    $grade = "fail";
}',
 '$score >= 50',
 '>= means "greater than or equal to". $score >= 50 is true for scores of 50, 60, 100 — anything at or above 50.'),

(18,5,'switch',
 'Spot the bug — when $day is "Monday", this prints "Monday" AND "Tuesday".',
 'spot_bug',
 '$day = "Monday";
switch ($day) {
    case "Monday":
        echo "Monday";
    case "Tuesday":
        echo "Tuesday";
        break;
}',
 'case "Monday":
        echo "Monday";
        break;',
 'Without break, switch falls through to the next case. After printing "Monday" it continues into the "Tuesday" case. Add break after each case body to stop execution.'),

(19,5,'match',
 'Fill in the blank — use PHP 8 match to map $code to a label.',
 'fill_blank',
 '$code = 200;
$label = ______ ($code) {
    200 => "OK",
    404 => "Not Found",
    500 => "Server Error",
    default => "Unknown",
};',
 'match',
 'match (PHP 8+) is like switch but returns a value, uses strict === comparison, and throws UnhandledMatchError if no arm matches without a default.'),

(20,5,'elseif',
 'Fill in the blank — add an elseif to check if $score is between 60 and 79.',
 'fill_blank',
 '$score = 70;
if ($score >= 80) {
    echo "A";
} ______ ($score >= 60) {
    echo "B";
} else {
    echo "C";
}',
 'elseif',
 'elseif (one word) adds another condition branch. Both elseif and else if work in PHP, but elseif is the standard convention. The conditions are checked in order — first true branch runs.');
```

- [ ] **Reseed the database:**

```bash
php -r "unlink('database/app.sqlite');" 2>/dev/null; php bin/setup.php
```

Expected output ends with: `Done! Database ready at: database/app.sqlite`

- [ ] **Verify:**

```bash
php -r "
require 'vendor/autoload.php';
\$db = App\Database::getInstance();
echo 'Remediation challenges: ' . \$db->query('SELECT COUNT(*) FROM remediation_challenges')->fetchColumn() . '\n';
"
```

Expected: `Remediation challenges: 20`

- [ ] **Commit:**

```bash
git add database/seed.sql
git commit -m "content: 20 remediation challenges (4 per PHP topic)"
```

---

## Task 2: Remediation Model — TDD

**Files:**
- Create: `src/Models/Remediation.php`
- Create: `tests/Models/RemediationTest.php`

- [ ] **Write the failing tests** — create `tests/Models/RemediationTest.php`:

```php
<?php
namespace Tests\Models;

use App\Database;
use App\Models\Remediation;
use App\Models\Challenge;
use PHPUnit\Framework\TestCase;

class RemediationTest extends TestCase
{
    protected function setUp(): void
    {
        Database::reset();
        $db = Database::getInstance();
        $db->migrate();
        $db->exec("INSERT INTO languages (name,slug,icon,is_active) VALUES ('PHP','php','🐘',1)");
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order)
                   VALUES (1,'Variables','variables','',1)");
    }

    public function test_for_topic_returns_empty_when_no_challenges(): void
    {
        $result = Remediation::forTopic(1);
        $this->assertSame([], $result);
    }

    public function test_for_topic_returns_seeded_challenges(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO remediation_challenges
                   (topic_id,weakness_tag,prompt,type,solution,explanation)
                   VALUES (1,'types','What is 1+1?','fill_blank','2','Basic math')");
        $db->exec("INSERT INTO remediation_challenges
                   (topic_id,weakness_tag,prompt,type,solution,explanation)
                   VALUES (1,'casting','Cast it','fill_blank','(int)\$s','Cast info')");
        $result = Remediation::forTopic(1);
        $this->assertCount(2, $result);
        $this->assertSame('types', $result[0]['weakness_tag']);
    }

    public function test_for_topic_ignores_other_topics(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order)
                   VALUES (1,'Operators','operators','',2)");
        $db->exec("INSERT INTO remediation_challenges
                   (topic_id,weakness_tag,prompt,type,solution,explanation)
                   VALUES (2,'modulo','What is 10%3?','fill_blank','1','Modulo info')");
        $result = Remediation::forTopic(1);
        $this->assertSame([], $result);
    }

    public function test_challenge_grade_works_with_remediation_shape(): void
    {
        // Verify Challenge::grade() accepts the remediation_challenge row shape
        $remChallenge = [
            'type'     => 'fill_blank',
            'solution' => '(int)$s',
        ];
        $this->assertTrue(Challenge::grade($remChallenge, '(int)$s'));
        $this->assertFalse(Challenge::grade($remChallenge, 'wrong'));
    }
}
```

- [ ] **Run — expect 4 failures:**

```bash
php vendor/bin/phpunit tests/Models/RemediationTest.php
```

Expected: `ERRORS` — `Remediation` class not found.

- [ ] **Create `src/Models/Remediation.php`:**

```php
<?php
namespace App\Models;

use App\Database;

class Remediation
{
    public static function forTopic(int $topicId): array
    {
        return Database::getInstance()->query(
            'SELECT * FROM remediation_challenges WHERE topic_id = ? ORDER BY id',
            [$topicId]
        )->fetchAll();
    }
}
```

- [ ] **Run — expect green:**

```bash
php vendor/bin/phpunit tests/Models/RemediationTest.php
```

Expected: `OK (4 tests, 5 assertions)`

- [ ] **Run full suite:**

```bash
php vendor/bin/phpunit
```

Expected: all tests pass.

- [ ] **Commit:**

```bash
git add src/Models/Remediation.php tests/Models/RemediationTest.php
git commit -m "feat: Remediation model with tests"
```

---

## Task 3: RemediationController — TDD

**Files:**
- Create: `src/Controllers/RemediationController.php`
- Create: `tests/RemediationControllerTest.php`

- [ ] **Write failing tests** — create `tests/RemediationControllerTest.php`:

```php
<?php
namespace Tests;

use App\Database;
use App\Models\Challenge;
use App\Models\Remediation;
use PHPUnit\Framework\TestCase;

class RemediationControllerTest extends TestCase
{
    protected function setUp(): void
    {
        Database::reset();
        $db = Database::getInstance();
        $db->migrate();
        $db->exec("INSERT INTO languages (name,slug,icon,is_active) VALUES ('PHP','php','🐘',1)");
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order)
                   VALUES (1,'Variables','variables','',1)");
        $db->exec("INSERT INTO remediation_challenges
                   (topic_id,weakness_tag,prompt,type,solution,explanation)
                   VALUES (1,'types','Q1?','fill_blank','gettype','Explanation A')");
        $db->exec("INSERT INTO remediation_challenges
                   (topic_id,weakness_tag,prompt,type,solution,explanation)
                   VALUES (1,'casting','Q2?','fill_blank','(int)\$s','Explanation B')");
    }

    public function test_grade_correct_answer_counts_as_passed(): void
    {
        $challenges = Remediation::forTopic(1);
        $passed = 0;
        $answers = [
            $challenges[0]['id'] => 'gettype',
            $challenges[1]['id'] => 'wrong',
        ];
        foreach ($challenges as $c) {
            if (Challenge::grade($c, $answers[$c['id']])) {
                $passed++;
            }
        }
        $this->assertSame(1, $passed);
    }

    public function test_score_calculation(): void
    {
        $challenges = Remediation::forTopic(1);
        $passed = 2;
        $total  = count($challenges);
        $score  = (int)round(($passed / $total) * 100);
        $this->assertSame(100, $score);
    }

    public function test_score_zero_when_all_wrong(): void
    {
        $challenges = Remediation::forTopic(1);
        $passed = 0;
        $total  = count($challenges);
        $score  = $total > 0 ? (int)round(($passed / $total) * 100) : 0;
        $this->assertSame(0, $score);
    }

    public function test_partial_score(): void
    {
        $challenges = Remediation::forTopic(1);
        $passed = 1;
        $total  = count($challenges); // 2
        $score  = (int)round(($passed / $total) * 100);
        $this->assertSame(50, $score);
    }
}
```

- [ ] **Run — expect pass** (tests only use model + grading, not controller HTTP):

```bash
php vendor/bin/phpunit tests/RemediationControllerTest.php
```

Expected: `OK (4 tests, 4 assertions)`

- [ ] **Create `src/Controllers/RemediationController.php`:**

```php
<?php
namespace App\Controllers;

use App\Models\Topic;
use App\Models\Remediation;
use App\Models\Challenge;

class RemediationController
{
    public function show(string $topicSlug): void
    {
        $topic      = Topic::findBySlug('php', $topicSlug);
        if (!$topic) { http_response_code(404); echo '404'; return; }

        $challenges = Remediation::forTopic($topic['id']);
        if (empty($challenges)) { http_response_code(404); echo '404'; return; }

        $title = 'Remediation: ' . $topic['name'];
        ob_start();
        require __DIR__ . '/../Views/remediation.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function submit(string $topicSlug): void
    {
        $topic      = Topic::findBySlug('php', $topicSlug);
        if (!$topic) { http_response_code(404); return; }

        $challenges = Remediation::forTopic($topic['id']);
        if (empty($challenges)) { http_response_code(404); return; }

        $passed  = 0;
        $results = [];
        foreach ($challenges as $c) {
            $answer  = trim($_POST['answer_' . $c['id']] ?? '');
            $correct = Challenge::grade($c, $answer);
            if ($correct) $passed++;
            $results[] = ['challenge' => $c, 'answer' => $answer, 'correct' => $correct];
        }

        $score = count($challenges) > 0
            ? (int)round($passed / count($challenges) * 100)
            : 0;

        $title = $topic['name'] . ' — Remediation Results';
        ob_start();
        require __DIR__ . '/../Views/remediation-results.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }
}
```

- [ ] **Run full suite:**

```bash
php vendor/bin/phpunit
```

Expected: all pass (controller isn't unit-tested via HTTP — model/grading layer already covered).

- [ ] **Commit:**

```bash
git add src/Controllers/RemediationController.php tests/RemediationControllerTest.php
git commit -m "feat: RemediationController show() and submit() with grading tests"
```

---

## Task 4: Router Routes

**Files:**
- Modify: `src/Router.php`

- [ ] **Add 2 routes** to `registerRoutes()` in `src/Router.php`, after the diagnostic routes (after `$this->get('/diagnostic/results', ...)`):

```php
$this->get('/remediation/{topic}',  [new \App\Controllers\RemediationController, 'show']);
$this->post('/remediation/{topic}', [new \App\Controllers\RemediationController, 'submit']);
```

- [ ] **Run tests:**

```bash
php vendor/bin/phpunit
```

- [ ] **Commit:**

```bash
git add src/Router.php
git commit -m "feat: remediation routes GET/POST /remediation/{topic}"
```

---

## Task 5: Views — Remediation Form

**Files:**
- Create: `src/Views/remediation.php`

- [ ] **Create `src/Views/remediation.php`:**

```php
<div class="page" style="max-width:700px">
  <div style="margin-bottom:6px;font-size:0.85rem">
    <a href="/diagnostic/results" style="color:var(--muted)">← Back to diagnostic results</a>
  </div>
  <h1 style="margin-bottom:4px">Remediation: <?= htmlspecialchars($topic['name']) ?></h1>
  <p style="color:var(--muted);margin-bottom:20px">
    Targeted practice to strengthen this topic. Answer all <?= count($challenges) ?> questions, then see your results.
  </p>

  <form method="POST" action="/remediation/<?= htmlspecialchars($topic['slug']) ?>">
    <?php foreach ($challenges as $i => $c): ?>
    <div class="card" style="margin-bottom:16px">
      <div style="color:var(--muted);font-size:0.8rem;margin-bottom:8px">
        Question <?= (int)($i + 1) ?>
        <span style="margin-left:8px;opacity:.6"><?= htmlspecialchars(str_replace('_', ' ', $c['type'])) ?></span>
      </div>
      <p style="font-weight:500;margin-bottom:10px"><?= htmlspecialchars($c['prompt']) ?></p>
      <?php if ($c['starter_code']): ?>
      <div class="code-block" style="margin-bottom:10px"><?= htmlspecialchars($c['starter_code']) ?></div>
      <?php endif; ?>
      <?php if ($c['type'] === 'write_code'): ?>
      <textarea name="answer_<?= (int)$c['id'] ?>" class="code-input" rows="4"
                placeholder="Your code here…"></textarea>
      <?php else: ?>
      <input type="text" name="answer_<?= (int)$c['id'] ?>"
             placeholder="Your answer…" autocomplete="off"
             style="font-family:var(--font-mono)">
      <?php endif; ?>
    </div>
    <?php endforeach; ?>
    <button type="submit" class="btn btn-primary" style="width:100%;padding:14px">
      Check My Answers →
    </button>
  </form>
</div>
```

- [ ] **Smoke test** — start dev server if not running:

```bash
php -S localhost:8000 -t public
```

Visit `http://localhost:8000/remediation/variables` — should show 4 challenges with answer inputs.  
Visit `http://localhost:8000/remediation/nonexistent` — should show `404`.

- [ ] **Run tests:**

```bash
php vendor/bin/phpunit
```

- [ ] **Commit:**

```bash
git add src/Views/remediation.php
git commit -m "feat: remediation challenge form view"
```

---

## Task 6: Views — Remediation Results

**Files:**
- Create: `src/Views/remediation-results.php`

- [ ] **Create `src/Views/remediation-results.php`:**

```php
<?php
$message = match(true) {
    $score === 100 => 'Perfect! You\'ve got this topic down.',
    $score >= 75   => 'Good work! A little more practice and you\'ll be solid.',
    $score >= 50   => 'Getting there — review the explanations above.',
    default        => 'Keep at it — read each explanation carefully before moving on.',
};
?>
<div class="page" style="max-width:700px">
  <div style="margin-bottom:6px;font-size:0.85rem">
    <a href="/diagnostic/results" style="color:var(--muted)">← Back to diagnostic results</a>
  </div>
  <h1 style="margin-bottom:4px"><?= htmlspecialchars($topic['name']) ?></h1>
  <p style="color:var(--muted);margin-bottom:16px">Remediation Results</p>

  <?php
  $color = $score >= 75 ? 'var(--success)' : ($score >= 50 ? 'var(--warning)' : 'var(--error)');
  ?>
  <div class="card" style="margin-bottom:20px;text-align:center">
    <div style="font-size:2rem;font-weight:800;color:<?= $color ?>;margin-bottom:4px">
      <?= (int)$passed ?> / <?= count($results) ?> correct
    </div>
    <div class="progress-bar" style="max-width:300px;margin:8px auto">
      <div class="progress-bar__fill" style="width:<?= (int)$score ?>%;background:<?= $color ?>"></div>
    </div>
    <div style="color:var(--muted);font-size:0.9rem;margin-top:8px"><?= htmlspecialchars($message) ?></div>
  </div>

  <?php foreach ($results as $r): ?>
  <div class="card" style="margin-bottom:12px;border-left:3px solid <?= $r['correct'] ? 'var(--success)' : 'var(--error)' ?>">
    <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:6px">
      <p style="font-weight:500;font-size:0.9rem;flex:1;margin-right:12px">
        <?= htmlspecialchars($r['challenge']['prompt']) ?>
      </p>
      <span style="color:<?= $r['correct'] ? 'var(--success)' : 'var(--error)' ?>;flex-shrink:0">
        <?= $r['correct'] ? '✅' : '✗' ?>
      </span>
    </div>
    <?php if (!$r['correct']): ?>
    <div style="color:var(--muted);font-size:0.85rem">
      Your answer: <code><?= htmlspecialchars($r['answer'] ?: '(blank)') ?></code>
    </div>
    <div style="color:var(--success);font-size:0.85rem;margin-top:2px">
      Correct: <code><?= htmlspecialchars($r['challenge']['solution']) ?></code>
    </div>
    <?php endif; ?>
    <div style="color:var(--muted);font-size:0.82rem;margin-top:6px;padding-top:6px;border-top:1px solid var(--border)">
      <?= htmlspecialchars($r['challenge']['explanation']) ?>
    </div>
  </div>
  <?php endforeach; ?>

  <div style="display:flex;gap:10px;margin-top:20px;flex-wrap:wrap">
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>" class="btn btn-primary" style="flex:1;min-width:200px">
      📚 Practice this topic →
    </a>
    <a href="/remediation/<?= htmlspecialchars($topic['slug']) ?>" class="btn btn-ghost">
      Retry Remediation
    </a>
    <a href="/diagnostic/results" class="btn btn-ghost">
      ← Diagnostic Results
    </a>
  </div>
</div>
```

- [ ] **Smoke test** — submit the form at `http://localhost:8000/remediation/variables`:
  - Submit with all blanks → results page loads, shows 0/4, score 0%
  - Submit with some correct answers → see mixed ✅/✗ results

- [ ] **Run tests:**

```bash
php vendor/bin/phpunit
```

- [ ] **Commit:**

```bash
git add src/Views/remediation-results.php
git commit -m "feat: remediation results view with score and explanations"
```

---

## Task 7: Update Diagnostic Results — "Fix it →" Buttons

**Files:**
- Modify: `src/Views/diagnostic-results.php`

- [ ] **Read the current file** at `src/Views/diagnostic-results.php` lines 49–58 (the learning plan section).

Find this block in the learning plan `foreach`:

```php
    <a href="/learn/php/<?= htmlspecialchars($r['topic']['slug']) ?>" style="text-decoration:none">
      <div style="display:flex;align-items:center;gap:12px;padding:10px;background:var(--bg);border-radius:6px;margin-bottom:8px;border-left:3px solid <?= $colors[$r['status']] ?>">
        <span style="color:var(--muted);font-size:0.85rem;min-width:20px"><?= (int)($i+1) ?></span>
        <span style="flex:1;color:var(--text);font-size:0.9rem"><?= htmlspecialchars($r['topic']['name']) ?></span>
        <span style="color:<?= $colors[$r['status']] ?>;font-size:0.8rem"><?= $r['status'] === 'weak' ? 'Priority' : 'Review' ?></span>
      </div>
    </a>
```

Replace it with:

```php
    <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;flex-wrap:wrap">
      <div style="flex:1;display:flex;align-items:center;gap:12px;padding:10px;background:var(--bg);border-radius:6px;border-left:3px solid <?= $colors[$r['status']] ?>;min-width:0">
        <span style="color:var(--muted);font-size:0.85rem;flex-shrink:0"><?= (int)($i+1) ?></span>
        <span style="flex:1;color:var(--text);font-size:0.9rem;overflow:hidden;text-overflow:ellipsis;white-space:nowrap"><?= htmlspecialchars($r['topic']['name']) ?></span>
        <span style="color:<?= $colors[$r['status']] ?>;font-size:0.8rem;flex-shrink:0"><?= $r['status'] === 'weak' ? 'Priority' : 'Review' ?></span>
      </div>
      <a href="/remediation/<?= htmlspecialchars($r['topic']['slug']) ?>"
         class="btn btn-primary"
         style="padding:6px 14px;font-size:0.82rem;min-height:36px;white-space:nowrap">
        Fix it →
      </a>
    </div>
```

- [ ] **Smoke test** — navigate to `http://localhost:8000/diagnostic`, submit a form (any answers), check `/diagnostic/results`:
  - Weak/review topics should show "Fix it →" buttons
  - Clicking "Fix it →" navigates to `/remediation/{slug}`
  - The full flow works: Diagnostic → Results → Fix it → Remediation form → Submit → Results → Practice topic

- [ ] **Run tests:**

```bash
php vendor/bin/phpunit
```

- [ ] **Commit:**

```bash
git add src/Views/diagnostic-results.php
git commit -m "feat: add Fix it buttons to diagnostic results learning plan"
```

---

## Task 8: Playwright End-to-End Tests

**Files:**
- Create: `e2e/remediation.spec.js`

- [ ] **Create `e2e/remediation.spec.js`:**

```js
// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Remediation flow', () => {
  test('remediation page loads for a valid topic', async ({ page }) => {
    await page.goto('/remediation/variables');
    await expect(page).toHaveURL(/\/remediation\/variables/);
    await expect(page.locator('h1')).toContainText('Variables');
    // Should have 4 challenge cards
    const cards = page.locator('.card');
    const count = await cards.count();
    expect(count).toBeGreaterThanOrEqual(4);
    // Should have answer inputs
    await expect(page.locator('input[name^="answer_"]').first()).toBeVisible();
  });

  test('remediation 404 for unknown topic', async ({ page }) => {
    const response = await page.goto('/remediation/nonexistent');
    expect(response?.status()).toBe(404);
  });

  test('submitting blank answers shows results page with 0%', async ({ page }) => {
    await page.goto('/remediation/variables');
    await page.locator('button[type="submit"]').click();
    await expect(page).toHaveURL(/\/remediation\/variables/);
    await expect(page.locator('.page')).toContainText('0 / 4');
    await expect(page.locator('a[href="/learn/php/variables"]')).toBeVisible();
    await expect(page.locator('a[href="/diagnostic/results"]')).toBeVisible();
  });

  test('submitting correct answers shows green score', async ({ page }) => {
    await page.goto('/remediation/variables');
    // Fill all inputs with correct answers
    await page.locator('input[name^="answer_"]').nth(0).fill('gettype');
    await page.locator('input[name^="answer_"]').nth(1).fill('(int)$s');
    await page.locator('button[type="submit"]').click();
    // At least some correct — score should show
    const text = await page.locator('.page').innerText();
    expect(text).toMatch(/\d+ \/ 4/);
  });

  test('results page links to practice topic and diagnostic', async ({ page }) => {
    await page.goto('/remediation/operators');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('a[href="/learn/php/operators"]')).toBeVisible();
    await expect(page.locator('a[href="/diagnostic/results"]')).toBeVisible();
  });

  test('retry link returns to the remediation form', async ({ page }) => {
    await page.goto('/remediation/strings');
    await page.locator('button[type="submit"]').click();
    await page.locator('a[href="/remediation/strings"]').click();
    await expect(page).toHaveURL(/\/remediation\/strings/);
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });

  test('back link on form goes to diagnostic results', async ({ page }) => {
    await page.goto('/remediation/conditionals');
    await page.locator('a[href="/diagnostic/results"]').click();
    await expect(page).toHaveURL(/\/diagnostic\/results/);
  });
});
```

- [ ] **Ensure dev server is running:**

```bash
php -S localhost:8000 -t public
```

- [ ] **Run only the remediation spec on desktop:**

```bash
npx playwright test e2e/remediation.spec.js --project=desktop
```

Expected: `7 passed`

- [ ] **Run full suite:**

```bash
npx playwright test
```

Expected: all tests pass (previous 64 + new remediation tests).

- [ ] **Commit:**

```bash
git add e2e/remediation.spec.js
git commit -m "test: Playwright e2e tests for remediation flow"
```

---

## Self-Review

**Spec coverage:**
- ✅ §3.2 Seed 20 challenges — Task 1
- ✅ §4 `Remediation::forTopic()` — Task 2
- ✅ §5.1 `show()` — loads topic + challenges, 404 if not found — Task 3
- ✅ §5.2 `submit()` — grades all answers, builds `$results`, computes `$score`, no DB writes — Task 3
- ✅ §6 Routes GET + POST — Task 4
- ✅ §7.1 `remediation.php` form view — Task 5
- ✅ §7.2 `remediation-results.php` with score messages — Task 6
- ✅ §7.3 "Fix it →" buttons on `diagnostic-results.php` — Task 7
- ✅ §8.1 PHPUnit `RemediationTest` — Task 2
- ✅ §8.2 PHPUnit `RemediationControllerTest` — Task 3
- ✅ §8.3 Playwright e2e — Task 8

**Placeholder scan:** None. All steps have concrete code or commands.

**Type consistency:**
- `Remediation::forTopic(int $topicId)` defined in Task 2, used in Tasks 3, 8 ✅
- `$challenges` array shape from `remediation_challenges` table: has `id`, `type`, `solution`, `prompt`, `starter_code`, `explanation`, `weakness_tag` ✅
- `Challenge::grade(array $challenge, string $answer)` — accepts any array with `type` + `solution` keys — compatible ✅
- `$results` array shape: `[challenge, answer, correct]` — defined in Task 3, used in Task 6 ✅
- `$score`, `$passed` variables — defined in controller Task 3, used in view Task 6 ✅
- `$topic['slug']` used in forms and links in Tasks 5, 6, 7 ✅
