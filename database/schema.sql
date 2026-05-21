PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS languages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    icon TEXT NOT NULL DEFAULT '📄',
    is_active INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    is_admin INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS topics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    language_id INTEGER NOT NULL REFERENCES languages(id),
    name TEXT NOT NULL,
    slug TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    sort_order INTEGER NOT NULL DEFAULT 0,
    UNIQUE(language_id, slug)
);

CREATE TABLE IF NOT EXISTS challenges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    title TEXT NOT NULL,
    prompt TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('fill_blank','write_code','spot_bug')),
    difficulty TEXT NOT NULL CHECK(difficulty IN ('beginner','intermediate','advanced')),
    starter_code TEXT NOT NULL DEFAULT '',
    solution TEXT NOT NULL,
    hint TEXT NOT NULL DEFAULT '',
    explanation TEXT NOT NULL,
    is_diagnostic INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS followup_challenges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    challenge_id INTEGER NOT NULL REFERENCES challenges(id),
    prompt TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('fill_blank','write_code','spot_bug')),
    starter_code TEXT NOT NULL DEFAULT '',
    solution TEXT NOT NULL,
    explanation TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS section_tests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    challenge_id INTEGER NOT NULL REFERENCES challenges(id),
    sort_order INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS remediation_challenges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    weakness_tag TEXT NOT NULL,
    prompt TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('fill_blank','write_code','spot_bug')),
    starter_code TEXT NOT NULL DEFAULT '',
    solution TEXT NOT NULL,
    explanation TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS user_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER REFERENCES users(id),
    session_token TEXT NOT NULL,
    challenge_id INTEGER NOT NULL REFERENCES challenges(id),
    passed INTEGER NOT NULL DEFAULT 0,
    attempts INTEGER NOT NULL DEFAULT 0,
    completed_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE(session_token, challenge_id)
);

CREATE TABLE IF NOT EXISTS tips (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    difficulty TEXT NOT NULL CHECK(difficulty IN ('beginner','intermediate','advanced','all')),
    title TEXT NOT NULL,
    content TEXT NOT NULL
);
