-- ═══════════════════════════════════════════════════════════════
-- Topics 6–28 seed
-- Challenge IDs start at 100 to avoid collisions with existing IDs
-- Remediation IDs start at 100
-- ═══════════════════════════════════════════════════════════════

INSERT OR IGNORE INTO topics (language_id, name, slug, description, sort_order) VALUES
(1, 'Loops', 'loops', 'for, while, do-while, and foreach — repeating actions in PHP.', 6),
(1, 'Functions', 'functions', 'Defining and calling reusable blocks of code in PHP.', 7),
(1, 'Form Handling', 'form-handling', 'Processing HTML form data with $_GET, $_POST, and superglobals.', 8),
(1, 'File Inclusion', 'file-inclusion', 'Organising code with include, require, include_once, and require_once.', 9),
(1, 'Array Functions', 'array-functions', 'PHP''s rich library of built-in array manipulation functions.', 10),
(1, 'Date & Time', 'date-time', 'Working with dates, times, and the DateTime class in PHP.', 11),
(1, 'Math Functions', 'math-functions', 'Built-in maths functions: round, abs, floor, ceil, rand, and more.', 12),
(1, 'Regular Expressions', 'regex', 'Pattern matching with preg_match, preg_replace, and PCRE syntax.', 13),
(1, 'File System', 'file-system', 'Reading and writing files with fopen, file_get_contents, and directory functions.', 14),
(1, 'Error Handling', 'error-handling', 'Try/catch, exceptions, set_error_handler, and error reporting.', 15),
(1, 'Sessions & Cookies', 'sessions-cookies', 'Persisting data across requests with $_SESSION and $_COOKIE.', 16),
(1, 'JSON', 'json', 'Encoding and decoding JSON data with json_encode and json_decode.', 17),
(1, 'APIs & cURL', 'apis-curl', 'Consuming HTTP APIs using cURL and file_get_contents wrappers.', 18),
(1, 'Input Validation', 'input-validation', 'Sanitising and validating user input with filter functions and custom rules.', 19),
(1, 'OOP – Classes & Objects', 'oop-classes', 'Defining classes, properties, methods, constructors, and visibility.', 20),
(1, 'OOP – Inheritance', 'oop-inheritance', 'Extending classes, overriding methods, and using parent::.', 21),
(1, 'OOP – Traits', 'oop-traits', 'Reusing methods across unrelated classes with traits.', 22),
(1, 'OOP – Namespaces', 'oop-namespaces', 'Organising code and avoiding name collisions with namespaces and use.', 23),
(1, 'PDO & Databases', 'pdo', 'Connecting to databases, prepared statements, and fetching rows with PDO.', 24),
(1, 'Security', 'security', 'Preventing XSS, SQL injection, CSRF, and password hashing.', 25),
(1, 'REST APIs', 'rest-apis', 'Building and consuming RESTful endpoints in PHP.', 26),
(1, 'Composer & Autoloading', 'composer', 'Managing dependencies and PSR-4 autoloading with Composer.', 27),
(1, 'PHP 8.x Features', 'php8-features', 'Named arguments, match, nullsafe operator, fibers, enums, and more.', 28);


-- ═══════════════════════════════════════════════
-- Topic 6 — Loops (topic_id resolved at runtime via slug)
-- We reference topic by SELECT subquery for portability,
-- but for simplicity we hard-code topic IDs 6–28 (they are
-- AUTOINCREMENT from the INSERT above; language has id=1 so
-- topics get IDs 6–28 if 1–5 already exist).
-- ═══════════════════════════════════════════════

-- ── Loops (topic_id = 6) ───────────────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(100,6,'for Loop Basics',
 'Fill in the blank so the loop prints 1 through 5.',
 'fill_blank','beginner',
 'for ($i = 1; ______; $i++) {
    echo $i . "\n";
}',
 '$i <= 5',
 'The middle part of a for loop is the condition that keeps it running.',
 'A for loop has three parts: initialiser ($i=1), condition ($i<=5), and increment ($i++). The loop runs while the condition is true.',
 1,1),

(101,6,'while Loop',
 'Fill in the blank to complete the while loop that counts down from 3 to 1.',
 'fill_blank','beginner',
 '$n = 3;
while (______) {
    echo $n . "\n";
    $n--;
}',
 '$n >= 1',
 'The loop should continue as long as $n is still 1 or above.',
 'while ($n >= 1) keeps looping while $n is at least 1. Each iteration prints then decrements $n.',
 1,2),

(102,6,'foreach Loop',
 'Spot the bug — the loop should print each fruit but it errors.',
 'spot_bug','beginner',
 '$fruits = ["apple","banana","cherry"];
foreach ($fruits as $fruit):
    echo $fruit . "\n";
endforeach',
 'endforeach;',
 'PHP alternative syntax requires a semicolon after the closing keyword.',
 'When using PHP''s alternative colon syntax, endforeach must be followed by a semicolon: endforeach;',
 0,3),

(103,6,'do-while Loop',
 'Write a do-while loop that prints "hello" exactly once even though the condition is false.',
 'write_code','beginner',
 '// Write your do-while loop here:',
 'do {
    echo "hello";
} while (false);',
 'A do-while always runs the body at least once before checking the condition.',
 'do { ... } while (false) executes the body once, then checks the condition. Since it''s false, it stops.',
 0,4),

(104,6,'break & continue',
 'Fill in the blank — skip even numbers so only odd numbers 1-9 are printed.',
 'fill_blank','beginner',
 'for ($i = 1; $i <= 10; $i++) {
    if ($i % 2 === 0) ______;
    echo $i . "\n";
}',
 'continue',
 'One keyword skips to the next iteration without exiting the loop.',
 'continue skips the rest of the current iteration and moves to the next. break would exit the loop entirely.',
 0,5);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(6,'all','Loop Types','for: count-controlled. while: condition-controlled. foreach: iterating arrays. do-while: runs at least once.'),
(6,'beginner','Quick Reference','for ($i=0; $i<5; $i++)    // classic counter
while ($x > 0)             // condition loop
foreach ($arr as $v)       // array iteration
do { } while ($cond);      // run-at-least-once'),
(6,'beginner','Common Mistake','Forgetting to increment the counter in a while loop causes an infinite loop. Always make sure the loop condition will eventually become false.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (6,100,1),(6,101,2),(6,102,3);

-- ── Functions (topic_id = 7) ───────────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(110,7,'Define a Function',
 'Fill in the blank to define a function named greet.',
 'fill_blank','beginner',
 '______ greet($name) {
    return "Hello, $name!";
}',
 'function',
 'Functions are declared with a keyword.',
 'The function keyword declares a reusable block. function greet($name) { ... } defines a function that accepts one parameter.',
 1,1),

(111,7,'Default Parameters',
 'Fill in the blank to give $greeting a default value of "Hello".',
 'fill_blank','beginner',
 'function greet($name, $greeting = ______) {
    return "$greeting, $name!";
}',
 '"Hello"',
 'Default values are assigned with = in the parameter list.',
 'Default parameter values let callers omit that argument. function greet($name, $greeting = "Hello") uses "Hello" when $greeting is not passed.',
 1,2),

(112,7,'Return Values',
 'Spot the bug — the function should return the square of $n but always returns 0.',
 'spot_bug','beginner',
 'function square($n) {
    $result = $n * $n;
}
echo square(4); // should print 16',
 'return $result;',
 'Without return, a function returns null.',
 'Functions must use return to send a value back. Without return $result, the function implicitly returns null, which echoes as empty.',
 0,3),

(113,7,'Type Declarations',
 'Fill in the blank — add a return type declaration of int to this function.',
 'fill_blank','intermediate',
 'function add(int $a, int $b): ______ {
    return $a + $b;
}',
 'int',
 'Return types are declared after the closing parenthesis with a colon.',
 'PHP 7+ supports return type declarations: function add(int $a, int $b): int { ... }. PHP will coerce or throw TypeError depending on strict_types.',
 0,4),

