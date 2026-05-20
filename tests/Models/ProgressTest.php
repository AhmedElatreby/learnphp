<?php
namespace Tests\Models;

use App\Database;
use App\Models\Progress;
use PHPUnit\Framework\TestCase;

class ProgressTest extends TestCase
{
    protected function setUp(): void
    {
        Database::reset();
        $db = Database::getInstance();
        $db->migrate();
        $db->exec("INSERT INTO languages (name,slug,icon,is_active) VALUES ('PHP','php','🐘',1)");
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order) VALUES (1,'Arrays','arrays','',1)");
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
                   VALUES (1,'C1','Q1','fill_blank','beginner','a','e')");
    }

    public function test_record_creates_progress_row(): void
    {
        Progress::record('token123', 1, true, null);
        $row = Database::getInstance()
            ->query('SELECT * FROM user_progress WHERE session_token = ?', ['token123'])
            ->fetch();
        $this->assertSame(1, (int)$row['passed']);
    }

    public function test_record_updates_attempts_on_duplicate(): void
    {
        Progress::record('token123', 1, false, null);
        Progress::record('token123', 1, true, null);
        $row = Database::getInstance()
            ->query('SELECT * FROM user_progress WHERE session_token = ?', ['token123'])
            ->fetch();
        $this->assertSame(2, (int)$row['attempts']);
        $this->assertSame(1, (int)$row['passed']);
    }

    public function test_topic_score_returns_percentage(): void
    {
        Progress::record('tok', 1, true, null);
        $score = Progress::topicScore('tok', 1, null);
        $this->assertSame(100, $score);
    }

    public function test_topic_score_returns_partial_percentage(): void
    {
        // Add second challenge to topic
        Database::getInstance()->exec(
            "INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
             VALUES (1,'C2','Q2','fill_blank','beginner','b','e')"
        );
        Progress::record('tok', 1, true, null);
        // challenge_id 2 not attempted
        $score = Progress::topicScore('tok', 1, null);
        $this->assertSame(50, $score);
    }
}
