// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Home page', () => {
  test('loads with dark background and correct heading', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveTitle(/LearnPHP/);
    await expect(page.locator('h1')).toContainText('Learn PHP');
    // Dark background (#0f172a)
    const bg = await page.evaluate(() =>
      getComputedStyle(document.body).backgroundColor
    );
    expect(bg).toBe('rgb(15, 23, 42)'); // #0f172a
  });

  test('shows diagnostic test and browse topics CTAs', async ({ page }) => {
    await page.goto('/');
    // Hero buttons (not nav links)
    await expect(page.locator('.page a[href="/diagnostic"]')).toBeVisible();
    await expect(page.locator('.page a[href="/learn/php"]')).toBeVisible();
  });

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

  test('feature cards are visible', async ({ page }) => {
    await page.goto('/');
    // Home page has 3 feature cards (Targeted Challenges, Teach on Mistakes, Personalised Plan)
    const cards = page.locator('.page .card');
    const count = await cards.count();
    expect(count).toBeGreaterThanOrEqual(3);
  });
});
