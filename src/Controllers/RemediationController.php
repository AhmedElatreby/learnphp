<?php
namespace App\Controllers;

use App\Models\Topic;
use App\Models\Remediation;
use App\Models\Challenge;

class RemediationController
{
    public function show(string $topicSlug): void
    {
        $topic      = Topic::findBySlug('php', $topicSlug);
        if (!$topic) { http_response_code(404); echo '404'; return; }

        $challenges = Remediation::forTopic($topic['id']);
        if (empty($challenges)) { http_response_code(404); echo '404'; return; }

        $title = 'Remediation: ' . $topic['name'];
        ob_start();
        require __DIR__ . '/../Views/remediation.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function submit(string $topicSlug): void
    {
        $topic      = Topic::findBySlug('php', $topicSlug);
        if (!$topic) { http_response_code(404); return; }

        $challenges = Remediation::forTopic($topic['id']);
        if (empty($challenges)) { http_response_code(404); return; }

        $passed  = 0;
        $results = [];
        foreach ($challenges as $c) {
            $answer  = trim($_POST['answer_' . $c['id']] ?? '');
            $correct = Challenge::grade($c, $answer);
            if ($correct) $passed++;
            $results[] = ['challenge' => $c, 'answer' => $answer, 'correct' => $correct];
        }

        $score = count($challenges) > 0
            ? (int)round($passed / count($challenges) * 100)
            : 0;

        $title = $topic['name'] . ' — Remediation Results';
        ob_start();
        require __DIR__ . '/../Views/remediation-results.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }
}
