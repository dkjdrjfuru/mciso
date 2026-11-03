#!/usr/bin/env bash
# ==============================================================
#  scripts/install-vscode.sh — VS Code (Microsoft .deb) + RE extensions
#  telemetry is disabled system-wide via the skel settings.json
# ==============================================================
set -uo pipefail
source "$(dirname "$0")/lib/gh-release.sh"
export DEBIAN_FRONTEND=noninteractive

if [ "${NETMASK_SKIP_VSCODE:-0}" = "1" ]; then
    echo ">>> [vscode] skipped (NETMASK_SKIP_VSCODE=1)"
    exit 0
fi

guard vscode bash -c '
    set -e
    dl "https://update.code.visualstudio.com/latest/linux-deb-x64/stable" /tmp/vscode.deb
    dpkg -i /tmp/vscode.deb >/dev/null 2>&1 || apt-get install -y -f -qq >/dev/null
    code --version | head -1
'

# pre-install extensions for the netmask user (headless CLI; non-fatal per item)
EXTENSIONS=(
    ms-python.python
    ms-vscode.cpptools
    ms-vscode.cpptools-extension-pack
    ms-vscode.hexeditor
    ms-azuretools.vscode-docker
)
for ext in "${EXTENSIONS[@]}"; do
    guard "vscode-ext:$ext" bash -c '
        set -e
        if [ -d /home/netmask ]; then
            sudo -u netmask HOME=/home/netmask code --install-extension '"$ext"' --force >/dev/null 2>&1
        fi
    '
done

exit 0
