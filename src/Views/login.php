<div class="page-sm">
  <h1 style="margin-bottom:4px">Welcome back</h1>
  <p style="color:var(--muted);margin-bottom:24px">Log in to continue your learning journey.</p>

  <?php if ($error): ?>
  <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
  <?php endif; ?>

  <form method="POST" action="/login">
    <input type="hidden" name="_token" value="<?= htmlspecialchars(\App\Auth::csrfToken()) ?>">
    <div class="form-group">
      <label>Email</label>
      <input type="email" name="email" required autofocus>
    </div>
    <div class="form-group">
      <label>Password</label>
      <input type="password" name="password" required>
    </div>
    <button type="submit" class="btn btn-primary" style="width:100%">Log In</button>
  </form>

  <p style="text-align:center;margin-top:20px;color:var(--muted)">
    No account? <a href="/register">Create one free</a>
  </p>
</div>
