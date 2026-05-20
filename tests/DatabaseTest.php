<?php
namespace Tests;

use App\Database;
use PHPUnit\Framework\TestCase;

class DatabaseTest extends TestCase
{
    public function test_can_get_instance(): void
    {
        $db = Database::getInstance();
        $this->assertInstanceOf(\PDO::class, $db->getPdo());
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
