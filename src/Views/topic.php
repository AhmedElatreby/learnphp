<div class="page">
  <div style="margin-bottom:6px;color:var(--muted);font-size:0.85rem">
    <a href="/learn/php">PHP</a> › <?= htmlspecialchars($topic['name']) ?>
  </div>
  <h1 style="margin-bottom:8px"><?= htmlspecialchars($topic['name']) ?></h1>
  <p style="color:var(--muted);margin-bottom:28px"><?= htmlspecialchars($topic['description']) ?></p>

  <div style="display:flex;flex-direction:column;gap:10px">
    <?php foreach ($challenges as $c): ?>
    <?php $done = in_array($c['id'], $completed); ?>
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/<?= $c['id'] ?>" style="text-decoration:none">
      <div class="card" style="display:flex;align-items:center;gap:16px;cursor:pointer">
        <div style="font-size:1.2rem"><?= $done ? '✅' : '○' ?></div>
        <div style="flex:1">
          <div style="font-weight:600;margin-bottom:2px"><?= htmlspecialchars($c['title']) ?></div>
          <div style="color:var(--muted);font-size:0.85rem"><?= htmlspecialchars($c['prompt']) ?></div>
        </div>
        <div>
          <span class="badge badge-<?= htmlspecialchars($c['difficulty']) ?>"><?= ucfirst($c['difficulty']) ?></span>
        </div>
      </div>
    </a>
    <?php endforeach; ?>
  </div>

  <?php $allDone = count(array_diff(array_column($challenges, 'id'), $completed)) === 0 && count($challenges) > 0; ?>
  <?php if ($allDone): ?>
  <div class="card" style="margin-top:20px;text-align:center">
    <h3 style="margin-bottom:8px">🏁 All challenges complete!</h3>
    <p style="color:var(--muted);margin-bottom:16px">Take the section test to confirm your understanding and unlock the next topic.</p>
    <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/test" class="btn btn-primary">Start Section Test →</a>
  </div>
  <?php endif; ?>
</div>
