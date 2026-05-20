<?php
namespace App\Controllers;

use App\Models\Topic;
use App\Models\Challenge;
use App\Models\Progress;
use App\Models\Tip;
use App\Auth;

class ChallengeController
{
    public function show(string $lang, string $topicSlug, string $id): void
    {
        $topic     = Topic::findBySlug($lang, $topicSlug);
        $challenge = Challenge::find((int)$id);
        if (!$topic || !$challenge) { http_response_code(404); echo '404'; return; }

        $tips      = Tip::forTopic($topic['id'], $challenge['difficulty']);
        $token     = Auth::sessionToken();
        $completed = Progress::completedIds($token);
        $allForTopic = Challenge::forTopic($topic['id']);
        $position  = array_search($challenge['id'], array_column($allForTopic, 'id')) + 1;
        $total     = count($allForTopic);

        $title = $challenge['title'];
        ob_start();
        require __DIR__ . '/../Views/challenge.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function submit(string $lang, string $topicSlug, string $id): void
    {
        $challenge = Challenge::find((int)$id);
        $topic     = Topic::findBySlug($lang, $topicSlug);
        if (!$challenge || !$topic) { http_response_code(404); return; }

        $answer  = trim($_POST['answer'] ?? '');
        $passed  = Challenge::grade($challenge, $answer);
        $token   = Auth::sessionToken();
        $user    = Auth::user();
        $userId  = $user['id'] ?? null;

        Progress::record($token, $challenge['id'], $passed, $userId);

        // HTMX: return only the feedback fragment
        if ($passed) {
            echo $this->renderFeedbackCorrect($challenge, $lang, $topicSlug, (int)$id, $topic, $token);
        } else {
            $followups = Challenge::followups($challenge['id']);
            echo $this->renderFeedbackWrong($challenge, $followups, $answer);
        }
    }

    public function submitFollowup(string $id): void
    {
        $db = \App\Database::getInstance();
        $fu = $db->query('SELECT * FROM followup_challenges WHERE id = ?', [(int)$id])->fetch();
        if (!$fu) { http_response_code(404); return; }

        $answer = trim($_POST['answer'] ?? '');
        $passed = Challenge::grade([
            'type'     => $fu['type'],
            'solution' => $fu['solution'],
        ], $answer);

        if ($passed) {
            $exp = htmlspecialchars($fu['explanation']);
            echo <<<HTML
<div id="followup-result" class="alert alert-success" style="margin-top:8px">
  ✅ Correct! {$exp}
  <p style="margin-top:8px;color:var(--muted)">You can now continue to the next challenge.</p>
</div>
HTML;
        } else {
            $sol = htmlspecialchars($fu['solution']);
            $exp = htmlspecialchars($fu['explanation']);
            echo <<<HTML
<div id="followup-result" class="alert alert-error" style="margin-top:8px">
  ✗ Not yet. The answer is <code>{$sol}</code>. {$exp}
</div>
HTML;
        }
    }

    public function sectionTest(string $lang, string $topicSlug): void
    {
        $topic      = Topic::findBySlug($lang, $topicSlug);
        if (!$topic) { http_response_code(404); echo '404'; return; }
        $challenges = Challenge::sectionTest($topic['id']);
        $title      = $topic['name'] . ' — Section Test';
        ob_start();
        require __DIR__ . '/../Views/section-test.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function sectionTestSubmit(string $lang, string $topicSlug): void
    {
        $topic      = Topic::findBySlug($lang, $topicSlug);
        if (!$topic) { http_response_code(404); return; }
        $challenges = Challenge::sectionTest($topic['id']);
        $token      = Auth::sessionToken();
        $userId     = Auth::user()['id'] ?? null;

        $passed = 0;
        $results = [];
        foreach ($challenges as $c) {
            $answer  = trim($_POST['answer_' . $c['id']] ?? '');
            $correct = Challenge::grade($c, $answer);
            if ($correct) $passed++;
            Progress::record($token, $c['id'], $correct, $userId);
            $results[] = ['challenge' => $c, 'answer' => $answer, 'correct' => $correct];
        }

        $score   = count($challenges) > 0 ? (int)round($passed / count($challenges) * 100) : 0;
        $mastered = $score >= 70;
        $title   = $topic['name'] . ' — Test Results';
        ob_start();
        require __DIR__ . '/../Views/section-results.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    private function renderFeedbackCorrect(array $c, string $lang, string $topicSlug, int $id, array $topic, string $token): string
    {
        $allForTopic = Challenge::forTopic($topic['id']);
        $ids = array_column($allForTopic, 'id');
        $pos = array_search($id, $ids);
        $nextId = $ids[$pos + 1] ?? null;

        $next = $nextId
            ? "<a href='/learn/{$lang}/{$topicSlug}/{$nextId}' class='btn btn-success'>→ Next Challenge</a>"
            : "<a href='/learn/{$lang}/{$topicSlug}' class='btn btn-success'>✅ Topic Complete</a>";

        $exp = htmlspecialchars($c['explanation']);
        return <<<HTML
<div class="alert alert-success">
  <strong>✅ Correct!</strong>
  <p style="margin-top:6px">{$exp}</p>
  <div style="margin-top:10px">{$next}</div>
</div>
HTML;
    }

    private function renderFeedbackWrong(array $c, array $followups, string $answer): string
    {
        $exp  = htmlspecialchars($c['explanation']);
        $sol  = htmlspecialchars($c['solution']);
        $answerEsc = htmlspecialchars($answer);
        $fu   = '';
        if (!empty($followups)) {
            $f   = $followups[0];
            $fId = (int)$f['id'];
            $fPrompt = htmlspecialchars($f['prompt']);
            $fu = <<<HTML
<div class="card" style="margin-top:16px">
  <h4 style="color:var(--warning);margin-bottom:8px">🔍 Quick Check — did you get it?</h4>
  <p style="margin-bottom:10px">{$fPrompt}</p>
  <form hx-post="/followup/{$fId}" hx-target="#followup-result" hx-swap="outerHTML">
    <input type="text" name="answer" placeholder="Your answer..." autocomplete="off" style="margin-bottom:8px">
    <button type="submit" class="btn btn-primary">Check →</button>
  </form>
  <div id="followup-result"></div>
</div>
HTML;
        }

        return <<<HTML
<div class="alert alert-error">
  <strong>✗ Not quite right</strong>
  <p style="margin-top:6px">Your answer: <code>{$answerEsc}</code></p>
</div>
<div class="alert alert-info">
  <strong>📖 Let's understand this</strong>
  <p style="margin-top:6px">{$exp}</p>
  <p style="margin-top:6px">Correct answer: <code>{$sol}</code></p>
</div>
{$fu}
HTML;
    }
}
