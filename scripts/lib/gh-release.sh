#!/usr/bin/env bash
# ==============================================================
#  scripts/lib/gh-release.sh — GitHub release resolver + download helpers
#  Sourced by the install-* modules. Needs: curl, python3.
#  Usage:
#     gh_latest_tag OWNER/REPO
#     gh_asset_url  OWNER/REPO REGEX          # first matching asset URL
#     dl            URL DEST                  # curl -fL with retries
# ==============================================================
set -euo pipefail

gh_api() { curl -fsSL --retry 2 --max-time 60 "$1" 2>/dev/null; }

gh_latest_tag() {
    gh_api "https://api.github.com/repos/$1/releases/latest" \
        | python3 -c 'import json,sys;print(json.load(sys.stdin).get("tag_name",""))'
}

# first asset of the latest release whose name matches REGEX (POSIX ERE, -i)
gh_asset_url() {
    gh_api "https://api.github.com/repos/$1/releases/latest" | python3 -c '
import json, re, sys
d = json.load(sys.stdin)
pat = re.compile(sys.argv[1], re.I)
for a in d.get("assets", []):
    if pat.search(a.get("name", "")):
        print(a["browser_download_url"]); break
' "$2"
}

# like gh_asset_url, but tries a space-separated list of regexes in order
gh_asset_url_try() {
    local repo="$1"; shift
    for rx in "$@"; do
        local url
        url="$(gh_asset_url "$repo" "$rx" || true)"
        [ -n "$url" ] && { echo "$url"; return 0; }
    done
    return 1
}

dl() {
    curl -fSL --retry 3 --retry-delay 2 --max-time 900 -o "$2" "$1"
}

# guarded run: run a module step, record failures without aborting the build
NETMASK_FAILED=()
guard() {
    local name="$1"; shift
    echo ">>> [$name] $*"
    if "$@"; then
        echo ">>> [$name] OK"
    else
        echo ">>> [$name] FAILED (continuing — see KNOWN-LIMITATIONS.md)" >&2
        NETMASK_FAILED+=("$name")
    fi
}
