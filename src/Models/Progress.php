<?php
namespace App\Models;

use App\Database;

class Progress
{
    public static function record(string $token, int $challengeId, bool $passed, ?int $userId): void
    {
        $db = Database::getInstance();
        $existing = $db->query(
            'SELECT id, attempts FROM user_progress WHERE session_token = ? AND challenge_id = ?',
            [$token, $challengeId]
        )->fetch();

        if ($existing) {
            $db->query(
                'UPDATE user_progress SET passed = ?, attempts = ?, completed_at = datetime("now"), user_id = ?
                 WHERE session_token = ? AND challenge_id = ?',
                [(int)$passed, $existing['attempts'] + 1, $userId, $token, $challengeId]
            );
        } else {
            $db->query(
                'INSERT INTO user_progress (user_id, session_token, challenge_id, passed, attempts)
                 VALUES (?, ?, ?, ?, 1)',
                [$userId, $token, $challengeId, (int)$passed]
            );
        }
    }

    public static function topicScore(string $token, int $topicId, ?int $userId): int
    {
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
