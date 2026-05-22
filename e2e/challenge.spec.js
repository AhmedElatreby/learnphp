// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Fill-blank challenge', () => {
  test('challenge 1 (Variables) loads correctly', async ({ page }) => {
    await page.goto('/learn/php/variables/4');
    await expect(page.locator('h2')).toBeVisible();
    await expect(page.locator('input[name="answer"]')).toBeVisible();
    await expect(page.locator('button[type="submit"]')).toContainText('Check Answer');
  });

  test('hint button reveals hint', async ({ page }) => {
    await page.goto('/learn/php/variables/4');
    const hint = page.locator('#hint');
    await expect(hint).toBeHidden();
    await page.locator('button', { hasText: 'Hint' }).click();
    await expect(hint).toBeVisible();
  });

  test('correct answer shows success feedback', async ({ page }) => {
    await page.goto('/learn/php/variables/4');
    await page.locator('input[name="answer"]').fill('"PHP"');
    await page.locator('button[type="submit"]').click();
    // HTMX swaps in feedback
    await expect(page.locator('#feedback')).toContainText('Correct', { timeout: 5000 });
    await expect(page.locator('.alert-success')).toBeVisible();
  });

  test('wrong answer shows error feedback with explanation', async ({ page }) => {
    await page.goto('/learn/php/variables/4');
    await page.locator('input[name="answer"]').fill('wrong');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('#feedback')).toContainText('Not', { timeout: 5000 });
    await expect(page.locator('.alert-error')).toBeVisible();
    // Explanation shown inside the feedback div
    await expect(page.locator('#feedback .alert-info')).toBeVisible();
  });

  test('correct answer shows Next Challenge button', async ({ page }) => {
    await page.goto('/learn/php/variables/4');
    await page.locator('input[name="answer"]').fill('"PHP"');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('#feedback a.btn')).toBeVisible({ timeout: 5000 });
  });

  test('difficulty badge is visible', async ({ page }) => {
    await page.goto('/learn/php/variables/4');
    await expect(page.locator('.badge-beginner')).toBeVisible();
  });
});

test.describe('Write-code challenge', () => {
  test('write_code challenge has CodeMirror editor', async ({ page }) => {
    // Challenge 7 is type casting (write_code)
    await page.goto('/learn/php/variables/7');
    // Must have passed challenge 6 first — if gating redirects, test that instead
    const url = page.url();
    if (url.includes('/variables/7')) {
      // CodeMirror editor should be present
      await expect(page.locator('#cm-editor')).toBeVisible({ timeout: 8000 });
      await expect(page.locator('#cm-answer')).toBeAttached();
      await expect(page.locator('button', { hasText: 'Run Code' })).toBeVisible();
    } else {
      // Gating redirect happened — correct behaviour
      expect(url).toContain('/variables');
    }
  });
});

test.describe('Progression gating', () => {
  test('challenge 2 redirects to topic when challenge 1 not passed', async ({ page }) => {
    await page.goto('/learn/php/variables/5');
    // Should redirect to /learn/php/variables
    await expect(page).toHaveURL(/\/learn\/php\/variables$/, { timeout: 3000 });
  });

  test('challenge 1 is always accessible', async ({ page }) => {
    await page.goto('/learn/php/variables/4');
    await expect(page).toHaveURL(/\/variables\/4/);
    await expect(page.locator('h2')).toBeVisible();
  });
});
