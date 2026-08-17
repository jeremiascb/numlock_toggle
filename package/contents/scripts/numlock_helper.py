#!/usr/bin/env python3
"""
NumLock Auto-Locker & Status Helper for KDE Plasma 6
Author: Jeremias (numlock_toggle)
Description:
  Detects and manages NumLock / CapsLock / ScrollLock state, and provides
  a background DBus listener that automatically forces NumLock ON whenever
  the Plasma screen locker (kscreenlocker) is activated.
  Includes virtual uinput injection to toggle NumLock on Wayland and X11.
"""

import sys
import os
import glob
import json
import time
import struct
import fcntl
import argparse
import subprocess
import configparser

def get_led_state(led_type: str) -> bool:
    """
    Reads the LED state from /sys/class/leds/input*::<led_type>/brightness
    Returns True if at least one matching device has brightness > 0.
    """
    pattern = f"/sys/class/leds/input*::{led_type}/brightness"
    led_files = glob.glob(pattern)
    for led_path in led_files:
        try:
            with open(led_path, "r") as f:
                val = f.read().strip()
                if val.isdigit() and int(val) > 0:
                    return True
        except (OSError, IOError):
            continue
    return False

def get_all_states() -> dict:
    """Returns a dictionary containing the state of all lock keys."""
    return {
        "numlock": get_led_state("numlock"),
        "capslock": get_led_state("capslock"),
        "scrolllock": get_led_state("scrolllock")
    }

