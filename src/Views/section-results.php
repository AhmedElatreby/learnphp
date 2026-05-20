<div class="page" style="max-width:700px">
  <h1 style="margin-bottom:4px"><?= htmlspecialchars($topic['name']) ?> — Test Results</h1>

  <?php if ($mastered): ?>
  <div class="alert alert-success" style="margin-bottom:20px">
    <strong>🎉 Topic Mastered! Score: <?= (int)$score ?>%</strong>
    <p style="margin-top:4px">You can now move on to the next topic.</p>
  </div>
  <?php else: ?>
  <div class="alert alert-error" style="margin-bottom:20px">
    <strong>Score: <?= (int)$score ?>% — Not quite yet (need 70%)</strong>
    <p style="margin-top:4px">Review the questions below, then try the topic challenges again.</p>
  </div>
  <?php endif; ?>

  <?php foreach ($results as $r): ?>
  <div class="card" style="margin-bottom:12px;border-left:3px solid <?= $r['correct'] ? 'var(--success)' : 'var(--error)' ?>">
    <div style="display:flex;justify-content:space-between;margin-bottom:6px">
      <strong style="font-size:0.9rem"><?= htmlspecialchars($r['challenge']['title']) ?></strong>
      <span style="color:<?= $r['correct'] ? 'var(--success)' : 'var(--error)' ?>"><?= $r['correct'] ? '✅' : '✗' ?></span>
    </div>
    <?php if (!$r['correct']): ?>
    <div style="color:var(--muted);font-size:0.85rem">Your answer: <code><?= htmlspecialchars($r['answer']) ?></code></div>
    <div style="color:var(--success);font-size:0.85rem;margin-top:2px">Correct: <code><?= htmlspecialchars($r['challenge']['solution']) ?></code></div>
    <div style="color:var(--muted);font-size:0.82rem;margin-top:4px"><?= htmlspecialchars($r['challenge']['explanation']) ?></div>
    <?php endif; ?>
  </div>
  <?php endforeach; ?>

  <div style="display:flex;gap:10px;margin-top:20px;flex-wrap:wrap">
    <?php if ($mastered): ?>
    <a href="/learn/php" class="btn btn-primary">Browse Next Topic →</a>
    <?php else: ?>
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>" class="btn btn-primary">Review Topic Again</a>
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/test" class="btn btn-ghost">Retry Test</a>
    <?php endif; ?>
  </div>
</div>
