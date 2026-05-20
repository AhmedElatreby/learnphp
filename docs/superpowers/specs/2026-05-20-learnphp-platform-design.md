# LearnPHP Platform — Design Spec
**Date:** 2026-05-20  
**Status:** Approved  
**Phase:** 1 — PHP (future phases add JS, Python, Kotlin, etc.)

---

## Mission

Make sure users are genuinely learning PHP — not just clicking through challenges. Every interaction teaches. Understanding is proven before progress is unlocked.

---

## 1. Architecture

### Stack (all free)

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Backend | PHP 8.x | Routing, business logic, HTML rendering |
| Database | SQLite | Single file, zero config, works locally and on free hosts |
| Interactivity | HTMX | Dynamic page updates without a JS framework |
| Code Runner | php-wasm (WebAssembly) | Runs user PHP code 100% in browser — no server execution |
| Styling | Vanilla CSS | Dark dev theme, hand-crafted |
| Hosting | Railway or Render (free tier) | Single PHP app + SQLite file |

### Request Flow

1. All requests enter via `public/index.php` (front controller)
2. `Router` maps URL → `Controller`
3. Controller queries SQLite via `Model` layer
4. Controller renders a PHP template → returns HTML
5. HTMX intercepts links/forms → swaps only the changed DOM fragment (no full reload)
6. Code runner challenges load php-wasm client-side → PHP execution stays in the browser

### Project Structure

```
learnphp/
├── public/               ← web root only
│   ├── index.php         ← front controller
│   └── assets/           ← CSS, JS, php-wasm bundle
├── src/
│   ├── Router.php
│   ├── Controllers/
│   │   ├── HomeController.php
│   │   ├── AuthController.php
│   │   ├── ChallengeController.php
│   │   ├── DiagnosticController.php
│   │   ├── TopicController.php
│   │   ├── DashboardController.php
│   │   └── AdminController.php
│   ├── Models/
│   │   ├── User.php
│   │   ├── Topic.php
│   │   ├── Challenge.php
│   │   ├── Progress.php
│   │   └── Tip.php
│   └── Views/            ← PHP template files
│       ├── layout.php
│       ├── home.php
│       ├── challenge.php
│       ├── diagnostic.php
│       └── ...
├── database/
│   ├── app.sqlite
│   └── schema.sql        ← source of truth for schema
├── composer.json         ← autoloading only, no heavy dependencies
└── .env.example
```

### Multi-Language Architecture (future-ready)

- A `languages` table controls which languages are active
- All topics and challenges belong to a language
- URL structure: `/learn/{language}/{topic}/{challenge}` (e.g. `/learn/php/arrays/3`)
- Code runner is swappable per language:
  - PHP → php-wasm
  - Python → Pyodide (WebAssembly)
  - JavaScript → native `eval()` in browser
  - Kotlin → Kotlin Playground API (free)
- Phase 1 deploys with only PHP active (`is_active = 1`). Other languages exist in the schema but are hidden until content is ready.

---

## 2. Database Schema

### `languages`
```sql
id, name, slug, icon, is_active, created_at
```
Seed: `{1, "PHP", "php", "🐘", 1}`

### `users`
```sql
id, username, email, password_hash, created_at
```

### `topics`
```sql
id, language_id, name, slug, description, sort_order
```
28 PHP topics (see Section 5).

### `challenges`
```sql
id, topic_id, title, prompt,
type            -- 'fill_blank' | 'write_code' | 'spot_bug'
difficulty      -- 'beginner' | 'intermediate' | 'advanced'
starter_code    -- shown to the user in the editor
solution        -- expected correct answer (string or expected output)
hint            -- shown if user clicks Hint
explanation     -- shown after submit (right or wrong) — WHY it works
is_diagnostic   -- bool: included in diagnostic test
sort_order
```

### `followup_challenges`
```sql
id, challenge_id, prompt, type, starter_code, solution, explanation
```
1–2 follow-up questions per challenge, shown only after a wrong answer.

### `section_tests`
```sql
id, topic_id, challenge_id, sort_order
```
Links 6 challenges to each topic's section-end test.

### `remediation_challenges`
```sql
id, topic_id, weakness_tag, prompt, type, starter_code, solution, explanation
```
Targeted extra challenges shown when a learner fails a section test.

### `user_progress`
```sql
id, user_id (NULL = guest), session_token,
challenge_id, passed (bool), attempts, completed_at
```

### `tips`
```sql
id, topic_id, difficulty, title, content
```

---

## 3. Pages

### Public (no login required)
| Page | URL | Description |
|------|-----|-------------|
| Home | `/` | Welcome, CTA to take diagnostic test or browse topics |
| Diagnostic Test | `/diagnostic` | ~15 challenges across all topics/difficulties |
| Diagnostic Results | `/diagnostic/results` | Score per topic, recommended learning plan |
| Topics List | `/learn/php` | Grid of all 28 PHP topics with progress bars (if logged in) |
| Topic Page | `/learn/php/{topic}` | Intro, tips, list of challenges by difficulty |
| Challenge Page | `/learn/php/{topic}/{id}` | Core learning screen (see Section 4) |

### Auth
| Page | URL | Description |
|------|-----|-------------|
| Register | `/register` | Username, email, password. Guest progress carried over automatically. |
| Login | `/login` | Email + password. Redirects back to previous page. |

### Logged-in
| Page | URL | Description |
|------|-----|-------------|
| Dashboard | `/dashboard` | Progress overview, weak areas, "continue where you left off" |
| Learning Plan | `/plan` | Personalised plan from diagnostic results |

### Admin (password-protected, local only)
| Page | URL | Description |
|------|-----|-------------|
| Manage Challenges | `/admin/challenges` | Add/edit challenges, assign topic/difficulty/type |

