<div class="page">
  <h1 style="margin-bottom:4px">Welcome back, <?= htmlspecialchars($user['username']) ?> 👋</h1>
  <p style="color:var(--muted);margin-bottom:28px">Here's your PHP learning progress.</p>

  <div class="grid-3" style="margin-bottom:28px">
    <div class="card" style="text-align:center">
      <div style="color:var(--success);font-size:1.8rem;font-weight:700"><?= (int)$completed ?></div>
      <div style="color:var(--muted);font-size:0.85rem">Topics Mastered</div>
    </div>
    <div class="card" style="text-align:center">
      <div style="color:var(--warning);font-size:1.8rem;font-weight:700"><?= (int)$inProgress ?></div>
      <div style="color:var(--muted);font-size:0.85rem">In Progress</div>
    </div>
    <div class="card" style="text-align:center">
      <div style="color:var(--primary);font-size:1.8rem;font-weight:700"><?= (int)(count($topicData) - $completed) ?></div>
      <div style="color:var(--muted);font-size:0.85rem">Topics Left</div>
    </div>
  </div>

  <?php if ($lastTopic): ?>
  <div class="card" style="margin-bottom:28px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px">
    <div>
      <div style="color:var(--muted);font-size:0.8rem;margin-bottom:4px">Continue where you left off</div>
      <div style="font-weight:600"><?= htmlspecialchars($lastTopic['name']) ?></div>
    </div>
    <a href="/learn/php/<?= htmlspecialchars($lastTopic['slug']) ?>" class="btn btn-primary">Continue →</a>
  </div>
  <?php endif; ?>

  <h3 style="margin-bottom:14px">All Topics</h3>
  <div class="topic-grid">
    <?php foreach ($topicData as $td): ?>
    <a href="/learn/php/<?= htmlspecialchars($td['topic']['slug']) ?>" style="text-decoration:none">
      <div class="card" style="cursor:pointer">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px">
          <span style="font-size:0.9rem;font-weight:600"><?= htmlspecialchars($td['topic']['name']) ?></span>
          <?php if ($td['score'] >= 70): ?>
          <span style="color:var(--success)">✅</span>
          <?php elseif ($td['score'] > 0): ?>
          <span style="color:var(--warning)">⏳</span>
          <?php endif; ?>
        </div>
        <div class="progress-bar">
          <div class="progress-bar__fill" style="width:<?= (int)$td['score'] ?>%"></div>
        </div>
        <div style="color:var(--muted);font-size:0.75rem;margin-top:4px"><?= (int)$td['score'] ?>%</div>
      </div>
    </a>
    <?php endforeach; ?>
  </div>
</div>
