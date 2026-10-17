const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { spawnSync } = require('node:child_process');

const translations = {};
vm.createContext(translations);
vm.runInContext(fs.readFileSync(path.join(__dirname, '../package/contents/ui/Translations.js'), 'utf8')
    .replace('.pragma library', ''), translations);

for (const language of translations.languageCodes) {
    assert.deepEqual(Object.keys(translations.messages[language]), Object.keys(translations.messages.en));
}
assert.equal(translations.tr(undefined, 'Configurações'), 'Settings');
assert.equal(translations.tr('pt_PT', 'Configurações'), 'Definições');
assert.equal(translations.tr('pt_BR', 'Configurações'), 'Configurações');
assert.equal(translations.tr('es', 'Configurações'), 'Configuración');
assert.equal(translations.tr('en', 'Num Lock: %1', translations.tr('en', 'ATIVADO')), 'Num Lock: ENABLED');

for (const language of translations.languageCodes) {
    for (const script of ['/tmp/script.sh', "/tmp/A person's script.sh", '/tmp/a;$(exit 1).sh']) {
        // Replace terminal and privilege launchers with argument recorders.
        const outer = spawnSync('bash', ['-c',
            'konsole() { printf "%s\\0" "$@"; }; ' + translations.sddmCommand(script, language)
        ], { encoding: 'utf8' });
        assert.equal(outer.status, 0, outer.stderr);
        const args = outer.stdout.split('\0');
        assert.deepEqual(args.slice(0, 3), ['-e', 'bash', '-c']);
        const inner = spawnSync('bash', ['-c',
            'pkexec() { printf "%s\\0" "$@"; }; ' + args[3]
        ], { input: '\n', encoding: 'utf8' });
        assert.equal(inner.status, 0, inner.stderr);
        const recorded = inner.stdout.split('\0');
        assert.deepEqual(recorded.slice(0, 4), ['bash', script, '--language', language]);
        assert.equal(recorded[4], '\n' + translations.tr(language, 'Pressione Enter para fechar...') + '\n');
    }
}
console.log('Translations and SDDM command: OK');
