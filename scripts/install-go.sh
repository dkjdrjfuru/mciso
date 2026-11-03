#!/usr/bin/env bash
# ==============================================================
#  scripts/install-go.sh — Go toolchain + Go-based security tools
#  Go  ${GO_VERSION:-1.27.3}   -> /usr/local/go
#  Tools -> /usr/local/bin via `go install`
# ==============================================================
set -uo pipefail
source "$(dirname "$0")/lib/gh-release.sh"

GO_VERSION="${GO_VERSION:-1.27.3}"

# ---- Go itself ----
guard go-toolchain bash -c "
    set -e
    dl https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz /tmp/go.tgz
    rm -rf /usr/local/go && tar -C /usr/local -xzf /tmp/go.tgz
    ln -sf /usr/local/go/bin/go /usr/local/bin/go
    ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
    go version
"

export PATH=/usr/local/go/bin:$PATH
export GOPATH=/opt/go GOPROXY=https://proxy.golang.org,direct
export GOFLAGS=-mod=mod
mkdir -p "$GOPATH/bin"

GO_TOOLS=(
    "github.com/ffuf/ffuf/v2@latest"
    "github.com/projectdiscovery/subfinder/v2@latest"
    "github.com/projectdiscovery/nuclei/v2@latest"
    "github.com/projectdiscovery/httpx/cmd/httpx@latest"
    "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
    "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    "github.com/projectdiscovery/katana/cmd/katana@latest"
    "github.com/hahwul/dalfox/v2@latest"
    "github.com/OJ/gobuster/v3@latest"
    "github.com/jpillora/chisel@latest"
    "github.com/owasp-amass/amass/v4/cmd/amass@latest"
    "github.com/lc/gau/v2@latest"
    "github.com/tomnomnom/waybackurls@latest"
    "github.com/ropnop/kerbrute@latest"
)

for spec in "${GO_TOOLS[@]}"; do
    name="$(basename "${spec%%@*}")"
    guard "go:$name" bash -c "
        set -e
        GOBIN=/usr/local/bin go install -v '$spec'
        command -v '$name'
    "
done

# nuclei templates for the netmask user (auto-detected by nuclei at ~/nuclei-templates)
guard nuclei-templates bash -c '
    set -e
    if [ -d /home/netmask ]; then
        git clone --depth 1 https://github.com/projectdiscovery/nuclei-templates.git \
            /home/netmask/nuclei-templates 2>/dev/null || \
        git -C /home/netmask/nuclei-templates pull --ff-only 2>/dev/null || true
        chown -R 1000:1000 /home/netmask/nuclei-templates || true
    fi
'

exit 0
