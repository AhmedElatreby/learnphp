// @ts-check
const { test, expect } = require('@playwright/test');

// Admin CRUD tests require a real admin account on the target server.
// Set these env vars to enable them:
//   ADMIN_EMAIL=...  ADMIN_PASSWORD=...
const ADMIN_EMAIL    = process.env.ADMIN_EMAIL    || '';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || '';
const hasAdminCreds  = !!(ADMIN_EMAIL && ADMIN_PASSWORD);

// Helper: log in as admin and land on the challenges list
async function loginAsAdmin(page) {
  await page.goto('/login');
  await page.fill('input[name="email"]', ADMIN_EMAIL);
  await page.fill('input[name="password"]', ADMIN_PASSWORD);
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL(/\/dashboard/);
  await page.goto('/admin/challenges');
  await expect(page).toHaveURL(/\/admin\/challenges/);
}

// ── Access control ──────────────────────────────────────────────────────────

test.describe('Admin access control', () => {
  test('guest gets 403 on /admin/challenges', async ({ page }) => {
    const res = await page.goto('/admin/challenges');
    expect(res?.status()).toBe(403);
  });

  test('guest gets 403 on admin new form', async ({ page }) => {
    const res = await page.goto('/admin/challenges/new');
    expect(res?.status()).toBe(403);
  });

  test('guest gets 403 on admin edit form', async ({ page }) => {
    const res = await page.goto('/admin/challenges/1/edit');
    expect(res?.status()).toBe(403);
  });

  test('logged-in non-admin gets 403 on /admin/challenges', async ({ page }) => {
    const id = `${Date.now()}${Math.random().toString(36).slice(2, 6)}`;
    await page.goto('/register');
    await page.fill('input[name="username"]', `nonadmin${id}`);
    await page.fill('input[name="email"]', `nonadmin${id}@example.com`);
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/dashboard/);

    const res = await page.goto('/admin/challenges');
    expect(res?.status()).toBe(403);
  });

  test('logged-in non-admin gets 403 on admin new form', async ({ page }) => {
    const id = `${Date.now()}${Math.random().toString(36).slice(2, 6)}`;
    await page.goto('/register');
    await page.fill('input[name="username"]', `nonadmin2${id}`);
    await page.fill('input[name="email"]', `nonadmin2${id}@example.com`);
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/dashboard/);

    const res = await page.goto('/admin/challenges/new');
    expect(res?.status()).toBe(403);
  });
});

// ── Auth pages (guest-visible) ──────────────────────────────────────────────

