#!/usr/bin/env bash
# ==============================================================
#  scripts/install-web.sh — Burp Suite Community, OWASP ZAP, XSStrike,
#  recon-ng  (sqlmap/ffuf/nuclei/dalfox come from apt + go modules)
# ==============================================================
set -uo pipefail
source "$(dirname "$0")/lib/gh-release.sh"
export DEBIAN_FRONTEND=noninteractive

# ---- Burp Suite Community (PortSwigger jar + launcher) ----
if [ "${NETMASK_SKIP_BURP:-0}" = "1" ]; then
    echo ">>> [burp] skipped (NETMASK_SKIP_BURP=1)"
else
    guard burp bash -c '
        set -e
        mkdir -p /opt/burp
        dl "https://portswigger.net/burp/releases/download?productId=100&type=jar" /opt/burp/burpsuite_community.jar
        [ -s /opt/burp/burpsuite_community.jar ]
        cat > /usr/local/bin/burp <<"EOF"
#!/bin/sh
# Burp Suite Community — accepts the license on first run.
# HTTPS interception CA: Burp generates it on first launch; export from
# Proxy -> Options -> Import / export CA certificate, then import into
# Firefox/Chromium. See /usr/share/doc/netmask/RE-CHEATSHEET.md
exec java -jar /opt/burp/burpsuite_community.jar "$@"
EOF
        chmod 755 /usr/local/bin/burp
        java -jar /opt/burp/burpsuite_community.jar --version 2>/dev/null | head -1 || true
    '
fi

# ---- OWASP ZAP ----
guard zaproxy bash -c '
    set -e
    URL="$(gh_asset_url_try zaproxy/zaproxy "zaproxy_[0-9.]+_linux\.tar\.gz" "ZAP_[0-9.]+_Core\.tar\.gz")"
    [ -n "$URL" ] || { echo "no ZAP linux asset"; exit 1; }
    dl "$URL" /tmp/zap.tar.gz
    mkdir -p /opt/zaproxy
    tar xzf /tmp/zap.tar.gz -C /opt/zaproxy --strip-components=1
    ln -sf /opt/zaproxy/zap.sh /usr/local/bin/zap
'

# ---- XSStrike ----
guard xsstrike bash -c '
    git clone --depth 1 https://github.com/s0md3v/XSStrike.git /opt/XSStrike 2>/dev/null || true
    printf "#!/bin/sh\ncd /opt/XSStrike && exec python3 xsstrike.py \"$@\"\n" \
        > /usr/local/bin/xsstrike && chmod 755 /usr/local/bin/xsstrike
'

# ---- recon-ng ----
guard recon-ng bash -c '
    set -e
    git clone --depth 1 https://github.com/lanmaster53/recon-ng.git /opt/recon-ng 2>/dev/null || \
        git -C /opt/recon-ng pull --ff-only
    /opt/netmask-py/bin/pip install -q -r /opt/recon-ng/REQUIREMENTS 2>/dev/null || true
    printf "#!/bin/sh\ncd /opt/recon-ng && exec /opt/netmask-py/bin/python recon-ng \"$@\"\n" \
        > /usr/local/bin/recon-ng && chmod 755 /usr/local/bin/recon-ng
'

exit 0
