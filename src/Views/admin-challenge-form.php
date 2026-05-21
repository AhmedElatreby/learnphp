<?php
$isEdit = isset($challenge);
$action = $isEdit ? '/admin/challenges/' . (int)$challenge['id'] : '/admin/challenges';
$v = fn(string $k, mixed $def = '') => htmlspecialchars((string)($old[$k] ?? $def));
?>
<div class="page" style="max-width:720px">
  <div style="margin-bottom:4px;font-size:0.85rem;color:var(--muted)">
    <a href="/admin/challenges">← Challenges</a>
  </div>
  <h1 style="margin-bottom:20px"><?= $isEdit ? 'Edit Challenge' : 'Add Challenge' ?></h1>

  <?php if ($errors): ?>
  <div class="alert alert-error" style="margin-bottom:16px">
    <ul style="margin:0;padding-left:18px">
      <?php foreach ($errors as $e): ?>
      <li><?= htmlspecialchars($e) ?></li>
      <?php endforeach; ?>
    </ul>
  </div>
  <?php endif; ?>

  <form method="POST" action="<?= $action ?>">
    <input type="hidden" name="_token" value="<?= htmlspecialchars(\App\Auth::csrfToken()) ?>">
    <div class="card">
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
        <div class="form-group">
          <label>Topic</label>
          <select name="topic_id">
            <?php
            $currentLang = '';
            $groupOpen   = false;
            foreach ($topics as $t):
              if ($t['language_name'] !== $currentLang):
                if ($groupOpen) echo '</optgroup>';
                $currentLang = $t['language_name'];
                $groupOpen   = true;
                echo '<optgroup label="' . htmlspecialchars($currentLang) . '">';
              endif;
              $sel = ((string)($old['topic_id'] ?? '') === (string)$t['id']) ? 'selected' : '';
            ?>
            <option value="<?= (int)$t['id'] ?>" <?= $sel ?>><?= htmlspecialchars($t['name']) ?></option>
            <?php endforeach; if ($groupOpen): ?></optgroup><?php endif; ?>
          </select>
        </div>
        <div class="form-group">
          <label>Sort Order</label>
          <input type="number" name="sort_order" value="<?= $v('sort_order', 0) ?>">
        </div>
      </div>

      <div class="form-group">
        <label>Title</label>
        <input type="text" name="title" value="<?= $v('title') ?>" placeholder="e.g. Ternary Operator">
      </div>
      <div class="form-group">
        <label>Prompt</label>
        <textarea name="prompt" rows="3" placeholder="What does the user need to do?"><?= $v('prompt') ?></textarea>
      </div>

      <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px">
        <div class="form-group">
          <label>Type</label>
          <select name="type">
            <?php foreach (['fill_blank','write_code','spot_bug'] as $t): ?>
            <option value="<?= $t ?>" <?= $v('type') === $t ? 'selected' : '' ?>><?= $t ?></option>
            <?php endforeach; ?>
          </select>
        </div>
        <div class="form-group">
          <label>Difficulty</label>
          <select name="difficulty">
            <?php foreach (['beginner','intermediate','advanced'] as $d): ?>
            <option value="<?= $d ?>" <?= $v('difficulty') === $d ? 'selected' : '' ?>><?= $d ?></option>
            <?php endforeach; ?>
          </select>
        </div>
        <div class="form-group">
          <label>Diagnostic?</label>
          <select name="is_diagnostic">
            <option value="0" <?= $v('is_diagnostic', 0) == 0 ? 'selected' : '' ?>>No</option>
            <option value="1" <?= $v('is_diagnostic', 0) == 1 ? 'selected' : '' ?>>Yes</option>
          </select>
        </div>
      </div>

      <div class="form-group">
        <label>Starter Code <span style="color:var(--muted)">(shown above answer box)</span></label>
        <textarea name="starter_code" rows="4" style="font-family:var(--font-mono);font-size:0.88rem"><?= $v('starter_code') ?></textarea>
      </div>
      <div class="form-group">
        <label>Solution <span style="color:var(--muted)">(the correct answer string)</span></label>
        <input type="text" name="solution" value="<?= $v('solution') ?>" style="font-family:var(--font-mono)">
      </div>
      <div class="form-group">
        <label>Hint</label>
        <input type="text" name="hint" value="<?= $v('hint') ?>" placeholder="A nudge…">
      </div>
      <div class="form-group">
        <label>Explanation <span style="color:var(--muted)">(shown after answering)</span></label>
        <textarea name="explanation" rows="4" placeholder="Explain the concept thoroughly…"><?= $v('explanation') ?></textarea>
      </div>

      <div style="display:flex;gap:10px;margin-top:8px">
        <button type="submit" class="btn btn-primary">💾 <?= $isEdit ? 'Update' : 'Save' ?> Challenge</button>
        <a href="/admin/challenges" class="btn btn-ghost">Cancel</a>
      </div>
    </div>
  </form>
</div>