test.describe('Auth pages', () => {
  test('login page renders correctly', async ({ page }) => {
    await page.goto('/login');
    await expect(page.locator('h1')).toContainText('Welcome back');
    await expect(page.locator('input[name="email"]')).toBeVisible();
    await expect(page.locator('input[name="password"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });

  test('register page renders correctly', async ({ page }) => {
    await page.goto('/register');
    await expect(page.locator('h1')).toContainText('Create your account');
    await expect(page.locator('input[name="username"]')).toBeVisible();
    await expect(page.locator('input[name="email"]')).toBeVisible();
    await expect(page.locator('input[name="password"]')).toBeVisible();
  });

  test('invalid login shows error', async ({ page }) => {
    await page.goto('/login');
    await page.fill('input[name="email"]', 'nobody@example.com');
    await page.fill('input[name="password"]', 'wrong');
    await page.click('button[type="submit"]');
    await expect(page.locator('.alert-error')).toBeVisible();
  });

  test('dashboard redirects guests to login', async ({ page }) => {
    await page.goto('/dashboard');
    await expect(page).toHaveURL(/\/login/);
  });
});

// ── Admin challenge list (requires admin creds) ─────────────────────────────

test.describe('Admin challenge list', () => {
  test.skip(!hasAdminCreds, 'Set ADMIN_EMAIL and ADMIN_PASSWORD to run');

  test('shows challenges list with Add Challenge button', async ({ page }) => {
    await loginAsAdmin(page);
    await expect(page.locator('h1')).toContainText('Challenges');
    await expect(page.locator('a[href="/admin/challenges/new"]')).toBeVisible();
  });

  test('challenges are grouped by topic with Edit and Delete buttons', async ({ page }) => {
    await loginAsAdmin(page);
    await expect(page.locator('table').first()).toBeVisible();
    await expect(page.locator('a.btn[href*="/edit"]').first()).toBeVisible();
    await expect(page.locator('button.btn-danger').first()).toBeVisible();
  });

  test('each row shows title, type badge and difficulty badge', async ({ page }) => {
    await loginAsAdmin(page);
    const firstRow = page.locator('tbody tr').first();
    await expect(firstRow.locator('.badge').first()).toBeVisible();
    const titleCell = firstRow.locator('td').nth(1);
    const title = await titleCell.innerText();
    expect(title.length).toBeGreaterThan(0);
  });
});

// ── Admin new challenge form (requires admin creds) ─────────────────────────

test.describe('Admin new challenge form', () => {
  test.skip(!hasAdminCreds, 'Set ADMIN_EMAIL and ADMIN_PASSWORD to run');

  test('form renders with all required fields', async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto('/admin/challenges/new');
    await expect(page.locator('h1')).toContainText('Add Challenge');
    await expect(page.locator('select[name="topic_id"]')).toBeVisible();
    await expect(page.locator('input[name="title"]')).toBeVisible();
    await expect(page.locator('textarea[name="prompt"]')).toBeVisible();
    await expect(page.locator('select[name="type"]')).toBeVisible();
    await expect(page.locator('select[name="difficulty"]')).toBeVisible();
    await expect(page.locator('input[name="solution"]')).toBeVisible();
    await expect(page.locator('textarea[name="explanation"]')).toBeVisible();
  });

  test('back link returns to challenges list', async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto('/admin/challenges/new');
    await page.locator('a[href="/admin/challenges"]').first().click();
    await expect(page).toHaveURL(/\/admin\/challenges$/);
  });

  test('submitting empty form shows validation errors', async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto('/admin/challenges/new');
    await page.fill('input[name="title"]', '');
    await page.fill('textarea[name="prompt"]', '');
    await page.fill('input[name="solution"]', '');
    await page.fill('textarea[name="explanation"]', '');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/admin\/challenges\/new/);
    await expect(page.locator('.alert-error')).toBeVisible();
  });

  test('full create → verify in list → delete cycle', async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto('/admin/challenges/new');

    const title = `E2E Test Challenge ${Date.now()}`;
    await page.selectOption('select[name="topic_id"]', { index: 0 });
    await page.fill('input[name="title"]', title);
    await page.fill('textarea[name="prompt"]', 'What does <?= 1 + 1 ?> output?');
    await page.selectOption('select[name="type"]', 'fill_blank');
    await page.selectOption('select[name="difficulty"]', 'beginner');
    await page.fill('input[name="solution"]', '2');
    await page.fill('textarea[name="explanation"]', 'Addition of two integers.');
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL(/\/admin\/challenges$/);
    await expect(page.locator('.alert-success')).toContainText('Challenge created');
    await expect(page.locator(`td:has-text("${title}")`)).toBeVisible();

    // Delete it
    const row = page.locator('tr', { has: page.locator(`td:has-text("${title}")`) });
    page.once('dialog', d => d.accept());
    await row.locator('button.btn-danger').click();

    await expect(page).toHaveURL(/\/admin\/challenges$/);
    await expect(page.locator('.alert-success')).toContainText('Challenge deleted');
    await expect(page.locator(`td:has-text("${title}")`)).toHaveCount(0);
  });
});

// ── Admin edit challenge form (requires admin creds) ────────────────────────

test.describe('Admin edit challenge form', () => {
  test.skip(!hasAdminCreds, 'Set ADMIN_EMAIL and ADMIN_PASSWORD to run');

  test('edit form pre-populates fields from existing challenge', async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto('/admin/challenges/1/edit');
    await expect(page.locator('h1')).toContainText('Edit Challenge');
    const title = await page.locator('input[name="title"]').inputValue();
    expect(title.length).toBeGreaterThan(0);
    const solution = await page.locator('input[name="solution"]').inputValue();
    expect(solution.length).toBeGreaterThan(0);
  });

  test('edit title, save, verify success flash, then restore', async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto('/admin/challenges/1/edit');

    const originalTitle = await page.locator('input[name="title"]').inputValue();
    await page.fill('input[name="title"]', originalTitle + ' (edited)');
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL(/\/admin\/challenges$/);
    await expect(page.locator('.alert-success')).toContainText('Challenge updated');

    // Restore
    await page.goto('/admin/challenges/1/edit');
    await page.fill('input[name="title"]', originalTitle);
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/admin\/challenges$/);
  });

  test('clearing required field shows validation error', async ({ page }) => {
    await loginAsAdmin(page);
    await page.goto('/admin/challenges/1/edit');
    await page.fill('input[name="title"]', '');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL(/\/admin\/challenges\/1\/edit/);
    await expect(page.locator('.alert-error')).toBeVisible();
  });
});
