# Design: Content Seed, Admin Panel, Progression Gating & Code Editor

**Date:** 2026-05-21  
**Status:** Approved  
**Scope:** PHP stage only — architecture supports future JS, Python, Kotlin

---

## 1. Context & Goals

LearnPHP is a free, challenge-based coding education platform. Users take a diagnostic test, receive a personalised learning plan, and work through topic challenges. The site currently has a working MVC framework, auth, router, and one seeded topic (Arrays, 3 challenges). The platform is unusable at scale without content and an admin panel.

**Goals of this iteration:**

1. Seed all 5 PHP topics with 8+ challenges each (40+ total)
2. Build a working admin panel for challenge CRUD (challenges only)
3. Enforce progression gating — users cannot skip to the next challenge without passing the current one
4. Upgrade `write_code` challenges with a CodeMirror 6 code editor

**Non-goals (future stages):** JS, Python, Kotlin content; topic CRUD in admin; remediation system; code execution sandbox (grading remains string-compare); AI chatbot (planned, free-only — see §9).

---

## 2. Multi-Language Architecture Note

The DB schema already has a `languages` table and routes are parameterised as `/learn/{lang}/{topic}/{id}`. All new code must stay language-agnostic:

- Admin panel challenge form includes a **language selector** (populated from the `languages` table)
- Content seed inserts challenges under `language_id = 1` (PHP) via the existing `languages` join
- CodeMirror language mode is selected based on the language slug — PHP mode now, others added later
- When a new language is added, only content needs seeding — no code changes required

---

## 3. Content Seed

### 3.1 Topics & Volume

| Topic | slug | Existing challenges | New challenges | Total |
|---|---|---|---|---|
| Variables & Data Types | `variables` | 0 | 8 | 8 |
| Operators | `operators` | 0 | 8 | 8 |
| Strings | `strings` | 0 | 8 | 8 |
| Arrays | `arrays` | 3 | 5 | 8 |
| Conditionals | `conditionals` | 0 | 8 | 8 |

**Total: 40 challenges** across 5 topics.

### 3.2 Challenge Distribution Per Topic

Each topic gets:
- 3 × `fill_blank` (beginner + intermediate + one harder)
- 3 × `write_code` (beginner + intermediate + advanced)
- 2 × `spot_bug` (intermediate)
- `is_diagnostic = 1` on 2 challenges per topic (one beginner, one intermediate)
- `hint` populated on every challenge
- `explanation` is thorough — explains the concept, not just the answer

### 3.3 Companion Data Per Topic

- **Tips** (3 per topic): one "Quick Reference", one "Common Mistake", one "Deep Dive"
- **Follow-up challenges** (1 per beginner `fill_blank`): triggered on wrong answer
- **Section test** (3 challenges per topic): mix of types, mapped in `section_tests` table

### 3.4 Delivery

All inserts go in `database/seed.sql` using `INSERT OR IGNORE` so `php bin/setup.php` is idempotent. No new files — matches existing pattern.

### 3.5 `write_code` Grading

The "▶ Run Code" button (php-wasm, in-browser) lets the user preview output. Grading compares the **submitted code string** trimmed against the **solution code string** trimmed — server-side, no execution. This is appropriate for the exercises being seeded (code completion, not output matching). The `runner.js` comment "caller passes actual stdout" is a stale artefact — it will be removed.

---

## 4. Admin Panel

### 4.1 Auth Guard

A new `is_admin` column is added to `users`:

```sql
ALTER TABLE users ADD COLUMN is_admin INTEGER NOT NULL DEFAULT 0;
```

