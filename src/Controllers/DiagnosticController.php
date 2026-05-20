<?php
namespace App\Controllers;

use App\Models\Challenge;
use App\Models\Progress;
use App\Models\Topic;
use App\Auth;

class DiagnosticController
{
    public function index(): void
    {
        $challenges = Challenge::diagnostic();
        $title = 'PHP Diagnostic Test';
        ob_start();
        require __DIR__ . '/../Views/diagnostic.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function submit(): void
    {
        $challenges = Challenge::diagnostic();
        $token      = Auth::sessionToken();
        $user       = Auth::user();
        $userId     = $user['id'] ?? null;

        foreach ($challenges as $c) {
            $answer = trim($_POST['answer_' . $c['id']] ?? '');
            $passed = Challenge::grade($c, $answer);
            Progress::record($token, $c['id'], $passed, $userId);
        }

        header('Location: /diagnostic/results');
        exit;
    }

    public function results(): void
    {
        $token  = Auth::sessionToken();
        $user   = Auth::user();
        $userId = $user['id'] ?? null;
        $topics = Topic::allForLanguage('php');

        $results = [];
        foreach ($topics as $t) {
            $score = Progress::topicScore($token, $t['id'], $userId);
            $results[] = [
                'topic'  => $t,
                'score'  => $score,
                'status' => $score >= 80 ? 'strong' : ($score >= 40 ? 'review' : 'weak'),
            ];
        }

        // Sort: weak first, then review, then strong
        usort($results, fn($a, $b) =>
            ['weak' => 0, 'review' => 1, 'strong' => 2][$a['status']] <=>
            ['weak' => 0, 'review' => 1, 'strong' => 2][$b['status']]
        );

        $title = 'Your Diagnostic Results';
        ob_start();
        require __DIR__ . '/../Views/diagnostic-results.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }
}
