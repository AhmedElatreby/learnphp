<?php
namespace Tests;

use App\Database;
use PHPUnit\Framework\TestCase;

class DatabaseTest extends TestCase
{
    protected function setUp(): void
    {
        Database::reset();
    }

    protected function tearDown(): void
    {
        Database::reset();
    }

    public function test_can_get_instance(): void
    {
        $db = Database::getInstance();
        // A live connection can execute SQL — if this doesn't throw, the connection is good
        $db->exec('SELECT 1');
        $this->assertTrue(true);
    }

    public function test_migrate_creates_tables(): void
    {
        $db = Database::getInstance();
        $db->migrate();
        $tables = $db->query(
            "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
        )->fetchAll(\PDO::FETCH_COLUMN);
        $expected = ['challenges','followup_challenges','languages','remediation_challenges',
                     'section_tests','tips','topics','user_progress','users'];
        foreach ($expected as $table) {
            $this->assertContains($table, $tables, "Table '$table' not found after migrate()");
        }
    }

    public function test_last_insert_id(): void
    {
        $db = Database::getInstance();
        $db->migrate();
        $db->query('INSERT INTO languages (name, slug, icon, is_active) VALUES (?, ?, ?, ?)',
                   ['PHP', 'php', '🐘', 1]);
        $this->assertSame('1', $db->lastInsertId());
    }

    public function test_query_returns_results(): void
    {
        $db = Database::getInstance();
        $db->exec('CREATE TABLE IF NOT EXISTS test_tbl (id INTEGER PRIMARY KEY, name TEXT)');
        $db->exec("INSERT INTO test_tbl (name) VALUES ('hello')");
        $rows = $db->query('SELECT * FROM test_tbl')->fetchAll();
        $this->assertCount(1, $rows);
        $this->assertSame('hello', $rows[0]['name']);
    }
}
