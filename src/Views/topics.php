<div class="page">
  <h1 style="margin-bottom:6px">PHP Topics</h1>
  <p style="color:var(--muted);margin-bottom:24px">28 topics from beginner to advanced. Work through them all, or jump to what you need.</p>

  <div class="topic-grid">
    <?php foreach ($topics as $t): ?>
    <a href="/learn/php/<?= htmlspecialchars($t['slug']) ?>" style="text-decoration:none">
      <div class="card" style="cursor:pointer;transition:border-color 0.15s" onmouseover="this.style.borderColor='var(--primary)'" onmouseout="this.style.borderColor='var(--border)'">
        <h3 style="margin-bottom:4px;font-size:1rem"><?= htmlspecialchars($t['name']) ?></h3>
        <p style="color:var(--muted);font-size:0.82rem;margin-bottom:10px"><?= htmlspecialchars($t['description']) ?></p>
        <?php if ($t['score'] > 0): ?>
        <div class="progress-bar">
          <div class="progress-bar__fill" style="width:<?= (int)$t['score'] ?>%"></div>
        </div>
        <div style="color:var(--muted);font-size:0.75rem;margin-top:4px"><?= (int)$t['score'] ?>% complete</div>
        <?php endif; ?>
      </div>
    </a>
    <?php endforeach; ?>
  </div>
</div>
