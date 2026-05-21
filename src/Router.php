<?php
namespace App;

class Router
{
    private array $routes = [];

    public function get(string $pattern, callable $handler): void
    {
        $this->routes['GET'][$pattern] = $handler;
    }

    public function post(string $pattern, callable $handler): void
    {
        $this->routes['POST'][$pattern] = $handler;
    }

    public function resolve(string $method, string $uri): mixed
    {
        $routes = $this->routes[$method] ?? [];
        foreach ($routes as $pattern => $handler) {
            $regex = preg_replace('/\{(\w+)\}/', '(?P<$1>[^/]+)', $pattern);
            $regex = '#^' . $regex . '$#';
            if (preg_match($regex, $uri, $matches)) {
                $params = array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);
                return $handler(...array_values($params));
            }
        }
        return null;
    }

    public function dispatch(): void
    {
        $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
        $uri    = strtok($_SERVER['REQUEST_URI'] ?? '/', '?') ?: '/';

        // Register all routes
        $this->registerRoutes();

        $result = $this->resolve($method, $uri);

        if ($result === null) {
            http_response_code(404);
            echo '<h1>404 Not Found</h1>';
            return;
        }
    }

    private function registerRoutes(): void
    {
        $this->get('/',                              [new \App\Controllers\HomeController, 'index']);
        $this->get('/learn/{lang}',                  [new \App\Controllers\TopicController, 'index']);
        $this->get('/learn/{lang}/{topic}',          [new \App\Controllers\TopicController, 'show']);
        // Specific literal BEFORE parameterised catch-all:
        $this->get('/learn/{lang}/{topic}/test',     [new \App\Controllers\ChallengeController, 'sectionTest']);
        $this->post('/learn/{lang}/{topic}/test',    [new \App\Controllers\ChallengeController, 'sectionTestSubmit']);
        $this->get('/learn/{lang}/{topic}/{id}',     [new \App\Controllers\ChallengeController, 'show']);
        $this->post('/learn/{lang}/{topic}/{id}',    [new \App\Controllers\ChallengeController, 'submit']);
        $this->get('/diagnostic',                    [new \App\Controllers\DiagnosticController, 'index']);
        $this->post('/diagnostic',                   [new \App\Controllers\DiagnosticController, 'submit']);
        $this->get('/diagnostic/results',            [new \App\Controllers\DiagnosticController, 'results']);
        $this->get('/dashboard',                     [new \App\Controllers\DashboardController, 'index']);
        $this->get('/login',                         [new \App\Controllers\AuthController, 'loginForm']);
        $this->post('/login',                        [new \App\Controllers\AuthController, 'login']);
        $this->get('/register',                      [new \App\Controllers\AuthController, 'registerForm']);
        $this->post('/register',                     [new \App\Controllers\AuthController, 'register']);
        $this->get('/logout',                        [new \App\Controllers\AuthController, 'logout']);
        $this->get('/admin/challenges',              [new \App\Controllers\AdminController, 'index']);
        $this->get('/admin/challenges/new',          [new \App\Controllers\AdminController, 'create']);
        $this->post('/admin/challenges',             [new \App\Controllers\AdminController, 'store']);
        $this->get('/admin/challenges/{id}/edit',    [new \App\Controllers\AdminController, 'edit']);
        $this->post('/admin/challenges/{id}',        [new \App\Controllers\AdminController, 'update']);
        $this->post('/admin/challenges/{id}/delete', [new \App\Controllers\AdminController, 'destroy']);
        $this->post('/followup/{id}',                [new \App\Controllers\ChallengeController, 'submitFollowup']);
    }
}
