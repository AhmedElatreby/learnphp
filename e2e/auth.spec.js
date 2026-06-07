// @ts-check
const { test, expect } = require('@playwright/test');

// Unique credentials per run — avoids conflicts on the live server
const run = Date.now();
const testUser = {
  username: `testuser${run}`,
  email:    `test${run}@example.com`,
  password: 'password123',
};

// ── Login page ──────────────────────────────────────────────────────────────

test.describe('Login page', () => {
  test('renders with email and password fields', async ({ page }) => {
    await page.goto('/login');
    await expect(page.locator('h1')).toContainText('Welcome back');
    await expect(page.locator('input[name="email"]')).toBeVisible();
    await expect(page.locator('input[name="password"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toContainText('Log In');
  });

  test('has a link to the register page', async ({ page }) => {
    await page.goto('/login');
    await expect(page.locator('.page-sm a[href="/register"]')).toBeVisible();
  });

  test('invalid credentials show an error and stay on login page', async ({ page }) => {
    await page.goto('/login');
    await page.fill('input[name="email"]', 'nobody@example.com');
    await page.fill('input[name="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/login/);
    await expect(page.locator('.alert-error')).toContainText('Invalid email or password');
  });
});

// ── Register page ───────────────────────────────────────────────────────────

test.describe('Register page', () => {
  test('renders with username, email and password fields', async ({ page }) => {
    await page.goto('/register');
    await expect(page.locator('h1')).toContainText('Create your account');
    await expect(page.locator('input[name="username"]')).toBeVisible();
    await expect(page.locator('input[name="email"]')).toBeVisible();
    await expect(page.locator('input[name="password"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toContainText('Create Account');
  });

  test('has a link to the login page', async ({ page }) => {
    await page.goto('/register');
    await expect(page.locator('.page-sm a[href="/login"]')).toBeVisible();
  });

  test('username too short shows validation error', async ({ page }) => {
    await page.goto('/register');
    await page.fill('input[name="username"]', 'a'); // 1 char — fails 2+ requirement
    await page.fill('input[name="email"]', `short${run}@example.com`);
    await page.fill('input[name="password"]', 'password123');
    // Strip HTML5 minlength so the server-side check is what we're testing
    await page.evaluate(() => {
      document.querySelector('input[name="username"]').removeAttribute('minlength');
    });
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/register/);
    await expect(page.locator('.alert-error')).toBeVisible();
  });

  test('password too short shows validation error', async ({ page }) => {
    await page.goto('/register');
    await page.fill('input[name="username"]', `validuser${run}b`);
    await page.fill('input[name="email"]', `shortpw${run}@example.com`);
    await page.fill('input[name="password"]', '123'); // 3 chars — fails 6+ requirement
    // Strip HTML5 minlength so the server-side check is what we're testing
    await page.evaluate(() => {
      document.querySelector('input[name="password"]').removeAttribute('minlength');
    });
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/register/);
    await expect(page.locator('.alert-error')).toBeVisible();
  });

  test('duplicate email shows error', async ({ page }) => {
    // Use per-invocation unique values so concurrent desktop+mobile workers don't clash
    const id = `${Date.now()}${Math.random().toString(36).slice(2, 6)}`;
    const dupEmail = `dup${id}@example.com`;
    // Register once
    await page.goto('/register');
    await page.fill('input[name="username"]', `dupuser${id}`);
    await page.fill('input[name="email"]', dupEmail);
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/dashboard/);

    // Logout and try same email again
    await page.goto('/logout');
    await page.goto('/register');
    await page.fill('input[name="username"]', `dupuser2${id}`);
    await page.fill('input[name="email"]', dupEmail);
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/register/);
    await expect(page.locator('.alert-error')).toContainText('already taken');
  });
});

// ── Registration → Dashboard ────────────────────────────────────────────────

test.describe('Registration flow', () => {
  test('successful registration redirects to dashboard', async ({ page }) => {
    await page.goto('/register');
    await page.fill('input[name="username"]', testUser.username);
    await page.fill('input[name="email"]', testUser.email);
    await page.fill('input[name="password"]', testUser.password);
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/dashboard/);
  });

  test('dashboard shows username after registration', async ({ page }) => {
    await page.goto('/register');
    const u = `dashuser${run}`;
    await page.fill('input[name="username"]', u);
    await page.fill('input[name="email"]', `dash${run}@example.com`);
    await page.fill('input[name="password"]', testUser.password);
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/dashboard/);
    await expect(page.locator('h1')).toContainText(u);
  });

  test('dashboard shows stats cards (Mastered / In Progress / Topics Left)', async ({ page }) => {
    await page.goto('/register');
    await page.fill('input[name="username"]', `statsuser${run}`);
    await page.fill('input[name="email"]', `stats${run}@example.com`);
    await page.fill('input[name="password"]', testUser.password);
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/dashboard/);
    const cards = page.locator('.grid-3 .card');
    await expect(cards).toHaveCount(3);
    await expect(cards.nth(0)).toContainText('Topics Mastered');
    await expect(cards.nth(1)).toContainText('In Progress');
    await expect(cards.nth(2)).toContainText('Topics Left');
  });

  test('dashboard shows all topics list', async ({ page }) => {
    await page.goto('/register');
    await page.fill('input[name="username"]', `topicuser${run}`);
    await page.fill('input[name="email"]', `topics${run}@example.com`);
    await page.fill('input[name="password"]', testUser.password);
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/dashboard/);
    // topic-grid shows all 28 topics as links
    const topicLinks = page.locator('.topic-grid a');
    await expect(topicLinks).toHaveCount(28);
  });
});

