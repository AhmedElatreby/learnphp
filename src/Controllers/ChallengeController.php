<?php
namespace App\Controllers;

class ChallengeController
{
    public function show(string $lang, string $topic, string $id): void
    {
        echo '<p>ChallengeController::show — coming soon</p>';
    }

    public function submit(string $lang, string $topic, string $id): void
    {
        echo '<p>ChallengeController::submit — coming soon</p>';
    }

    public function sectionTest(string $lang, string $topic): void
    {
        echo '<p>ChallengeController::sectionTest — coming soon</p>';
    }

    public function sectionTestSubmit(string $lang, string $topic): void
    {
        echo '<p>ChallengeController::sectionTestSubmit — coming soon</p>';
    }

    public function submitFollowup(string $id): void
    {
        echo '<p>ChallengeController::submitFollowup — coming soon</p>';
    }
}
