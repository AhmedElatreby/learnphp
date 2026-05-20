<?php
namespace App\Controllers;

use App\Models\Topic;
use App\Models\Challenge;
use App\Models\Progress;
use App\Models\Tip;
use App\Auth;

class TopicController
{
    public function index(string $lang): void
    {
        $topics = Topic::allForLanguage($lang);
        $token  = Auth::sessionToken();
        foreach ($topics as &$t) {
            $t['score'] = Progress::topicScore($token, $t['id'], Auth::user()['id'] ?? null);
        }
        $title = strtoupper($lang) . ' Topics';
        ob_start();
        require __DIR__ . '/../Views/topics.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function show(string $lang, string $topicSlug): void
    {
        $topic      = Topic::findBySlug($lang, $topicSlug);
        if (!$topic) { http_response_code(404); echo '404'; return; }
        $challenges = Challenge::forTopic($topic['id']);
        $token      = Auth::sessionToken();
        $completed  = Progress::completedIds($token);
        $tips       = Tip::forTopic($topic['id'], 'beginner');
        $title      = $topic['name'];
        ob_start();
        require __DIR__ . '/../Views/topic.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }
}
