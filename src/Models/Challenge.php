<?php
namespace App\Models;

use App\Database;

class Challenge
{
    public static function find(int $id): ?array
    {
        $row = Database::getInstance()
            ->query('SELECT * FROM challenges WHERE id = ?', [$id])
            ->fetch();
        return $row ?: null;
    }

    public static function forTopic(int $topicId): array
    {
        return Database::getInstance()->query(
            'SELECT * FROM challenges WHERE topic_id = ? ORDER BY
             CASE difficulty WHEN "beginner" THEN 1 WHEN "intermediate" THEN 2 ELSE 3 END,
             sort_order',
            [$topicId]
        )->fetchAll();
    }

    public static function diagnostic(): array
    {
        return Database::getInstance()->query(
            'SELECT c.*, t.slug AS topic_slug, t.name AS topic_name
             FROM challenges c JOIN topics t ON t.id = c.topic_id
             WHERE c.is_diagnostic = 1 ORDER BY RANDOM() LIMIT 15'
        )->fetchAll();
    }

    public static function followups(int $challengeId): array
    {
        return Database::getInstance()->query(
            'SELECT * FROM followup_challenges WHERE challenge_id = ?',
            [$challengeId]
        )->fetchAll();
    }

    public static function sectionTest(int $topicId): array
    {
        return Database::getInstance()->query(
            'SELECT c.* FROM challenges c
             JOIN section_tests st ON st.challenge_id = c.id
             WHERE st.topic_id = ? ORDER BY st.sort_order',
            [$topicId]
        )->fetchAll();
    }

    /**
     * Grade a challenge answer.
     * For fill_blank and spot_bug: normalise and compare strings.
     * For write_code: caller passes actual stdout as $answer, solution is expected stdout.
     */
    public static function grade(array $challenge, string $answer): bool
    {
        $solution = self::normalise($challenge['solution']);
        $answer   = self::normalise($answer);
        return $solution === $answer;
    }

    private static function normalise(string $s): string
    {
        $s = trim($s);
        $s = str_replace('"', "'", $s);
        $s = rtrim($s, ';');
        $s = strtolower($s);
        return $s;
    }
}
