<?php
namespace App\Models;

use App\Database;

class Progress
{
    public static function record(string $token, int $challengeId, bool $passed, ?int $userId): void
    {
        Database::getInstance()->query(
            'INSERT INTO user_progress (user_id, session_token, challenge_id, passed, attempts)
             VALUES (?, ?, ?, ?, 1)
             ON CONFLICT(session_token, challenge_id)
             DO UPDATE SET
               passed = excluded.passed,
               attempts = attempts + 1,
               completed_at = datetime("now"),
               user_id = COALESCE(excluded.user_id, user_id)',
            [$userId, $token, $challengeId, (int)$passed]
        );
    }

    public static function topicScore(string $token, int $topicId, ?int $userId): int
    {
        // Progress is always looked up by session_token (works for both guests and
        // registered users). $userId is accepted for API symmetry but not used in
        // the query — the session token is the authoritative key.
        $db = Database::getInstance();
        $total = (int)$db->query(
            'SELECT COUNT(*) FROM challenges WHERE topic_id = ?', [$topicId]
        )->fetchColumn();
        if ($total === 0) return 0;

        $passed = (int)$db->query(
            'SELECT COUNT(*) FROM user_progress
             WHERE session_token = ? AND passed = 1
             AND challenge_id IN (SELECT id FROM challenges WHERE topic_id = ?)',
            [$token, $topicId]
        )->fetchColumn();

        return (int)round(($passed / $total) * 100);
    }

    public static function completedIds(string $token): array
    {
        return array_column(
            Database::getInstance()->query(
                'SELECT challenge_id FROM user_progress WHERE session_token = ? AND passed = 1',
                [$token]
            )->fetchAll(),
            'challenge_id'
        );
    }
}
