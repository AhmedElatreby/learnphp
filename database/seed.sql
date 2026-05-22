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

-- ═══════════════════════════════════════════════
-- Variables & Data Types (topic_id = 1)
-- ═══════════════════════════════════════════════
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(4,1,'Assign a Variable',
 'Fill in the blank to assign the string "PHP" to the variable.',
 'fill_blank','beginner',
 '$name = ______;',
 '"PHP"',
 'Strings are wrapped in quotes. Variables start with $.',
 'In PHP, variables start with $. Strings are wrapped in single or double quotes: $name = "PHP". Single quotes also work.',
 1, 1),

(5,1,'Spot the Variable Bug',
 'This code should print "Hello" but throws an error. Find and fix the bug.',
 'spot_bug','beginner',
 'name = "Hello";
echo $name;',
 '$name = "Hello";',
 'PHP variable names always start with a dollar sign.',
 'Every PHP variable must begin with $. Without it, PHP does not recognise "name" as a variable. The fix is $name = "Hello";',
 1, 2),

(6,1,'Get a Variable Type',
 'Fill in the built-in function that returns the type of a variable as a string.',
 'fill_blank','beginner',
 '$x = 42;
echo ______($x); // prints "integer"',
 'gettype',
 'Think: "get the type".',
 'gettype() returns a string describing the variable type: "integer", "double", "string", "boolean", "array", "NULL", etc.',
 0, 3),

(7,1,'Type Casting',
 'Fill in the blank to cast the string $str to an integer using PHP cast syntax.',
 'fill_blank','beginner',
 '$str = "42";
$num = ______;',
 '(int)$str',
 'PHP uses (type) prefix syntax for casting: (int), (float), (string).',
 '(int)$str casts the string "42" to integer 42. You can also use intval($str). Casting is essential when handling form input, which always arrives as strings.',
 0, 4),

(8,1,'Strict Comparison',
 'Fill in the blank — use strict equality so the comparison returns false when types differ.',
 'fill_blank','intermediate',
 '$a = "1";
$b = 1;
var_dump($a ______ $b); // bool(false)',
 '===',
 '== checks value only; === checks value AND type.',
 '== (loose) returns true for "1" == 1 because PHP coerces types. === (strict) returns false because one is a string and the other an integer. Prefer === to avoid surprise type coercion bugs.',
 0, 5),

(9,1,'Loose Comparison Trap',
 'Spot the bug — this should print "not empty" for "hello" but prints "empty".',
 'spot_bug','intermediate',
 '$input = "hello";
if ($input == 0) {
    echo "empty";
} else {
    echo "not empty";
}',
 'if ($input === 0) {',
 'Comparing a non-numeric string to 0 with == is always true in PHP.',
 'When PHP compares a non-numeric string to an integer with ==, it converts the string to 0. So "hello" == 0 is true. Use === to compare value AND type.',
 1, 6),

(10,1,'Null Coalescing Operator',
 'Fill in the blank — use ?? to return $config[''timeout''] if set, otherwise 30.',
 'fill_blank','intermediate',
 '$config = [];
$timeout = ______;',
 '$config[''timeout''] ?? 30',
 'The ?? operator returns the left side if it exists and is not null, otherwise the right side.',
 'The null coalescing operator ?? (PHP 7+) returns the left operand if it exists and is not null, otherwise the right operand.',
 0, 7),

(11,1,'Define a Constant',
 'Write the statement to define a constant named MAX_SIZE with value 100.',
 'fill_blank','advanced',
 '',
 'define(''MAX_SIZE'', 100)',
 'PHP uses define() or the const keyword.',
 'define(''MAX_SIZE'', 100) creates a global constant. Constants have no $ prefix and cannot be changed after definition.',
 0, 8);

