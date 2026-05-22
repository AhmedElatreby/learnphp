// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Topics page', () => {
  test('lists all 5 PHP topics', async ({ page }) => {
    await page.goto('/learn/php');
    await expect(page.locator('h1')).toContainText('PHP');
    // Each topic is an <a> wrapping a .card — count anchors in the grid
    const topicLinks = page.locator('.topic-grid > a');
    await expect(topicLinks).toHaveCount(5);
  });

  test('topic names are correct', async ({ page }) => {
    await page.goto('/learn/php');
    // Check each h3 inside the topic grid
    const headings = page.locator('.topic-grid h3');
    await expect(headings.filter({ hasText: 'Variables' })).toBeVisible();
    await expect(headings.filter({ hasText: 'Operators' })).toBeVisible();
    await expect(headings.filter({ hasText: 'Strings' })).toBeVisible();
    await expect(headings.filter({ hasText: 'Arrays' })).toBeVisible();
    await expect(headings.filter({ hasText: 'Conditionals' })).toBeVisible();
  });

  test('clicking a topic navigates to topic detail', async ({ page }) => {
    await page.goto('/learn/php');
    await page.locator('a[href*="/learn/php/variables"]').first().click();
    await expect(page).toHaveURL(/\/learn\/php\/variables/);
  });
});

test.describe('Topic detail page', () => {
  test('variables topic shows 8 challenges', async ({ page }) => {
    await page.goto('/learn/php/variables');
    await expect(page.locator('h1')).toContainText('Variables');
    // Should have 8 challenge cards (mix of locked/unlocked)
    const challengeCards = page.locator('.card').filter({ hasNot: page.locator('h1') });
    const count = await challengeCards.count();
    expect(count).toBeGreaterThanOrEqual(8);
  });

  test('first challenge is unlocked (has a link)', async ({ page }) => {
    await page.goto('/learn/php/variables');
    // First challenge should be a clickable link
    const firstLink = page.locator('a[href*="/learn/php/variables/"]').first();
    await expect(firstLink).toBeVisible();
  });

  test('later challenges are locked (shown greyed out)', async ({ page }) => {
    await page.goto('/learn/php/variables');
    // Locked cards have opacity:0.45 and cursor:not-allowed
    const lockedCards = page.locator('.card[style*="cursor: not-allowed"], .card[style*="cursor:not-allowed"]');
    const count = await lockedCards.count();
    expect(count).toBeGreaterThan(0);
  });

  test('locked challenges show lock icon', async ({ page }) => {
    await page.goto('/learn/php/variables');
    const pageText = await page.locator('.page').innerText();
    expect(pageText).toContain('🔒');
  });
});
