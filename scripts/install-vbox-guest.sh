#!/usr/bin/env bash
# ==============================================================
#  scripts/install-vbox-guest.sh — VirtualBox Guest Additions
#  (not in Debian; pulled from the official VirtualBox ISO)
#  Gives: auto-resize display, shared clipboard, drag&drop, time sync —
#  the "insert ISO -> boot -> desktop, zero interaction" experience.
#  Skip with NETMASK_SKIP_VBOXGUEST=1.
# ==============================================================
set -uo pipefail
source "$(dirname "$0")/lib/gh-release.sh"
export DEBIAN_FRONTEND=noninteractive

if [ "${NETMASK_SKIP_VBOXGUEST:-0}" = "1" ]; then
    echo ">>> [vbox-guest] skipped (NETMASK_SKIP_VBOXGUEST=1)"
    exit 0
fi

guard vbox-guest bash -c '
    set -e
    # build deps for the kernel modules
    apt-get install -y -qq --no-install-recommends \
        build-essential perl make gcc bzip2 linux-headers-amd64 >/dev/null 2>&1 || true

    V="${VBOX_VERSION:-$(curl -fsSL --max-time 30 https://download.virtualbox.org/virtualbox/LATEST.TXT 2>/dev/null | tr -d "[:space:]")}"
    [ -n "$V" ] || V="${VBOX_VERSION:-7.1.6}"
    echo ">>> [vbox-guest] using VirtualBox $V"

    dl "https://download.virtualbox.org/virtualbox/${V}/VBoxGuestAdditions_${V}.iso" \
        /tmp/VBoxGuestAdditions.iso

    rm -rf /tmp/vga && mkdir -p /tmp/vga
    7z x -y -o/tmp/vga /tmp/VBoxGuestAdditions.iso >/dev/null 2>&1 \
        || bsdtar -xf /tmp/VBoxGuestAdditions.iso -C /tmp/vga

    [ -f /tmp/vga/VBoxLinuxAdditions.run ] || { echo "VBoxLinuxAdditions.run missing"; exit 1; }
    sh /tmp/vga/VBoxLinuxAdditions.run --nox11 -- --force > /tmp/vbox-additions.log 2>&1 \
        || echo ">>> [vbox-guest] installer returned non-zero (modules may still be fine)"

    systemctl enable vboxservice.service 2>/dev/null || true
    ls /usr/sbin/VBoxService >/dev/null 2>&1 && echo "VBoxService installed"
    modinfo vboxguest >/dev/null 2>&1 && echo "vboxguest module present" || true
'

exit 0
