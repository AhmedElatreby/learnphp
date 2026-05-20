<?php
namespace App\Models;

use App\Database;

class Tip
{
    public static function forTopic(int $topicId, string $difficulty): array
    {
        return Database::getInstance()->query(
            'SELECT * FROM tips WHERE topic_id = ? AND (difficulty = ? OR difficulty = \'all\') LIMIT 3',
            [$topicId, $difficulty]
        )->fetchAll();
    }
}
