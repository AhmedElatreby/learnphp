<?php
namespace App\Models;

use App\Database;

class Remediation
{
    public static function forTopic(int $topicId): array
    {
        return Database::getInstance()->query(
            'SELECT * FROM remediation_challenges WHERE topic_id = ? ORDER BY id',
            [$topicId]
        )->fetchAll();
    }
}