def inject_numlock_key() -> bool:
    """
    Injects a KEY_NUMLOCK event into the Linux input subsystem via /dev/uinput.
    This simulates a physical NumLock key press, which KWin / Wayland catches
    and toggles the active modifier state across all keyboards.
    """
    # 1. Try pure /dev/uinput ioctl
    try:
        fd = os.open("/dev/uinput", os.O_WRONLY | os.O_NONBLOCK)
        try:
            UI_SET_EVBIT = 0x40045564
            UI_SET_KEYBIT = 0x40045565
            UI_DEV_CREATE = 0x5501
            UI_DEV_DESTROY = 0x5502
            UI_DEV_SETUP = 0x405c5503

            EV_KEY = 0x01
            EV_SYN = 0x00
            KEY_NUMLOCK = 69
            SYN_REPORT = 0

            fcntl.ioctl(fd, UI_SET_EVBIT, EV_KEY)
            fcntl.ioctl(fd, UI_SET_KEYBIT, KEY_NUMLOCK)

            # uinput_setup: bustype, vendor, product, version, name[80], ff_effects_max
            setup_data = struct.pack("HHHH80sI", 0x03, 0x1234, 0x5678, 1, b"NumLock Virtual Key".ljust(80, b'\x00'), 0)
            try:
                fcntl.ioctl(fd, UI_DEV_SETUP, setup_data)
            except Exception:
                # Legacy fallback
                pass

            fcntl.ioctl(fd, UI_DEV_CREATE)
            time.sleep(0.03)

            # Key Down + Sync
            ev_down = struct.pack("qqHHi", 0, 0, EV_KEY, KEY_NUMLOCK, 1)
            ev_syn = struct.pack("qqHHi", 0, 0, EV_SYN, SYN_REPORT, 0)
            os.write(fd, ev_down + ev_syn)
            time.sleep(0.02)

            # Key Up + Sync
            ev_up = struct.pack("qqHHi", 0, 0, EV_KEY, KEY_NUMLOCK, 0)
            os.write(fd, ev_up + ev_syn)
            time.sleep(0.03)

            fcntl.ioctl(fd, UI_DEV_DESTROY)
            os.close(fd)
            print("[Helper] Successfully injected KEY_NUMLOCK via uinput.")
            return True
        except Exception as e:
            try:
                os.close(fd)
            except Exception:
                pass
            print(f"[Helper] Error in uinput ioctl: {e}", file=sys.stderr)
    except PermissionError:
        print("[Helper] /dev/uinput requires permissions (run scripts/sync_sddm.sh or setup udev rule).", file=sys.stderr)
    except Exception as e:
        print(f"[Helper] Could not open /dev/uinput: {e}", file=sys.stderr)

    # 2. Try ydotool fallback
    try:
        res = subprocess.run(["ydotool", "key", "69:1", "69:0"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=1)
        if res.returncode == 0:
            print("[Helper] Injected KEY_NUMLOCK via ydotool.")
            return True
    except Exception:
        pass

    # 3. Try wtype fallback
    try:
        res = subprocess.run(["wtype", "-k", "Num_Lock"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=1)
        if res.returncode == 0:
            print("[Helper] Injected KEY_NUMLOCK via wtype.")
            return True
    except Exception:
        pass

    # 4. Try X11 numlockx if in X11
    if os.environ.get("XDG_SESSION_TYPE") == "x11":
        try:
            res = subprocess.run(["numlockx", "toggle"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=1)
            if res.returncode == 0:
                print("[Helper] Toggled via numlockx.")
                return True
        except Exception:
            pass

    return False

def sync_kcminputrc_numlock(enable: bool = True):
    """
    Ensures ~/.config/kcminputrc has [Keyboard] NumLock=0 (0 = Turn On, 1 = Turn Off)
    and notifies KWin to reload keyboard configuration.
    """
    kcminputrc_path = os.path.expanduser("~/.config/kcminputrc")
    try:
        config = configparser.ConfigParser(strict=False)
        config.read(kcminputrc_path)
        if not config.has_section("Keyboard"):
            config.add_section("Keyboard")

        # In KDE Plasma: 0 = Turn On, 1 = Turn Off, 2 = Leave Unchanged
        config.set("Keyboard", "NumLock", "0" if enable else "1")

        with open(kcminputrc_path, "w") as f:
            config.write(f, space_around_delimiters=False)
    except Exception as e:
        print(f"[Helper] Error updating kcminputrc: {e}", file=sys.stderr)

    # Inform KWin to reconfigure
    try:
        subprocess.run(
            ["qdbus-qt6", "org.kde.KWin", "/KWin", "org.kde.KWin.reconfigure"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=1
        )
    except Exception:
        pass

def toggle_numlock():
    """Toggles NumLock state using input event injection."""
    injected = inject_numlock_key()
    if not injected:
        # Fallback: toggle kcminputrc
        current = get_led_state("numlock")
        sync_kcminputrc_numlock(not current)
    print("[Helper] NumLock toggle triggered.")

def enable_numlock(notify: bool = False):
    """Enforces NumLock to be ON."""
    # Ensure kcminputrc is 0 (Turn On)
    sync_kcminputrc_numlock(True)

    # Check if currently off, and toggle
    if not get_led_state("numlock"):
        inject_numlock_key()

    if notify:
        try:
            subprocess.run([
                "notify-send",
                "-a", "Num Lock Auto Locker",
                "-i", "input-dialpad",
                "Num Lock Ativado",
                "Num Lock foi ativado automaticamente para a tela de bloqueio."
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=2)
        except Exception:
            pass
    print("[Helper] NumLock forced ON successfully.")

def disable_numlock():
    """Enforces NumLock to be OFF."""
    sync_kcminputrc_numlock(False)
    if get_led_state("numlock"):
        inject_numlock_key()
    print("[Helper] NumLock forced OFF.")

def run_daemon(notify: bool = False):
    """
    Runs a persistent DBus listener for org.freedesktop.ScreenSaver and org.kde.screensaver.
    Whenever the screen is locked, automatically forces NumLock ON.
    """
    try:
        import dbus
        from dbus.mainloop.glib import DBusGMainLoop
        from gi.repository import GLib
    except ImportError as e:
        print(f"[Helper] Required Python DBus bindings missing: {e}", file=sys.stderr)
        sys.exit(1)

    print("[Helper Daemon] Starting NumLock Auto-Locker Daemon...")
    DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()

    def on_active_changed(active: bool):
        print(f"[Helper Daemon] ScreenSaver.ActiveChanged: {active}")
        if active:
            enable_numlock(notify=notify)

    def on_about_to_lock():
        print("[Helper Daemon] screensaver.AboutToLock received!")
        enable_numlock(notify=notify)

    bus.add_signal_receiver(
        on_active_changed,
        signal_name="ActiveChanged",
        dbus_interface="org.freedesktop.ScreenSaver"
    )
    bus.add_signal_receiver(
        on_about_to_lock,
        signal_name="AboutToLock",
        dbus_interface="org.kde.screensaver"
    )

    print("[Helper Daemon] Listening for screen lock events. Press Ctrl+C to exit.")
    loop = GLib.MainLoop()
    try:
        loop.run()
    except KeyboardInterrupt:
        print("[Helper Daemon] Stopped by user.")

def main():
    parser = argparse.ArgumentParser(description="NumLock Auto-Locker & Status Helper")
    parser.add_argument("--status", action="store_true", help="Print lock keys status in plain text")
    parser.add_argument("--json", action="store_true", help="Print lock keys status in JSON format")
    parser.add_argument("--enable", action="store_true", help="Force NumLock ON")
    parser.add_argument("--disable", action="store_true", help="Force NumLock OFF")
    parser.add_argument("--toggle", action="store_true", help="Toggle NumLock state")
    parser.add_argument("--daemon", action="store_true", help="Run in background monitoring screen lock events")
    parser.add_argument("--notify", action="store_true", help="Send desktop notification on auto-activation")

    args = parser.parse_args()

    if args.daemon:
        run_daemon(notify=args.notify)
    elif args.enable:
        enable_numlock(notify=args.notify)
    elif args.disable:
        disable_numlock()
    elif args.toggle:
        toggle_numlock()
    elif args.json:
        print(json.dumps(get_all_states()))
    else:
        states = get_all_states()
        print(f"NumLock:    {'ON' if states['numlock'] else 'OFF'}")
        print(f"CapsLock:   {'ON' if states['capslock'] else 'OFF'}")
        print(f"ScrollLock: {'ON' if states['scrolllock'] else 'OFF'}")

if __name__ == "__main__":
    main()
