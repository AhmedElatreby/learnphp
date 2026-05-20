-- Language
INSERT OR IGNORE INTO languages (name, slug, icon, is_active) VALUES ('PHP', 'php', '🐘', 1);

-- Topics (first 5 for initial seed — rest added incrementally)
INSERT OR IGNORE INTO topics (language_id, name, slug, description, sort_order) VALUES
(1, 'Variables & Data Types', 'variables', 'Learn how PHP stores data in variables and the types of values they can hold.', 1),
(1, 'Operators', 'operators', 'Arithmetic, comparison, and logical operators in PHP.', 2),
(1, 'Strings', 'strings', 'Working with text in PHP — string functions, interpolation, and manipulation.', 3),
(1, 'Arrays', 'arrays', 'Indexed and associative arrays — the workhorse of PHP data structures.', 4),
(1, 'Conditionals', 'conditionals', 'if, else, elseif, and switch — controlling the flow of your program.', 5);

-- Sample challenges for Arrays topic (topic_id = 4)
INSERT OR IGNORE INTO challenges (topic_id, title, prompt, type, difficulty, starter_code, solution, hint, explanation, is_diagnostic, sort_order) VALUES
(4, 'Create an Array',
 'Fill in the blank to create an array containing the strings "apple", "banana", and "cherry".',
 'fill_blank', 'beginner',
 '$fruits = ______;',
 '["apple","banana","cherry"]',
 'Use square brackets [ ] with quoted strings separated by commas.',
 'In PHP, arrays are created with square bracket syntax: $arr = ["item1", "item2"]. The old array() function also works but [] is the modern standard.',
 1, 1),

(4, 'Access Array Element',
 'Spot the bug — this code should print "banana" but it doesn''t.',
 'spot_bug', 'beginner',
 '$fruits = ["apple", "banana", "cherry"];
echo $fruits[2];',
 'echo $fruits[1];',
 'PHP arrays start at index 0, not 1.',
 'Array indexes start at 0. So $fruits[0] = "apple", $fruits[1] = "banana", $fruits[2] = "cherry". To get "banana" you need index 1.',
 0, 2),

(4, 'Count Array Items',
 'Write PHP code that counts how many items are in the $colors array and stores the result in $total.',
 'write_code', 'beginner',
 '$colors = ["red", "green", "blue", "yellow"];
// Your code here:
$total = ',
 'count($colors)',
 'PHP has a built-in function specifically for counting array elements.',
 'count() is the standard PHP function for getting array length. $total = count($colors) stores 4 in $total.',
 0, 3);

-- Follow-up for challenge 1 (wrong answer teaching)
INSERT OR IGNORE INTO followup_challenges (challenge_id, prompt, type, starter_code, solution, explanation) VALUES
(1, 'Which of these correctly creates a PHP array? Fill in the correct syntax: $items = ______;',
 'fill_blank',
 '$items = ______;',
 '["x","y"]',
 'Square brackets with quoted, comma-separated strings is the correct modern PHP array syntax.');

-- Tips for Arrays topic (topic_id = 4)
INSERT OR IGNORE INTO tips (topic_id, difficulty, title, content) VALUES
(4, 'all', 'Array Basics', 'Arrays store multiple values in one variable. Access items with their index starting at 0: $arr[0] is the first item.'),
(4, 'beginner', 'Quick Reference', '$a = ["x","y","z"]; // create
$a[0]       // "x"
count($a)   // 3
$a[] = "w"; // append'),
(4, 'beginner', 'Common Mistake', 'Arrays start at index 0, not 1. $arr[1] gives the SECOND item, not the first.');

-- Section test for Arrays (uses challenge IDs 1, 2, 3)
INSERT OR IGNORE INTO section_tests (topic_id, challenge_id, sort_order) VALUES (4, 1, 1), (4, 2, 2), (4, 3, 3);
