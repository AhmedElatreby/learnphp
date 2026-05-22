<?php
// Variables expected: $title (string), $content (trusted HTML rendered by a controller — never pass raw user input)
$user = \App\Auth::user();
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><?= htmlspecialchars($title ?? 'LearnPHP') ?> — LearnPHP</title>
  <link rel="stylesheet" href="/assets/css/main.css">
  <link rel="stylesheet" href="/assets/css/layout.css">
  <link rel="stylesheet" href="/assets/css/challenge.css">
  <script src="https://unpkg.com/htmx.org@1.9.12" defer></script>
</head>
<body>
  <nav class="nav">
    <a class="nav__logo" href="/">🐘 LearnPHP</a>
    <div class="nav__links">
      <a href="/learn/php">Topics</a>
      <a href="/diagnostic">Diagnostic Test</a>
      <?php if ($user): ?>
        <a href="/dashboard">Dashboard</a>
        <a href="/logout">Logout</a>
      <?php else: ?>
        <a href="/login">Login</a>
        <a href="/register" class="btn btn-primary" style="padding:6px 14px;font-size:0.85rem">Sign Up</a>
      <?php endif; ?>
    </div>
    <button class="nav__hamburger" aria-label="Open menu" aria-expanded="false">☰</button>
  </nav>

  <div class="nav__overlay" id="nav-overlay" role="dialog" aria-modal="true" aria-label="Navigation">
    <div class="nav__overlay-header">
      <span class="nav__overlay-logo">🐘 LearnPHP</span>
      <button class="nav__close" aria-label="Close menu">✕</button>
    </div>
    <nav class="nav__overlay-links">
      <a href="/learn/php">Topics</a>
      <a href="/diagnostic">Diagnostic Test</a>
      <?php if ($user): ?>
        <a href="/dashboard">Dashboard</a>
        <a href="/logout">Logout</a>
      <?php else: ?>
        <a href="/login">Login</a>
        <a href="/register" class="btn btn-primary nav__overlay-signup">Sign Up</a>
      <?php endif; ?>
    </nav>
  </div>

  <main>
    <?= $content ?>
  </main>
<script>
(function () {
  var overlay   = document.getElementById('nav-overlay');
  var hamburger = document.querySelector('.nav__hamburger');
  var closeBtn  = document.querySelector('.nav__close');
  if (!overlay || !hamburger) return;

  function openMenu()  { overlay.classList.add('open');    hamburger.setAttribute('aria-expanded', 'true');  }
  function closeMenu() { overlay.classList.remove('open'); hamburger.setAttribute('aria-expanded', 'false'); }

  hamburger.addEventListener('click', openMenu);
  closeBtn.addEventListener('click', closeMenu);

  overlay.querySelectorAll('a').forEach(function(a) {
    a.addEventListener('click', closeMenu);
  });

  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeMenu();
  });
})();
</script>
</body>
</html>
