<div class="page" style="max-width:700px">
  <h1 style="margin-bottom:4px">Section Test: <?= htmlspecialchars($topic['name']) ?></h1>
  <p style="color:var(--muted);margin-bottom:6px"><?= (int)count($challenges) ?> questions — score 70% or more to unlock the next topic.</p>
  <div class="alert alert-info" style="margin-bottom:20px">
    💡 This tests what you learned in this topic. Take your time.
  </div>

  <form method="POST">
    <?php foreach ($challenges as $i => $c): ?>
    <div class="card" style="margin-bottom:16px">
      <div style="color:var(--muted);font-size:0.8rem;margin-bottom:8px">Question <?= (int)($i+1) ?></div>
      <p style="font-weight:500;margin-bottom:10px"><?= htmlspecialchars($c['prompt']) ?></p>
      <?php if ($c['starter_code']): ?>
      <div class="code-block" style="margin-bottom:10px"><?= htmlspecialchars($c['starter_code']) ?></div>
      <?php endif; ?>
      <?php if ($c['type'] === 'write_code'): ?>
      <textarea name="answer_<?= (int)$c['id'] ?>" class="code-input" rows="4" placeholder="Your code..."></textarea>
      <?php else: ?>
      <input type="text" name="answer_<?= (int)$c['id'] ?>" placeholder="Your answer...">
      <?php endif; ?>
    </div>
    <?php endforeach; ?>
    <button type="submit" class="btn btn-primary" style="width:100%;padding:14px">Submit Test →</button>
  </form>
</div>
