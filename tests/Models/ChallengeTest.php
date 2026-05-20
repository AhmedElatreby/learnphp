<?php
namespace Tests\Models;

use App\Database;
use App\Models\Challenge;
use App\Models\Topic;
use PHPUnit\Framework\TestCase;

class ChallengeTest extends TestCase
{
    protected function setUp(): void
    {
        Database::reset();
        $db = Database::getInstance();
        $db->migrate();
        $db->exec("INSERT INTO languages (name,slug,icon,is_active) VALUES ('PHP','php','🐘',1)");
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order) VALUES (1,'Arrays','arrays','Learn arrays',1)");
    }

    public function test_find_returns_challenge(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
                   VALUES (1,'Test','What is 1+1?','fill_blank','beginner','2','Because math')");
        $c = Challenge::find(1);
        $this->assertSame('Test', $c['title']);
    }

    public function test_for_topic_returns_list(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
                   VALUES (1,'C1','Q1','fill_blank','beginner','a','e'),
                          (1,'C2','Q2','spot_bug','intermediate','b','e')");
        $list = Challenge::forTopic(1);
        $this->assertCount(2, $list);
    }

    public function test_grade_fill_blank_correct(): void
    {
        $this->assertTrue(Challenge::grade(['type' => 'fill_blank', 'solution' => '["a","b"]'], '["a","b"]'));
    }

    public function test_grade_fill_blank_wrong(): void
    {
        $this->assertFalse(Challenge::grade(['type' => 'fill_blank', 'solution' => '["a","b"]'], '["x"]'));
    }

    public function test_grade_normalises_whitespace(): void
    {
        $this->assertTrue(Challenge::grade(['type' => 'fill_blank', 'solution' => '$i++'], '  $i++  '));
    }
}
