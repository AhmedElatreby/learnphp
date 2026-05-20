<div class="page" style="max-width:720px">
  <h1 style="margin-bottom:4px">Your Diagnostic Results</h1>
  <p style="color:var(--muted);margin-bottom:24px">Here's where you stand across PHP topics.</p>

  <?php
  $strong = array_filter($results, fn($r) => $r['status'] === 'strong');
  $review = array_filter($results, fn($r) => $r['status'] === 'review');
  $weak   = array_filter($results, fn($r) => $r['status'] === 'weak');
  $colors = ['strong' => 'var(--success)', 'review' => 'var(--warning)', 'weak' => 'var(--error)'];
  $labels = ['strong' => '✓ Strong', 'review' => 'Review', 'weak' => '⚠ Weak'];
  ?>

  <!-- Summary cards -->
  <div class="grid-3" style="margin-bottom:24px">
    <div class="card" style="text-align:center">
      <div style="color:var(--success);font-size:1.8rem;font-weight:700"><?= (int)count($strong) ?></div>
      <div style="color:var(--muted);font-size:0.85rem">Strong Topics</div>
    </div>
    <div class="card" style="text-align:center">
      <div style="color:var(--warning);font-size:1.8rem;font-weight:700"><?= (int)count($review) ?></div>
      <div style="color:var(--muted);font-size:0.85rem">Need Review</div>
    </div>
    <div class="card" style="text-align:center">
      <div style="color:var(--error);font-size:1.8rem;font-weight:700"><?= (int)count($weak) ?></div>
      <div style="color:var(--muted);font-size:0.85rem">Weak Areas</div>
    </div>
  </div>

  <!-- Topic breakdown -->
  <div class="card" style="margin-bottom:20px">
    <h3 style="margin-bottom:14px">Topic Breakdown</h3>
    <?php foreach ($results as $r): ?>
    <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px">
      <span style="width:180px;font-size:0.85rem;flex-shrink:0"><?= htmlspecialchars($r['topic']['name']) ?></span>
      <div style="flex:1" class="progress-bar">
        <div class="progress-bar__fill" style="width:<?= max((int)$r['score'], 3) ?>%;background:<?= $colors[$r['status']] ?>"></div>
      </div>
      <span style="color:<?= $colors[$r['status']] ?>;font-size:0.8rem;width:35px;text-align:right"><?= (int)$r['score'] ?>%</span>
      <span class="badge" style="background:var(--bg);color:<?= $colors[$r['status']] ?>;min-width:70px;text-align:center"><?= $labels[$r['status']] ?></span>
    </div>
    <?php endforeach; ?>
  </div>

  <!-- Recommended plan -->
  <?php $plan = array_values(array_filter($results, fn($r) => $r['status'] !== 'strong')); ?>
  <?php if (!empty($plan)): ?>
  <div class="card" style="margin-bottom:20px">
    <h3 style="margin-bottom:14px">📋 Your Recommended Learning Plan</h3>
    <?php foreach ($plan as $i => $r): ?>
    <a href="/learn/php/<?= htmlspecialchars($r['topic']['slug']) ?>" style="text-decoration:none">
      <div style="display:flex;align-items:center;gap:12px;padding:10px;background:var(--bg);border-radius:6px;margin-bottom:8px;border-left:3px solid <?= $colors[$r['status']] ?>">
        <span style="color:var(--muted);font-size:0.85rem;min-width:20px"><?= (int)($i+1) ?></span>
        <span style="flex:1;color:var(--text);font-size:0.9rem"><?= htmlspecialchars($r['topic']['name']) ?></span>
        <span style="color:<?= $colors[$r['status']] ?>;font-size:0.8rem"><?= $r['status'] === 'weak' ? 'Priority' : 'Review' ?></span>
      </div>
    </a>
    <?php endforeach; ?>
  </div>
  <?php endif; ?>

  <div style="display:flex;gap:10px;flex-wrap:wrap">
    <?php if (!empty($plan)): ?>
    <a href="/learn/php/<?= htmlspecialchars($plan[0]['topic']['slug']) ?>" class="btn btn-primary" style="flex:1;min-width:200px">
      🚀 Start My Learning Plan
    </a>
    <?php endif; ?>
    <a href="/learn/php" class="btn btn-ghost">Browse All Topics</a>
    <?php if (!\App\Auth::user()): ?>
    <a href="/register" class="btn btn-ghost">💾 Save Progress</a>
    <?php endif; ?>
  </div>
</div>
