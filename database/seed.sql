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