(114,7,'Variable Scope',
 'Spot the bug — the function should use the $count variable defined outside, but prints nothing.',
 'spot_bug','beginner',
 '$count = 10;
function showCount() {
    echo $count;
}
showCount();',
 'global $count;',
 'Variables defined outside a function are not automatically available inside it.',
 'PHP functions have their own scope. To access an outer variable, declare it with global $count; inside the function body.',
 0,5);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(7,'all','Function Basics','Declare with function. Use return to send a value back. Parameters can have defaults.'),
(7,'beginner','Quick Reference','function name($param = default): returnType {
    return value;
}'),
(7,'intermediate','Scope','Variables outside a function are not visible inside. Use global $var or pass as a parameter.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (7,110,1),(7,111,2),(7,112,3);

-- ── Form Handling (topic_id = 8) ──────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(120,8,'Read POST Data',
 'Fill in the blank to read the "username" field from a submitted POST form.',
 'fill_blank','beginner',
 '$username = ______["username"];',
 '$_POST',
 'PHP stores POST form data in a special superglobal array.',
 '$_POST is the superglobal that holds data submitted via HTTP POST. $_GET holds query-string data. $_REQUEST holds both.',
 1,1),

(121,8,'Check Field Exists',
 'Fill in the blank — check whether the "email" key exists in $_POST before using it.',
 'fill_blank','beginner',
 'if (______("email", $_POST)) {
    $email = $_POST["email"];
}',
 'isset',
 'One function checks if an array key exists AND is not null.',
 'isset() returns true if the key exists and is not null. array_key_exists() also works but isset is idiomatic for superglobals.',
 1,2),

(122,8,'Sanitise Input',
 'Spot the bug — this code is vulnerable to XSS when displaying user input.',
 'spot_bug','beginner',
 '$name = $_GET["name"];
echo "Hello, $name!";',
 '$name = htmlspecialchars($_GET["name"], ENT_QUOTES, ''UTF-8'');',
 'User input must be escaped before being output as HTML.',
 'htmlspecialchars() converts <, >, &, " and '' to safe HTML entities, preventing XSS. Always escape untrusted data before echoing it.',
 0,3),

