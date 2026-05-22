# Mobile Nav Fullscreen Overlay — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a hamburger button that opens a fullscreen dark overlay with all nav links on viewports ≤ 768px.

**Architecture:** Pure CSS (opacity transition) + 20-line vanilla JS IIFE in `layout.php`. No new files, no new dependencies. The overlay duplicates the nav links so desktop and mobile nav are independent DOM elements.

**Tech Stack:** PHP template (`layout.php`), vanilla CSS (`main.css`), vanilla JS inline, Playwright for e2e tests.

---

## File Map

| File | Change |
|---|---|
| `public/assets/css/main.css` | Add hamburger button, overlay, overlay-links, and `@media (max-width:768px)` block |
| `src/Views/layout.php` | Add `.nav__hamburger` button inside nav, add `.nav__overlay` div before `<main>`, add inline `<script>` before `</body>` |
| `e2e/home.spec.js` | Replace `isMobile` TODO branch with overlay interaction assertion |
| `e2e/mobile.spec.js` | Add 4 overlay behaviour tests |

---

## Task 1: CSS — Hamburger button + fullscreen overlay

**Files:**
- Modify: `public/assets/css/main.css` (after the `.nav__links` rule, line 85)

- [ ] **Add the following CSS block** to `public/assets/css/main.css`, immediately after the `.nav__links` rule:

```css
/* ── Mobile nav ─────────────────────────────────────────── */
.nav__hamburger {
  display: none;
  background: transparent;
  border: none;
  color: var(--text);
  font-size: 1.5rem;
  cursor: pointer;
  padding: 4px 8px;
  line-height: 1;
}

.nav__overlay {
  position: fixed;
  inset: 0;
  background: var(--bg);
  z-index: 999;
  display: flex;
  flex-direction: column;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.2s ease;
}
.nav__overlay.open {
  opacity: 1;
  pointer-events: all;
}
.nav__overlay-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 24px;
  height: 56px;
  border-bottom: 1px solid var(--border);
  flex-shrink: 0;
}
.nav__close {
  background: transparent;
  border: none;
  color: var(--muted);
  font-size: 1.5rem;
  cursor: pointer;
  padding: 4px 8px;
  line-height: 1;
}
.nav__close:hover { color: var(--text); }

.nav__overlay-links {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 32px;
  flex: 1;
}
.nav__overlay-links a {
  color: var(--text);
  text-decoration: none;
  font-size: 1.2rem;
  font-weight: 500;
}
.nav__overlay-links a:hover { color: var(--primary); }
.nav__overlay-signup { font-size: 1rem !important; padding: 12px 32px; }

@media (max-width: 768px) {
  .nav__links     { display: none; }
  .nav__hamburger { display: block; }
}
```

- [ ] **Verify no syntax errors** by opening `http://localhost:8000/` — the page should still render identically on desktop. No visual change yet (hamburger is `display:none` on desktop).

---

## Task 2: HTML + JS — layout.php

**Files:**
- Modify: `src/Views/layout.php`

- [ ] **Add the hamburger button** inside `<nav class="nav">`, after the `.nav__links` div:

Replace:
```php
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
```

With:
```php
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
    <button class="nav__hamburger" aria-label="Open menu" aria-expanded="false">☰</button>
  </nav>
```

- [ ] **Add the overlay div** between `</nav>` and `<main>`:

```php
  <div class="nav__overlay" id="nav-overlay" role="dialog" aria-modal="true" aria-label="Navigation">
    <div class="nav__overlay-header">
      <span class="nav__logo">🐘 LearnPHP</span>
      <button class="nav__close" aria-label="Close menu">✕</button>
    </div>
    <nav class="nav__overlay-links">
      <a href="/learn/php">Topics</a>
      <a href="/diagnostic">Diagnostic Test</a>
      <?php if ($user): ?>
        <a href="/dashboard">Dashboard</a>
        <a href="/logout">Logout</a>
      <?php else: ?>
        <a href="/login">Login</a>
        <a href="/register" class="btn btn-primary nav__overlay-signup">Sign Up</a>
      <?php endif; ?>
    </nav>
  </div>
```

- [ ] **Add the JS** just before `</body>`:

```php
<script>
(function () {
  var overlay   = document.getElementById('nav-overlay');
  var hamburger = document.querySelector('.nav__hamburger');
  var closeBtn  = document.querySelector('.nav__close');
  if (!overlay || !hamburger) return;

  function openMenu()  { overlay.classList.add('open');    hamburger.setAttribute('aria-expanded', 'true');  }
  function closeMenu() { overlay.classList.remove('open'); hamburger.setAttribute('aria-expanded', 'false'); }

  hamburger.addEventListener('click', openMenu);
  closeBtn.addEventListener('click', closeMenu);

  overlay.querySelectorAll('a').forEach(function(a) {
    a.addEventListener('click', closeMenu);
  });

  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeMenu();
  });
})();
</script>
```

