import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"


class ShellLanguageTests(unittest.TestCase):
    def test_help_and_invalid_language_exit_before_system_changes(self):
        for name in ("install.sh", "uninstall.sh", "sync_sddm.sh"):
            with self.subTest(script=name):
                help_result = subprocess.run(
                    ["bash", str(SCRIPTS / name), "--help"], capture_output=True, text=True
                )
                self.assertEqual(help_result.returncode, 0, help_result.stderr)
                self.assertIn("--language en|pt_PT|pt_BR|es", help_result.stdout)
                invalid = subprocess.run(
                    ["bash", str(SCRIPTS / name), "--language", "invalid"],
                    capture_output=True, text=True,
                )
                self.assertEqual(invalid.returncode, 2)
                self.assertIn("Unsupported language", invalid.stderr)

    def test_sddm_output_in_each_language_without_changing_system(self):
        expectations = {
            "en": ("Configuring Num Lock", "System configured successfully", "ENABLED"),
            "pt_PT": ("A configurar o Num Lock", "Sistema configurado com sucesso", "ATIVADO"),
            "pt_BR": ("Configurando Num Lock", "Sistema configurado com sucesso", "ATIVADO"),
            "es": ("Configurando Num Lock", "Sistema configurado correctamente", "ACTIVADO"),
        }
        with tempfile.TemporaryDirectory() as directory:
            temporary = Path(directory)
            script = (SCRIPTS / "sync_sddm.sh").read_text()
            script = script.replace('if [ "$EUID" -ne 0 ]; then', 'if false; then')
            script = script.replace("/etc/", str(temporary / "etc") + "/")
            script = script.replace("/var/lib/sddm", str(temporary / "sddm"))
            script = script.replace("/dev/uinput", str(temporary / "uinput"))
            sandbox_script = temporary / "sync_sddm.sh"
            sandbox_script.write_text(script)
            (temporary / "numlock_i18n.sh").write_bytes((SCRIPTS / "numlock_i18n.sh").read_bytes())
            (temporary / "etc/udev/rules.d").mkdir(parents=True)
            (temporary / "sddm").mkdir()
            wrapper = '''
chmod() { :; }
chown() { :; }
id() { return 1; }
udevadm() { :; }
usermod() { :; }
source "$1" --language "$2"
'''
            for language, messages in expectations.items():
                with self.subTest(language=language):
                    result = subprocess.run(
                        ["bash", "-c", wrapper, "test", str(sandbox_script), language],
                        capture_output=True, text=True,
                        env={**os.environ, "SUDO_USER": ""},
                    )
                    self.assertEqual(result.returncode, 0, result.stderr)
                    for message in messages:
                        self.assertIn(message, result.stdout)
                    self.assertIn("Numlock=on", (temporary / "etc/sddm.conf.d/numlock.conf").read_text())

    def test_shell_defaults_to_english_and_preserves_explicit_language(self):
        for arguments, expected in (([], "en"), (["--language", "pt_PT"], "pt_PT"), (["--language=es"], "es")):
            result = subprocess.run(
                ["bash", "-c", 'source "$1"; shift; numlock_init_language "$@"; printf "%s" "$NUMLOCK_LANGUAGE"',
                 "test", str(SCRIPTS / "numlock_i18n.sh"), *arguments],
                capture_output=True, text=True,
                env={key: value for key, value in os.environ.items() if key != "NUMLOCK_LANGUAGE"},
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, expected)


if __name__ == "__main__":
    unittest.main()
