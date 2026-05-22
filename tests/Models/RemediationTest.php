<?php
namespace Tests\Models;

use App\Database;
use App\Models\Remediation;
use App\Models\Challenge;
use PHPUnit\Framework\TestCase;

class RemediationTest extends TestCase
{
    protected function setUp(): void
    {
        Database::reset();
        $db = Database::getInstance();
        $db->migrate();
        $db->exec("INSERT INTO languages (name,slug,icon,is_active) VALUES ('PHP','php','🐘',1)");
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order)
                   VALUES (1,'Variables','variables','',1)");
    }

    public function test_for_topic_returns_empty_when_no_challenges(): void
    {
        $result = Remediation::forTopic(1);
        $this->assertSame([], $result);
    }

    public function test_for_topic_returns_seeded_challenges(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO remediation_challenges
                   (topic_id,weakness_tag,prompt,type,solution,explanation)
                   VALUES (1,'types','What is 1+1?','fill_blank','2','Basic math')");
        $db->exec("INSERT INTO remediation_challenges
                   (topic_id,weakness_tag,prompt,type,solution,explanation)
                   VALUES (1,'casting','Cast it','fill_blank','(int)\$s','Cast info')");
        $result = Remediation::forTopic(1);
        $this->assertCount(2, $result);
        $this->assertSame('types', $result[0]['weakness_tag']);
    }

    public function test_for_topic_ignores_other_topics(): void
    {
        $db = Database::getInstance();
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order)
                   VALUES (1,'Operators','operators','',2)");
        $db->exec("INSERT INTO remediation_challenges
                   (topic_id,weakness_tag,prompt,type,solution,explanation)
                   VALUES (2,'modulo','What is 10%3?','fill_blank','1','Modulo info')");
        $result = Remediation::forTopic(1);
        $this->assertSame([], $result);
    }

    public function test_challenge_grade_works_with_remediation_shape(): void
    {
        $remChallenge = [
            'type'     => 'fill_blank',
            'solution' => '(int)$s',
        ];
        $this->assertTrue(Challenge::grade($remChallenge, '(int)$s'));
        $this->assertFalse(Challenge::grade($remChallenge, 'wrong'));
    }
}
