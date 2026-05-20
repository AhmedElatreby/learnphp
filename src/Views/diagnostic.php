<div class="page" style="max-width:720px">
  <h1 style="margin-bottom:6px">PHP Diagnostic Test</h1>
  <p style="color:var(--muted);margin-bottom:28px">
    ~15 quick challenges across all PHP topics. Take your time — no timer.
    At the end we'll show you exactly what to study.
  </p>

  <?php if (empty($challenges)): ?>
  <div class="alert alert-info">
    No diagnostic challenges available yet. <a href="/learn/php">Browse topics instead →</a>
  </div>
  <?php else: ?>
  <form method="POST" action="/diagnostic">
    <?php foreach ($challenges as $i => $c): ?>
    <div class="card" style="margin-bottom:16px">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
        <span style="color:var(--muted);font-size:0.8rem">
          Question <?= (int)($i+1) ?> of <?= (int)count($challenges) ?> · <?= htmlspecialchars($c['topic_name']) ?>
        </span>
        <span class="badge badge-<?= htmlspecialchars($c['difficulty']) ?>"><?= ucfirst($c['difficulty']) ?></span>
      </div>
      <p style="margin-bottom:10px;font-weight:500"><?= htmlspecialchars($c['prompt']) ?></p>
      <?php if ($c['starter_code']): ?>
      <div class="code-block" style="margin-bottom:10px"><?= htmlspecialchars($c['starter_code']) ?></div>
      <?php endif; ?>
      <?php if ($c['type'] === 'write_code'): ?>
      <textarea name="answer_<?= (int)$c['id'] ?>" class="code-input" placeholder="Write your answer..." rows="4"></textarea>
      <?php else: ?>
      <input type="text" name="answer_<?= (int)$c['id'] ?>" placeholder="Your answer...">
      <?php endif; ?>
    </div>
    <?php endforeach; ?>
    <button type="submit" class="btn btn-primary" style="width:100%;padding:14px;font-size:1rem">
      Submit Diagnostic →
    </button>
  </form>
  <?php endif; ?>
</div>
