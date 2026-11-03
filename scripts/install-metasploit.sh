#!/usr/bin/env bash
# ==============================================================
#  scripts/install-metasploit.sh — Metasploit Framework (omnibus nightly)
#  + postgresql DB bootstrap helper for the netmask user
# ==============================================================
set -uo pipefail
source "$(dirname "$0")/lib/gh-release.sh"
export DEBIAN_FRONTEND=noninteractive

if [ "${NETMASK_SKIP_METASPLOIT:-0}" = "1" ]; then
    echo ">>> [metasploit] skipped (NETMASK_SKIP_METASPLOIT=1)"
    exit 0
fi

guard metasploit bash -c '
    set -e
    curl -fsSL -o /tmp/msfinstall \
      https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb
    chmod 755 /tmp/msfinstall
    /tmp/msfinstall >/dev/null 2>&1
    msfconsole --version
'

# first-boot DB bootstrap (run as netmask; msfdb needs a user session)
guard msfdb-helper bash -c '
    set -e
    cat > /usr/local/bin/netmask-msfdb-init <<"EOF"
#!/bin/sh
# Initialize the Metasploit database (postgresql) for this user — idempotent.
[ "$(id -u)" -eq 0 ] && { echo "run as the netmask user, not root"; exit 1; }
if [ ! -f ~/.msf4/db/database.yml ]; then
    msfdb init
else
    echo "msfdb already initialized (~/.msf4/db/database.yml)"
fi
EOF
    chmod 755 /usr/local/bin/netmask-msfdb-init
    systemctl enable postgresql.service 2>/dev/null || true
'

exit 0
