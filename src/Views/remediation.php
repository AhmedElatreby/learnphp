<div class="page" style="max-width:700px">
  <div style="margin-bottom:6px;font-size:0.85rem">
    <a href="/diagnostic/results" style="color:var(--muted)">← Back to diagnostic results</a>
  </div>
  <h1 style="margin-bottom:4px">Remediation: <?= htmlspecialchars($topic['name']) ?></h1>
  <p style="color:var(--muted);margin-bottom:20px">
    Targeted practice to strengthen this topic. Answer all <?= count($challenges) ?> questions, then see your results.
  </p>

  <form method="POST" action="/remediation/<?= htmlspecialchars($topic['slug']) ?>">
    <?php foreach ($challenges as $i => $c): ?>
    <div class="card" style="margin-bottom:16px">
      <div style="color:var(--muted);font-size:0.8rem;margin-bottom:8px">
        Question <?= (int)($i + 1) ?>
        <span style="margin-left:8px;opacity:.6"><?= htmlspecialchars(str_replace('_', ' ', $c['type'])) ?></span>
      </div>
      <p style="font-weight:500;margin-bottom:10px"><?= htmlspecialchars($c['prompt']) ?></p>
      <?php if ($c['starter_code']): ?>
      <div class="code-block" style="margin-bottom:10px"><?= htmlspecialchars($c['starter_code']) ?></div>
      <?php endif; ?>
      <?php if ($c['type'] === 'write_code'): ?>
      <textarea name="answer_<?= (int)$c['id'] ?>" class="code-input" rows="4"
                placeholder="Your code here…"></textarea>
      <?php else: ?>
      <input type="text" name="answer_<?= (int)$c['id'] ?>"
             placeholder="Your answer…" autocomplete="off"
             style="font-family:var(--font-mono)">
      <?php endif; ?>
    </div>
    <?php endforeach; ?>
    <button type="submit" class="btn btn-primary" style="width:100%;padding:14px">
      Check My Answers →
    </button>
  </form>
</div>
