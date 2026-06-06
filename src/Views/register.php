<div class="page-sm">
  <h1 style="margin-bottom:4px">Create your account</h1>
  <p style="color:var(--muted);margin-bottom:24px">Free forever. Save your progress and get a personalised learning plan.</p>

  <?php if ($error): ?>
  <div class="alert alert-error"><?= htmlspecialchars($error) ?></div>
  <?php endif; ?>

  <form method="POST" action="/register">
    <input type="hidden" name="_token" value="<?= htmlspecialchars(\App\Auth::csrfToken()) ?>">
    <div class="form-group">
      <label>Username</label>
      <input type="text" name="username" required minlength="2" autofocus>
    </div>
    <div class="form-group">
      <label>Email</label>
      <input type="email" name="email" required>
    </div>
    <div class="form-group">
      <label>Password</label>
      <input type="password" name="password" required minlength="6">
    </div>
    <button type="submit" class="btn btn-primary" style="width:100%">Create Account</button>
  </form>

  <p style="text-align:center;margin-top:20px;color:var(--muted)">
    Already have an account? <a href="/login">Log in</a>
  </p>
</div>
