// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Remediation flow', () => {
  test('remediation page loads for a valid topic', async ({ page }) => {
    await page.goto('/remediation/variables');
    await expect(page).toHaveURL(/\/remediation\/variables/);
    await expect(page.locator('h1')).toContainText('Variables');
    // Should have 4 challenge cards
    const cards = page.locator('.card');
    const count = await cards.count();
    expect(count).toBeGreaterThanOrEqual(4);
    // Should have answer inputs
    await expect(page.locator('input[name^="answer_"]').first()).toBeVisible();
  });

  test('remediation 404 for unknown topic', async ({ page }) => {
    const response = await page.goto('/remediation/nonexistent');
    expect(response?.status()).toBe(404);
  });

  test('submitting blank answers shows results page with 0%', async ({ page }) => {
    await page.goto('/remediation/variables');
    await page.locator('button[type="submit"]').click();
    await expect(page).toHaveURL(/\/remediation\/variables/);
    await expect(page.locator('.page')).toContainText('0 / 4');
    await expect(page.locator('a[href="/learn/php/variables"]')).toBeVisible();
    await expect(page.locator('.page a[href="/diagnostic/results"]').first()).toBeVisible();
  });

  test('submitting correct answers shows score', async ({ page }) => {
    await page.goto('/remediation/variables');
    // Fill first two inputs with correct answers (gettype, (int)$s)
    await page.locator('input[name^="answer_"]').nth(0).fill('gettype');
    await page.locator('input[name^="answer_"]').nth(1).fill('(int)$s');
    await page.locator('button[type="submit"]').click();
    // At least 1 answer was correct — score must be ≥ 1/4, not 0/4
    const text = await page.locator('.page').innerText();
    expect(text).toMatch(/[1-4] \/ 4/);
  });

  test('results page links to practice topic and diagnostic', async ({ page }) => {
    await page.goto('/remediation/operators');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('a[href="/learn/php/operators"]')).toBeVisible();
    await expect(page.locator('.page a[href="/diagnostic/results"]').first()).toBeVisible();
  });

  test('retry link returns to the remediation form', async ({ page }) => {
    await page.goto('/remediation/strings');
    await page.locator('button[type="submit"]').click();
    await page.locator('a[href="/remediation/strings"]').click();
    await expect(page).toHaveURL(/\/remediation\/strings/);
    await expect(page.locator('button[type="submit"]')).toBeVisible();
  });

  test('back link on form goes to diagnostic results page', async ({ page }) => {
    await page.goto('/remediation/conditionals');
    await page.locator('a[href="/diagnostic/results"]').click();
    await expect(page).toHaveURL(/\/diagnostic\/results/);
  });
});
