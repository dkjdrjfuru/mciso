#!/usr/bin/env bash
# ==============================================================
#  scripts/install-cloud.sh — trivy, kube-bench
#  (kube-hunter / scout-suite / prowler come from the pip venv)
# ==============================================================
set -uo pipefail
source "$(dirname "$0")/lib/gh-release.sh"
export DEBIAN_FRONTEND=noninteractive

# ---- trivy (.deb from upstream releases) ----
guard trivy bash -c '
    set -e
    V="${TRIVY_VERSION:-$(gh_latest_tag aquasecurity/trivy)}"
    URL="$(gh_asset_url_try aquasecurity/trivy "trivy_${V}_Linux-64bit\.deb" "trivy_.*_Linux-64bit\.deb")"
    [ -n "$URL" ] || { echo "no trivy deb asset"; exit 1; }
    dl "$URL" /tmp/trivy.deb
    dpkg -i /tmp/trivy.deb >/dev/null || apt-get install -y -f -qq >/dev/null
    trivy --version
'

# ---- kube-bench (pinned in versions.env) ----
guard kube-bench bash -c '
    set -e
    V="${KUBE_BENCH_VERSION:-0.16.0}"
    dl "https://github.com/aquasecurity/kube-bench/releases/download/v${V}/kube-bench_${V}_linux_amd64.tar.gz" /tmp/kb.tgz
    tar xzf /tmp/kb.tgz -C /usr/local/bin kube-bench
    kube-bench --version
'

exit 0
