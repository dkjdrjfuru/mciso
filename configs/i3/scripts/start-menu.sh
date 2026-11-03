#!/bin/sh
# ~/.config/i3/scripts/start-menu.sh — Netmask OS start menu.
# Bound to the Win key alone (via xcape -> F13) and Super+D, and opened
# by the Start button in the taskbar.
if command -v xfce4-popup-whiskermenu >/dev/null 2>&1; then
    exec xfce4-popup-whiskermenu
fi
# fallback: the rofi app launcher
exec rofi -show drun