(123,8,'GET vs POST',
 'Fill in the blank — read the "page" parameter from the URL query string.',
 'fill_blank','beginner',
 '$page = (int) ______["page"] ?? 1;',
 '$_GET',
 'URL query string data comes through a different superglobal than form POST data.',
 '$_GET holds data from the URL query string (?page=2). $_POST holds data from the request body. Both are arrays.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(8,'all','Superglobals','$_POST — form body data. $_GET — URL query string. $_REQUEST — both. Always validate and sanitise before use.'),
(8,'beginner','Never Trust Input','Always escape output with htmlspecialchars() and validate types before processing form data.'),
(8,'intermediate','CSRF','Protect forms with a hidden token: generate a random token, store in $_SESSION, verify on submit.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (8,120,1),(8,121,2),(8,122,3);

-- ── File Inclusion (topic_id = 9) ─────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(130,9,'require vs include',
 'Fill in the blank — include the file "header.php" in a way that stops execution if the file is missing.',
 'fill_blank','beginner',
 '______ "header.php";',
 'require',
 'One keyword throws a fatal error on failure; the other only a warning.',
 'require causes a fatal error if the file is not found, stopping execution. include only emits a warning and continues.',
 1,1),

(131,9,'require_once',
 'Fill in the blank — include "config.php" but ensure it is loaded only once even if this line runs multiple times.',
 'fill_blank','beginner',
 '______ "config.php";',
 'require_once',
 'The _once variant prevents double-loading.',
 'require_once checks whether the file has already been included. If so, it skips it. Useful for class files and configuration.',
 1,2),

(132,9,'__DIR__ Constant',
 'Spot the bug — the include path breaks when the script is run from a different directory.',
 'spot_bug','beginner',
 'require "includes/functions.php";',
 'require __DIR__ . "/includes/functions.php";',
 'Relative paths are relative to the CWD, not the script location.',
 '__DIR__ is the directory of the current file. Prepending it makes includes work regardless of where PHP is invoked from.',
 0,3);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(9,'all','Include vs Require','include: warning on fail, execution continues. require: fatal error on fail. Add _once to prevent duplicate loading.'),
(9,'beginner','Always Use __DIR__','require __DIR__ . "/path/to/file.php" prevents path issues when running from different directories.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (9,130,1),(9,131,2),(9,132,3);

-- ── Array Functions (topic_id = 10) ───────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(140,10,'array_map',
 'Fill in the blank — double every number in $nums using array_map.',
 'fill_blank','beginner',
 '$nums = [1, 2, 3, 4];
$doubled = array_map(______, $nums);',
 'fn($n) => $n * 2',
 'array_map takes a callable as its first argument.',
 'array_map applies a function to each element and returns a new array. fn($n) => $n * 2 is an arrow function (PHP 7.4+).',
 1,1),

(141,10,'array_filter',
 'Fill in the blank — keep only even numbers from $nums.',
 'fill_blank','beginner',
 '$nums = [1, 2, 3, 4, 5, 6];
$evens = array_filter($nums, ______);',
 'fn($n) => $n % 2 === 0',
 'array_filter keeps elements for which the callback returns true.',
 'array_filter passes each element to the callback. Elements where the callback returns true are kept in the result.',
 1,2),

(142,10,'array_reduce',
 'Fill in the blank — sum all numbers in $nums using array_reduce.',
 'fill_blank','intermediate',
 '$nums = [1, 2, 3, 4, 5];
$sum = array_reduce($nums, fn($carry, $item) => ______, 0);',
 '$carry + $item',
 'The callback receives the running total ($carry) and the current item.',
 'array_reduce folds an array to a single value. The callback receives the accumulator ($carry) and current element ($item). Starting value is 0.',
 0,3),

(143,10,'usort',
 'Spot the bug — the sort puts "banana" before "apple" (should be alphabetical).',
 'spot_bug','beginner',
 '$fruits = ["banana", "apple", "cherry"];
usort($fruits, fn($a, $b) => $a > $b);',
 'usort($fruits, fn($a, $b) => $a <=> $b);',
 'The comparison callback must return negative, zero, or positive — not a boolean.',
 'usort expects the callback to return <0, 0, or >0. Returning a boolean (true/false = 1/0) gives wrong ordering. Use the spaceship operator <=> instead.',
 0,4),

(144,10,'array_merge vs + operator',
 'Fill in the blank — merge $a and $b so that $b''s values override $a''s for duplicate string keys.',
 'fill_blank','intermediate',
 '$a = ["x" => 1, "y" => 2];
$b = ["y" => 99, "z" => 3];
$merged = ______($a, $b);',
 'array_merge',
 'Two ways to combine arrays have different behaviour with string keys.',
 'array_merge reindexes numeric keys and lets later arrays override string keys. The + operator keeps the first array''s value for duplicate keys.',
 0,5);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(10,'all','Key Functions','array_map — transform. array_filter — keep matching. array_reduce — fold to one value. usort — custom sort.'),
(10,'beginner','Quick Reference','array_map(fn($x)=>$x*2, $arr)
array_filter($arr, fn($x)=>$x>0)
array_reduce($arr, fn($c,$i)=>$c+$i, 0)
in_array($val, $arr)
array_search($val, $arr)'),
(10,'intermediate','Spaceship Operator','Use <=> in sort callbacks: $a <=> $b returns -1, 0, or 1. Perfect for usort.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (10,140,1),(10,141,2),(10,142,3);

-- ── Date & Time (topic_id = 11) ───────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(150,11,'date() Function',
 'Fill in the blank — format today''s date as YYYY-MM-DD.',
 'fill_blank','beginner',
 'echo date(______);',
 '"Y-m-d"',
 'date() takes a format string. Y = 4-digit year, m = 2-digit month, d = 2-digit day.',
 'date("Y-m-d") outputs the current date in ISO 8601 format, e.g. 2024-06-15. Y=full year, m=month 01-12, d=day 01-31.',
 1,1),

(151,11,'strtotime',
 'Fill in the blank — convert the string "next Monday" to a Unix timestamp.',
 'fill_blank','beginner',
 '$ts = ______("next Monday");',
 'strtotime',
 'One function parses human-readable date strings into timestamps.',
 'strtotime() parses English date descriptions into a Unix timestamp (seconds since 1970-01-01). strtotime("next Monday") gives midnight of next Monday.',
 1,2),

(152,11,'DateTime Class',
 'Spot the bug — the code should print tomorrow''s date but prints today''s.',
 'spot_bug','intermediate',
 '$dt = new DateTime();
echo $dt->format("Y-m-d");',
 '$dt->modify("+1 day");',
 'You need to advance the DateTime object before formatting it.',
 'DateTime::modify() changes the date. Without calling ->modify("+1 day"), the object still holds today''s date.',
 0,3),

(153,11,'Date Difference',
 'Fill in the blank — calculate the number of days between two dates.',
 'fill_blank','intermediate',
 '$d1 = new DateTime("2024-01-01");
$d2 = new DateTime("2024-12-31");
$diff = $d1->diff($d2);
echo ______;',
 '$diff->days',
 'DateInterval has a property for total days.',
 'DateTime::diff() returns a DateInterval. Its ->days property gives the total number of days between the two dates.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(11,'all','Two Approaches','date() + strtotime() for simple formatting. DateTime class for arithmetic and timezone-awareness.'),
(11,'beginner','Format Codes','Y=2024  m=01  d=31  H=14  i=05  s=00  D=Mon  l=Monday  N=1(Mon)-7(Sun)'),
(11,'intermediate','Timezones','Always set a timezone: date_default_timezone_set("UTC") or new DateTimeZone("America/New_York").');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (11,150,1),(11,151,2),(11,152,3);

-- ── Math Functions (topic_id = 12) ────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(160,12,'round()',
 'Fill in the blank — round 3.14159 to 2 decimal places.',
 'fill_blank','beginner',
 'echo ______(3.14159, 2);',
 'round',
 'The function name matches what it does.',
 'round($num, $decimals) rounds to the given number of decimal places. round(3.14159, 2) returns 3.14.',
 1,1),

(161,12,'floor & ceil',
 'Spot the bug — the code should always round UP to the nearest integer but sometimes rounds down.',
 'spot_bug','beginner',
 'echo floor(4.1); // expected 5',
 'echo ceil(4.1);',
 'floor rounds down; ceil rounds up.',
 'floor() rounds toward negative infinity (down). ceil() rounds toward positive infinity (up). ceil(4.1) = 5, floor(4.1) = 4.',
 1,2),

(162,12,'rand & mt_rand',
 'Fill in the blank — generate a random integer between 1 and 100 (inclusive).',
 'fill_blank','beginner',
 '$roll = ______(1, 100);',
 'mt_rand',
 'mt_rand is the modern, faster random integer function.',
 'mt_rand($min, $max) generates a random integer in the inclusive range. It uses the Mersenne Twister algorithm and is faster than rand().',
 0,3),

(163,12,'abs & pow',
 'Fill in the blank — compute 2 to the power of 8.',
 'fill_blank','beginner',
 'echo ______(2, 8); // 256',
 'pow',
 'There is a built-in function for exponentiation (and the ** operator also works).',
 'pow($base, $exp) computes $base ** $exp. pow(2, 8) = 256. The ** operator is equivalent: 2 ** 8.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(12,'all','Key Functions','abs() — absolute value. round/floor/ceil — rounding. pow() or ** — exponent. sqrt() — square root. mt_rand() — random integer.'),
(12,'beginner','Quick Reference','round(3.567, 1) → 3.6
floor(3.9)     → 3
ceil(3.1)      → 4
abs(-5)        → 5
pow(2,10)      → 1024
mt_rand(1,6)   → dice roll');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (12,160,1),(12,161,2),(12,162,3);


-- ═══════════════════════════════════════════════
-- Topics 13–19
-- ═══════════════════════════════════════════════

-- ── Regular Expressions (topic_id = 13) ──────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(170,13,'preg_match Basics',
 'Fill in the blank — check if $email looks like an email address using preg_match.',
 'fill_blank','beginner',
 '$email = "user@example.com";
if (______(''/@.+\..+/'', $email)) {
    echo "valid";
}',
 'preg_match',
 'The PHP function for matching a PCRE pattern against a string.',
 'preg_match($pattern, $string) returns 1 on match, 0 on no match. Patterns are delimited by / / in PHP.',
 1,1),

(171,13,'Capture Groups',
 'Fill in the blank — extract the year, month, and day from a date string.',
 'fill_blank','intermediate',
 '$date = "2024-06-15";
preg_match(______, $date, $m);
// $m[1]=year, $m[2]=month, $m[3]=day',
 '"/(\d{4})-(\d{2})-(\d{2})/"',
 'Parentheses create capture groups that end up in the $matches array.',
 'Each set of () creates a capture group. $m[0] is the full match, $m[1] is the first group, etc.',
 1,2),

(172,13,'preg_replace',
 'Fill in the blank — remove all non-digit characters from $phone.',
 'fill_blank','beginner',
 '$phone = "(555) 867-5309";
$digits = preg_replace(______, "", $phone);',
 '"/\D+/"',
 '\D matches any non-digit character.',
 '\D is the PCRE non-digit shorthand (opposite of \d). The + quantifier matches one or more. preg_replace replaces all matches with the empty string.',
 0,3),

(173,13,'preg_split',
 'Spot the bug — the split should separate on any whitespace but only splits on a single space.',
 'spot_bug','beginner',
 '$words = preg_split("/ /", "hello   world");
// should give ["hello","world"]',
 'preg_split("/\s+/", "hello   world")',
 '\s matches any whitespace; + means one or more.',
 '\s+ matches one or more whitespace characters (spaces, tabs, newlines). Splitting on " " only catches a single space.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(13,'all','Core Functions','preg_match — test/capture. preg_replace — find & replace. preg_split — split string. preg_match_all — find all matches.'),
(13,'beginner','Pattern Delimiters','PHP PCRE patterns need delimiters: "/pattern/flags". Common flags: i (case-insensitive), m (multiline), s (dot matches newline).'),
(13,'intermediate','Useful Shorthands','\d digit  \w word char  \s whitespace  . any char  ^ start  $ end  + one or more  * zero or more  ? optional');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (13,170,1),(13,171,2),(13,172,3);

-- ── File System (topic_id = 14) ───────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(180,14,'file_get_contents',
 'Fill in the blank — read the entire contents of "data.txt" into a string.',
 'fill_blank','beginner',
 '$text = ______("data.txt");',
 'file_get_contents',
 'The simplest function for reading a whole file.',
 'file_get_contents($path) reads a file into a string in one call. For large files, use fopen/fread to stream it.',
 1,1),

(181,14,'file_put_contents',
 'Fill in the blank — append "new line\n" to "log.txt" without overwriting existing content.',
 'fill_blank','beginner',
 'file_put_contents("log.txt", "new line\n", ______);',
 'FILE_APPEND',
 'A flag constant controls whether to append or overwrite.',
 'file_put_contents with FILE_APPEND adds to the end of the file. Without it, the file is overwritten.',
 1,2),

(182,14,'file_exists Check',
 'Spot the bug — the code crashes if the file does not exist.',
 'spot_bug','beginner',
 '$data = file_get_contents("config.json");
$config = json_decode($data, true);',
 'if (file_exists("config.json")) {
    $data = file_get_contents("config.json");
    $config = json_decode($data, true);
}',
 'Always check if a file exists before trying to read it.',
 'file_get_contents returns false if the file is missing, causing json_decode to fail. Wrap in file_exists() or check the return value.',
 0,3),

(183,14,'scandir',
 'Fill in the blank — list all files and directories inside "/var/uploads".',
 'fill_blank','beginner',
 '$items = ______("/var/uploads");',
 'scandir',
 'scandir() returns an array of filenames in a directory.',
 'scandir($dir) returns an array including "." and "..". Filter them with array_diff($items, [".", ".."]).',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(14,'all','Quick Reads/Writes','file_get_contents / file_put_contents for whole-file ops. fopen/fread/fwrite for streaming large files.'),
(14,'beginner','Check Before Reading','Always verify file_exists() or check for false return before processing a file.'),
(14,'intermediate','Paths','Use realpath() to resolve symlinks and __DIR__ to anchor relative paths.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (14,180,1),(14,181,2),(14,182,3);

-- ── Error Handling (topic_id = 15) ────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(190,15,'try/catch',
 'Fill in the blank — catch any Exception thrown in the try block.',
 'fill_blank','beginner',
 'try {
    riskyOperation();
} ______ (Exception $e) {
    echo $e->getMessage();
}',
 'catch',
 'try pairs with another keyword to handle exceptions.',
 'catch (ExceptionClass $e) { } catches exceptions of that class or its subclasses. $e->getMessage() returns the error message.',
 1,1),

(191,15,'throw',
 'Fill in the blank — throw an InvalidArgumentException if $age is negative.',
 'fill_blank','beginner',
 'function setAge(int $age): void {
    if ($age < 0) {
        ______ new InvalidArgumentException("Age cannot be negative");
    }
}',
 'throw',
 'Exceptions are created with new and thrown with a keyword.',
 'throw new ExceptionClass("message") raises an exception that bubbles up to the nearest matching catch block.',
 1,2),

(192,15,'finally',
 'Spot the bug — the database connection is not closed when an exception occurs.',
 'spot_bug','intermediate',
 'try {
    $db = connectDb();
    doWork($db);
} catch (Exception $e) {
    logError($e);
}
$db->close();',
 'finally {
    $db->close();
}',
 'One block runs regardless of whether an exception was thrown.',
 'finally { } runs after try/catch, whether or not an exception occurred — perfect for cleanup like closing connections.',
 0,3),

(193,15,'Custom Exception',
 'Fill in the blank — create a custom exception class named NotFoundException that extends RuntimeException.',
 'fill_blank','intermediate',
 'class NotFoundException ______ RuntimeException {}',
 'extends',
 'Custom exceptions inherit from existing exception classes.',
 'class NotFoundException extends RuntimeException {} creates a named exception type. Catching NotFoundException separately from RuntimeException lets you handle it differently.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(15,'all','try/catch/finally','try: risky code. catch: handle specific exceptions. finally: always-runs cleanup.'),
(15,'beginner','Exception Hierarchy','Exception is the base. RuntimeException, InvalidArgumentException, LogicException are common subclasses. Extend any of them for custom types.'),
(15,'intermediate','Error vs Exception','In PHP 7+, fatal errors are also catchable as Error objects. catch (Throwable $e) catches both Error and Exception.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (15,190,1),(15,191,2),(15,192,3);

-- ── Sessions & Cookies (topic_id = 16) ────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(200,16,'session_start',
 'Fill in the blank — start or resume a session so $_SESSION is available.',
 'fill_blank','beginner',
 '______();
$_SESSION["user"] = "Alice";',
 'session_start',
 'Sessions need to be initialised before any output.',
 'session_start() must be called before any output. It creates or resumes a session. Data stored in $_SESSION persists across requests for the same browser session.',
 1,1),

(201,16,'Destroy Session',
 'Spot the bug — the logout code leaves the session data intact.',
 'spot_bug','beginner',
 'session_start();
session_destroy();',
 'session_start();
$_SESSION = [];
session_destroy();',
 'session_destroy() removes the server-side file but does not clear the $_SESSION superglobal in the current request.',
 'To fully log out: clear $_SESSION = [] so current-request code no longer sees old data, then call session_destroy() to delete the server file.',
 1,2),

(202,16,'setcookie',
 'Fill in the blank — set a cookie named "theme" to "dark" that expires in 30 days.',
 'fill_blank','beginner',
 'setcookie("theme", "dark", ______);',
 'time() + 60 * 60 * 24 * 30',
 'The third argument is a Unix timestamp for the expiry.',
 'setcookie($name, $value, $expiry) sets a cookie. time() + 30*24*3600 sets expiry 30 days from now. Cookies must be set before any HTML output.',
 0,3),

(203,16,'Read Cookie',
 'Fill in the blank — read the "theme" cookie value, defaulting to "light" if absent.',
 'fill_blank','beginner',
 '$theme = ______["theme"] ?? "light";',
 '$_COOKIE',
 'Cookies sent by the browser are available in a superglobal.',
 '$_COOKIE holds all cookies sent in the current request. The ?? null-coalescing operator provides a default when the key is absent.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(16,'all','Sessions vs Cookies','Sessions store data server-side (referenced by a cookie ID). Cookies store small data client-side. Sessions expire when browser closes (default); cookies can be long-lived.'),
(16,'beginner','session_start() Rules','Call it at the very top of every script that uses sessions, before any echo or HTML. Headers must not have been sent.'),
(16,'intermediate','Security','Set cookies with HttpOnly and Secure flags: setcookie("name","val",expiry,"/","",true,true). Regenerate session ID after login: session_regenerate_id(true).');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (16,200,1),(16,201,2),(16,202,3);

-- ── JSON (topic_id = 17) ──────────────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(210,17,'json_encode',
 'Fill in the blank — convert the $data array to a JSON string.',
 'fill_blank','beginner',
 '$data = ["name" => "Alice", "age" => 30];
echo ______($data);',
 'json_encode',
 'PHP has a built-in function that converts arrays/objects to JSON.',
 'json_encode($value) converts PHP arrays and objects to a JSON string. Flags like JSON_PRETTY_PRINT add formatting.',
 1,1),

(211,17,'json_decode',
 'Fill in the blank — decode a JSON string into a PHP associative array.',
 'fill_blank','beginner',
 '$json = ''{"name":"Bob","age":25}'';
$data = json_decode($json, ______);',
 'true',
 'The second argument controls whether objects become arrays.',
 'json_decode($json, true) returns an associative array. Without true, it returns a stdClass object.',
 1,2),

(212,17,'JSON Error Checking',
 'Spot the bug — the code silently ignores JSON parse errors.',
 'spot_bug','intermediate',
 '$data = json_decode($input, true);
processData($data);',
 '$data = json_decode($input, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    throw new RuntimeException("Invalid JSON: " . json_last_error_msg());
}
processData($data);',
 'json_decode returns null on error — you need to check for it explicitly.',
 'json_last_error() returns the last JSON error code. JSON_ERROR_NONE means success. Always check it before using decoded data.',
 0,3),

(213,17,'JSON Pretty Print',
 'Fill in the blank — encode $data as a pretty-printed JSON string with unicode preserved.',
 'fill_blank','intermediate',
 'echo json_encode($data, ______);',
 'JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE',
 'json_encode flags can be combined with the | operator.',
 'JSON_PRETTY_PRINT adds indentation. JSON_UNESCAPED_UNICODE outputs non-ASCII as-is instead of \uXXXX sequences. Combine flags with |.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(17,'all','Encode/Decode','json_encode($php) → JSON string. json_decode($json, true) → PHP array.'),
(17,'beginner','Common Flags','JSON_PRETTY_PRINT — readable output. JSON_UNESCAPED_UNICODE — keep UTF-8. JSON_UNESCAPED_SLASHES — no \/ escaping.'),
(17,'intermediate','Always Check Errors','json_last_error() !== JSON_ERROR_NONE means the decode failed. Handle it before using the data.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (17,210,1),(17,211,2),(17,212,3);

-- ── APIs & cURL (topic_id = 18) ───────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(220,18,'Simple GET Request',
 'Fill in the blank — fetch the JSON from a URL using the simplest PHP one-liner.',
 'fill_blank','beginner',
 '$json = ______("https://api.example.com/data");
$data = json_decode($json, true);',
 'file_get_contents',
 'file_get_contents works on URLs as well as local files (when allow_url_fopen is on).',
 'file_get_contents can fetch HTTP URLs when allow_url_fopen is enabled. For production use cURL for more control and error handling.',
 1,1),

(221,18,'cURL GET',
 'Fill in the blank — execute a cURL handle and get the response body.',
 'fill_blank','intermediate',
 '$ch = curl_init("https://api.example.com/users");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = ______($ch);
curl_close($ch);',
 'curl_exec',
 'One function executes the cURL request.',
 'curl_exec($ch) performs the request. CURLOPT_RETURNTRANSFER true means the response is returned as a string rather than printed.',
 1,2),

(222,18,'Check cURL Errors',
 'Spot the bug — errors from the cURL request are silently ignored.',
 'spot_bug','intermediate',
 '$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);
$data = json_decode($response, true);',
 'if (curl_errno($ch)) {
    throw new RuntimeException(curl_error($ch));
}',
 'curl_errno() returns 0 on success and a non-zero code on failure.',
 'Always check curl_errno($ch) after curl_exec. curl_error($ch) gives the human-readable error message.',
 0,3),

(223,18,'POST with cURL',
 'Fill in the blank — configure the cURL handle to send a POST request.',
 'fill_blank','intermediate',
 '$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, ______, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));',
 'CURLOPT_POST',
 'A cURL option constant switches the method from GET to POST.',
 'CURLOPT_POST, true sets the method to POST. CURLOPT_POSTFIELDS supplies the body. Also set Content-Type: application/json via CURLOPT_HTTPHEADER.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(18,'all','Two Approaches','file_get_contents for simple GETs. cURL for POST, headers, auth, error handling, and timeouts.'),
(18,'beginner','cURL Boilerplate','$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$res = curl_exec($ch);
curl_close($ch);'),
(18,'intermediate','Always Set Timeouts','curl_setopt($ch, CURLOPT_TIMEOUT, 10) prevents a slow API from hanging your script indefinitely.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (18,220,1),(18,221,2),(18,222,3);

-- ── Input Validation (topic_id = 19) ─────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(230,19,'filter_var Email',
 'Fill in the blank — validate that $email is a valid email address.',
 'fill_blank','beginner',
 'if (filter_var($email, ______)) {
    // valid
}',
 'FILTER_VALIDATE_EMAIL',
 'filter_var has constants for common validation tasks.',
 'FILTER_VALIDATE_EMAIL uses PHP''s built-in email validation. Returns the value on success or false on failure.',
 1,1),

(231,19,'filter_var Integer',
 'Fill in the blank — ensure $input is a valid integer.',
 'fill_blank','beginner',
 '$n = filter_var($input, ______);
if ($n === false) { /* invalid */ }',
 'FILTER_VALIDATE_INT',
 'A constant validates integers.',
 'FILTER_VALIDATE_INT validates and returns an int, or false if $input is not a valid integer representation.',
 1,2),

(232,19,'FILTER_SANITIZE',
 'Spot the bug — the code strips tags but does not encode special HTML characters.',
 'spot_bug','beginner',
 '$comment = strip_tags($_POST["comment"]);
echo $comment;',
 '$comment = htmlspecialchars(strip_tags($_POST["comment"]), ENT_QUOTES, "UTF-8");',
 'strip_tags removes tags, but < and > in text still need escaping before output.',
 'strip_tags removes HTML tags, but text like "1 < 2" still contains <. Always follow with htmlspecialchars() before echoing into HTML.',
 0,3),

(233,19,'Custom Validation',
 'Fill in the blank — validate that $username is 3–20 characters, letters and numbers only.',
 'fill_blank','intermediate',
 'if (!preg_match(______, $username)) {
    $errors[] = "Invalid username";
}',
 '"/^[a-zA-Z0-9]{3,20}$/"',
 'A regex with anchors, a character class, and a quantifier handles this.',
 '^..$ anchors to full string. [a-zA-Z0-9] matches alphanumeric. {3,20} enforces length. Without ^ and $, partial matches would pass.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(19,'all','Validate Then Sanitise','Validate: is this the right shape? Sanitise: make it safe to use. Never trust user input for either database queries or HTML output.'),
(19,'beginner','filter_var Constants','FILTER_VALIDATE_EMAIL  FILTER_VALIDATE_INT  FILTER_VALIDATE_URL  FILTER_VALIDATE_BOOLEAN  FILTER_SANITIZE_NUMBER_INT'),
(19,'intermediate','Defence In Depth','Validate on the server even if you validate on the client. Clients can be bypassed. Use prepared statements AND htmlspecialchars.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (19,230,1),(19,231,2),(19,232,3);

-- ── OOP – Classes & Objects (topic_id = 20) ───────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(240,20,'Define a Class',
 'Fill in the blank — define a class named Car with a public property $color.',
 'fill_blank','beginner',
 '______ Car {
    public string $color;
}',
 'class',
 'Classes are declared with a keyword.',
 'The class keyword defines a class. Properties are declared inside with a visibility modifier (public/protected/private) and optional type.',
 1,1),

(241,20,'Constructor',
 'Fill in the blank — add a constructor that sets $this->color from a parameter.',
 'fill_blank','beginner',
 'class Car {
    public string $color;
    public function ______(string $color) {
        $this->color = $color;
    }
}',
 '__construct',
 'PHP''s constructor method has a special name starting with two underscores.',
 '__construct() runs automatically when new Car() is called. $this refers to the current object instance.',
 1,2),

(242,20,'Visibility',
 'Spot the bug — the private property is accessed from outside the class.',
 'spot_bug','beginner',
 'class BankAccount {
    private float $balance = 0;
}
$a = new BankAccount();
echo $a->balance;',
 'echo $a->getBalance();',
 'Private properties can only be accessed from inside the class.',
 'private means only code inside the class can read or write that property. Expose it via a public getter method like getBalance().',
 0,3),

(243,20,'Constructor Promotion',
 'Fill in the blank — rewrite the constructor using PHP 8 constructor property promotion.',
 'fill_blank','intermediate',
 'class Point {
    public function __construct(
        ______ float $x,
        public float $y
    ) {}
}',
 'public',
 'Each promoted parameter needs a visibility modifier.',
 'Constructor promotion (PHP 8+) declares and assigns properties in one place. Each parameter gets a visibility keyword (public/protected/private), eliminating the need for explicit property declarations.',
 0,4),

(244,20,'Static Methods',
 'Fill in the blank — call the static method create() on the Car class without instantiating it.',
 'fill_blank','beginner',
 '$car = Car::______("red");',
 'create',
 'Static methods are called on the class itself, not an instance.',
 'Static methods belong to the class, not an object. Call them with ClassName::methodName(). Inside the method, use self:: instead of $this.',
 0,5);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(20,'all','OOP Basics','class declares a type. new creates an instance. $this references the current object. static belongs to the class not an instance.'),
(20,'beginner','Visibility','public — anyone. protected — class and subclasses. private — class only. Default is public if omitted in older code.'),
(20,'intermediate','Constructor Promotion','PHP 8: public function __construct(public string $name) {} automatically declares and sets the property.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (20,240,1),(20,241,2),(20,242,3);

-- ── OOP – Inheritance (topic_id = 21) ────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(250,21,'extends',
 'Fill in the blank — make ElectricCar extend Car.',
 'fill_blank','beginner',
 'class ElectricCar ______ Car {
    public int $batteryKwh;
}',
 'extends',
 'Inheritance uses a keyword to reference the parent class.',
 'extends lets ElectricCar inherit all public and protected properties and methods from Car.',
 1,1),

(251,21,'parent::',
 'Fill in the blank — call the parent constructor from the child constructor.',
 'fill_blank','beginner',
 'class ElectricCar extends Car {
    public function __construct(string $color, int $kwh) {
        ______::__construct($color);
        $this->batteryKwh = $kwh;
    }
}',
 'parent',
 'A special keyword references the parent class.',
 'parent:: refers to the parent class. parent::__construct() calls the parent''s constructor so it can initialise its own properties.',
 1,2),

(252,21,'Method Override',
 'Spot the bug — the overridden describe() should also include battery info but it does not.',
 'spot_bug','intermediate',
 'class ElectricCar extends Car {
    public function describe(): string {
        return "Battery: {$this->batteryKwh} kWh";
    }
}',
 'public function describe(): string {
    return parent::describe() . " Battery: {$this->batteryKwh} kWh";
}',
 'The override should build on the parent method rather than replacing it entirely.',
 'Calling parent::describe() gets the base description first. The child appends its extra info. Without parent::, the parent''s output is lost.',
 0,3),

(253,21,'abstract',
 'Fill in the blank — declare an abstract method area() that subclasses must implement.',
 'fill_blank','intermediate',
 'abstract class Shape {
    ______ public function area(): float;
}',
 'abstract',
 'Abstract methods have no body — subclasses are forced to implement them.',
 'abstract methods in abstract classes define a contract. Any non-abstract subclass must provide a concrete implementation or PHP throws a fatal error.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(21,'all','Inheritance','extends gives a child class all parent public/protected members. Override by redefining the method. Call parent:: to reuse parent logic.'),
(21,'beginner','When to Extend','Extend when the child IS-A parent (ElectricCar is a Car). Prefer composition (HAS-A) when the relationship is less clear.'),
(21,'intermediate','final','Mark a class or method final to prevent further extension/override: final class Singleton {} or final public function seal().');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (21,250,1),(21,251,2),(21,252,3);

-- ── OOP – Traits (topic_id = 22) ─────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(260,22,'Define a Trait',
 'Fill in the blank — declare a trait named Timestampable.',
 'fill_blank','beginner',
 '______ Timestampable {
    public string $createdAt;
    public function touch(): void {
        $this->createdAt = date("Y-m-d H:i:s");
    }
}',
 'trait',
 'Traits use their own keyword.',
 'trait declares a reusable group of methods/properties. Traits cannot be instantiated directly — they must be used inside a class.',
 1,1),

(261,22,'use a Trait',
 'Fill in the blank — include the Timestampable trait inside the Post class.',
 'fill_blank','beginner',
 'class Post {
    ______ Timestampable;
    public string $title;
}',
 'use',
 'The keyword to include a trait inside a class.',
 'use TraitName; inside a class body imports all the trait''s methods and properties as if they were defined in the class.',
 1,2),

(262,22,'Trait Conflict',
 'Spot the bug — two traits both define hello() and the conflict is not resolved.',
 'spot_bug','intermediate',
 'trait A { public function hello() { echo "A"; } }
trait B { public function hello() { echo "B"; } }
class C {
    use A, B;
}',
 'use A, B {
    A::hello insteadof B;
    B::hello as helloB;
}',
 'PHP requires explicit resolution when two traits define the same method.',
 'insteadof chooses which trait''s method to use. as aliases the other under a different name so it''s still accessible.',
 0,3);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(22,'all','Traits','Traits enable horizontal reuse across unrelated classes. Use them for cross-cutting concerns: logging, timestamping, soft-deletion.'),
(22,'beginner','Trait vs Interface','Traits provide implementation. Interfaces define contracts (method signatures only). A class can use multiple traits and implement multiple interfaces.'),
(22,'intermediate','Conflict Resolution','insteadof picks a winner. as creates an alias. You can also change visibility: use A { hello as protected; }');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (22,260,1),(22,261,2),(22,262,3);

-- ── OOP – Namespaces (topic_id = 23) ─────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(270,23,'Declare Namespace',
 'Fill in the blank — declare the namespace App\Models at the top of the file.',
 'fill_blank','beginner',
 '______ App\Models;
class User {}',
 'namespace',
 'Namespaces are declared with a keyword on the first line.',
 'namespace App\Models; must be the first statement in the file (before any class, function, or other code). It scopes everything that follows.',
 1,1),

(271,23,'use Alias',
 'Fill in the blank — import the class App\Models\User so it can be used as User.',
 'fill_blank','beginner',
 '______ App\Models\User;
$user = new User();',
 'use',
 'use brings a fully-qualified class name into the current scope.',
 'use App\Models\User; lets you write new User() instead of new App\Models\User(). Alias with as: use App\Models\User as UserModel;',
 1,2),

(272,23,'FQCN',
 'Spot the bug — the code uses a class without importing it or using a fully-qualified name.',
 'spot_bug','beginner',
 'namespace App\Controllers;
$user = new Models\User();',
 '$user = new \App\Models\User();',
 'Without use, relative namespace names resolve against the current namespace.',
 'Inside namespace App\Controllers, Models\User resolves to App\Controllers\Models\User (wrong). Use a leading backslash for a fully-qualified name: \App\Models\User.',
 0,3);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(23,'all','Namespaces','Declare at the top with namespace. Import with use. Use a leading \ for fully-qualified names without importing.'),
(23,'beginner','PSR-4 Autoloading','Namespaces map to directory structure. App\Models\User → src/Models/User.php. Composer autoloader handles this automatically.'),
(23,'intermediate','Aliasing','use App\Models\User as UserModel avoids name collisions when two packages define a class with the same name.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (23,270,1),(23,271,2),(23,272,3);

-- ── PDO & Databases (topic_id = 24) ───────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(280,24,'Connect with PDO',
 'Fill in the blank — complete the PDO connection DSN for SQLite.',
 'fill_blank','beginner',
 '$pdo = new PDO(______);',
 '"sqlite:/var/db/app.db"',
 'SQLite DSNs start with "sqlite:" followed by the file path.',
 'PDO DSNs vary by driver. SQLite: "sqlite:/path/to/file.db". MySQL: "mysql:host=localhost;dbname=app". Pass credentials as 2nd/3rd arguments for MySQL.',
 1,1),

(281,24,'Prepared Statements',
 'Fill in the blank — bind the :id placeholder to $userId safely.',
 'fill_blank','beginner',
 '$stmt = $pdo->prepare("SELECT * FROM users WHERE id = :id");
______(":id", $userId, PDO::PARAM_INT);
$stmt->execute();',
 '$stmt->bindValue',
 'Prepared statements use a method to bind values to placeholders.',
 'bindValue(":id", $val, PDO::PARAM_INT) binds a value once. bindParam binds by reference. Using named placeholders (:name) or ? prevents SQL injection.',
 1,2),

(282,24,'Fetch Results',
 'Fill in the blank — fetch all rows as associative arrays.',
 'fill_blank','beginner',
 '$stmt->execute();
$rows = $stmt->______(PDO::FETCH_ASSOC);',
 'fetchAll',
 'One method retrieves all rows at once.',
 'fetchAll(PDO::FETCH_ASSOC) returns an array of associative arrays. fetch() returns one row at a time. FETCH_OBJ returns stdClass objects.',
 0,3),

(283,24,'PDO Error Handling',
 'Spot the bug — database errors are silently swallowed.',
 'spot_bug','intermediate',
 '$pdo = new PDO($dsn);',
 '$pdo = new PDO($dsn);
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);',
 'PDO defaults to silent error mode.',
 'By default PDO uses ERRMODE_SILENT. Setting ERRMODE_EXCEPTION makes it throw PDOException on errors, making bugs visible instead of hidden.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(24,'all','PDO Workflow','new PDO($dsn) → prepare($sql) → bind values → execute() → fetch results.'),
(24,'beginner','Never Interpolate User Data','Never: "SELECT * FROM users WHERE id = $id". Always use prepared statements with ? or :name placeholders.'),
(24,'intermediate','Transactions','$pdo->beginTransaction(); ... $pdo->commit(); Wrap multi-step writes in a transaction so they all succeed or all roll back.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (24,280,1),(24,281,2),(24,282,3);

-- ── Security (topic_id = 25) ──────────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(290,25,'Password Hashing',
 'Fill in the blank — hash a password securely before storing it.',
 'fill_blank','beginner',
 '$hash = ______($password, PASSWORD_BCRYPT);',
 'password_hash',
 'PHP has a purpose-built function for password hashing.',
 'password_hash($password, PASSWORD_BCRYPT) generates a bcrypt hash with a random salt. Never use md5/sha1 for passwords.',
 1,1),

(291,25,'Verify Password',
 'Fill in the blank — check if a submitted password matches the stored hash.',
 'fill_blank','beginner',
 'if (______ ($submitted, $storedHash)) {
    // logged in
}',
 'password_verify',
 'A companion function checks a plain password against a hash.',
 'password_verify($plain, $hash) returns true if the plain text matches the hash. It is timing-safe so it resists timing attacks.',
 1,2),

(292,25,'XSS Prevention',
 'Spot the bug — this code is vulnerable to XSS.',
 'spot_bug','beginner',
 'echo "<p>Welcome, " . $_GET["name"] . "</p>";',
 'echo "<p>Welcome, " . htmlspecialchars($_GET["name"], ENT_QUOTES, "UTF-8") . "</p>";',
 'User input echoed into HTML must be escaped.',
 'htmlspecialchars() converts < > & " '' into safe HTML entities, preventing injected scripts from executing.',
 0,3),

(293,25,'CSRF Token',
 'Fill in the blank — generate a CSRF token and store it in the session.',
 'fill_blank','intermediate',
 'session_start();
$_SESSION["csrf"] = ______;',
 'bin2hex(random_bytes(32))',
 'A cryptographically secure random value prevents cross-site request forgery.',
 'random_bytes(32) generates 32 cryptographically secure random bytes. bin2hex converts them to a hex string safe for HTML. Store in session, compare on form submit.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(25,'all','Security Checklist','Hash passwords with password_hash. Escape output with htmlspecialchars. Use prepared statements. Validate CSRF tokens. Set secure/HttpOnly cookie flags.'),
(25,'beginner','Never Use md5/sha1 for Passwords','They are fast and therefore brute-forceable. password_hash uses bcrypt or argon2 with a work factor that can be increased over time.'),
(25,'intermediate','Security Headers','Content-Security-Policy, X-Frame-Options, and Strict-Transport-Security headers greatly reduce attack surface. Set them in every response.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (25,290,1),(25,291,2),(25,292,3);

-- ── REST APIs (topic_id = 26) ─────────────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(300,26,'Send JSON Response',
 'Fill in the blank — set the Content-Type header before echoing JSON.',
 'fill_blank','beginner',
 '______("Content-Type: application/json");
echo json_encode(["status" => "ok"]);',
 'header',
 'Headers are sent with a built-in function.',
 'header() sends raw HTTP headers. Always call it before any output. application/json tells clients to parse the body as JSON.',
 1,1),

(301,26,'Read Request Method',
 'Fill in the blank — get the HTTP method of the current request.',
 'fill_blank','beginner',
 '$method = ______["REQUEST_METHOD"];',
 '$_SERVER',
 'Request metadata lives in a superglobal.',
 '$_SERVER["REQUEST_METHOD"] returns "GET", "POST", "PUT", "DELETE", etc. Route requests based on this value.',
 1,2),

(302,26,'Read JSON Body',
 'Fill in the blank — read and decode a JSON request body sent by the client.',
 'fill_blank','intermediate',
 '$body = file_get_contents(______);
$data = json_decode($body, true);',
 '"php://input"',
 'PHP has a special stream for the raw request body.',
 'php://input is a read-only stream that holds the raw HTTP request body. Use it to read JSON or XML sent with PUT/POST requests.',
 0,3),

(303,26,'HTTP Status Codes',
 'Fill in the blank — send a 201 Created response.',
 'fill_blank','beginner',
 'http_response_code(______);
echo json_encode(["id" => $newId]);',
 '201',
 'REST conventions use specific numeric codes: 200 OK, 201 Created, 404 Not Found, 422 Unprocessable Entity.',
 'http_response_code(201) sets the response status. 201 Created is the correct code when a new resource has been successfully created.',
 0,4);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(26,'all','REST Conventions','GET=read, POST=create, PUT/PATCH=update, DELETE=remove. Return appropriate status codes. Always respond with JSON and Content-Type header.'),
(26,'beginner','Status Codes','200 OK  201 Created  204 No Content  400 Bad Request  401 Unauthorized  403 Forbidden  404 Not Found  422 Unprocessable  500 Server Error'),
(26,'intermediate','CORS','Cross-origin requests need Access-Control-Allow-Origin and preflight handling. header("Access-Control-Allow-Origin: *") is the simplest permissive setting.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (26,300,1),(26,301,2),(26,302,3);

-- ── Composer & Autoloading (topic_id = 27) ───────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(310,27,'Require Autoloader',
 'Fill in the blank — include Composer''s autoloader.',
 'fill_blank','beginner',
 'require ______;',
 '"vendor/autoload.php"',
 'Composer generates an autoloader in the vendor directory.',
 'require "vendor/autoload.php" loads Composer''s class map. After this, any class covered by PSR-4 autoloading is available without manual includes.',
 1,1),

(311,27,'composer.json require',
 'Fill in the blank — the key in composer.json that lists runtime dependencies.',
 'fill_blank','beginner',
 '{
    "______": {
        "monolog/monolog": "^3.0"
    }
}',
 'require',
 '"require" for runtime; "require-dev" for development-only packages.',
 '"require" lists packages needed to run the app. "require-dev" lists packages only needed for development (testing, linting, etc.).',
 1,2),

(312,27,'PSR-4 Autoload Config',
 'Spot the bug — classes in src/ are not found by Composer''s autoloader.',
 'spot_bug','intermediate',
 '{
    "autoload": {
        "psr-4": {
            "App\\": "app/"
        }
    }
}',
 '"App\\\\": "src/"',
 'The directory path must match where the source files actually live.',
 'The PSR-4 mapping must point to the actual directory. If classes are in src/, the value should be "src/". Run composer dump-autoload after changing this.',
 0,3);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(27,'all','Composer Workflow','composer init → add require entries → composer install → require vendor/autoload.php → use classes.'),
(27,'beginner','Key Commands','composer install  — install from composer.lock
composer require vendor/pkg  — add a package
composer update  — update to latest allowed versions
composer dump-autoload  — regenerate class map'),
(27,'intermediate','Semantic Versioning','^3.0 allows >=3.0.0 <4.0.0. ~3.1 allows >=3.1 <3.2. Prefer ^ for libraries. Lock files pin exact versions for reproducible builds.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (27,310,1),(27,311,2),(27,312,3);

-- ── PHP 8.x Features (topic_id = 28) ─────────────────────────
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(320,28,'Named Arguments',
 'Fill in the blank — call array_slice using named arguments to skip the first argument.',
 'fill_blank','intermediate',
 '$result = array_slice($array, offset: 2, ______: 3);',
 'length',
 'Named arguments use the parameter name followed by a colon.',
 'Named arguments (PHP 8.0+) let you pass arguments by name in any order, skipping optional ones: array_slice($arr, offset: 2, length: 3).',
 1,1),

(321,28,'Match Expression',
 'Fill in the blank — use match (not switch) to map HTTP codes to labels.',
 'fill_blank','beginner',
 '$label = ______ ($code) {
    200 => "OK",
    404 => "Not Found",
    default => "Other",
};',
 'match',
 'PHP 8 introduced a match expression that returns a value.',
 'match uses strict === comparison, has no fall-through, and throws UnhandledMatchError if no arm matches (unless default is present). It returns a value directly.',
 1,2),

(322,28,'Nullsafe Operator',
 'Spot the bug — the code crashes with a TypeError when getUser() returns null.',
 'spot_bug','beginner',
 '$city = $user->getAddress()->getCity();',
 '$city = $user?->getAddress()?->getCity();',
 'PHP 8 introduced an operator that short-circuits on null.',
 '?-> is the nullsafe operator. If any part of the chain returns null, the whole expression short-circuits to null instead of throwing an error.',
 0,3),

(323,28,'Enums',
 'Fill in the blank — declare a backed enum Status with string values.',
 'fill_blank','intermediate',
 '______ Status: string {
    case Active = ''active'';
    case Inactive = ''inactive'';
}',
 'enum',
 'PHP 8.1 added a dedicated keyword for enumerations.',
 'enum (PHP 8.1+) declares a type-safe set of named values. Backed enums (: string or : int) have scalar values accessible via ->value.',
 0,4),

(324,28,'Fibers',
 'Fill in the blank — suspend a Fiber''s execution and yield a value back to the caller.',
 'fill_blank','advanced',
 '$fiber = new Fiber(function(): void {
    $val = Fiber::______(''hello'');
    echo "Resumed with: $val";
});',
 'suspend',
 'A static method on Fiber pauses execution.',
 'Fiber::suspend($value) pauses the fiber and returns $value to whoever called $fiber->resume() or $fiber->start(). Fibers enable cooperative concurrency in PHP 8.1+.',
 0,5);

INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(28,'all','PHP 8 Highlights','Named args, match, nullsafe ?->, constructor promotion, union types, enums (8.1), fibers (8.1), readonly properties (8.1), intersection types (8.1).'),
(28,'beginner','match vs switch','match: strict ===, no fall-through, returns a value, throws on unmatched. switch: loose ==, falls through, statement-based.'),
(28,'intermediate','Readonly Properties','readonly string $name; — can only be assigned once (in the constructor). Great for value objects and DTOs.');

INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (28,320,1),(28,321,2),(28,322,3);


-- ═══════════════════════════════════════════════════════════════
-- Remediation challenges for new topics (IDs 100+)
-- ═══════════════════════════════════════════════════════════════

-- Loops (topic_id = 6)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(100,6,'for-loop',
 'Fill in the blank — write a for loop that prints squares of 1 through 5 (1, 4, 9, 16, 25).',
 'fill_blank',
 'for ($i = 1; $i <= 5; ______) {
    echo $i * $i . "\n";
}',
 '$i++',
 'The third part of a for loop advances the counter. $i++ increments $i by 1 after each iteration.'),

(101,6,'while-loop',
 'Spot the bug — this while loop never ends.',
 'spot_bug',
 '$i = 0;
while ($i < 5) {
    echo $i;
}',
 '$i++;',
 'Without incrementing $i, the condition $i < 5 is always true. Add $i++; inside the loop body.'),

(102,6,'foreach',
 'Fill in the blank — iterate over $colors and print each value.',
 'fill_blank',
 '$colors = ["red","green","blue"];
foreach ($colors as ______) {
    echo $color . "\n";
}',
 '$color',
 'The variable after "as" receives each element''s value on every iteration.'),

(103,6,'break-continue',
 'Fill in the blank — exit the loop immediately when $i equals 3.',
 'fill_blank',
 'for ($i = 0; $i < 10; $i++) {
    if ($i === 3) ______;
    echo $i;
}',
 'break',
 'break exits the nearest enclosing loop immediately. continue would skip only the current iteration.');

