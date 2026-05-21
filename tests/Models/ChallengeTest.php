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

    public function test_grade_strips_trailing_semicolon(): void
    {
        $this->assertTrue(Challenge::grade(['type' => 'fill_blank', 'solution' => '$i++'], '$i++;'));
    }

    public function test_grade_normalises_quotes(): void
    {
        $this->assertTrue(Challenge::grade(['type' => 'fill_blank', 'solution' => "['a']"], '["a"]'));
    }

    public function test_grade_write_code_is_case_sensitive(): void
    {
        $this->assertFalse(Challenge::grade(['type' => 'write_code', 'solution' => 'Hello World'], 'hello world'));
    }

    public function test_for_topic_orders_beginner_before_advanced(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation,sort_order)
                   VALUES (1,'Adv','Q','fill_blank','advanced','a','e',1),
                          (1,'Beg','Q','fill_blank','beginner','a','e',2)");
        $list = Challenge::forTopic(1);
        $this->assertSame('beginner', $list[0]['difficulty']);
        $this->assertSame('advanced', $list[count($list)-1]['difficulty']);
    }

    public function test_all_returns_challenges_with_topic_and_language(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
                   VALUES (1,'My Challenge','Q?','fill_blank','beginner','a','e')");
        $all = Challenge::all();
        $this->assertNotEmpty($all);
        $this->assertArrayHasKey('topic_name', $all[0]);
        $this->assertArrayHasKey('language_name', $all[0]);
        $this->assertSame('Arrays', $all[0]['topic_name']);
        $this->assertSame('PHP', $all[0]['language_name']);
    }

    public function test_update_persists_changes(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
                   VALUES (1,'Old Title','Q?','fill_blank','beginner','a','e')");
        $id = (int)$db->lastInsertId();
        Challenge::update($id, [
            'title' => 'New Title', 'prompt' => 'Q?', 'type' => 'fill_blank',
            'difficulty' => 'intermediate', 'solution' => 'a', 'explanation' => 'e',
            'topic_id' => 1, 'starter_code' => '', 'hint' => '',
            'is_diagnostic' => 0, 'sort_order' => 0,
        ]);
        $c = Challenge::find($id);
        $this->assertSame('New Title', $c['title']);
        $this->assertSame('intermediate', $c['difficulty']);
    }

    public function test_delete_removes_challenge_and_followups(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO challenges (topic_id,title,prompt,type,difficulty,solution,explanation)
                   VALUES (1,'Del Me','Q?','fill_blank','beginner','a','e')");
        $id = (int)$db->lastInsertId();
        $db->exec("INSERT INTO followup_challenges (challenge_id,prompt,type,solution,explanation)
                   VALUES ({$id},'FQ?','fill_blank','a','e')");
        Challenge::delete($id);
        $this->assertNull(Challenge::find($id));
        $fu = $db->query('SELECT * FROM followup_challenges WHERE challenge_id = ?', [$id])->fetchAll();
        $this->assertEmpty($fu);
    }
}