// ── Login flow ──────────────────────────────────────────────────────────────

test.describe('Login flow', () => {
  test('successful login redirects to dashboard', async ({ page }) => {
    // Register fresh user, then log out and log back in
    const u = `loginuser${run}`;
    const e = `login${run}@example.com`;

    await page.goto('/register');
    await page.fill('input[name="username"]', u);
    await page.fill('input[name="email"]', e);
    await page.fill('input[name="password"]', testUser.password);
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/dashboard/);

    await page.goto('/logout');

    await page.goto('/login');
    await page.fill('input[name="email"]', e);
    await page.fill('input[name="password"]', testUser.password);
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/dashboard/);
    await expect(page.locator('h1')).toContainText(u);
  });

  test('nav shows username and logout link when logged in', async ({ page }) => {
    await page.goto('/register');
    const u = `navuser${run}`;
    await page.fill('input[name="username"]', u);
    await page.fill('input[name="email"]', `nav${run}@example.com`);
    await page.fill('input[name="password"]', testUser.password);
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/dashboard/);
    await expect(page.locator('.nav a[href="/logout"]')).toBeVisible();
    // Login/Sign Up links should be gone
    await expect(page.locator('.nav a[href="/login"]')).toHaveCount(0);
  });
});

// ── Logout flow ─────────────────────────────────────────────────────────────

test.describe('Logout flow', () => {
  test('logout redirects to home page', async ({ page }) => {
    await page.goto('/register');
    await page.fill('input[name="username"]', `logoutuser${run}`);
    await page.fill('input[name="email"]', `logout${run}@example.com`);
    await page.fill('input[name="password"]', testUser.password);
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/dashboard/);

    await page.goto('/logout');
    await expect(page).toHaveURL(/\/$/);
    await expect(page.locator('h1')).toContainText('Learn PHP');
  });

  test('after logout, dashboard redirects to login', async ({ page }) => {
    await page.goto('/register');
    await page.fill('input[name="username"]', `redir${run}`);
    await page.fill('input[name="email"]', `redir${run}@example.com`);
    await page.fill('input[name="password"]', testUser.password);
    await page.click('button[type="submit"]');
    await page.goto('/logout');

    await page.goto('/dashboard');
    await expect(page).toHaveURL(/\/login/);
  });

  test('after logout, nav shows Login and Sign Up', async ({ page, isMobile }) => {
    await page.goto('/register');
    await page.fill('input[name="username"]', `navout${run}`);
    await page.fill('input[name="email"]', `navout${run}@example.com`);
    await page.fill('input[name="password"]', testUser.password);
    await page.click('button[type="submit"]');
    await page.goto('/logout');

    if (isMobile) {
      await page.locator('.nav__hamburger').click();
      await expect(page.locator('#nav-overlay a[href="/login"]')).toBeVisible();
      await expect(page.locator('#nav-overlay a[href="/register"]')).toBeVisible();
    } else {
      await expect(page.locator('.nav a[href="/login"]')).toBeVisible();
      await expect(page.locator('.nav a[href="/register"]')).toBeVisible();
    }
  });
});
