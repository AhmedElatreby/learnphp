<?php
namespace App;

class Database
{
    private static ?Database $instance = null;
    private \PDO $pdo;

    private function __construct()
    {
        $path = $_ENV['DB_PATH'] ?? 'database/app.sqlite';
        $dsn  = $path === ':memory:' ? 'sqlite::memory:' : 'sqlite:' . __DIR__ . '/../' . $path;

        $this->pdo = new \PDO($dsn);
        $this->pdo->setAttribute(\PDO::ATTR_DEFAULT_FETCH_MODE, \PDO::FETCH_ASSOC);
        $this->pdo->setAttribute(\PDO::ATTR_ERRMODE, \PDO::ERRMODE_EXCEPTION);
        $this->pdo->exec('PRAGMA foreign_keys = ON');
    }

    public static function getInstance(): self
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getPdo(): \PDO
    {
        return $this->pdo;
    }

    public function query(string $sql, array $params = []): \PDOStatement
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    }

    public function exec(string $sql): void
    {
        $this->pdo->exec($sql);
    }

    public function lastInsertId(): string
    {
        return $this->pdo->lastInsertId();
    }

    /** Run schema.sql to initialise the database */
    public function migrate(): void
    {
        $schema = file_get_contents(__DIR__ . '/../database/schema.sql');
        $this->pdo->exec($schema);
    }

    /** Reset singleton — test use only */
    public static function reset(): void
    {
        self::$instance = null;
    }
}
