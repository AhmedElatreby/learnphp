// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Admin access control', () => {
  test('guest gets 403 on /admin/challenges', async ({ page }) => {
    const response = await page.goto('/admin/challenges');
    expect(response?.status()).toBe(403);
    await expect(page.locator('h1')).toContainText('403');
  });

  test('guest gets 403 on admin new form', async ({ page }) => {
    const response = await page.goto('/admin/challenges/new');
    expect(response?.status()).toBe(403);
  });
});

test.describe('Auth pages', () => {
  test('login page renders correctly', async ({ page }) => {
    await page.goto('/login');
    await expect(page.locator('h1, h2')).toBeVisible();
    await expect(page.locator('input[name="email"]')).toBeVisible();
    await expect(page.locator('input[name="password"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });

  test('register page renders correctly', async ({ page }) => {
    await page.goto('/register');
    await expect(page.locator('input[name="username"]')).toBeVisible();
    await expect(page.locator('input[name="email"]')).toBeVisible();
    await expect(page.locator('input[name="password"]')).toBeVisible();
  });

  test('invalid login shows error', async ({ page }) => {
    await page.goto('/login');
    await page.locator('input[name="email"]').fill('nobody@test.com');
    await page.locator('input[name="password"]').fill('wrongpass');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('.alert-error')).toBeVisible({ timeout: 3000 });
  });

  test('dashboard redirects guests to login', async ({ page }) => {
    await page.goto('/dashboard');
    await expect(page).toHaveURL(/\/login/);
  });
});
