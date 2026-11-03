#!/usr/bin/env bash
# ==============================================================
#  scripts/install-extra.sh — the "add a lot more tools" module
#  jadx · dex2jar · stegseek · CyberChef · ImHex · Wine (+x64dbg helper)
#  ruby gems (zsteg, wpscan) · sherlock · RsaCtfTool · bettercap caplets
# ==============================================================
set -uo pipefail
source "$(dirname "$0")/lib/gh-release.sh"
export DEBIAN_FRONTEND=noninteractive

BUILD=/tmp/nm-build && mkdir -p "$BUILD"
cd "$BUILD"

# ---- jadx (upstream zip; dropped from bookworm) ----
guard jadx bash -c '
    set -e
    URL="$(gh_asset_url_try skylot/jadx "jadx-[0-9].*\.zip")"
    [ -n "$URL" ] || { echo "no jadx asset"; exit 1; }
    dl "$URL" jadx.zip && rm -rf /opt/jadx && unzip -q jadx.zip -d /opt/jadx
    chmod +x /opt/jadx/bin/jadx /opt/jadx/bin/jadx-gui
    ln -sf /opt/jadx/bin/jadx /usr/local/bin/jadx
    ln -sf /opt/jadx/bin/jadx-gui /usr/local/bin/jadx-gui
    jadx --version 2>/dev/null | head -1 || true
'

# ---- dex2jar ----
guard dex2jar bash -c '
    set -e
    URL="$(gh_asset_url_try pxb1988/dex2jar "dex2jar-[0-9].*\.zip")"
    [ -n "$URL" ] || { echo "no dex2jar asset"; exit 1; }
    dl "$URL" d2j.zip && rm -rf /opt/dex2jar && unzip -q d2j.zip -d /tmp/d2j
    mv /tmp/d2j/dex2jar-* /opt/dex2jar
    chmod +x /opt/dex2jar/*.sh 2>/dev/null || true
    for s in /opt/dex2jar/d2j-*.sh; do
        ln -sf "$s" "/usr/local/bin/$(basename "$s")"
    done
    d2j-dex2jar --version 2>/dev/null | head -1 || true
'

# ---- stegseek (worlds-fastest steghide cracker; deb) ----
guard stegseek bash -c '
    set -e
    URL="$(gh_asset_url_try stegseek/stegseek "stegseek_.*\.deb")"
    [ -n "$URL" ] || { echo "no stegseek deb"; exit 1; }
    dl "$URL" stegseek.deb
    dpkg -i stegseek.deb >/dev/null 2>&1 || apt-get install -y -f -qq >/dev/null
    stegseek --version 2>/dev/null | head -1 || true
'

# ---- CyberChef (offline single-file web app) ----
guard cyberchef bash -c '
    set -e
    URL="$(gh_asset_url_try gchq/CyberChef "CyberChef_v[0-9.]+\.zip")"
    [ -n "$URL" ] || { echo "no CyberChef asset"; exit 1; }
    dl "$URL" cc.zip && rm -rf /opt/cyberchef && mkdir -p /opt/cyberchef
    unzip -q cc.zip -d /opt/cyberchef
    HTML="$(find /opt/cyberchef -name "CyberChef_*.html" | head -n1)"
    [ -n "$HTML" ] || { echo "cyberchef html missing"; exit 1; }
    printf "#!/bin/sh\nexec xdg-open %s\n" "$HTML" > /usr/local/bin/cyberchef
    chmod 755 /usr/local/bin/cyberchef
    cyberchef >/dev/null 2>&1 || true
'

# ---- ImHex (the hacker hex editor) ----
guard imhex bash -c '
    set -e
    URL="$(gh_asset_url_try WerWolv/ImHex "imhex-.*x86_64\.deb" "imhex-.*_amd64\.deb")"
    [ -n "$URL" ] || { echo "no imhex deb"; exit 1; }
    dl "$URL" imhex.deb
    dpkg -i imhex.deb >/dev/null 2>&1 || apt-get install -y -f -qq >/dev/null
    command -v imhex
'

# ---- Wine (run PE targets / optional x64dbg) ----
if [ "${NETMASK_SKIP_WINE:-0}" = "1" ]; then
    echo ">>> [wine] skipped (NETMASK_SKIP_WINE=1)"
else
    guard wine bash -c '
        set -e
        apt-get install -y -qq --no-install-recommends wine wine64 winetricks >/dev/null 2>&1
        wine --version 2>/dev/null | head -1 || true
    '
    # stage the crackme pack for Wine runs as well
    guard wine-crackmes bash -c '
        set -e
        [ -d /usr/share/netmask/crackmes ] || exit 0
        mkdir -p /opt/wine-crackmes
        cp /usr/share/netmask/crackmes/*/binary/*.exe /opt/wine-crackmes/ 2>/dev/null || true
        echo "PE crackmes staged: /opt/wine-crackmes (run with: wine crackme04.exe)"
    '
fi

# ---- ruby gems: zsteg + wpscan ----
guard zsteg bash -c '
    set -e
    gem install zsteg --no-document -q
    zsteg --help 2>&1 | head -1 || true
'
guard wpscan bash -c '
    set -e
    gem install wpscan --no-document -q || { echo "wpscan gem build failed"; exit 1; }
    wpscan --version 2>/dev/null | head -1 || true
'

# ---- feroxbuster (rust content discovery) ----
guard feroxbuster bash -c '
    set -e
    URL="$(gh_asset_url_try epi052/feroxbuster "feroxbuster_.*_linux\.tar\.xz" "x86_64_linux.*\.tar\.xz")"
    [ -n "$URL" ] || { echo "no feroxbuster asset"; exit 1; }
    dl "$URL" ferox.tar.xz && tar xf ferox.tar.xz
    install -m755 feroxbuster /usr/local/bin/feroxbuster
    feroxbuster --version 2>/dev/null | head -1 || true
'

# ---- feroxbuster wordlist deps live in seclists (cloned by postinst) ----

# ---- sherlock (OSINT username hunter) ----
guard sherlock bash -c '
    set -e
    git clone --depth 1 https://github.com/sherlock-project/sherlock.git /opt/sherlock 2>/dev/null || \
        git -C /opt/sherlock pull --ff-only
    /opt/netmask-py/bin/pip install -q -r /opt/sherlock/requirements.txt
    printf "#!/bin/sh\ncd /opt/sherlock && exec /opt/netmask-py/bin/python sherlock \"$@\"\n" \
        > /usr/local/bin/sherlock && chmod 755 /usr/local/bin/sherlock
    sherlock --help 2>&1 | head -1 || true
'

# ---- RsaCtfTool (CTF RSA swiss knife) ----
guard rsactftool bash -c '
    set -e
    git clone --depth 1 https://github.com/RsaCtfTool/RsaCtfTool.git /opt/RsaCtfTool 2>/dev/null || \
        git -C /opt/RsaCtfTool pull --ff-only
    /opt/netmask-py/bin/pip install -q -r /opt/RsaCtfTool/requirements.txt 2>/dev/null || true
    printf "#!/bin/sh\ncd /opt/RsaCtfTool && exec /opt/netmask-py/bin/python RsaCtfTool.py \"$@\"\n" \
        > /usr/local/bin/RsaCtfTool && chmod 755 /usr/local/bin/RsaCtfTool
    RsaCtfTool --help 2>&1 | head -1 || true
'

# ---- bettercap caplets ----
guard caplets bash -c '
    git clone --depth 1 https://github.com/bettercap/caplets.git /opt/bettercap-caplets 2>/dev/null || true
'

exit 0