Added to `schema.sql` so fresh setups include it. A migration statement is added to `bin/setup.php` using `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` (SQLite doesn't support `IF NOT EXISTS` on columns, so we catch the PDOException and ignore it if the column already exists).

`Auth::requireAdmin()` — new static method:
- Calls `Auth::user()` — if null, sends HTTP 401 and exits
- If `user['is_admin']` is not 1, sends HTTP 403 and exits
- Called as the first line in every `AdminController` method

To make a user admin: direct SQL (`UPDATE users SET is_admin=1 WHERE email='...'`). No UI for this — it's a one-person admin panel.

### 4.2 Routes

Six new routes added to `Router::registerRoutes()`:

```
GET  /admin/challenges              → AdminController::index()
GET  /admin/challenges/new          → AdminController::create()
POST /admin/challenges              → AdminController::store()
GET  /admin/challenges/{id}/edit    → AdminController::edit()
POST /admin/challenges/{id}         → AdminController::update()
POST /admin/challenges/{id}/delete  → AdminController::destroy()
```

**Route ordering:** The literal `/admin/challenges/new` must be registered before `/admin/challenges/{id}/edit` to prevent `new` being matched as an ID.

### 4.3 AdminController Methods

| Method | Action |
|---|---|
| `index()` | List all challenges grouped by topic+language. Shows id, title, type, difficulty, edit/delete links. |
| `create()` | Render blank form |
| `store()` | Validate, insert, redirect to index with flash success |
| `edit(string $id)` | Fetch challenge, render pre-filled form |
| `update(string $id)` | Validate, update, redirect to index with flash success |
| `destroy(string $id)` | Delete challenge + its followups + section_test rows, redirect to index |

All methods call `Auth::requireAdmin()` first.

### 4.4 Validation Rules

| Field | Rule |
|---|---|
| `topic_id` | Required, must exist in `topics` |
| `title` | Required, non-empty string |
| `prompt` | Required, non-empty string |
| `type` | Required, one of: `fill_blank`, `write_code`, `spot_bug` |
| `difficulty` | Required, one of: `beginner`, `intermediate`, `advanced` |
| `solution` | Required, non-empty string |
| `explanation` | Required, non-empty string |
| `starter_code`, `hint` | Optional |
| `is_diagnostic`, `sort_order` | Optional integers, default 0 |

Validation errors flash to `$_SESSION['admin_errors']`, form values flash to `$_SESSION['admin_old']` — displayed on the form and cleared after one request.

### 4.5 Views

Two new view files:

**`src/Views/admin-challenges.php`** — index list:
- Nav breadcrumb: Admin › Challenges
- "Add Challenge" button (top right)
- Table grouped by language › topic: columns = ID, Title, Type, Difficulty, Diagnostic, Edit, Delete
- Delete is a `<form method="POST" action="/admin/challenges/{id}/delete">` with a confirm prompt via `onclick="return confirm('Delete?')"`
- Flash success/error alerts

**`src/Views/admin-challenge-form.php`** — create/edit form:
- Language select (populates topic select via simple JS `onchange` or static grouped `<optgroup>`)  
- Topic select (grouped by language using `<optgroup>`)
- All challenge fields as labelled form-groups
- Type and difficulty as `<select>` dropdowns
- `is_diagnostic` and `sort_order` as number inputs
- Old values re-populated from `$_SESSION['admin_old']` on validation failure
- Inline error list from `$_SESSION['admin_errors']`
- Uses existing CSS: `card`, `form-group`, `btn`, `btn-primary`, `btn-ghost`, `alert`

### 4.6 Challenge Model Additions

```php
Challenge::all(): array          // SELECT all, joined with topic + language name
Challenge::update(int $id, array $data): void
Challenge::delete(int $id): void // also deletes followup_challenges and section_tests rows
```

---

## 5. Progression Gating

### 5.1 Rule

A user may only view challenge N if challenge N−1 (ordered by `difficulty` then `sort_order`) is marked `passed = 1` in `user_progress` for their session token. Challenge 1 in any topic is always unlocked.

### 5.2 Enforcement — Controller

`ChallengeController::show()` after fetching `$allForTopic` and `$position`:

```php
if ($position > 1) {
    $prevId = $allForTopic[$position - 2]['id'];
    if (!in_array($prevId, $completed)) {
        header('Location: /learn/' . $lang . '/' . $topicSlug);
        exit;
    }
}
```

No change to `submit()` — submitting an answer is always allowed (prevents edge cases with form re-submissions).

### 5.3 Enforcement — Topic Page

`src/Views/topic.php` displays each challenge card. Each card shows:
- **Unlocked** (challenge 1, or previous is passed): clickable link, challenge title, difficulty badge
- **Locked** (previous not passed): greyed-out card, 🔒 icon, "Complete the previous challenge first" tooltip

`TopicController::show()` already has `$completed` array. No controller changes needed — the view uses `in_array()` checks.

### 5.4 No Bypass Via Direct URL

The controller redirect (§5.2) handles this. Users who manually type `/learn/php/arrays/3` without having passed challenge 2 are sent back to the topic page.

---

## 6. CodeMirror Code Editor

### 6.1 Library

**CodeMirror 6** loaded from CDN (jsDelivr — free, no account required):

```html
<script type="module" src="/assets/js/editor.js"></script>
```

`editor.js` imports CodeMirror 6 packages from `https://esm.sh/` (free ESM CDN):
- `@codemirror/view`
- `@codemirror/state`
- `@codemirror/lang-php` (for PHP syntax highlighting)
- `@codemirror/theme-one-dark` (matches existing dark theme)

### 6.2 Integration

Applied only to `write_code` challenges (existing `if ($challenge['type'] === 'write_code')` block in `challenge.php`).

- A `<div id="cm-editor"></div>` replaces the raw `<textarea>`
- A hidden `<input type="hidden" name="answer" id="cm-answer">` holds the value
- `editor.js` mounts CodeMirror into `#cm-editor`, pre-populated with `starter_code`
- On every editor change: `document.getElementById('cm-answer').value = view.state.doc.toString()`
- The existing HTMX form submits the hidden input — no change to backend

### 6.3 Language Mode Selection

`editor.js` reads `data-lang` attribute from the editor div:
```html
<div id="cm-editor" data-lang="php"></div>
```
Future languages add their CodeMirror extension package and a switch case in `editor.js`.

### 6.4 Fallback

If ESM CDN fails (offline, blocked), the hidden input is still there but empty. The form degrades: users see an empty answer submitted. A future improvement could add a visible `<noscript>` textarea fallback — out of scope here.

---

## 7. Testing

### 7.1 Existing Tests (must stay green)
All 26 existing tests must continue to pass.

### 7.2 New Tests

**`tests/AdminControllerTest.php`**
- Unauthenticated request to `/admin/challenges` → `Auth::requireAdmin()` exits with 403
- Non-admin user → 403
- Admin user GET `/admin/challenges` → 200
- `store()` with missing required fields → validation error, no DB insert
- `store()` with valid data → challenge inserted
- `update()` → challenge updated
- `destroy()` → challenge deleted, followups deleted

**`tests/Models/ChallengeTest.php`** (extend existing)
- `Challenge::all()` returns array with `topic_name` and `language_name` keys
- `Challenge::update()` persists changes
- `Challenge::delete()` removes challenge and its followup rows

**`tests/ProgressionGatingTest.php`**
- Accessing challenge 2 without passing challenge 1 → redirect to topic page
- After passing challenge 1 → challenge 2 accessible
- Challenge 1 always accessible

### 7.3 Manual Smoke Test Checklist
- [ ] `php bin/setup.php` runs cleanly on fresh DB
- [ ] `/learn/php` shows all 5 topics
- [ ] `/learn/php/variables` shows 8 challenges, challenge 2+ locked
- [ ] Passing challenge 1 unlocks challenge 2
- [ ] `/admin/challenges` returns 403 for guest
- [ ] Admin user can add/edit/delete a challenge
- [ ] `write_code` challenge shows CodeMirror editor
- [ ] "▶ Run Code" still works (php-wasm)
- [ ] Diagnostic test has ≥2 diagnostic challenges per topic

---

## 8. Responsive Design & Guest Mode

### 8.1 Responsive Design

The site must work on desktop browsers and mobile phones. The existing CSS already has a 768px breakpoint for the challenge layout and nav. All new views (admin panel, updated topic cards) must follow the same pattern:

- Admin challenge list: table scrolls horizontally on mobile (`overflow-x: auto` wrapper)
- Admin form: full-width inputs (already default from existing `input { width:100% }` rule)
- Topic locked-card state: same card size as unlocked, lock icon replaces difficulty badge slot on narrow screens
- No new CSS frameworks — extend `main.css` and `challenge.css` only

### 8.2 Guest Mode

Users can use the platform without registering. This is already architected:

- `Auth::sessionToken()` issues a `guest_token` into the PHP session — works for guests and logged-in users identically
- `Progress::record()` and `Progress::topicScore()` both work with session token alone
- Progression gating uses `completedIds($token)` — works for guests

**What guests can do:** Diagnostic test, all topic challenges, section tests, view results.  
**What requires login:** Dashboard (redirects to `/login`). Logged-in users get progress persisted across devices/browsers via `user_id`; guests lose progress when the session expires.

The nav already shows Login / Sign Up for guests — no change needed.

---

## 9. Deployment & Free Infrastructure

### 9.1 Local Development

Run locally with PHP's built-in server:
```
php -S localhost:8000 -t public
```
SQLite database at `database/app.sqlite`. No extra services needed.

### 9.2 Free Hosting Target

**Recommended: [Railway.app](https://railway.app)** — free starter tier, supports PHP via Nixpacks, persistent volume for SQLite.

Alternative: **Render.com** (free tier, PHP + disk) or **Fly.io** (free tier, Docker-based).

**Avoid:** Netlify, Vercel, GitHub Pages (static only — won't run PHP).

**SQLite on free hosts:** Most free tiers have ephemeral filesystems — data resets on redeploy. Mitigation: mount a persistent volume for `database/` (Railway and Fly.io both support this for free). Document this in a `DEPLOY.md` to be written before first deploy.

### 9.3 Cost Constraint

Every dependency used must be free with no credit card required:
- **php-wasm** (CDN, MIT) ✅
- **CodeMirror 6** (esm.sh CDN, MIT) ✅  
- **HTMX** (unpkg CDN, 0BSD) ✅
- **SQLite** (built into PHP) ✅
- **PHPUnit** (dev-only, MIT) ✅

---

## 10. Future: AI Chatbot (Free)

A chatbot to answer PHP questions is planned for a later stage. **No paid APIs.** Options when the time comes:

| Option | Cost | Notes |
|---|---|---|
| **Ollama** (local) | Free | Runs open-source LLMs (Llama 3, Mistral) on your machine. Perfect for local dev. |
| **Google Gemini API** | Free tier (60 req/min) | No credit card for free tier. Best production option. |
| **Groq API** | Free tier | Very fast inference, free tier available. |
| **Hugging Face Inference** | Free tier | Rate-limited but no cost. |

**Architecture when built:** A `POST /chat` route → `ChatController` → calls chosen free API → streams response back. The chat widget floats over the challenge page. No changes needed to current code — it's purely additive.

**Decision deferred** until after this iteration ships.

---

## 11. File Change Summary

| File | Change |
|---|---|
| `database/schema.sql` | Add `is_admin` column to `users` |
| `database/seed.sql` | Add 37 new challenges + tips + followups + section_tests |
| `bin/setup.php` | Apply `is_admin` migration safely |
| `src/Auth.php` | Add `requireAdmin()` method |
| `src/Models/Challenge.php` | Add `all()`, `update()`, `delete()` |
| `src/Controllers/AdminController.php` | Full implementation (was stubs) |
| `src/Router.php` | Add 6 admin routes |
| `src/Views/admin-challenges.php` | New — challenge list (responsive) |
| `src/Views/admin-challenge-form.php` | New — create/edit form (responsive) |
| `src/Controllers/ChallengeController.php` | Add gating check in `show()` |
| `src/Views/challenge.php` | Replace textarea with CodeMirror div + hidden input |
| `src/Views/topic.php` | Add lock state to challenge cards |
| `public/assets/js/editor.js` | New — CodeMirror 6 integration |
| `public/assets/js/runner.js` | Remove stale stdout comment |
| `tests/AdminControllerTest.php` | New |
| `tests/ProgressionGatingTest.php` | New |
| `tests/Models/ChallengeTest.php` | Extend with new model methods |
