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
            "SELECT * FROM challenges WHERE topic_id = ? ORDER BY
             CASE difficulty WHEN 'beginner' THEN 1 WHEN 'intermediate' THEN 2 ELSE 3 END,
             sort_order",
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
        if ($challenge['type'] === 'write_code') {
            // write_code: compare trimmed stdout exactly (case-sensitive)
            return trim($challenge['solution']) === trim($answer);
        }
        // fill_blank and spot_bug: normalise for PHP style variations
        return self::normalise($challenge['solution']) === self::normalise($answer);
    }

    private static function normalise(string $s): string
    {
        $s = trim($s);
        $s = str_replace('"', "'", $s);
        $s = rtrim($s, ';');
        $s = strtolower($s);
        return $s;
    }

    public static function all(): array
    {
        return Database::getInstance()->query(
            'SELECT c.*, t.name AS topic_name, l.name AS language_name
             FROM challenges c
             JOIN topics t ON t.id = c.topic_id
             JOIN languages l ON l.id = t.language_id
             ORDER BY l.name, t.sort_order, c.sort_order, c.id'
        )->fetchAll();
    }

    public static function update(int $id, array $data): void
    {
        Database::getInstance()->query(
            'UPDATE challenges SET
                topic_id=?, title=?, prompt=?, type=?, difficulty=?,
                starter_code=?, solution=?, hint=?, explanation=?,
                is_diagnostic=?, sort_order=?
             WHERE id=?',
            [
                (int)$data['topic_id'], $data['title'], $data['prompt'],
                $data['type'], $data['difficulty'], $data['starter_code'] ?? '',
                $data['solution'], $data['hint'] ?? '', $data['explanation'],
                (int)($data['is_diagnostic'] ?? 0), (int)($data['sort_order'] ?? 0),
                $id,
            ]
        );
    }

    public static function delete(int $id): void
    {
        $db = Database::getInstance();
        $db->beginTransaction();
        try {
            $db->query('DELETE FROM followup_challenges WHERE challenge_id = ?', [$id]);
            $db->query('DELETE FROM section_tests WHERE challenge_id = ?', [$id]);
            $db->query('DELETE FROM user_progress WHERE challenge_id = ?', [$id]);
            $db->query('DELETE FROM challenges WHERE id = ?', [$id]);
            $db->commit();
        } catch (\Throwable $e) {
            $db->rollback();
            throw $e;
        }
    }
}