-- Tips for Variables & Data Types (topic_id = 1)
INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(1,'all','Quick Reference',
 '$x = 42;       // integer
$y = 3.14;     // float
$s = "hello";  // string
$b = true;     // boolean
$n = null;     // null
gettype($x)    // "integer"'),
(1,'beginner','Common Mistake',
 'Forgetting the $ prefix: name = "PHP" causes an error. Always: $name = "PHP".'),
(1,'intermediate','=== vs ==',
 'Use === (strict) not == (loose). "1" == 1 is true; "1" === 1 is false. Loose comparison causes hard-to-find bugs.');

-- Section test for Variables (challenges 4, 5, 6)
INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (1,4,1),(1,5,2),(1,6,3);

-- Follow-up for challenge 4
INSERT OR IGNORE INTO followup_challenges (challenge_id,prompt,type,solution,explanation) VALUES
(4,'What character do ALL PHP variable names start with? Fill in: ______name = "PHP";',
 'fill_blank','$',
 'Every PHP variable starts with a dollar sign $. Without it PHP does not recognise it as a variable.');


-- ═══════════════════════════════════════════════
-- Operators (topic_id = 2)
-- ═══════════════════════════════════════════════
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(12,2,'Modulo Operator',
 'Fill in the blank — what is the result of 10 % 3?',
 'fill_blank','beginner',
 '$result = 10 % 3;
echo $result; // ______',
 '1',
 'The % operator returns the remainder after division.',
 '10 divided by 3 is 3 remainder 1. The modulo operator % returns that remainder.',
 1, 1),

(13,2,'String Concatenation',
 'Fill in the blank — concatenate $first and $last with a space between them.',
 'fill_blank','beginner',
 '$first = "John";
$last  = "Doe";
$full  = ______;',
 '$first . " " . $last',
 'PHP uses the dot (.) operator for string concatenation, not +.',
 'In PHP, strings are joined with . (dot). $first . " " . $last produces "John Doe".',
 1, 2),

(14,2,'Assignment vs Comparison',
 'Spot the bug — the condition always evaluates to true.',
 'spot_bug','beginner',
 '$score = 50;
if ($score = 100) {
    echo "Perfect!";
}',
 'if ($score == 100) {',
 'One = is assignment; == is comparison.',
 '$score = 100 inside an if is an assignment, not a comparison. It assigns 100 to $score (truthy), so the block always runs.',
 0, 3),

(15,2,'Increment / Decrement',
 'Fill in the blank — increment $counter by 1 using the shortest PHP syntax.',
 'fill_blank','beginner',
 '$counter = 5;
______;
echo $counter; // 6',
 '$counter++',
 'PHP has ++ (post-increment) and -- (post-decrement) operators.',
 '$counter++ is post-increment: it returns the current value then increments.',
 0, 4),

(16,2,'Ternary Operator',
 'Fill in the blank — use the ternary operator to set $label to "adult" if $age >= 18, else "minor".',
 'fill_blank','intermediate',
 '$age = 20;
$label = ______;',
 '$age >= 18 ? "adult" : "minor"',
 'The ternary is: condition ? value_if_true : value_if_false',
 'The ternary operator is a one-line if/else: condition ? true_value : false_value.',
 1, 5),

(17,2,'Loose Equality Gotcha',
 'Spot the bug — this should only match the integer 0, not the string "foo".',
 'spot_bug','intermediate',
 '$val = "foo";
if ($val == 0) {
    echo "zero";
}',
 'if ($val === 0) {',
 'Non-numeric strings equal 0 under loose comparison.',
 'PHP converts non-numeric strings to 0 for arithmetic comparisons. "foo" == 0 is true. Use ===.',
 0, 6),

(18,2,'Null Coalescing Assignment',
 'Fill in the blank — use ??= to set $visits to 1 only if it is currently null.',
 'fill_blank','intermediate',
 '$visits = null;
$visits ______= 1;
echo $visits; // 1',
 '??',
 'PHP 7.4 added ??= which assigns only when the left side is null.',
 '$visits ??= 1 is shorthand for $visits = $visits ?? 1.',
 0, 7),

(19,2,'Spaceship Operator',
 'Fill in the blank — use the spaceship operator to compare $a and $b (returns -1, 0, or 1).',
 'fill_blank','advanced',
 '$a = 5;
$b = 10;
$result = ______;
echo $result; // -1',
 '$a <=> $b',
 'The spaceship operator <=> returns -1, 0, or 1.',
 '$a <=> $b returns -1 if $a < $b, 0 if equal, 1 if $a > $b.',
 0, 8);

-- Tips for Operators (topic_id = 2)
INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(2,'all','Quick Reference',
 '+ - * / %   arithmetic
.            concatenate strings
== ===       loose / strict equal
!= !==       loose / strict not-equal
&& ||        logical and / or
?:           ternary
??           null coalesce
<=>          spaceship (-1/0/1)'),
(2,'beginner','Common Mistake',
 'Using + to join strings: "Hello" + "World" gives 0 (numeric). Use . instead.'),
(2,'intermediate','Strict Always',
 'Default to === and !==. Only use == when you explicitly want type coercion.');

-- Section test for Operators (challenges 12, 14, 16)
INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (2,12,1),(2,14,2),(2,16,3);

-- Follow-up for challenge 12
INSERT OR IGNORE INTO followup_challenges (challenge_id,prompt,type,solution,explanation) VALUES
(12,'What operator gives you the remainder after division? Fill in: 10 ______ 3 gives 1',
 'fill_blank','%',
 'The modulo operator % returns the division remainder. 10 % 3 = 1 because 10 = 3x3 + 1.');

-- ═══════════════════════════════════════════════
-- Strings (topic_id = 3)
-- ═══════════════════════════════════════════════
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(20,3,'String Length',
 'Fill in the built-in function to get the number of characters in $str.',
 'fill_blank','beginner',
 '$str = "Hello";
echo ______($str); // 5',
 'strlen',
 'Think: "string length".',
 'strlen() returns the number of bytes in a string. For multibyte strings use mb_strlen().',
 1, 1),

(21,3,'String Interpolation',
 'Fill in the blank — embed the variable $name inside the double-quoted string.',
 'fill_blank','beginner',
 '$name = "World";
echo "Hello, ______!"; // Hello, World!',
 '$name',
 'PHP interpolates variables directly inside double-quoted strings.',
 'Inside double quotes, PHP replaces $variable with its value. Single quotes do NOT interpolate.',
 1, 2),

(22,3,'Uppercase Conversion',
 'Spot the bug — this should print "HELLO" but prints "hello".',
 'spot_bug','beginner',
 '$str = "hello";
echo strtolower($str);',
 'echo strtoupper($str);',
 'strtolower makes lowercase; strtoupper makes uppercase.',
 'strtolower() converts to lowercase, strtoupper() to uppercase. The code used the wrong function.',
 0, 3),

(23,3,'String Replace',
 'Fill in the blank — replace every "cat" with "dog" in $sentence.',
 'fill_blank','beginner',
 '$sentence = "I love my cat. My cat is great.";
echo ______("cat", "dog", $sentence);',
 'str_replace',
 'PHP has a function called str_replace.',
 'str_replace($search, $replace, $subject) replaces all occurrences. It is case-sensitive. Use str_ireplace() for case-insensitive replacement.',
 0, 4),

(24,3,'strpos Truthy Trap',
 'Spot the bug — this should print "found" when "PHP" is at position 0 but prints "not found".',
 'spot_bug','intermediate',
 '$str = "PHP is great";
if (strpos($str, "PHP")) {
    echo "found";
} else {
    echo "not found";
}',
 'if (strpos($str, "PHP") !== false) {',
 'strpos returns 0 when found at position 0 — and 0 is falsy.',
 'strpos() returns the integer position or false if not found. Position 0 is falsy, so bare if (strpos(...)) misses matches at the start. Always use !== false.',
 1, 5),

(25,3,'Substring',
 'Fill in the blank — extract 5 characters starting from position 7.',
 'fill_blank','intermediate',
 '$str = "Hello, World!";
echo ______($str, 7, 5); // World',
 'substr',
 'PHP has a function to extract part of a string.',
 'substr($string, $start, $length) extracts $length characters from $string starting at $start (0-indexed).',
 0, 6),

(26,3,'String Padding',
 'Fill in the blank — pad $num with leading zeros to make it 5 characters wide.',
 'fill_blank','intermediate',
 '$num = "42";
echo ______($num, 5, "0", STR_PAD_LEFT); // 00042',
 'str_pad',
 'PHP has a str_pad() function for padding strings.',
 'str_pad($input, $length, $pad_string, $pad_type) pads a string to a given length. STR_PAD_LEFT pads on the left.',
 0, 7),

(27,3,'sprintf Formatting',
 'Fill in the blank — use sprintf to format $price as a 2-decimal float.',
 'fill_blank','advanced',
 '$price = 9.5;
echo ______("$%.2f", $price); // $9.50',
 'sprintf',
 'sprintf() formats strings using placeholders like %.2f for 2-decimal floats.',
 'sprintf($format, ...$values) returns a formatted string. %.2f formats a float to 2 decimal places.',
 0, 8);

-- Tips for Strings (topic_id = 3)
INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(3,'all','Quick Reference',
 'strlen($s)               // length
strtoupper/strtolower($s) // case
str_replace($f,$r,$s)    // replace
strpos($s,$needle)        // position (use !== false!)
substr($s,$start,$len)   // slice
trim($s)                 // strip whitespace'),
(3,'beginner','Single vs Double Quotes',
 'Double quotes interpolate variables: "Hello $name" -> Hello World
Single quotes are literal: ''Hello $name'' -> Hello $name'),
(3,'intermediate','strpos Gotcha',
 'strpos returns 0 when the needle is at the start — 0 is falsy!
Always: if (strpos($str, $needle) !== false) { ... }');

-- Section test for Strings (challenges 20, 21, 24)
INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (3,20,1),(3,21,2),(3,24,3);

-- Follow-up for challenge 21
INSERT OR IGNORE INTO followup_challenges (challenge_id,prompt,type,solution,explanation) VALUES
(21,'Which type of quotes allow variable interpolation in PHP? Fill in: ______ quotes',
 'fill_blank','double',
 'Only double-quoted strings interpolate variables. Single-quoted strings treat $ as literal.');


-- ═══════════════════════════════════════════════
-- Arrays additions (topic_id = 4, IDs 28-32)
-- ═══════════════════════════════════════════════
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(28,4,'Associative Array',
 'Fill in the blank — create an associative array with key "color" set to "red".',
 'fill_blank','beginner',
 '$car = ______;',
 '["color" => "red"]',
 'Associative arrays use => to map keys to values.',
 'Associative arrays use string keys: ["color" => "red"]. Access values with $car["color"].',
 1, 4),

(29,4,'Add to Array',
 'Fill in the blank — append "cherry" to the end of $fruits.',
 'fill_blank','intermediate',
 '$fruits = ["apple", "banana"];
______;',
 '$fruits[] = "cherry"',
 '$arr[] = $value appends to the end.',
 '$fruits[] = "cherry" is idiomatic PHP for appending. Equivalent to array_push($fruits, "cherry").',
 0, 5),

(30,4,'foreach Loop',
 'Spot the bug — this should print each fruit on its own line but prints nothing.',
 'spot_bug','intermediate',
 '$fruits = ["apple", "banana", "cherry"];
foreach ($fruit as $item) {
    echo $item . "\n";
}',
 'foreach ($fruits as $item) {',
 'Check the variable name in the foreach — does it match the array?',
 'The foreach references $fruit (singular) but the array is $fruits (plural). Fix: foreach ($fruits as $item).',
 0, 6),

(31,4,'array_map',
 'Fill in the blank — use array_map to double every number in $numbers.',
 'fill_blank','advanced',
 '$numbers = [1, 2, 3, 4];
$doubled = ______($numbers);',
 'array_map(fn($n) => $n * 2,',
 'array_map applies a callback to every element and returns a new array.',
 'array_map(callback, array) applies the callback to each element and returns a new array.',
 0, 7),

(32,4,'array_filter',
 'Fill in the blank — keep only even numbers from $numbers.',
 'fill_blank','advanced',
 '$numbers = [1, 2, 3, 4, 5, 6];
$evens = ______($numbers, fn($n) => $n % 2 === 0);',
 'array_filter',
 'array_filter keeps elements where the callback returns true.',
 'array_filter(array, callback) returns elements for which the callback returns true.',
 0, 8);

-- Section test additions for Arrays
INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (4,28,4),(4,29,5),(4,30,6);

-- Tips additions for Arrays
INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(4,'intermediate','Array Functions',
 'array_map($fn, $arr)     // transform each element
array_filter($arr, $fn)  // keep matching elements
array_keys($arr)         // get all keys
in_array($val, $arr)     // check membership'),
(4,'advanced','Keys After filter',
 'array_filter preserves original keys.
Use array_values(array_filter(...)) to get a re-indexed array.');


-- ═══════════════════════════════════════════════
-- Conditionals (topic_id = 5)
-- ═══════════════════════════════════════════════
INSERT OR IGNORE INTO challenges (id,topic_id,title,prompt,type,difficulty,starter_code,solution,hint,explanation,is_diagnostic,sort_order) VALUES
(33,5,'Basic if/else',
 'Fill in the blank — print "pass" if $score is 50 or above, otherwise "fail".',
 'fill_blank','beginner',
 '$score = 75;
if (______) {
    echo "pass";
} else {
    echo "fail";
}',
 '$score >= 50',
 'The >= operator means "greater than or equal to".',
 'The condition $score >= 50 is true when $score is 50 or above.',
 1, 1),

(34,5,'elseif Chain',
 'Fill in the keyword — complete the elseif chain to add a "B" grade check.',
 'fill_blank','beginner',
 '$score = 85;
if ($score >= 90) {
    echo "A";
} ______ ($score >= 80) {
    echo "B";
} elseif ($score >= 70) {
    echo "C";
}',
 'elseif',
 'PHP uses elseif (one word) for additional conditions.',
 'elseif adds another condition to an if chain. Both elseif and else if work, but elseif is the PHP convention.',
 1, 2),

(35,5,'Switch Statement',
 'Fill in the blank — complete the switch to handle the "admin" role.',
 'fill_blank','beginner',
 '$role = "admin";
switch ($role) {
    case "admin":
        echo "Full access";
        ______;
    case "editor":
        echo "Edit access";
        break;
}',
 'break',
 'Without break, execution falls through to the next case.',
 'switch cases fall through without break. Without break after "Full access", PHP would also print "Edit access".',
 0, 3),

(36,5,'Switch Fall-Through Bug',
 'Spot the bug — "Medium" is printed even when $size is "small".',
 'spot_bug','intermediate',
 '$size = "small";
switch ($size) {
    case "small":
        echo "Small";
    case "medium":
        echo "Medium";
        break;
    case "large":
        echo "Large";
        break;
}',
 'case "small":
        echo "Small";
        break;',
 'A missing break causes execution to fall into the next case.',
 'Without break after case "small", execution falls through to "medium". Add break after each case.',
 0, 4),

(37,5,'match Expression',
 'Fill in the blank — use the match expression to map $status to a label.',
 'fill_blank','intermediate',
 '$status = "active";
$label = ______ ($status) {
    "active"   => "Active User",
    "inactive" => "Inactive",
    default    => "Unknown",
};',
 'match',
 'PHP 8 introduced match — like switch but returns a value and uses strict comparison.',
 'match (PHP 8+) returns a value, uses strict === comparison, and throws UnhandledMatchError if no arm matches.',
 1, 5),

(38,5,'match Strict Types',
 'Spot the bug — match should NOT match integer 0 with the false arm.',
 'spot_bug','intermediate',
 '$val = 0;
$result = match($val) {
    false => "Boolean false",
    0     => "Zero integer",
    default => "Other",
};
echo $result;',
 '$result = match($val) {
    0     => "Zero integer",
    false => "Boolean false",
    default => "Other",
};',
 'match uses strict === comparison. What is 0 === false?',
 'match uses strict comparison. 0 !== false under ===, but arms are checked in order. Move the 0 arm before false to match the integer correctly.',
 0, 6),

(39,5,'Null Safe Operator',
 'Fill in the blank — use the null-safe operator to call getCity() on $user only if it is not null.',
 'fill_blank','advanced',
 '$user = null;
$city = $user______getCity();
echo $city ?? "unknown"; // unknown',
 '?->',
 'PHP 8 added the null-safe operator ?->.',
 '$user?->getCity() returns null without error if $user is null, instead of throwing "Call to a member function on null".',
 0, 7),

(40,5,'Short-Circuit Evaluation',
 'Fill in the blank — use && so loadUser() is only called if $id is truthy.',
 'fill_blank','advanced',
 '$id = 0;
$result = $id ______ loadUser($id);
// loadUser() should NOT be called when $id is 0',
 '&&',
 'With &&, if the left side is falsy the right side is never evaluated.',
 '&& short-circuits: if $id is falsy (0, "", null, false), PHP skips the right side entirely.',
 0, 8);

-- Tips for Conditionals (topic_id = 5)
INSERT OR IGNORE INTO tips (topic_id,difficulty,title,content) VALUES
(5,'all','Quick Reference',
 'if / elseif / else     // classic branching
switch / case / break   // multi-value branching
match (PHP 8+)          // strict, returns value
??                      // null coalesce
?->                     // null-safe method call'),
(5,'beginner','switch Needs break',
 'Without break, switch falls through to the next case.
Always add break (or return) after each case body.'),
(5,'intermediate','match vs switch',
 'match uses === (strict), switch uses == (loose).
match throws if no arm matches; switch does nothing without default.
match returns a value; switch does not.');

-- Section test for Conditionals (challenges 33, 34, 37)
INSERT OR IGNORE INTO section_tests (topic_id,challenge_id,sort_order) VALUES (5,33,1),(5,34,2),(5,37,3);

-- Follow-up for challenge 33
INSERT OR IGNORE INTO followup_challenges (challenge_id,prompt,type,solution,explanation) VALUES
(33,'What operator checks if a number is greater than OR equal to another? Fill in: $score ______ 50',
 'fill_blank','>=',
 '>= means "greater than or equal to". $score >= 50 is true when score is 50 or above.');

-- ═══════════════════════════════════════════════
-- Remediation Challenges (4 per topic)
-- ═══════════════════════════════════════════════

-- Variables & Data Types (topic_id = 1)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(1,1,'types',
 'Fill in the blank — which function returns the type of a variable as a string?',
 'fill_blank',
 '$x = 42;
echo ______($x); // "integer"',
 'gettype',
 'gettype() returns a string describing the variable''s type: "integer", "double", "string", "boolean", "array", or "NULL".'),

(2,1,'casting',
 'Fill in the blank — cast the string $s to an integer.',
 'fill_blank',
 '$s = "7";
$n = ______;',
 '(int)$s',
 '(int)$variable casts to integer. intval($variable) also works. Form data always arrives as strings, so casting is essential.'),

(3,1,'comparison',
 'Spot the bug — this should only print "match" when $val is exactly the integer 0, not other falsy values.',
 'spot_bug',
 '$val = 0;
if ($val == false) {
    echo "match";
}',
 'if ($val === false) {',
 '== (loose) treats 0 and false as equal. === (strict) checks value AND type — 0 === false is false. Always prefer === to avoid type-coercion surprises.'),

(4,1,'constants',
 'Fill in the blank — define a constant named APP_VERSION with value "1.0".',
 'fill_blank',
 '______;',
 'define(''APP_VERSION'', ''1.0'')',
 'define(''NAME'', value) creates a global constant. Constants have no $ prefix and cannot be reassigned. Use const NAME = value inside class scope.');

-- Operators (topic_id = 2)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(5,2,'modulo',
 'Fill in the blank — what does 17 % 5 evaluate to?',
 'fill_blank',
 '$result = 17 % 5;
echo $result; // ______',
 '2',
 '17 divided by 5 is 3 remainder 2. The modulo operator % returns that remainder. Use n % 2 === 0 to test if a number is even.'),

(6,2,'concatenation',
 'Spot the bug — this should print "Hello World" but prints "0" instead.',
 'spot_bug',
 '$a = "Hello";
$b = "World";
echo $a + " " + $b;',
 'echo $a . " " . $b;',
 'PHP uses . (dot) for string concatenation, not + (plus). The + operator tries to add numerically — "Hello" becomes 0, so the result is 0.'),

(7,2,'ternary',
 'Fill in the blank — use the ternary operator to set $msg to "yes" if $ok is true, otherwise "no".',
 'fill_blank',
 '$ok = true;
$msg = ______;',
 '$ok ? "yes" : "no"',
 'The ternary operator: condition ? value_if_true : value_if_false. It is a one-line if/else that returns a value.'),

(8,2,'strict',
 'Fill in the blank — use strict equality to compare $a and $b.',
 'fill_blank',
 '$a = "5";
$b = 5;
var_dump($a ______ $b); // bool(false)',
 '===',
 '=== checks both value AND type. "5" === 5 is false because one is a string and one an integer. == would return true due to type coercion.');

-- Strings (topic_id = 3)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(9,3,'length',
 'Fill in the blank — get the number of characters in $word.',
 'fill_blank',
 '$word = "elephant";
echo ______($word); // 8',
 'strlen',
 'strlen() counts bytes (same as characters for ASCII/Latin text). For emoji or accented characters in UTF-8, use mb_strlen() instead.'),

(10,3,'interpolation',
 'Spot the bug — this should print "Hello Ahmed" but prints "Hello $name" literally.',
 'spot_bug',
 '$name = "Ahmed";
echo ''Hello $name'';',
 'echo "Hello $name";',
 'Single-quoted strings are literal — $variables are NOT interpolated. Use double quotes: "Hello $name" to embed variables directly in strings.'),

(11,3,'strpos',
 'Spot the bug — this should print "found" when "PHP" appears at the start of $str, but it prints "not found".',
 'spot_bug',
 '$str = "PHP is great";
if (strpos($str, "PHP")) {
    echo "found";
} else {
    echo "not found";
}',
 'if (strpos($str, "PHP") !== false) {',
 'strpos() returns the position (0 for the start), or false if not found. Position 0 is falsy, so bare if (strpos(...)) misses matches at the start. Always use !== false.'),

(12,3,'replace',
 'Fill in the blank — replace every "dog" with "cat" in $sentence.',
 'fill_blank',
 '$sentence = "I love my dog. My dog is great.";
echo ______("dog", "cat", $sentence);',
 'str_replace',
 'str_replace($search, $replace, $subject) replaces all occurrences of $search with $replace in $subject. It is case-sensitive. Use str_ireplace() for case-insensitive replacement.');

-- Arrays (topic_id = 4)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(13,4,'access',
 'Fill in the blank — access the second element of $colors.',
 'fill_blank',
 '$colors = ["red", "green", "blue"];
echo ______; // "green"',
 '$colors[1]',
 'Arrays are zero-indexed: $colors[0] is "red", $colors[1] is "green", $colors[2] is "blue". The second element is always at index 1.'),

(14,4,'count',
 'Fill in the blank — store the number of items in $fruits into $total.',
 'fill_blank',
 '$fruits = ["apple", "banana", "cherry", "date"];
$total = ______;',
 'count($fruits)',
 'count() returns the number of elements in an array. It is the standard PHP way to get array length — not sizeof() or length().'),

(15,4,'associative',
 'Spot the bug — this should print "Ahmed" but gives an error.',
 'spot_bug',
 '$user = ["name" => "Ahmed", "age" => 30];
echo $user[0];',
 'echo $user["name"];',
 'Associative arrays use string keys, not numeric indexes. $user[0] does not exist — use $user["name"] to access the "name" key.'),

(16,4,'foreach',
 'Fill in the blank — loop through $numbers and echo each one followed by a newline.',
 'fill_blank',
 '$numbers = [1, 2, 3, 4, 5];
foreach ($numbers as ______) {
    echo $n . "\n";
}',
 '$n',
 'foreach ($array as $item) iterates over each element. The variable after "as" ($n here) holds the current item. For key-value access use: foreach ($arr as $key => $value).');

-- Conditionals (topic_id = 5)
INSERT OR IGNORE INTO remediation_challenges (id,topic_id,weakness_tag,prompt,type,starter_code,solution,explanation) VALUES
(17,5,'if-else',
 'Fill in the blank — complete the condition so $grade is "pass" when $score is 50 or above.',
 'fill_blank',
 '$score = 65;
if (______) {
    $grade = "pass";
} else {
    $grade = "fail";
}',
 '$score >= 50',
 '>= means "greater than or equal to". $score >= 50 is true for scores of 50, 60, 100 — anything at or above 50.'),

(18,5,'switch',
 'Spot the bug — when $day is "Monday", this prints "Monday" AND "Tuesday".',
 'spot_bug',
 '$day = "Monday";
switch ($day) {
    case "Monday":
        echo "Monday";
    case "Tuesday":
        echo "Tuesday";
        break;
}',
 'case "Monday":
        echo "Monday";
        break;',
 'Without break, switch falls through to the next case. After printing "Monday" it continues into the "Tuesday" case. Add break after each case body to stop execution.'),

(19,5,'match',
 'Fill in the blank — use PHP 8 match to map $code to a label.',
 'fill_blank',
 '$code = 200;
$label = ______ ($code) {
    200 => "OK",
    404 => "Not Found",
    500 => "Server Error",
    default => "Unknown",
};',
 'match',
 'match (PHP 8+) is like switch but returns a value, uses strict === comparison, and throws UnhandledMatchError if no arm matches without a default.'),

(20,5,'elseif',
 'Fill in the blank — add an elseif to check if $score is between 60 and 79.',
 'fill_blank',
 '$score = 70;
if ($score >= 80) {
    echo "A";
} ______ ($score >= 60) {
    echo "B";
} else {
    echo "C";
}',
 'elseif',
 'elseif (one word) adds another condition branch. Both elseif and else if work in PHP, but elseif is the standard convention. The conditions are checked in order — first true branch runs.');

