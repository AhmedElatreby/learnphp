<?php
namespace App\Controllers;

use App\Auth;
use App\Database;
use App\Models\Challenge;

class AdminController
{
    private const TYPES        = ['fill_blank', 'write_code', 'spot_bug'];
    private const DIFFICULTIES = ['beginner', 'intermediate', 'advanced'];

    public function index(): void
    {
        $this->guard();
        $challenges = Challenge::all();
        $grouped = [];
        foreach ($challenges as $c) {
            $grouped[$c['language_name']][$c['topic_name']][] = $c;
        }
        $flash = $this->popFlash();
        $title = 'Admin — Challenges';
        ob_start();
        require __DIR__ . '/../Views/admin-challenges.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function create(): void
    {
        $this->guard();
        $topics = $this->allTopics();
        $old    = $this->popOld();
        $errors = $this->popErrors();
        $title  = 'Admin — Add Challenge';
        ob_start();
        require __DIR__ . '/../Views/admin-challenge-form.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function store(): void
    {
        $this->guard();
        $data   = $this->inputFromPost();
        $errors = $this->validate($data);

        if ($errors) {
            $this->flashErrors($errors);
            $this->flashOld($data);
            header('Location: /admin/challenges/new');
            exit;
        }

        $db = Database::getInstance();
        $db->query(
            'INSERT INTO challenges
             (topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order)
             VALUES (?,?,?,?,?,?,?,?,?,?,?)',
            [
                (int)$data['topic_id'], $data['title'], $data['prompt'],
                $data['type'], $data['difficulty'], $data['starter_code'],
                $data['solution'], $data['hint'], $data['explanation'],
                (int)$data['is_diagnostic'], (int)$data['sort_order'],
            ]
        );
        $this->flashSuccess('Challenge created.');
        header('Location: /admin/challenges');
        exit;
    }

    public function edit(string $id): void
    {
        $this->guard();
        $challenge = Challenge::find((int)$id);
        if (!$challenge) { http_response_code(404); echo '404'; return; }
        $topics = $this->allTopics();
        $old    = $this->popOld() ?: $challenge;
        $errors = $this->popErrors();
        $title  = 'Admin — Edit Challenge';
        ob_start();
        require __DIR__ . '/../Views/admin-challenge-form.php';
        $content = ob_get_clean();
        require __DIR__ . '/../Views/layout.php';
    }

    public function update(string $id): void
    {
        $this->guard();
        $challenge = Challenge::find((int)$id);
        if (!$challenge) { http_response_code(404); return; }

        $data   = $this->inputFromPost();
        $errors = $this->validate($data);

        if ($errors) {
            $this->flashErrors($errors);
            $this->flashOld($data);
            header('Location: /admin/challenges/' . (int)$id . '/edit');
            exit;
        }

        Challenge::update((int)$id, $data);
        $this->flashSuccess('Challenge updated.');
        header('Location: /admin/challenges');
        exit;
    }

    public function destroy(string $id): void
    {
        $this->guard();
        Challenge::delete((int)$id);
        $this->flashSuccess('Challenge deleted.');
        header('Location: /admin/challenges');
        exit;
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private function guard(): void
    {
        try {
            Auth::requireAdmin();
        } catch (\RuntimeException $e) {
            http_response_code(403);
            echo '<h1>403 Forbidden</h1>';
            exit;
        }
    }

    private function allTopics(): array
    {
        return Database::getInstance()->query(
            'SELECT t.*, l.name AS language_name FROM topics t
             JOIN languages l ON l.id = t.language_id
             ORDER BY l.name, t.sort_order'
        )->fetchAll();
    }

    private function inputFromPost(): array
    {
        return [
            'topic_id'      => trim($_POST['topic_id'] ?? ''),
            'title'         => trim($_POST['title'] ?? ''),
            'prompt'        => trim($_POST['prompt'] ?? ''),
            'type'          => trim($_POST['type'] ?? ''),
            'difficulty'    => trim($_POST['difficulty'] ?? ''),
            'starter_code'  => $_POST['starter_code'] ?? '',
            'solution'      => trim($_POST['solution'] ?? ''),
            'hint'          => trim($_POST['hint'] ?? ''),
            'explanation'   => trim($_POST['explanation'] ?? ''),
            'is_diagnostic' => (int)($_POST['is_diagnostic'] ?? 0),
            'sort_order'    => (int)($_POST['sort_order'] ?? 0),
        ];
    }

    private function validate(array $data): array
    {
        $errors = [];
        if (empty($data['topic_id']) || !is_numeric($data['topic_id'])) $errors[] = 'Topic is required.';
        if (empty($data['title']))       $errors[] = 'Title is required.';
        if (empty($data['prompt']))      $errors[] = 'Prompt is required.';
        if (!in_array($data['type'], self::TYPES, true))              $errors[] = 'Invalid type.';
        if (!in_array($data['difficulty'], self::DIFFICULTIES, true)) $errors[] = 'Invalid difficulty.';
        if (empty($data['solution']))    $errors[] = 'Solution is required.';
        if (empty($data['explanation'])) $errors[] = 'Explanation is required.';
        return $errors;
    }

    private function flashSuccess(string $msg): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $_SESSION['admin_flash'] = ['type' => 'success', 'msg' => $msg];
    }

    private function popFlash(): ?array
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $f = $_SESSION['admin_flash'] ?? null;
        unset($_SESSION['admin_flash']);
        return $f;
    }

    private function flashErrors(array $errors): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $_SESSION['admin_errors'] = $errors;
    }

    private function flashOld(array $data): void
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $_SESSION['admin_old'] = $data;
    }

    private function popErrors(): array
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $e = $_SESSION['admin_errors'] ?? [];
        unset($_SESSION['admin_errors']);
        return $e;
    }

    private function popOld(): array
    {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $o = $_SESSION['admin_old'] ?? [];
        unset($_SESSION['admin_old']);
        return $o;
    }
}
