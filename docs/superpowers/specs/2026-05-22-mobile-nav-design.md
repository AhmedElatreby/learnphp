# Design: Mobile Navigation Overlay

**Date:** 2026-05-22  
**Status:** Approved

---

## 1. Problem

The nav bar has no mobile treatment. Below 768px the `.nav__links` overflow and are clipped — Login, Sign Up, and all nav links are unreachable on phones.

## 2. Solution: Fullscreen Overlay

A hamburger button (☰) appears in the nav on mobile. Tapping it opens a dark fullscreen overlay that centres all nav links vertically. Tapping ✕, pressing Escape, or clicking any link closes it.

---

## 3. HTML Changes — `src/Views/layout.php`

### 3.1 Hamburger button (inside `.nav`)

```html
<button class="nav__hamburger" aria-label="Open menu" aria-expanded="false">☰</button>
```

Sits inside `.nav`, after `.nav__links`. Hidden on desktop via CSS.

### 3.2 Fullscreen overlay (sibling of `<nav>`, before `<main>`)

```html
<div class="nav__overlay" id="nav-overlay" role="dialog" aria-modal="true" aria-label="Navigation">
  <div class="nav__overlay-header">
    <span class="nav__logo">🐘 LearnPHP</span>
    <button class="nav__close" aria-label="Close menu">✕</button>
  </div>
  <nav class="nav__overlay-links">
    <!-- same links as desktop nav, PHP-conditional on $user -->
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

---

## 4. CSS Changes — `public/assets/css/main.css`

```css
/* Hamburger — hidden on desktop */
.nav__hamburger {
  display: none;
  background: transparent;
  border: none;
  color: var(--text);
  font-size: 1.4rem;
  cursor: pointer;
  padding: 4px 8px;
  line-height: 1;
}

/* Fullscreen overlay */
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
  font-size: 1.4rem;
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
  gap: 28px;
  flex: 1;
  font-size: 1.2rem;
}
.nav__overlay-links a { color: var(--text); text-decoration: none; font-weight: 500; }
.nav__overlay-links a:hover { color: var(--primary); }
.nav__overlay-signup { font-size: 1rem; padding: 12px 28px; }

/* Mobile breakpoint */
@media (max-width: 768px) {
  .nav__links    { display: none; }
  .nav__hamburger { display: block; }
}
```

---

## 5. JS — inline `<script>` at bottom of `layout.php`

20 lines, no dependencies:

```js
(function () {
  const overlay   = document.getElementById('nav-overlay');
  const hamburger = document.querySelector('.nav__hamburger');
  const closeBtn  = document.querySelector('.nav__close');
  if (!overlay || !hamburger) return;

  function open()  { overlay.classList.add('open');    hamburger.setAttribute('aria-expanded', 'true');  }
  function close() { overlay.classList.remove('open'); hamburger.setAttribute('aria-expanded', 'false'); }

  hamburger.addEventListener('click', open);
  closeBtn.addEventListener('click', close);

  // Close on any link click (navigation)
  overlay.querySelectorAll('a').forEach(a => a.addEventListener('click', close));

  // Close on Escape
  document.addEventListener('keydown', e => { if (e.key === 'Escape') close(); });
})();
```

---

## 6. Testing

### 6.1 PHPUnit (existing — must stay green)
All 36 tests must pass — no PHP changes.

### 6.2 Playwright updates

**`e2e/home.spec.js`** — remove the `isMobile` branch, test overlay instead:
```js
test('nav shows Login and Sign Up for guests', async ({ page, isMobile }) => {
  await page.goto('/');
  if (isMobile) {
    // Hamburger visible; open overlay; links visible
    await expect(page.locator('.nav__hamburger')).toBeVisible();
    await page.locator('.nav__hamburger').click();
    await expect(page.locator('.nav__overlay.open a[href="/login"]')).toBeVisible();
  } else {
    await expect(page.locator('.nav a[href="/login"]')).toBeVisible();
    await expect(page.locator('.nav a[href="/register"]')).toBeVisible();
  }
});
```

**`e2e/mobile.spec.js`** — add overlay interaction tests:
```js
test('hamburger opens fullscreen overlay', async ({ page }) => { ... });
test('close button dismisses overlay', async ({ page }) => { ... });
test('Escape key closes overlay', async ({ page }) => { ... });
test('clicking a nav link closes overlay', async ({ page }) => { ... });
```

---

## 7. File Change Summary

| File | Change |
|---|---|
| `src/Views/layout.php` | Add `.nav__hamburger` button, add `.nav__overlay` div, add inline JS |
| `public/assets/css/main.css` | Add hamburger, overlay, and mobile breakpoint CSS |
| `e2e/home.spec.js` | Replace `isMobile` branch with overlay interaction |
| `e2e/mobile.spec.js` | Add 4 overlay behaviour tests |
