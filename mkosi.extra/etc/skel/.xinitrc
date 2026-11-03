#!/bin/sh
# ~/.xinitrc — Netmask OS session (Windows-style desktop shell)
# dbus-run-session gives xfce4-panel/xfdesktop/xfconf their session bus.
exec dbus-run-session -- i3
