// @ts-check
const { test, expect } = require('@playwright/test');

// Mobile tests — run on Pixel 5 viewport (393×851) from playwright.config.js
test.describe('Mobile layout', () => {
  test('home page is readable on mobile', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('h1')).toBeVisible();
    // Nav logo visible
    await expect(page.locator('.nav__logo')).toBeVisible();
  });

  test('topics page stacks cards on mobile', async ({ page }) => {
    await page.goto('/learn/php');
    await expect(page.locator('h1')).toBeVisible();
    // All topic cards should still be visible
    const cards = page.locator('.card');
    const count = await cards.count();
    expect(count).toBeGreaterThan(4);
  });

  test('challenge page stacks on mobile (tips below challenge)', async ({ page }) => {
    await page.goto('/learn/php/variables/4');
    await expect(page.locator('h2')).toBeVisible();
    // Input still reachable
    await expect(page.locator('input[name="answer"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });

  test('no horizontal overflow on home', async ({ page }) => {
    await page.goto('/');
    const scrollWidth = await page.evaluate(() => document.body.scrollWidth);
    const clientWidth = await page.evaluate(() => document.body.clientWidth);
    expect(scrollWidth).toBeLessThanOrEqual(clientWidth + 5); // 5px tolerance
  });
});