-- Functions (topic_id = 7)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(104,7,'define-function',
 'Fill in the blank — define a function multiply that returns $a times $b.',
 'fill_blank',
 'function multiply($a, $b) {
    ______ $a * $b;
}',
 'return',
 'return sends a value back to the caller. Without it the function returns null.'),

(105,7,'default-params',
 'Spot the bug — calling greet("Alice") crashes because $greeting has no default.',
 'spot_bug',
 'function greet($name, $greeting) {
    return "$greeting, $name!";
}
echo greet("Alice");',
 'function greet($name, $greeting = "Hello")',
 'Adding = "Hello" makes $greeting optional. Parameters with defaults must come after required parameters.'),

(106,7,'scope',
 'Fill in the blank — make the outer $total accessible inside the function.',
 'fill_blank',
 '$total = 100;
function addTax() {
    ______ $total;
    $total *= 1.2;
}
addTax();
echo $total;',
 'global',
 'global $var; imports an outer variable into a function''s scope. Prefer passing as a parameter when possible.');

-- Form Handling (topic_id = 8)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(107,8,'post-data',
 'Fill in the blank — safely read and echo the "username" field from a POST form.',
 'fill_blank',
 '$name = htmlspecialchars(______["username"] ?? "", ENT_QUOTES, "UTF-8");
echo $name;',
 '$_POST',
 '$_POST holds form fields submitted via HTTP POST. Always escape before output with htmlspecialchars.'),

