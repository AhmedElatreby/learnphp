// php-wasm in-browser PHP runner
// Used for write_code challenges — shows output without grading

async function runCode() {
    const answer = document.getElementById('cm-answer')?.value
                ?? document.querySelector('textarea[name="answer"]')?.value
                ?? '';
    const output = document.getElementById('runner-output');
    const pre    = document.getElementById('runner-pre');

    output.style.display = 'block';
    pre.textContent = 'Running…';

    try {
        const { PhpWeb } = await import('https://cdn.jsdelivr.net/npm/php-wasm/PhpWeb.mjs');
        const php  = new PhpWeb();
        const code = answer.trim().startsWith('<?php') ? answer : '<?php\n' + answer;
        const result = await php.run(code);
        pre.textContent = result.output || '(no output)';
    } catch (e) {
        pre.textContent = 'Error: ' + e.message;
    }
}
