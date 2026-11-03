#!/usr/bin/env bash
# ==============================================================
#  scripts/install-pytools.sh — Python tooling in /opt/netmask-py venv
#  console scripts are symlinked into /usr/local/bin (in PATH)
# ==============================================================
set -uo pipefail
source "$(dirname "$0")/lib/gh-release.sh"
export DEBIAN_FRONTEND=noninteractive

PY=/opt/netmask-py/bin/python
PIP="/opt/netmask-py/bin/pip -q"

# ---- venv ----
guard py-venv bash -c '
    set -e
    python3 -m venv /opt/netmask-py
    /opt/netmask-py/bin/pip install -q --upgrade pip wheel setuptools
    /opt/netmask-py/bin/python --version
'

# each on its own guarded line — one bad wheel never kills the module
VENV_PKGS=(
    # --- RE / exploit dev libraries ---
    "capstone"
    "keystone-engine"
    "unicorn"
    "lief"
    "pyelftools"
    "angr"
    "qiling"
    # --- dynamic analysis ---
    "frida-tools"
    # --- binary / malware classification ---
    "flare-capa"
    "floss"
    "peframe"
    # --- mobile ---
    "objection"
    "apkleaks"
    "mobsf"
    # --- web ---
    "wfuzz"
    "wafw00f"
    "arjun"
    "dirsearch"
    "mitm6"
    # --- network / AD ---
    "impacket"
    "netexec"
    "smbmap"
    "enum4linux-ng"
    "bloodhound-python"
    "certipy-ad"
    # --- cloud ---
    "kube-hunter"
    "scout-suite"
    "prowler"
    # --- forensics / firmware ---
    "volatility3"
    "ubi_reader"
    "jefferson"
    # --- OSINT ---
    "theHarvester"
    "shodan"
)
for pkg in "${VENV_PKGS[@]}"; do
    guard "pip:$pkg" bash -c "$PIP install '$pkg'"
done

# expose every console script on PATH
guard py-path bash -c '
    set -e
    for f in /opt/netmask-py/bin/*; do
        [ -f "$f" ] && [ ! -L "$f" ] && head -c2 "$f" | grep -q "#!" || continue
        ln -sf "$f" /usr/local/bin/"$(basename "$f")"
    done
    frida --version 2>/dev/null || true
    vol --version 2>/dev/null || volatility3 --version 2>/dev/null || true
    capa --version 2>/dev/null || true
'

exit 0
