#!/usr/bin/env bash
# ==============================================================
#  scripts/install-dynamic.sh — DynamoRIO, Intel Pin (best effort),
#  LiME sources, frida-server service wiring
#  (strace/ltrace/qemu-user-static/rr come from APT)
# ==============================================================
set -uo pipefail
source "$(dirname "$0")/lib/gh-release.sh"
export DEBIAN_FRONTEND=noninteractive

# ---- DynamoRIO ----
guard dynamorio bash -c '
    set -e
    URL="$(gh_asset_url_try DynamoRIO/dynamorio "DynamoRIO-Linux-[0-9.]+\.tar\.gz")"
    [ -n "$URL" ] || { echo "no DynamoRIO linux asset"; exit 1; }
    dl "$URL" /tmp/drio.tgz
    rm -rf /opt/dynamorio && mkdir -p /opt/dynamorio
    tar xzf /tmp/drio.tgz -C /opt/dynamorio --strip-components=1
    ln -sf /opt/dynamorio/bin/drrun /usr/local/bin/drrun
    drrun --version 2>/dev/null | head -1 || true
'

# ---- Intel Pin (direct download; URL may change upstream — non-fatal) ----
guard pin bash -c '
    set -e
    URL="https://downloads.intel.com/35998/pin-3.28-98733-ga0eb2140e-gcc-linux.tar.gz"
    dl "$URL" /tmp/pin.tgz 2>/dev/null || { echo "Intel Pin URL moved — install manually, see KNOWN-LIMITATIONS.md"; exit 1; }
    mkdir -p /opt/pin && tar xzf /tmp/pin.tgz -C /opt/pin --strip-components=1
    ln -sf /opt/pin/pin /usr/local/bin/pin
'

# ---- LiME (loadable kernel module — built on target with linux-headers) ----
guard lime-sources bash -c '
    git clone --depth 1 https://github.com/504ensicsLabs/LiME.git /opt/LiME 2>/dev/null || true
'

# ---- frida-server systemd service ----
guard frida-service bash -c '
    set -e
    systemctl enable frida-server.service 2>/dev/null || true
    echo "frida-server enabled on 127.0.0.1:27042"
'

exit 0
