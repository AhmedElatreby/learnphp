<?php
namespace App\Controllers;

use App\Models\Topic;
use App\Models\Progress;
use App\Auth;

class DashboardController
{
    public function index(): void
    {
        $user = Auth::user();
        if (!$user) {
            header('Location: /login');
            exit;
        }

        $token  = Auth::sessionToken();
        $topics = Topic::allForLanguage('php');
        $userId = $user['id'];

        $topicData = [];
        foreach ($topics as $t) {
            $score = Progress::topicScore($token, $t['id'], $userId);
            $topicData[] = ['topic' => $t, 'score' => $score];
        }

        $completed  = count(array_filter($topicData, fn($td) => $td['score'] >= 70));
        $inProgress = count(array_filter($topicData, fn($td) => $td['score'] > 0 && $td['score'] < 70));

        // Find last active topic (in progress but not complete)
        $lastTopic = null;
        foreach (array_reverse($topicData) as $td) {
            if ($td['score'] > 0 && $td['score'] < 100) {
                $lastTopic = $td['topic'];
                break;
            }
        }

        $title = 'Dashboard';
        ob_start();
        require __DIR__ . '/../Views/dashboard.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }
}
