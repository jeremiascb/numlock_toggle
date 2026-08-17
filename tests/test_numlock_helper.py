import importlib.util
import pathlib
import unittest
from unittest import mock


HELPER_PATH = pathlib.Path(__file__).parents[1] / "scripts" / "numlock_helper.py"
SPEC = importlib.util.spec_from_file_location("numlock_helper", HELPER_PATH)
helper = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(helper)


class EnableNumLockTests(unittest.TestCase):
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


if __name__ == "__main__":
    unittest.main()
