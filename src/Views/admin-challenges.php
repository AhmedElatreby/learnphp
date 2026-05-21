<div class="page">
  <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;flex-wrap:wrap;gap:12px">
    <div>
      <h1 style="margin-bottom:2px">Challenges</h1>
      <p style="color:var(--muted);font-size:0.85rem">Admin › Challenges</p>
    </div>
    <a href="/admin/challenges/new" class="btn btn-primary">+ Add Challenge</a>
  </div>

  <?php if ($flash): ?>
  <div class="alert <?= $flash['type'] === 'success' ? 'alert-success' : 'alert-error' ?>" style="margin-bottom:16px">
    <?= htmlspecialchars($flash['msg']) ?>
  </div>
  <?php endif; ?>

  <?php foreach ($grouped as $langName => $topicGroups): ?>
  <?php foreach ($topicGroups as $topicName => $items): ?>
  <div class="card" style="margin-bottom:16px;padding:0;overflow:hidden">
    <div style="padding:10px 16px;background:#1a2744;border-bottom:1px solid var(--border);font-size:0.85rem;font-weight:600">
      <?= htmlspecialchars($langName) ?> › <?= htmlspecialchars($topicName) ?>
      <span style="color:var(--muted);font-weight:400"> (<?= count($items) ?>)</span>
    </div>
    <div style="overflow-x:auto">
      <table style="width:100%;border-collapse:collapse;font-size:0.85rem">
        <thead>
          <tr>
            <th style="text-align:left;color:var(--muted);font-size:0.78rem;padding:8px 12px;border-bottom:1px solid var(--border)">ID</th>
            <th style="text-align:left;color:var(--muted);font-size:0.78rem;padding:8px 12px;border-bottom:1px solid var(--border)">Title</th>
            <th style="text-align:left;color:var(--muted);font-size:0.78rem;padding:8px 12px;border-bottom:1px solid var(--border)">Type</th>
            <th style="text-align:left;color:var(--muted);font-size:0.78rem;padding:8px 12px;border-bottom:1px solid var(--border)">Difficulty</th>
            <th style="text-align:center;color:var(--muted);font-size:0.78rem;padding:8px 12px;border-bottom:1px solid var(--border)">Diag</th>
            <th style="padding:8px 12px;border-bottom:1px solid var(--border)"></th>
          </tr>
        </thead>
        <tbody>
          <?php foreach ($items as $c): ?>
          <tr>
            <td style="padding:8px 12px;color:var(--muted);border-bottom:1px solid #1e293b"><?= (int)$c['id'] ?></td>
            <td style="padding:8px 12px;border-bottom:1px solid #1e293b"><?= htmlspecialchars($c['title']) ?></td>
            <td style="padding:8px 12px;border-bottom:1px solid #1e293b"><span class="badge" style="background:var(--bg);color:var(--muted);border:1px solid var(--border)"><?= htmlspecialchars($c['type']) ?></span></td>
            <td style="padding:8px 12px;border-bottom:1px solid #1e293b"><span class="badge badge-<?= htmlspecialchars($c['difficulty']) ?>"><?= ucfirst($c['difficulty']) ?></span></td>
            <td style="padding:8px 12px;text-align:center;border-bottom:1px solid #1e293b"><?= $c['is_diagnostic'] ? '✅' : '—' ?></td>
            <td style="padding:8px 12px;border-bottom:1px solid #1e293b;white-space:nowrap">
              <a href="/admin/challenges/<?= (int)$c['id'] ?>/edit" class="btn btn-ghost" style="padding:4px 10px;font-size:0.8rem;min-height:30px">Edit</a>
              <form method="POST" action="/admin/challenges/<?= (int)$c['id'] ?>/delete" style="display:inline" onsubmit="return confirm('Delete this challenge?')">
                <button type="submit" class="btn btn-danger" style="padding:4px 10px;font-size:0.8rem;min-height:30px">Delete</button>
              </form>
            </td>
          </tr>
          <?php endforeach; ?>
        </tbody>
      </table>
    </div>
  </div>
  <?php endforeach; ?>
  <?php endforeach; ?>
</div>