(108,8,'xss',
 'Spot the bug — this code is vulnerable to XSS.',
 'spot_bug',
 '$msg = $_POST["message"];
echo "<div>$msg</div>";',
 '$msg = htmlspecialchars($_POST["message"], ENT_QUOTES, "UTF-8");',
 'htmlspecialchars() converts special HTML characters to entities, preventing injected scripts from running.');

-- Array Functions (topic_id = 10)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(109,10,'array_map',
 'Fill in the blank — use array_map to triple every number in $nums.',
 'fill_blank',
 '$nums = [1, 2, 3];
$tripled = array_map(______, $nums);',
 'fn($n) => $n * 3',
 'array_map applies the callback to each element and returns a new array. Arrow functions (fn) are concise for simple transformations.'),

(110,10,'array_filter',
 'Spot the bug — the filter should keep numbers above 10 but keeps all of them.',
 'spot_bug',
 '$nums = [5, 15, 3, 20];
$big = array_filter($nums, fn($n) => $n > 0);',
 'fn($n) => $n > 10',
 '$n > 0 is always true for positive numbers. The condition should be $n > 10 to keep only numbers above 10.');

-- Date & Time (topic_id = 11)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(111,11,'date-format',
 'Fill in the blank — output the current date as "Day, DD Month YYYY" (e.g. "Saturday, 15 June 2024").',
 'fill_blank',
 'echo date(______);',
 '"l, d F Y"',
 'l=full weekday, d=zero-padded day, F=full month name, Y=4-digit year.'),