---

## 4. Core Learning Flows

### Challenge Page Layout
- **Top bar:** Breadcrumb (PHP › Topic › Challenge N of M) + difficulty badge + type badge
- **Left panel:** Prompt, starter code, answer input, Check / Hint / Run buttons, feedback area
- **Right panel:** Tips (topic-specific), quick reference snippet, common mistake warning, progress bar

### Answer Grading

| Challenge Type | Grading Method |
|---------------|---------------|
| Fill in blank | Normalised string match (trim whitespace, normalise quotes) |
| Write code | php-wasm executes code, compares stdout against expected output |
| Spot the bug | Normalised string match of the fixed line against solution |

### Wrong Answer Flow (teaching mode)

1. User submits wrong answer
2. System shows: what was wrong + a **mini-lesson** explaining the concept with correct vs incorrect code examples
3. A **follow-up question** is presented (1–2 per challenge) — must answer correctly before proceeding
4. On success: explanation of why the follow-up answer is correct, then continue

### Right Answer Flow

1. System shows: ✅ Correct
2. **Explanation always shown** — why the answer works, what to remember
3. "Next Challenge" button

### Section Completion Test

- Triggered automatically after all challenges in a topic are completed
- 6 questions drawn from `section_tests` for that topic (mix of all three challenge types)
- Pass threshold: **70%**
- **Pass:** Topic marked mastered, next topic unlocked, encouragement shown
- **Fail:** System identifies weak areas from wrong answers, adds targeted `remediation_challenges` to the user's plan, invites retry

### Guest → Registered Transition

- A `session_token` cookie is set on first visit
- All progress stored with `user_id = NULL` and the token
- On registration: all progress rows matching the token are updated to the new `user_id`
- No progress lost

---

## 5. PHP Topics (28 total)

### Beginner (9)
1. Variables & Data Types
2. Operators (arithmetic, comparison, logical)
3. Strings & String Functions
4. Arrays (indexed, associative)
5. Conditionals (if / else / switch)
6. Loops (for, while, foreach, do-while)
7. Functions (define, call, return)
8. Form Handling (GET & POST)
9. File Inclusion (include / require)

### Intermediate (10)
10. Array Functions (sort, map, filter, etc.)
11. Date & Time
12. Math Functions
13. Regular Expressions
14. File System (read/write files)
15. Error Handling (try / catch / finally)
16. Sessions & Cookies
17. JSON Handling
18. Working with APIs (curl / file_get_contents)
19. Input Validation & Sanitisation

### Advanced (9)
20. OOP — Classes & Objects
21. OOP — Inheritance & Interfaces
22. OOP — Traits & Abstract Classes
23. Namespaces & Autoloading
24. PDO & Databases (MySQL/SQLite)
25. Security (XSS, SQL Injection, CSRF)
26. REST API Development in PHP
27. Composer & Packages
28. PHP 8.x Modern Features (match, named args, nullsafe operator, enums)

### Diagnostic Test
- 15 challenges drawn from `is_diagnostic = true` challenges, covering the 15 most commonly misunderstood PHP topics (1 per topic, spread across beginner/intermediate/advanced)
- Topics without a diagnostic challenge are assumed neutral — included in the learning plan at default priority if the user hasn't covered them
- Result: score per topic, categorised as Strong (≥80%) / Review (40–79%) / Weak (<40%)
- Output: personalised ordered learning plan (weak/review topics first, strong topics last)

---

## 6. Visual Design

- **Theme:** Dark / dev — dark backgrounds, syntax-highlighted code, subtle borders
- **Colours:** `#0f172a` background, `#1e293b` cards, `#3b82f6` primary action, `#4ade80` success, `#ef4444` error, `#f59e0b` warning
- **Typography:** System sans-serif for UI, monospace for all code
- **No external CSS framework** — hand-crafted CSS, zero dependencies

### Mobile & Responsive Design

The site is fully accessible on mobile browsers (iOS Safari, Android Chrome).

- **Responsive layouts:** CSS Grid/Flexbox with media queries. On mobile, the challenge page stacks vertically — tips panel moves below the code editor
- **Touch-friendly:** All interactive elements minimum 44×44px tap targets (buttons, hint, run, navigation)
- **Code input on mobile:** `<textarea>` with monospace font — works with phone keyboards without requiring a heavy editor library
- **Code blocks:** Scroll horizontally on overflow rather than wrapping (preserves formatting on small screens)
- **Breakpoints:** Single breakpoint at `768px` — desktop layout above, mobile layout below
- **Note:** Write-code challenges are more comfortable on desktop; fill-in-blank and spot-the-bug work well on mobile. The site works on all devices but learners are gently nudged toward desktop for longer coding tasks.

---

## 7. Free Tooling & Deployment

### Local Development
- PHP 8.x (built-in server: `php -S localhost:8000 -t public`)
- SQLite (no separate server needed)
- No build step — plain PHP, plain CSS, HTMX from CDN

### Free Hosting (production)
- **Railway** or **Render** — both support PHP apps with SQLite
- Environment variables for config (`.env` file locally, platform dashboard in production)
- Deploy: push to GitHub → auto-deploy

### External Dependencies (all free)
| Dependency | Source | Purpose |
|-----------|--------|---------|
| HTMX | CDN (unpkg) | Dynamic page updates |
| php-wasm | CDN or bundled | In-browser PHP execution |
| Composer | composer.org | Autoloading only |

---

## 8. Out of Scope (Phase 1)

- Other languages (JS, Python, Kotlin) — schema ready, content not built
- Mobile app
- User-submitted challenges
- Leaderboards / social features
- Paid tiers
- Email verification
