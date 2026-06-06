<?php
namespace App\Controllers;

use App\Auth;

class AuthController
{
    public function loginForm(): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $title = 'Login';
        $error = $_SESSION['auth_error'] ?? null;
        unset($_SESSION['auth_error']);
        ob_start();
        require __DIR__ . '/../Views/login.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function login(): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        Auth::verifyCsrf();
        $email    = trim($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';
        $user     = Auth::attempt($email, $password);

        if (!$user) {
            $_SESSION['auth_error'] = 'Invalid email or password.';
            header('Location: /login');
            exit;
        }

        $token = Auth::sessionToken();
        Auth::login($user);
        Auth::claimGuestProgress($token, $user['id']);
        header('Location: /dashboard');
        exit;
    }

    public function registerForm(): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $title = 'Create Account';
        $error = $_SESSION['auth_error'] ?? null;
        unset($_SESSION['auth_error']);
        ob_start();
        require __DIR__ . '/../Views/register.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function register(): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        Auth::verifyCsrf();
        $username = trim($_POST['username'] ?? '');
        $email    = trim($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';

        if (strlen($username) < 2 || strlen($password) < 6) {
            $_SESSION['auth_error'] = 'Username must be 2+ chars, password 6+ chars.';
            header('Location: /register');
            exit;
        }

        try {
            $token  = Auth::sessionToken();
            $userId = Auth::register($username, $email, $password);
            $user   = ['id' => $userId, 'username' => $username];
            Auth::login($user);
            Auth::claimGuestProgress($token, $userId);
            header('Location: /dashboard');
            exit;
        } catch (\PDOException $e) {
            $_SESSION['auth_error'] = 'Email or username already taken.';
            header('Location: /register');
            exit;
        }
    }

    public function logout(): void
    {
        Auth::logout();
        header('Location: /');
        exit;
    }
}