(112,11,'strtotime',
 'Spot the bug — the timestamp is 0 because the date string is malformed.',
 'spot_bug',
 '$ts = strtotime("June 15 2024");
echo date("Y-m-d", $ts);',
 '$ts = strtotime("2024-06-15");',
 'strtotime understands ISO 8601 dates reliably. Non-standard formats can produce unexpected results. Use "YYYY-MM-DD" for safety.');

-- OOP Classes (topic_id = 20)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(113,20,'class-property',
 'Fill in the blank — declare a protected integer property $age in the Person class.',
 'fill_blank',
 'class Person {
    ______ int $age;
}',
 'protected',
 'protected means the property is accessible inside the class and any subclass, but not from outside.'),

(114,20,'constructor',
 'Spot the bug — the constructor sets $this->name but the property is never declared.',
 'spot_bug',
 'class Dog {
    public function __construct(string $name) {
        $this->name = $name;
    }
}',
 'public string $name;',
 'Typed properties must be declared. Adding public string $name; before __construct fixes it. Or use constructor promotion: public function __construct(public string $name) {}');

-- PDO (topic_id = 24)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(115,24,'prepared-statement',
 'Spot the bug — this query is vulnerable to SQL injection.',
 'spot_bug',
 '$id = $_GET["id"];
$stmt = $pdo->query("SELECT * FROM users WHERE id = $id");',
 '$stmt = $pdo->prepare("SELECT * FROM users WHERE id = :id");
$stmt->bindValue(":id", $id, PDO::PARAM_INT);
$stmt->execute();',
 'Never interpolate user input into SQL. Use prepare() and bindValue() so PDO handles escaping.'),

