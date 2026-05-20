<?php
// Variables expected: $title (string), $content (string)
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
  </nav>
  <main>
    <?= $content ?>
  </main>
</body>
</html>
