#!/usr/bin/env bash
# scripts/optional/install-x64dbg-wine.sh  — OPT-IN, not part of the default build
# x64dbg + Wine on Linux: works for light userland debugging, but it is slow,
# fragile, and Wine adds ~1.5 GB. Run manually inside the live session:
#     sudo bash /usr/local/lib/netmask/optional/install-x64dbg-wine.sh
set -uo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y --no-install-recommends wine wine64 || exit 1

mkdir -p /opt/x64dbg
URL="$(curl -fsSL https://api.github.com/repos/x64dbg/x64dbg/releases/latest \
    | python3 -c 'import json,sys;d=json.load(sys.stdin);print([a["browser_download_url"] for a in d.get("assets",[]) if "snapshot" in a["name"].lower() and a["name"].endswith(".zip")][0])' 2>/dev/null)" || URL=""
[ -n "$URL" ] || { echo "could not resolve an x64dbg release asset"; exit 1; }

curl -fSL --retry 3 -o /tmp/x64dbg.zip "$URL"
unzip -q -o /tmp/x64dbg.zip -d /opt/x64dbg
cat > /usr/local/bin/x64dbg <<'EOF'
#!/bin/sh
# Windows-userland debugger under Wine (32- and 64-bit targets).
exec wine /opt/x64dbg/release/x96dbg.exe "$@"
EOF
chmod 755 /usr/local/bin/x64dbg
echo "x64dbg installed — first run initializes the Wine prefix."
