import importlib.util
import pathlib
import tempfile
import unittest
from unittest import mock


HELPER_PATH = pathlib.Path(__file__).parents[1] / "scripts" / "numlock_helper.py"
SPEC = importlib.util.spec_from_file_location("numlock_helper", HELPER_PATH)
helper = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(helper)


class EnableNumLockTests(unittest.TestCase):
    @mock.patch.object(helper, "sync_kcminputrc_numlock")
    @mock.patch.object(helper, "inject_numlock_key", return_value=True)
    @mock.patch.object(helper, "get_led_state", return_value=False)
    @mock.patch.object(helper.subprocess, "run")
    def test_notification_uses_selected_language(self, run, get_state, inject, sync):
        titles = {
            "en": "Num Lock enabled",
            "pt_PT": "Num Lock ativado",
            "pt_BR": "Num Lock ativado",
            "es": "Num Lock activado",
        }
        for language, title in titles.items():
            with self.subTest(language=language):
                helper.enable_numlock(notify=True, language=language)
                self.assertEqual(run.call_args.args[0][5], title)

    @mock.patch.object(helper, "sync_kcminputrc_numlock")
    @mock.patch.object(helper, "inject_numlock_key", return_value=True)
    @mock.patch.object(helper, "get_led_state", return_value=False)
    @mock.patch.object(helper.subprocess, "run")
    def test_notification_defaults_to_english(self, run, get_state, inject, sync):
        helper.enable_numlock(notify=True)
        self.assertEqual(run.call_args.args[0][5], "Num Lock enabled")

    @mock.patch.object(helper, "sync_kcminputrc_numlock")
    @mock.patch.object(helper, "inject_numlock_key")
    @mock.patch.object(helper, "get_led_state", return_value=True)
    def test_enable_does_not_toggle_when_already_active(self, get_state, inject, sync):
        helper.enable_numlock()

        get_state.assert_called_once_with("numlock")
        inject.assert_not_called()
        sync.assert_called_once_with(True)

    @mock.patch.object(helper, "sync_kcminputrc_numlock")
    @mock.patch.object(helper, "inject_numlock_key", return_value=True)
    @mock.patch.object(helper, "get_led_state", return_value=False)
    def test_enable_injects_exactly_once_when_inactive(self, get_state, inject, sync):
        helper.enable_numlock()

        get_state.assert_called_once_with("numlock")
        inject.assert_called_once_with()
        sync.assert_called_once_with(True)


class KcminputrcTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.config_path = pathlib.Path(self.temp_dir.name) / "kcminputrc"
        self.expanduser = mock.patch.object(
            helper.os.path, "expanduser", return_value=str(self.config_path)
        )
        self.expanduser.start()
        self.qdbus = mock.patch.object(helper.subprocess, "run")
        self.qdbus.start()

    def tearDown(self):
        self.qdbus.stop()
        self.expanduser.stop()
        self.temp_dir.cleanup()

    def test_enable_writes_kde_key_and_value(self):
        self.config_path.write_text("[Keyboard]\nNumLock=2\n", encoding="utf-8")

        helper.sync_kcminputrc_numlock(True)

        self.assertEqual(
            self.config_path.read_text(encoding="utf-8"),
            "[Keyboard]\nNumLock=0\n",
        )

    def test_disable_writes_kde_key_and_value(self):
        helper.sync_kcminputrc_numlock(False)

        self.assertEqual(
            self.config_path.read_text(encoding="utf-8"),
            "[Keyboard]\nNumLock=1\n",
        )

    def test_replaces_legacy_spacing_and_preserves_other_sections(self):
        self.config_path.write_text(
            "[Keyboard]\nNumLock = 1\n\n[Mouse]\ncursorTheme=breeze\n",
            encoding="utf-8",
        )

        helper.sync_kcminputrc_numlock(True)

        self.assertEqual(
            self.config_path.read_text(encoding="utf-8"),
            "[Keyboard]\nNumLock=0\n\n[Mouse]\ncursorTheme=breeze\n",
        )

if __name__ == "__main__":
    unittest.main()
