// @ts-check
const { test, expect } = require('@playwright/test');

// Variables section test: challenges 4, 5, 6 (IDs from seed.sql)
// challenge 4 — fill_blank — solution: "PHP"
// challenge 5 — spot_bug  — solution: $name = "Hello";
// challenge 6 — fill_blank — solution: gettype

test.describe('Section test page', () => {
  test('loads for variables topic', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await expect(page.locator('h1')).toContainText('Section Test');
    await expect(page.locator('h1')).toContainText('Variables');
  });

  test('shows question count and 70% threshold notice', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await expect(page.locator('p').filter({ hasText: /score 70%/i })).toBeVisible();
  });

  test('shows 3 questions for variables', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await expect(page.getByText('Question 1')).toBeVisible();
    await expect(page.getByText('Question 2')).toBeVisible();
    await expect(page.getByText('Question 3')).toBeVisible();
  });

  test('each question has an answer input', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await expect(page.locator('[name="answer_4"]')).toBeVisible();
    await expect(page.locator('[name="answer_5"]')).toBeVisible();
    await expect(page.locator('[name="answer_6"]')).toBeVisible();
  });

  test('has submit button', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await expect(page.locator('button[type="submit"]')).toContainText('Submit Test');
  });

  test('accessible without login', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await expect(page).toHaveURL(/\/variables\/test/);
    await expect(page.locator('h1')).toBeVisible();
  });
});

test.describe('Section test — failing result', () => {
  test('submitting wrong answers shows failing score', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    // Leave inputs empty → all wrong
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('.alert-error')).toContainText('Not quite yet');
    await expect(page.locator('.alert-error')).toContainText('70%');
  });

  test('failing result shows score percentage', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.locator('button[type="submit"]').click();
    // 0/3 → 0%
    await expect(page.locator('.alert-error')).toContainText('0%');
  });

  test('failing result shows Review Topic Again button', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('a', { hasText: 'Review Topic Again' })).toBeVisible();
  });

  test('failing result shows Retry Test button', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('a', { hasText: 'Retry Test' })).toBeVisible();
  });

  test('Retry Test button navigates back to section test', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.locator('button[type="submit"]').click();
    await page.locator('a', { hasText: 'Retry Test' }).click();
    await expect(page).toHaveURL(/\/learn\/php\/variables\/test/);
    await expect(page.locator('h1')).toContainText('Section Test');
  });

  test('Review Topic Again link points to topic page', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.locator('button[type="submit"]').click();
    const href = await page.locator('a', { hasText: 'Review Topic Again' }).getAttribute('href');
    expect(href).toMatch(/\/learn\/php\/variables$/);
  });

  test('wrong answers show ✗ and correct answers in results', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.locator('button[type="submit"]').click();
    const pageText = await page.locator('.page').innerText();
    expect(pageText).toContain('✗');
    // Correct answer is revealed for wrong questions
    expect(pageText.toLowerCase()).toContain('correct:');
  });
});

test.describe('Section test — passing result', () => {
  test('all correct answers shows Topic Mastered', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.fill('[name="answer_4"]', '"PHP"');
    await page.fill('[name="answer_5"]', '$name = "Hello";');
    await page.fill('[name="answer_6"]', 'gettype');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('.alert-success')).toContainText('Topic Mastered');
  });

  test('passing shows 100% score', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.fill('[name="answer_4"]', '"PHP"');
    await page.fill('[name="answer_5"]', '$name = "Hello";');
    await page.fill('[name="answer_6"]', 'gettype');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('.alert-success')).toContainText('100%');
  });

  test('mastered result shows Browse Next Topic button', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.fill('[name="answer_4"]', '"PHP"');
    await page.fill('[name="answer_5"]', '$name = "Hello";');
    await page.fill('[name="answer_6"]', 'gettype');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('a', { hasText: 'Browse Next Topic' })).toBeVisible();
  });

  test('mastered result does not show Retry Test button', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.fill('[name="answer_4"]', '"PHP"');
    await page.fill('[name="answer_5"]', '$name = "Hello";');
    await page.fill('[name="answer_6"]', 'gettype');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('a', { hasText: 'Retry Test' })).toHaveCount(0);
  });

  test('correct answers show ✅ indicators', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.fill('[name="answer_4"]', '"PHP"');
    await page.fill('[name="answer_5"]', '$name = "Hello";');
    await page.fill('[name="answer_6"]', 'gettype');
    await page.locator('button[type="submit"]').click();
    const pageText = await page.locator('.page').innerText();
    expect(pageText).toContain('✅');
  });

  test('normalisation: single quotes accepted', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    // Use single quotes — grader normalises " → '
    await page.fill('[name="answer_4"]', "'PHP'");
    await page.fill('[name="answer_5"]', "$name = 'Hello';");
    await page.fill('[name="answer_6"]', 'gettype');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('.alert-success')).toContainText('Topic Mastered');
  });

  test('partial pass (2/3 = 67%) still fails', async ({ page }) => {
    await page.goto('/learn/php/variables/test');
    await page.fill('[name="answer_4"]', '"PHP"');
    await page.fill('[name="answer_5"]', '"PHP"'); // wrong
    await page.fill('[name="answer_6"]', 'gettype');
    await page.locator('button[type="submit"]').click();
    // 2/3 = 66.67% → rounds to 67% → below 70%
    await expect(page.locator('.alert-error')).toContainText('Not quite yet');
  });
});

test.describe('Section test — other topics', () => {
  test('operators section test loads', async ({ page }) => {
    await page.goto('/learn/php/operators/test');
    await expect(page.locator('h1')).toContainText('Section Test');
    await expect(page.locator('h1')).toContainText('Operators');
  });

  test('strings section test loads', async ({ page }) => {
    await page.goto('/learn/php/strings/test');
    await expect(page.locator('h1')).toContainText('Section Test');
    await expect(page.locator('h1')).toContainText('Strings');
  });

  test('invalid topic slug returns 404', async ({ page }) => {
    const response = await page.goto('/learn/php/nonexistent-topic/test');
    expect(response?.status()).toBe(404);
  });
});
