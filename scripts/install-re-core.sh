#!/usr/bin/env bash
# ==============================================================
#  scripts/install-re-core.sh — radare2 / rizin / Cutter / upx / ropper / DIE
#  (Debian removed radare2/rizin/upx from bookworm — built from upstream)
# ==============================================================
set -uo pipefail
source "$(dirname "$0")/lib/gh-release.sh"
export DEBIAN_FRONTEND=noninteractive

BUILD=/tmp/nm-build && mkdir -p "$BUILD"
cd "$BUILD"

# ---- radare2 (source build, ~3 min) ----
guard radare2 bash -c '
    set -e
    rm -rf radare2 && git clone --depth 1 https://github.com/radareorg/radare2.git
    cd radare2 && sys/install.sh >/dev/null
    r2 -v | head -1
'

# ---- rizin (source build via meson) ----
guard rizin bash -c '
    set -e
    rm -rf rizin && git clone --depth 1 https://github.com/rizinorg/rizin.git
    cd rizin && meson setup build >/dev/null && ninja -C build >/dev/null \
        && ninja -C build install >/dev/null && ldconfig
    rizin -v | head -1
'

# ---- Cutter (official AppImage, extracted — no libfuse needed) ----
guard cutter bash -c '
    set -e
    URL="$(gh_asset_url_try CutterOrg/Cutter "Cutter-.*x64_Linux\.AppImage" "Cutter-.*Linux.*\.AppImage")"
    [ -n "$URL" ] || { echo "no Cutter AppImage asset found"; exit 1; }
    dl "$URL" cutter.AppImage && chmod +x cutter.AppImage
    ./cutter.AppImage --appimage-extract >/dev/null
    rm -rf /opt/cutter && mv squashfs-root /opt/cutter
    ln -sf /opt/cutter/AppRun /usr/local/bin/cutter
    cutter --version 2>/dev/null | head -1 || true
'

# ---- upx (upstream binary; upx-ucl no longer in bookworm) ----
guard upx bash -c '
    set -e
    V="${UPX_VERSION:-$(gh_latest_tag upx/upx)}"
    URL="$(gh_asset_url_try upx/upx "upx-${V}-amd64_linux\.tar\.xz" "upx-.*amd64_linux\.tar\.xz")"
    [ -n "$URL" ] || { echo "no upx asset"; exit 1; }
    dl "$URL" upx.tar.xz && tar xf upx.tar.xz
    install -m755 upx-*/upx /usr/local/bin/upx && upx --version | head -1
'

# ---- ropper (pip; "ropper" package not in bookworm) ----
guard ropper bash -c '
    set -e
    /opt/netmask-py/bin/pip install -q ropper
    ln -sf /opt/netmask-py/bin/ropper /usr/local/bin/ropper
    ropper --version
'

# ---- Detect-It-Easy (DIE) ----
guard die bash -c '
    set -e
    URL="$(gh_asset_url_try horsicq/DIE-tool "die_lin64_portable\.tar\.xz" "die_lin.*\.tar\.xz" "die_linux.*\.tar\.gz")"
    [ -n "$URL" ] || { echo "no DIE linux asset"; exit 1; }
    dl "$URL" die.tar && mkdir -p /opt/die
    case "$URL" in
      *.xz) tar xf die.tar -C /opt/die --strip-components=1 ;;
      *)    tar xzf die.tar -C /opt/die --strip-components=1 ;;
    esac
    ln -sf /opt/die/die /usr/local/bin/die
    ln -sf /opt/die/diec /usr/local/bin/diec
    diec --version 2>/dev/null | head -1 || true
'

exit 0
