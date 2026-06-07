// @ts-check
const { test, expect } = require('@playwright/test');

// Logged-in challenge progression tests
// These verify that completing a challenge unlocks the next one,
// and that progress is tied to the session (guest or logged-in).

async function registerAndLogin(page, suffix) {
  const id = `${Date.now()}${suffix}${Math.random().toString(36).slice(2, 5)}`;
  await page.goto('/register');
  await page.fill('input[name="username"]', `proguser${id}`);
  await page.fill('input[name="email"]', `prog${id}@example.com`);
  await page.fill('input[name="password"]', 'Password123!');
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL(/\/dashboard/);
}

test.describe('Guest challenge progression', () => {
  test('completing challenge 1 unlocks challenge 2 within same session', async ({ page }) => {
    // Verify challenge 2 (id=5) is locked initially
    await page.goto('/learn/php/variables/5');
    await expect(page).toHaveURL(/\/learn\/php\/variables$/, { timeout: 4000 });

    // Complete challenge 1 (id=4) correctly
    await page.goto('/learn/php/variables/4');
    await page.fill('input[name="answer"]', '"PHP"');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('#feedback .alert-success')).toBeVisible({ timeout: 5000 });

    // Challenge 2 should now be accessible
    await page.goto('/learn/php/variables/5');
    await expect(page).toHaveURL(/\/variables\/5/);
    await expect(page.locator('h2')).toBeVisible();
  });

  test('challenge 1 is always accessible without completing anything', async ({ page }) => {
    await page.goto('/learn/php/variables/4');
    await expect(page).toHaveURL(/\/variables\/4/);
    await expect(page.locator('h2')).toBeVisible();
  });

  test('challenge 3 redirects when challenge 2 not passed', async ({ page }) => {
    // Pass challenge 1 only
    await page.goto('/learn/php/variables/4');
    await page.fill('input[name="answer"]', '"PHP"');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('#feedback .alert-success')).toBeVisible({ timeout: 5000 });

    // Challenge 3 (id=6) still locked — need to pass challenge 2 (id=5) first
    await page.goto('/learn/php/variables/6');
    await expect(page).toHaveURL(/\/learn\/php\/variables$/, { timeout: 4000 });
  });
});

test.describe('Logged-in challenge progression', () => {
  test('completing challenge 1 unlocks challenge 2', async ({ page }) => {
    await registerAndLogin(page, 'a');

    // Challenge 2 locked initially
    await page.goto('/learn/php/variables/5');
    await expect(page).toHaveURL(/\/learn\/php\/variables$/, { timeout: 4000 });

    // Complete challenge 1
    await page.goto('/learn/php/variables/4');
    await page.fill('input[name="answer"]', '"PHP"');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('#feedback .alert-success')).toBeVisible({ timeout: 5000 });

    // Challenge 2 now accessible
    await page.goto('/learn/php/variables/5');
    await expect(page).toHaveURL(/\/variables\/5/);
    await expect(page.locator('h2')).toBeVisible();
  });

  test('next challenge link appears in feedback after correct answer', async ({ page }) => {
    await registerAndLogin(page, 'b');

    await page.goto('/learn/php/variables/4');
    await page.fill('input[name="answer"]', '"PHP"');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('#feedback a.btn')).toBeVisible({ timeout: 5000 });
    const linkText = await page.locator('#feedback a.btn').innerText();
    expect(linkText).toMatch(/Next Challenge|Topic Complete/);
  });

  test('clicking Next Challenge navigates to challenge 2', async ({ page }) => {
    await registerAndLogin(page, 'c');

    await page.goto('/learn/php/variables/4');
    await page.fill('input[name="answer"]', '"PHP"');
    await page.locator('button[type="submit"]').click();
    const nextLink = page.locator('#feedback a.btn');
    await expect(nextLink).toBeVisible({ timeout: 5000 });
    await nextLink.click();
    await expect(page).toHaveURL(/\/variables\/5/);
  });

  test('wrong answer does not unlock the next challenge', async ({ page }) => {
    await registerAndLogin(page, 'd');

    // Submit wrong answer to challenge 1
    await page.goto('/learn/php/variables/4');
    await page.fill('input[name="answer"]', 'wrong');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('#feedback .alert-error')).toBeVisible({ timeout: 5000 });

    // Challenge 2 still locked
    await page.goto('/learn/php/variables/5');
    await expect(page).toHaveURL(/\/learn\/php\/variables$/, { timeout: 4000 });
  });

  test('topic detail shows locked challenges greyed out at start', async ({ page }) => {
    await registerAndLogin(page, 'e');

    await page.goto('/learn/php/variables');
    const locked = page.locator('.card[style*="cursor"]');
    const count = await locked.count();
    expect(count).toBeGreaterThan(0);
  });

  test('completing challenge 1 and 2 unlocks challenge 3', async ({ page }) => {
    await registerAndLogin(page, 'f');

    // Pass challenge 1 (id=4)
    await page.goto('/learn/php/variables/4');
    await page.fill('input[name="answer"]', '"PHP"');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('#feedback .alert-success')).toBeVisible({ timeout: 5000 });

    // Pass challenge 2 (id=5) — spot_bug: $name = "Hello";
    await page.goto('/learn/php/variables/5');
    await page.fill('input[name="answer"]', '$name = "Hello";');
    await page.locator('button[type="submit"]').click();
    await expect(page.locator('#feedback .alert-success')).toBeVisible({ timeout: 5000 });

    // Challenge 3 (id=6) now accessible
    await page.goto('/learn/php/variables/6');
    await expect(page).toHaveURL(/\/variables\/6/);
    await expect(page.locator('h2')).toBeVisible();
  });
});
