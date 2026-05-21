<div class="page">
  <!-- Topbar -->
  <div class="challenge-topbar" style="margin-bottom:16px">
    <span>
      <a href="/learn/php" style="color:var(--muted)">PHP</a>
      › <a href="/learn/php/<?= htmlspecialchars($topic['slug']) ?>" style="color:var(--muted)"><?= htmlspecialchars($topic['name']) ?></a>
      › Challenge <?= (int)$position ?> of <?= (int)$total ?>
    </span>
    <div style="display:flex;gap:8px">
      <span class="badge badge-<?= htmlspecialchars($challenge['difficulty']) ?>"><?= ucfirst($challenge['difficulty']) ?></span>
      <span class="badge" style="background:var(--bg-card);color:var(--muted)"><?= ucfirst(str_replace('_',' ',$challenge['type'])) ?></span>
    </div>
  </div>

  <div class="challenge-layout">
    <!-- Left: Challenge -->
    <div>
      <div class="card" style="margin-bottom:16px">
        <h2 style="font-size:1.1rem;margin-bottom:6px"><?= htmlspecialchars($challenge['title']) ?></h2>
        <p style="color:var(--muted);margin-bottom:14px"><?= htmlspecialchars($challenge['prompt']) ?></p>

        <?php if ($challenge['starter_code']): ?>
        <div class="code-block" style="margin-bottom:14px"><?= htmlspecialchars($challenge['starter_code']) ?></div>
        <?php endif; ?>

        <form hx-post="/learn/php/<?= htmlspecialchars($topic['slug']) ?>/<?= (int)$challenge['id'] ?>"
              hx-target="#feedback"
              hx-swap="innerHTML">
          <div class="form-group">
            <label>Your answer:</label>
            <?php if ($challenge['type'] === 'write_code'): ?>
            <div id="cm-editor" data-starter="<?= htmlspecialchars($challenge['starter_code']) ?>" data-lang="php"></div>
            <input type="hidden" name="answer" id="cm-answer">
            <?php else: ?>
            <input type="text" name="answer" placeholder="Type your answer..." autocomplete="off">
            <?php endif; ?>
          </div>
          <div class="challenge-actions">
            <button type="submit" class="btn btn-primary">✓ Check Answer</button>
            <button type="button" class="btn btn-ghost"
                    onclick="document.getElementById('hint').style.display='block';this.style.display='none'">
              💡 Hint
            </button>
            <?php if ($challenge['type'] === 'write_code'): ?>
            <button type="button" class="btn btn-ghost" onclick="runCode()">▶ Run Code</button>
            <?php endif; ?>
          </div>
        </form>

        <div id="hint" style="display:none;margin-top:12px" class="alert alert-info">
          <?= htmlspecialchars($challenge['hint']) ?>
        </div>
      </div>

      <div id="feedback"></div>

      <?php if ($challenge['type'] === 'write_code'): ?>
      <div id="runner-output" style="display:none;margin-top:12px" class="card">
        <div style="color:var(--muted);font-size:0.8rem;margin-bottom:6px">Output:</div>
        <pre id="runner-pre" style="margin:0"></pre>
      </div>
      <script src="/assets/js/runner.js" defer></script>
      <script type="module" src="/assets/js/editor.js"></script>
      <?php endif; ?>
    </div>

    <!-- Right: Tips -->
    <div class="challenge-tips">
      <div class="card">
        <div style="color:var(--muted);font-size:0.75rem;text-transform:uppercase;letter-spacing:1px;margin-bottom:12px">💡 Learning Tips</div>
        <?php foreach ($tips as $tip): ?>
        <div class="tip-card <?= $tip['title'] === 'Common Mistake' ? 'tip-warning' : '' ?>">
          <h4><?= htmlspecialchars($tip['title']) ?></h4>
          <p><?= nl2br(htmlspecialchars($tip['content'])) ?></p>
        </div>
        <?php endforeach; ?>

        <div style="margin-top:16px;padding-top:14px;border-top:1px solid var(--border)">
          <div style="color:var(--muted);font-size:0.75rem;text-transform:uppercase;letter-spacing:1px;margin-bottom:8px">Progress</div>
          <div style="color:var(--text);font-size:0.85rem;margin-bottom:6px"><?= htmlspecialchars($topic['name']) ?></div>
          <div class="progress-bar">
            <div class="progress-bar__fill" style="width:<?= $total > 0 ? (int)round(($position-1)/$total*100) : 0 ?>%"></div>
          </div>
          <div style="color:var(--muted);font-size:0.78rem;margin-top:4px"><?= (int)$position - 1 ?> of <?= (int)$total ?> done</div>
        </div>
      </div>
    </div>
  </div>
</div>