- [ ] **Manual smoke test** — resize browser to < 768px wide. Confirm:
  - Desktop (> 768px): nav links visible, hamburger hidden, no overlay
  - Mobile (≤ 768px): hamburger visible (☰), nav links hidden
  - Tap ☰ → fullscreen dark overlay appears with all links centred
  - Tap ✕ → overlay closes
  - Tap a link → overlay closes and navigates

- [ ] **Run PHPUnit** — all 36 tests must still pass (no PHP logic changed):
```bash
php vendor/bin/phpunit
```
Expected: `OK (36 tests, 53 assertions)`

- [ ] **Commit:**
```bash
git add public/assets/css/main.css src/Views/layout.php
git commit -m "feat: mobile nav fullscreen overlay with hamburger toggle"
```

---

## Task 3: Update Playwright tests

**Files:**
- Modify: `e2e/home.spec.js`
- Modify: `e2e/mobile.spec.js`

- [ ] **Update `e2e/home.spec.js`** — replace the `isMobile` TODO branch with a proper overlay test.

Replace the entire `nav shows Login and Sign Up for guests` test:
```js
  test('nav shows Login and Sign Up for guests', async ({ page, isMobile }) => {
    await page.goto('/');
    if (isMobile) {
      // Nav links collapse on mobile — element exists in DOM even if not visible
      // TODO: add hamburger menu for mobile nav
      await expect(page.locator('.nav a[href="/login"]')).toBeAttached();
    } else {
      await expect(page.locator('.nav a[href="/login"]')).toBeVisible();
      await expect(page.locator('.nav a[href="/register"]')).toBeVisible();
    }
  });
```

With:
```js
  test('nav shows Login and Sign Up for guests', async ({ page, isMobile }) => {
    await page.goto('/');
    if (isMobile) {
      // Hamburger visible; tap it; links appear in overlay
      await expect(page.locator('.nav__hamburger')).toBeVisible();
      await page.locator('.nav__hamburger').click();
      await expect(page.locator('#nav-overlay')).toHaveClass(/open/);
      await expect(page.locator('#nav-overlay a[href="/login"]')).toBeVisible();
      await expect(page.locator('#nav-overlay a[href="/register"]')).toBeVisible();
    } else {
      await expect(page.locator('.nav a[href="/login"]')).toBeVisible();
      await expect(page.locator('.nav a[href="/register"]')).toBeVisible();
    }
  });
```

- [ ] **Add 4 new tests** to `e2e/mobile.spec.js` — append inside `test.describe('Mobile layout', ...)`:

```js
  test('hamburger button is visible on mobile', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('.nav__hamburger')).toBeVisible();
    // Desktop nav links are hidden on mobile
    await expect(page.locator('.nav__links')).toBeHidden();
  });

  test('hamburger opens fullscreen overlay', async ({ page }) => {
    await page.goto('/');
    const overlay = page.locator('#nav-overlay');
    await expect(overlay).not.toHaveClass(/open/);
    await page.locator('.nav__hamburger').click();
    await expect(overlay).toHaveClass(/open/);
    await expect(page.locator('#nav-overlay a[href="/learn/php"]')).toBeVisible();
  });

  test('close button dismisses overlay', async ({ page }) => {
    await page.goto('/');
    await page.locator('.nav__hamburger').click();
    await expect(page.locator('#nav-overlay')).toHaveClass(/open/);
    await page.locator('.nav__close').click();
    await expect(page.locator('#nav-overlay')).not.toHaveClass(/open/);
  });

  test('Escape key closes overlay', async ({ page }) => {
    await page.goto('/');
    await page.locator('.nav__hamburger').click();
    await expect(page.locator('#nav-overlay')).toHaveClass(/open/);
    await page.keyboard.press('Escape');
    await expect(page.locator('#nav-overlay')).not.toHaveClass(/open/);
  });
```

- [ ] **Run only the mobile project** to verify all tests pass:
```bash
npx playwright test --project=mobile
```
Expected: all mobile tests pass (previously 29/30, now should be 34/34 with 4 new + 1 updated)

- [ ] **Run full suite** across both projects:
```bash
npx playwright test
```
Expected: 64 passed (60 previous + 4 new)

- [ ] **Commit:**
```bash
git add e2e/home.spec.js e2e/mobile.spec.js
git commit -m "test: update mobile nav tests for hamburger overlay"
```

---

## Self-Review

**Spec coverage:**
- ✅ §3.1 Hamburger button inside `.nav` — Task 2
- ✅ §3.2 Fullscreen overlay with header + links — Task 2
- ✅ §4 All CSS rules including `@media (max-width:768px)` — Task 1
- ✅ §5 JS: open/close/link-click/Escape — Task 2
- ✅ §6.1 PHPUnit stays green — Task 2
- ✅ §6.2 Playwright home.spec updated — Task 3
- ✅ §6.2 Playwright mobile.spec 4 new tests — Task 3

**Placeholder scan:** None.

**Type consistency:** Class names `.nav__hamburger`, `.nav__overlay`, `.nav__close`, `.nav__overlay-links`, `.nav__overlay-signup`, `#nav-overlay` used consistently across CSS, HTML, JS, and tests.
