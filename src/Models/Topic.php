<?php
namespace App\Models;

use App\Database;

class Topic
{
    public static function allForLanguage(string $langSlug): array
    {
        return Database::getInstance()->query(
            'SELECT t.* FROM topics t
             JOIN languages l ON l.id = t.language_id
             WHERE l.slug = ? ORDER BY t.sort_order',
            [$langSlug]
        )->fetchAll();
    }

    public static function findBySlug(string $langSlug, string $topicSlug): ?array
    {
        $row = Database::getInstance()->query(
            'SELECT t.* FROM topics t
             JOIN languages l ON l.id = t.language_id
             WHERE l.slug = ? AND t.slug = ?',
            [$langSlug, $topicSlug]
        )->fetch();
        return $row ?: null;
    }
}
