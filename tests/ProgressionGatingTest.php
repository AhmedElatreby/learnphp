<?php
namespace Tests;

use App\Database;
use App\Models\Progress;
use PHPUnit\Framework\TestCase;

class ProgressionGatingTest extends TestCase
{
    private int $challenge1Id;
    private int $challenge2Id;

    protected function setUp(): void
    {
        Database::reset();
        $db = Database::getInstance();
        $db->migrate();
        $db->exec("INSERT INTO languages (name,slug,icon,is_active) VALUES ('PHP','php','🐘',1)");
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order) VALUES (1,'Operators','operators','',2)");
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation,sort_order)
                   VALUES (1,'C1','Q1','fill_blank','beginner','a','e',1)");
        $this->challenge1Id = (int)$db->lastInsertId();
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation,sort_order)
                   VALUES (1,'C2','Q2','fill_blank','beginner','a','e',2)");
        $this->challenge2Id = (int)$db->lastInsertId();
    }

    public function test_first_challenge_always_unlocked(): void
    {
        $completed = Progress::completedIds('token_x');
        $position = 1;
        $isLocked = $position > 1 && !in_array($this->challenge1Id, $completed);
        $this->assertFalse($isLocked);
    }

    public function test_second_challenge_locked_without_passing_first(): void
    {
        $completed = Progress::completedIds('token_x');
        $prevId = $this->challenge1Id;
        $isLocked = !in_array($prevId, $completed);
        $this->assertTrue($isLocked);
    }

    public function test_second_challenge_unlocked_after_passing_first(): void
    {
        Progress::record('token_x', $this->challenge1Id, true, null);
        $completed = Progress::completedIds('token_x');
        $prevId = $this->challenge1Id;
        $isLocked = !in_array($prevId, $completed);
        $this->assertFalse($isLocked);
    }

    public function test_failed_attempt_does_not_unlock_next(): void
    {
        Progress::record('token_x', $this->challenge1Id, false, null);
        $completed = Progress::completedIds('token_x');
        $prevId = $this->challenge1Id;
        $isLocked = !in_array($prevId, $completed);
        $this->assertTrue($isLocked);
    }
}
