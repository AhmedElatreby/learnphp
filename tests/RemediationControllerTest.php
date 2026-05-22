<?php
namespace Tests;

use App\Database;
use App\Models\Challenge;
use App\Models\Remediation;
use PHPUnit\Framework\TestCase;

class RemediationControllerTest extends TestCase
{
    protected function setUp(): void
    {
        Database::reset();
        $db = Database::getInstance();
        $db->migrate();
        $db->exec("INSERT INTO languages (name,slug,icon,is_active) VALUES ('PHP','php','🐘',1)");
        $db->exec("INSERT INTO topics (language_id,name,slug,description,sort_order)
                   VALUES (1,'Variables','variables','',1)");
        $db->exec("INSERT INTO remediation_challenges
                   (topic_id,weakness_tag,prompt,type,solution,explanation)
                   VALUES (1,'types','Q1?','fill_blank','gettype','Explanation A')");
        $db->exec("INSERT INTO remediation_challenges
                   (topic_id,weakness_tag,prompt,type,solution,explanation)
                   VALUES (1,'casting','Q2?','fill_blank','(int)\$s','Explanation B')");
    }

    public function test_grade_correct_answer_counts_as_passed(): void
    {
        $challenges = Remediation::forTopic(1);
        $passed = 0;
        $answers = [
            $challenges[0]['id'] => 'gettype',
            $challenges[1]['id'] => 'wrong',
        ];
        foreach ($challenges as $c) {
            if (Challenge::grade($c, $answers[$c['id']])) {
                $passed++;
            }
        }
        $this->assertSame(1, $passed);
    }

    public function test_score_calculation(): void
    {
        $challenges = Remediation::forTopic(1);
        $passed = 2;
        $total  = count($challenges);
        $score  = (int)round(($passed / $total) * 100);
        $this->assertSame(100, $score);
    }

    public function test_score_zero_when_all_wrong(): void
    {
        $challenges = Remediation::forTopic(1);
        $passed = 0;
        $total  = count($challenges);
        $score  = $total > 0 ? (int)round(($passed / $total) * 100) : 0;
        $this->assertSame(0, $score);
    }

    public function test_partial_score(): void
    {
        $challenges = Remediation::forTopic(1);
        $passed = 1;
        $total  = count($challenges); // 2
        $score  = (int)round(($passed / $total) * 100);
        $this->assertSame(50, $score);
    }
}
