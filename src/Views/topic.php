<div class="page">
  <div style="margin-bottom:6px;color:var(--muted);font-size:0.85rem">
    <a href="/learn/php">PHP</a> › <?= htmlspecialchars($topic['name']) ?>
  </div>
  <h1 style="margin-bottom:8px"><?= htmlspecialchars($topic['name']) ?></h1>
  <p style="color:var(--muted);margin-bottom:28px"><?= htmlspecialchars($topic['description']) ?></p>

  <div style="display:flex;flex-direction:column;gap:10px">
    <?php foreach ($challenges as $i => $c):
      $done     = in_array($c['id'], $completed);
      $prevDone = $i === 0 || in_array($challenges[$i - 1]['id'], $completed);
      $locked   = !$prevDone && !$done;
    ?>

    <?php if ($locked): ?>
    <div class="card" style="display:flex;align-items:center;gap:16px;opacity:0.45;cursor:not-allowed">
      <div style="font-size:1.2rem">🔒</div>
      <div style="flex:1">
        <div style="font-weight:600;margin-bottom:2px"><?= htmlspecialchars($c['title']) ?></div>
        <div style="color:var(--muted);font-size:0.82rem">Complete the previous challenge first.</div>
      </div>
      <span class="badge badge-<?= htmlspecialchars($c['difficulty']) ?>"><?= ucfirst($c['difficulty']) ?></span>
    </div>

    <?php else: ?>
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/<?= (int)$c['id'] ?>" style="text-decoration:none">
      <div class="card" style="display:flex;align-items:center;gap:16px;cursor:pointer;border-color:<?= $done ? '#166534' : 'var(--border)' ?>">
        <div style="font-size:1.2rem"><?= $done ? '✅' : '▶' ?></div>
        <div style="flex:1">
          <div style="font-weight:600;margin-bottom:2px"><?= htmlspecialchars($c['title']) ?></div>
          <div style="color:var(--muted);font-size:0.85rem"><?= htmlspecialchars($c['prompt']) ?></div>
        </div>
        <div style="display:flex;gap:6px;align-items:center">
          <span class="badge badge-<?= htmlspecialchars($c['difficulty']) ?>"><?= ucfirst($c['difficulty']) ?></span>
          <span class="badge" style="background:var(--bg);color:var(--muted);border:1px solid var(--border);font-size:0.72rem"><?= htmlspecialchars(str_replace('_',' ',$c['type'])) ?></span>
        </div>
      </div>
    </a>
    <?php endif; ?>

    <?php endforeach; ?>
  </div>

  <?php $allDone = count($challenges) > 0 && count(array_diff(array_column($challenges,'id'), $completed)) === 0; ?>
  <?php if ($allDone): ?>
  <div class="card" style="margin-top:20px;text-align:center">
    <h3 style="margin-bottom:8px">🏁 All challenges complete!</h3>
    <p style="color:var(--muted);margin-bottom:16px">Take the section test to confirm your understanding.</p>
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/test" class="btn btn-primary">Start Section Test →</a>
  </div>
  <?php endif; ?>
</div>
