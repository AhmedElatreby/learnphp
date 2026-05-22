<?php
$message = match(true) {
    $score === 100 => 'Perfect! You\'ve got this topic down.',
    $score >= 75   => 'Good work! A little more practice and you\'ll be solid.',
    $score >= 50   => 'Getting there — review the explanations above.',
    default        => 'Keep at it — read each explanation carefully before moving on.',
};
?>
<div class="page" style="max-width:700px">
  <div style="margin-bottom:6px;font-size:0.85rem">
    <a href="/diagnostic/results" style="color:var(--muted)">← Back to diagnostic results</a>
  </div>
  <h1 style="margin-bottom:4px"><?= htmlspecialchars($topic['name']) ?></h1>
  <p style="color:var(--muted);margin-bottom:16px">Remediation Results</p>

  <?php
  $color = $score >= 75 ? 'var(--success)' : ($score >= 50 ? 'var(--warning)' : 'var(--error)');
  ?>
  <div class="card" style="margin-bottom:20px;text-align:center">
    <div style="font-size:2rem;font-weight:800;color:<?= $color ?>;margin-bottom:4px">
      <?= (int)$passed ?> / <?= count($results) ?> correct
    </div>
    <div class="progress-bar" style="max-width:300px;margin:8px auto">
      <div class="progress-bar__fill" style="width:<?= (int)$score ?>%;background:<?= $color ?>"></div>
    </div>
    <div style="color:var(--muted);font-size:0.9rem;margin-top:8px"><?= htmlspecialchars($message) ?></div>
  </div>

  <?php foreach ($results as $r): ?>
  <div class="card" style="margin-bottom:12px;border-left:3px solid <?= $r['correct'] ? 'var(--success)' : 'var(--error)' ?>">
    <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:6px">
      <p style="font-weight:500;font-size:0.9rem;flex:1;margin-right:12px">
        <?= htmlspecialchars($r['challenge']['prompt']) ?>
      </p>
      <span style="color:<?= $r['correct'] ? 'var(--success)' : 'var(--error)' ?>;flex-shrink:0">
        <?= $r['correct'] ? '✅' : '✗' ?>
      </span>
    </div>
    <?php if (!$r['correct']): ?>
    <div style="color:var(--muted);font-size:0.85rem">
      Your answer: <code><?= htmlspecialchars($r['answer'] ?: '(blank)') ?></code>
    </div>
    <div style="color:var(--success);font-size:0.85rem;margin-top:2px">
      Correct: <code><?= htmlspecialchars($r['challenge']['solution']) ?></code>
    </div>
    <?php endif; ?>
    <div style="color:var(--muted);font-size:0.82rem;margin-top:6px;padding-top:6px;border-top:1px solid var(--border)">
      <?= htmlspecialchars($r['challenge']['explanation']) ?>
    </div>
  </div>
  <?php endforeach; ?>

  <div style="display:flex;gap:10px;margin-top:20px;flex-wrap:wrap">
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>" class="btn btn-primary" style="flex:1;min-width:200px">
      📚 Practice this topic →
    </a>
    <a href="/remediation/<?= htmlspecialchars($topic['slug']) ?>" class="btn btn-ghost">
      Retry Remediation
    </a>
    <a href="/diagnostic/results" class="btn btn-ghost">
      ← Diagnostic Results
    </a>
  </div>
</div>