(116,24,'fetch',
 'Fill in the blank — fetch a single row as an associative array.',
 'fill_blank',
 '$stmt->execute();
$row = $stmt->______(PDO::FETCH_ASSOC);',
 'fetch',
 'fetch() returns one row (or false when there are no more). fetchAll() returns all rows at once.');

-- Security (topic_id = 25)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(117,25,'password-hash',
 'Spot the bug — the password is stored using a weak hashing algorithm.',
 'spot_bug',
 '$hash = md5($password);',
 '$hash = password_hash($password, PASSWORD_BCRYPT);',
 'MD5 is fast and reversible via rainbow tables. password_hash uses bcrypt with a salt and a configurable cost factor.'),

(118,25,'password-verify',
 'Fill in the blank — verify the submitted password against the stored hash.',
 'fill_blank',
 'if (______($submitted, $storedHash)) {
    // grant access
}',
 'password_verify',
 'password_verify($plain, $hash) compares safely using a timing-safe comparison to prevent timing attacks.');

-- PHP 8.x (topic_id = 28)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(119,28,'match',
 'Fill in the blank — replace the switch with a match expression that assigns $result.',
 'fill_blank',
 '$code = 404;
$result = match(______) {
    200 => "OK",
    404 => "Not Found",
    default => "Unknown",
};',
 '$code',
 'match($expr) evaluates $expr and compares it strictly (===) against each arm.'),

(120,28,'nullsafe',
 'Spot the bug — the code crashes when $order is null.',
 'spot_bug',
 '$city = $order->getCustomer()->getAddress()->getCity();',
 '$city = $order?->getCustomer()?->getAddress()?->getCity();',
 '?-> short-circuits the entire chain to null if any step returns null, preventing TypeError.');
