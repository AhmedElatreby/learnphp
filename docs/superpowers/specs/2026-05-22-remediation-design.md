# Design: Remediation System

**Date:** 2026-05-22  
**Status:** Approved

---

## 1. Problem

The diagnostic test labels topics as `weak / review / strong` but provides no actionable path to fix weaknesses. Users see "Variables & Data Types — Priority" and a link to the full topic page — which starts at challenge 1 behind progression gating. There is no targeted practice loop.

## 2. Solution

A lightweight remediation flow:

1. Diagnostic results page gains a **"Fix it →"** button per weak/review topic
2. Clicking it serves a **short form** (4 targeted challenges per topic)
3. On submit, the user sees their **score + explanations**
4. CTAs link to the **real topic page** to continue, and back to the diagnostic

No progress persistence — remediation is deliberate practice, not part of the topic score. Improvement shows when the user completes real topic challenges and retakes the diagnostic.

---

## 3. Database

### 3.1 `remediation_challenges` table (already exists)

```sql
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
```

`weakness_tag` groups challenges by sub-skill (e.g. `types`, `comparison`). Used for future per-weakness routing; not filtered in this iteration.

### 3.2 Seeded content

4 remediation challenges per topic × 5 topics = **20 challenges** added to `database/seed.sql`.

| Topic | Tags covered |
|---|---|
| Variables & Data Types | `types`, `casting`, `comparison`, `constants` |
| Operators | `modulo`, `concatenation`, `ternary`, `strict` |
| Strings | `length`, `interpolation`, `strpos`, `replace` |
| Arrays | `access`, `count`, `associative`, `foreach` |
| Conditionals | `if-else`, `switch`, `match`, `elseif` |

Each challenge has `prompt`, `type`, `solution`, `explanation`, and optional `starter_code`. Types follow the existing distribution: mix of `fill_blank`, `spot_bug`, and `write_code`.

---

## 4. Model — `src/Models/Remediation.php`

Single static method:

```php
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

Grading reuses `Challenge::grade(array $challenge, string $answer): bool` — same normalise logic. The `$challenge` array shape matches (`type`, `solution`) so it works directly.

---

## 5. Controller — `src/Controllers/RemediationController.php`

### 5.1 `show(string $topicSlug): void`

```
GET /remediation/{topic}
```

- Look up topic via `Topic::findBySlug('php', $topicSlug)` — 404 if not found
- Load `Remediation::forTopic($topic['id'])`
- 404 if no challenges exist for this topic
- Render `src/Views/remediation.php` via `ob_start` → `layout.php`

### 5.2 `submit(string $topicSlug): void`

```
POST /remediation/{topic}
```

- Look up topic — 404 if not found
- Load challenges — 404 if none
- For each challenge, read `$_POST['answer_{id}']`, call `Challenge::grade($c, $answer)`
- Build `$results` array: `[challenge, answer, correct]` per item
- Compute `$score = (int)round($passed / count($challenges) * 100)`
- **No database writes** — results are in-memory only
- Render `src/Views/remediation-results.php` via `ob_start` → `layout.php`

---

## 6. Routes

Two new routes added to `Router::registerRoutes()`, after the diagnostic routes:

```php
$this->get('/remediation/{topic}',  [new \App\Controllers\RemediationController, 'show']);
$this->post('/remediation/{topic}', [new \App\Controllers\RemediationController, 'submit']);
```

---

## 7. Views

### 7.1 `src/Views/remediation.php`

```
┌─────────────────────────────────────┐
│ ← Back to diagnostic results        │
│                                     │
│ Remediation: Variables & Data Types │
│ You scored 25% on this topic.       │
│ Work through these 4 challenges...  │
│                                     │
│ Challenge 1: [prompt]               │
│ [starter code block if present]     │
│ [ answer input / textarea ]         │
│                                     │
│ Challenge 2: ...                    │
│ Challenge 3: ...                    │
│ Challenge 4: ...                    │
│                                     │
│     [ Check My Answers → ]          │
└─────────────────────────────────────┘
```

- Answer inputs: `<input>` for `fill_blank`/`spot_bug`, `<textarea class="code-input">` for `write_code`
- Input names: `answer_{challenge_id}`
- No HTMX — standard form POST, matches `section-test.php` pattern exactly

### 7.2 `src/Views/remediation-results.php`

```
┌─────────────────────────────────────┐
│ Variables & Data Types              │
│ Remediation Results                 │
│                                     │
│  3 / 4 correct — Good work!         │
│  ████████████░░  75%                │
│                                     │
│ ✅ Challenge 1 title                │
│    Your answer: "PHP"               │
│    Explanation: ...                 │
│                                     │
│ ✗  Challenge 2 title                │
│    Your answer: name = "PHP"        │
│    Correct:     $name = "PHP"       │
│    Explanation: ...                 │
│                                     │
│  [ 📚 Practice this topic → ]       │
│  [ ← Back to diagnostic results ]   │
└─────────────────────────────────────┘
```

Score message:
- 100%: "Perfect! You've got this topic down."
- ≥75%: "Good work! A little more practice and you'll be solid."
- ≥50%: "Getting there — review the explanations above."
- <50%: "Keep at it — read each explanation carefully before moving on."

### 7.3 `src/Views/diagnostic-results.php` — updated learning plan

In the "Recommended Learning Plan" section, each row gains a "Fix it →" button linking to `/remediation/{slug}` — only shown when remediation challenges exist for the topic:

```php
<a href="/remediation/<?= htmlspecialchars($r['topic']['slug']) ?>" class="btn btn-primary btn-sm">Fix it →</a>
```

The existing "Go to topic" link remains as the secondary action.

---

## 8. Testing

### 8.1 PHPUnit — `tests/Models/RemediationTest.php`

- `test_for_topic_returns_empty_when_no_challenges`: `forTopic(999)` returns `[]`
- `test_for_topic_returns_seeded_challenges`: after seeding, returns correct count
- `test_grade_works_with_remediation_challenge_shape`: `Challenge::grade(['type'=>'fill_blank','solution'=>'$x'],'$x')` returns true — verifies model shapes are compatible

### 8.2 PHPUnit — `tests/RemediationControllerTest.php`

Testing via the `Remediation` model + `Challenge::grade()` directly (no HTTP):

- `test_submit_grades_correct_answer`: grade correct → passed count increments
- `test_submit_grades_wrong_answer`: grade wrong → not counted
- `test_score_calculation`: 3 of 4 correct → 75%

### 8.3 Playwright — `e2e/remediation.spec.js`

- Navigate to `/diagnostic`, submit form → `/diagnostic/results`
- Verify "Fix it →" button visible for at least one topic
- Click "Fix it →" → arrives at `/remediation/{slug}`
- Form visible with at least one answer input
- Submit with all blanks → results page loads (even with 0% score)
- Results page shows score and "Practice this topic" link
- "Practice this topic" link href is correct (`/learn/php/{slug}`)

---

## 9. File Change Summary

| File | Change |
|---|---|
| `database/seed.sql` | Add 20 remediation challenges (4 per topic) |
| `src/Models/Remediation.php` | New — `forTopic(int $topicId): array` |
| `src/Controllers/RemediationController.php` | New — `show()` and `submit()` |
| `src/Router.php` | Add 2 remediation routes |
| `src/Views/remediation.php` | New — challenge form |
| `src/Views/remediation-results.php` | New — score + explanations |
| `src/Views/diagnostic-results.php` | Add "Fix it →" buttons to learning plan |
| `tests/Models/RemediationTest.php` | New |
| `tests/RemediationControllerTest.php` | New |
| `e2e/remediation.spec.js` | New |
