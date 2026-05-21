// CodeMirror 6 — loaded only on write_code challenges
// Imports from esm.sh (free CDN, no npm required)
import { EditorView, keymap } from 'https://esm.sh/@codemirror/view@6';
import { EditorState } from 'https://esm.sh/@codemirror/state@6';
import { defaultKeymap, indentWithTab } from 'https://esm.sh/@codemirror/commands@6';
import { php } from 'https://esm.sh/@codemirror/lang-php@6';
import { oneDark } from 'https://esm.sh/@codemirror/theme-one-dark@6';
import { basicSetup } from 'https://esm.sh/codemirror@6';

const mount  = document.getElementById('cm-editor');
const hidden = document.getElementById('cm-answer');
if (mount && hidden) {
    const startDoc = mount.dataset.starter || '';
    const view = new EditorView({
        state: EditorState.create({
            doc: startDoc,
            extensions: [
                basicSetup,
                php(),
                oneDark,
                keymap.of([indentWithTab, ...defaultKeymap]),
                EditorView.updateListener.of(update => {
                    if (update.docChanged) {
                        hidden.value = update.state.doc.toString();
                    }
                }),
                EditorView.theme({
                    '&': { fontSize: '0.9rem', minHeight: '140px' },
                    '.cm-scroller': { fontFamily: "'Courier New', monospace" },
                }),
            ],
        }),
        parent: mount,
    });
    // Initialise hidden input with starter code
    hidden.value = startDoc;
}
