<?php
namespace App\Controllers;

class HomeController
{
    public function index(): void
    {
        $title = 'Learn PHP for Free';
        ob_start();
        require __DIR__ . '/../Views/home.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }
}
