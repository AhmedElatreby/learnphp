<?php
namespace Tests;

use App\Router;
use PHPUnit\Framework\TestCase;

class RouterTest extends TestCase
{
    public function test_matches_exact_route(): void
    {
        $router = new Router();
        $router->get('/', fn() => 'home');
        $result = $router->resolve('GET', '/');
        $this->assertSame('home', $result);
    }

    public function test_matches_parameterised_route(): void
    {
        $router = new Router();
        $router->get('/learn/{lang}/{topic}', fn($lang, $topic) => "$lang:$topic");
        $result = $router->resolve('GET', '/learn/php/arrays');
        $this->assertSame('php:arrays', $result);
    }

    public function test_returns_null_for_unknown_route(): void
    {
        $router = new Router();
        $result = $router->resolve('GET', '/not-found');
        $this->assertNull($result);
    }

    public function test_test_route_matches_before_id_catchall(): void
    {
        $router = new Router();
        $router->get('/learn/{lang}/{topic}/test', fn($lang, $topic) => "test:$lang:$topic");
        $router->get('/learn/{lang}/{topic}/{id}', fn($lang, $topic, $id) => "challenge:$id");
        $result = $router->resolve('GET', '/learn/php/arrays/test');
        $this->assertSame('test:php:arrays', $result);
    }
}
