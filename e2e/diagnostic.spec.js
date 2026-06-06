// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Diagnostic flow', () => {
  // ── Page load ──────────────────────────────────────────────────────────────

  test('diagnostic page loads with correct title and description', async ({ page }) => {
    await page.goto('/diagnostic');
    await expect(page).toHaveTitle(/LearnPHP/);
    await expect(page.locator('h1')).toContainText('PHP Diagnostic Test');
    await expect(page.locator('.page p').first()).toContainText('~15 quick challenges');
  });

  test('shows 15 question cards', async ({ page }) => {
    await page.goto('/diagnostic');
    const cards = page.locator('.page .card');
    await expect(cards).toHaveCount(15);
  });

  test('each card shows question number, topic label and difficulty badge', async ({ page }) => {
    await page.goto('/diagnostic');
    // First card should say "Question 1 of 15"
    const firstCard = page.locator('.page .card').first();
    await expect(firstCard).toContainText('Question 1 of 15');
    // Should have a difficulty badge (beginner / intermediate / advanced)
    await expect(firstCard.locator('.badge')).toBeVisible();
  });

  test('has a mix of text inputs and textareas for answers', async ({ page }) => {
    await page.goto('/diagnostic');
    // At minimum fill-blank questions use <input>
    const inputs = page.locator('input[name^="answer_"]');
    const count = await inputs.count();
    expect(count).toBeGreaterThan(0);
  });

  test('submit button is visible at the bottom', async ({ page }) => {
    await page.goto('/diagnostic');
    const btn = page.locator('button[type="submit"]');
    await expect(btn).toBeVisible();
    await expect(btn).toContainText('Submit Diagnostic');
  });

  // ── Submission ─────────────────────────────────────────────────────────────

  test('submitting blank answers redirects to results page', async ({ page }) => {
    await page.goto('/diagnostic');
    await page.locator('button[type="submit"]').click();
    await expect(page).toHaveURL(/\/diagnostic\/results/);
  });

  test('submitting blank answers shows 0% for all topics', async ({ page }) => {
    await page.goto('/diagnostic');
    await page.locator('button[type="submit"]').click();
    await expect(page).toHaveURL(/\/diagnostic\/results/);
    // At least one progress bar is visible
    await expect(page.locator('.progress-bar__fill').first()).toBeVisible();
    // Strong Topics counter should be 0
    await expect(page.locator('.grid-3 .card').first()).toContainText('0');
  });

  // ── Results page ───────────────────────────────────────────────────────────

  test('results page loads directly via /diagnostic/results', async ({ page }) => {
    await page.goto('/diagnostic/results');
    await expect(page).toHaveURL(/\/diagnostic\/results/);
    await expect(page.locator('h1')).toContainText('Your Diagnostic Results');
  });

  test('results page shows the three summary cards (Strong / Review / Weak)', async ({ page }) => {
    await page.goto('/diagnostic/results');
    const summaryCards = page.locator('.grid-3 .card');
    await expect(summaryCards).toHaveCount(3);
    await expect(summaryCards.nth(0)).toContainText('Strong Topics');
    await expect(summaryCards.nth(1)).toContainText('Need Review');
    await expect(summaryCards.nth(2)).toContainText('Weak Areas');
  });

  test('results page shows topic breakdown with progress bars', async ({ page }) => {
    await page.goto('/diagnostic/results');
    await expect(page.locator('h3').filter({ hasText: 'Topic Breakdown' })).toBeVisible();
    const bars = page.locator('.progress-bar');
    const count = await bars.count();
    expect(count).toBeGreaterThanOrEqual(1);
  });

  test('results page shows recommended learning plan after blank submission', async ({ page }) => {
    await page.goto('/diagnostic');
    await page.locator('button[type="submit"]').click();
    await expect(page).toHaveURL(/\/diagnostic\/results/);
    // All topics will be weak — plan should appear
    await expect(page.locator('h3').filter({ hasText: 'Recommended Learning Plan' })).toBeVisible();
  });

  test('Fix it buttons link to remediation pages', async ({ page }) => {
    await page.goto('/diagnostic');
    await page.locator('button[type="submit"]').click();
    await expect(page).toHaveURL(/\/diagnostic\/results/);
    // Each plan item has a "Fix it →" link to /remediation/<slug>
    const firstFixLink = page.locator('a.btn[href^="/remediation/"]').first();
    await expect(firstFixLink).toBeVisible();
    const href = await firstFixLink.getAttribute('href');
    expect(href).toMatch(/^\/remediation\//);
  });

  test('results page has Browse All Topics link', async ({ page }) => {
    await page.goto('/diagnostic/results');
    await expect(page.locator('a[href="/learn/php"].btn')).toBeVisible();
  });

  test('results page shows Save Progress link for guests', async ({ page }) => {
    await page.goto('/diagnostic/results');
    await expect(page.locator('a[href="/register"].btn-ghost')).toBeVisible();
  });

  test('Start My Learning Plan button links to first weak topic', async ({ page }) => {
    await page.goto('/diagnostic');
    await page.locator('button[type="submit"]').click();
    await expect(page).toHaveURL(/\/diagnostic\/results/);
    // After all-blank submission every topic is weak — plan button should appear
    const startBtn = page.locator('a[href^="/learn/php/"]').filter({ hasText: 'Start My Learning Plan' });
    await expect(startBtn).toBeVisible();
    const href = await startBtn.getAttribute('href');
    expect(href).toMatch(/^\/learn\/php\//);
  });

  // ── Navigation ─────────────────────────────────────────────────────────────

  test('home page CTA links to /diagnostic', async ({ page }) => {
    await page.goto('/');
    const diagnosticLink = page.locator('.page a[href="/diagnostic"]');
    await expect(diagnosticLink).toBeVisible();
    await diagnosticLink.click();
    await expect(page).toHaveURL(/\/diagnostic/);
    await expect(page.locator('h1')).toContainText('PHP Diagnostic Test');
  });
});
