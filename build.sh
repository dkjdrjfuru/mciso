#!/usr/bin/env bash
# ==============================================================
#  Netmask OS (hacker edition) — one-command build
#
#    ./build.sh                 # build output/netmask-os-hacker-YYYYMMDD.iso
#    SIGN=1 ./build.sh          # also produce a detached GPG signature
#
#  Skips (any non-empty value):
#    NETMASK_SKIP_SAGE=1       keep sagemath out (−~1 GB)      [rebuild needed]
#    NETMASK_SKIP_PY312=1      skip the CPython 3.12 side-build
#    NETMASK_SKIP_METASPLOIT=1 / NETMASK_SKIP_BURP=1 / NETMASK_SKIP_VSCODE=1
#    NETMASK_SKIP_WINE=1       skip wine (~1.2 GB)
#    NETMASK_SKIP_VBOXGUEST=1  skip VirtualBox guest additions
#
#  Output: output/netmask-os-hacker-YYYYMMDD.iso + .sha256 (+ .sig with SIGN=1)
#  Boot UX: grub timeout=0 (hidden menu) -> plymouth matrix-rain splash
#           -> getty autologin -> i3. Insert ISO -> desktop, zero interaction.
# ==============================================================
set -euo pipefail
cd "$(dirname "$0")"

BOLD=$'\033[1m'; CYAN=$'\033[0;36m'; RED=$'\033[0;31m'; GRN=$'\033[0;32m'; RST=$'\033[0m'
step() { printf '%s\n' "${BOLD}${CYAN}>>> ${*}${RST}"; }
warn() { printf '%s\n' "${RED}WARNING:${RST} ${*}"; }

# ---------------------------------------------------------------- host deps
step "checking host build dependencies"
HOST_PKGS=(git pipx squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools
           debian-archive-keyring dosfstools cpio zstd xz-utils binutils curl)
if command -v apt-get >/dev/null 2>&1; then
    MISSING=()
    for p in "${HOST_PKGS[@]}"; do dpkg -s "$p" >/dev/null 2>&1 || MISSING+=("$p"); done
    if ((${#MISSING[@]})); then
        step "installing host packages: ${MISSING[*]}"
        if [ "$(id -u)" -eq 0 ]; then
            apt-get update -qq && apt-get install -y -qq "${MISSING[@]}"
        else
            sudo apt-get update -qq && sudo apt-get install -y -qq "${MISSING[@]}"
        fi
    fi
else
    warn "no apt-get found — make sure mkosi >= 25 + squashfs-tools/xorriso/grub tools are installed"
fi
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------- mkosi
step "ensuring a current mkosi (>= 25)"
need_mkosi=1
if command -v mkosi >/dev/null 2>&1; then
    v="$(mkosi --version | awk '{print $NF}')"
    if dpkg --compare-versions "$v" ge 25 2>/dev/null; then need_mkosi=0; fi
fi
if [ "$need_mkosi" -eq 1 ]; then
    warn "mkosi missing or too old — installing the latest from upstream via pipx"
    if [ "$(id -u)" -eq 0 ]; then
        python3 -m pipx install --force 'git+https://github.com/systemd/mkosi.git' \
            || pip3 install --break-system-packages 'git+https://github.com/systemd/mkosi.git'
    else
        pipx install --force 'git+https://github.com/systemd/mkosi.git' \
            || pip3 install --user --break-system-packages 'git+https://github.com/systemd/mkosi.git'
    fi
fi
MKOSI="$(command -v mkosi || echo "$HOME/.local/bin/mkosi")"
echo "using mkosi: $MKOSI ($("$MKOSI" --version))"

# ---------------------------------------------------------------- packages
step "syncing packages-full.txt -> mkosi.conf.d/20-full-packages.conf"
mkdir -p mkosi.conf.d
{
    echo "# GENERATED from packages-full.txt by build.sh — do not edit by hand."
    echo "[Content]"
    echo "Packages="
    grep -vE '^\s*(#|$)' packages-full.txt | sed 's/^/    /'
} > mkosi.conf.d/20-full-packages.conf

# ---------------------------------------------------------------- content sync
# canonical sources: configs/ assets/ tutorials/ crackmes/  (this repo)
# are synced into mkosi.extra so a bare `mkosi build` also works.
step "syncing configs/ assets/ tutorials/ crackmes/ -> mkosi.extra"

# desktop configs -> /etc/skel
mkdir -p mkosi.extra/etc/skel/.config/{i3/scripts,kitty,rofi,picom,dunst} \
         mkosi.extra/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml \
         mkosi.extra/etc/skel/.config/xfce4/panel \
         mkosi.extra/etc/skel/.config/gtk-3.0 \
         mkosi.extra/etc/skel/.config/gtk-4.0 \
         mkosi.extra/etc/skel/Desktop
cp -f configs/i3/config                               mkosi.extra/etc/skel/.config/i3/config
install -m755 configs/i3/scripts/start-menu.sh        mkosi.extra/etc/skel/.config/i3/scripts/start-menu.sh
cp -f configs/kitty/kitty.conf                        mkosi.extra/etc/skel/.config/kitty/kitty.conf
cp -f configs/zsh/.zshrc                              mkosi.extra/etc/skel/.zshrc
cp -f configs/rofi/config.rasi                        mkosi.extra/etc/skel/.config/rofi/config.rasi
cp -f configs/picom/picom.conf                        mkosi.extra/etc/skel/.config/picom/picom.conf
cp -f configs/dunst/dunstrc                           mkosi.extra/etc/skel/.config/dunst/dunstrc
# Windows-style shell: taskbar (xfce4-panel) + desktop icons (xfdesktop)
cp -f configs/xfce4/xfce4-panel.xml                   mkosi.extra/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
cp -f configs/xfce4/xfce4-desktop.xml                 mkosi.extra/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
cp -f configs/xfce4/whiskermenu.rc                    mkosi.extra/etc/skel/.config/xfce4/panel/whiskermenu-1.rc
cp -f configs/gtk-3.0/settings.ini                    mkosi.extra/etc/skel/.config/gtk-3.0/settings.ini
cp -f configs/gtk-3.0/gtk.css                         mkosi.extra/etc/skel/.config/gtk-3.0/gtk.css
cp -f configs/gtk-4.0/settings.ini                    mkosi.extra/etc/skel/.config/gtk-4.0/settings.ini
cp -f configs/user-dirs/user-dirs.dirs                mkosi.extra/etc/skel/.config/user-dirs.dirs
install -m644 configs/desktop/*.desktop               mkosi.extra/etc/skel/Desktop/

# visual assets
mkdir -p mkosi.extra/usr/share/backgrounds/netmask \
         mkosi.extra/usr/share/plymouth/themes/netmask \
         mkosi.extra/usr/share/netmask/grub-theme \
         mkosi.extra/usr/share/icons/hicolor/256x256/apps \
         mkosi.extra/usr/share/icons/hicolor/48x48/apps
cp -f assets/netmask_logo.png    mkosi.extra/usr/share/backgrounds/netmask/
cp -f assets/netmask_icon.png    mkosi.extra/usr/share/backgrounds/netmask/
cp -f assets/netmask_logo_48.png mkosi.extra/usr/share/backgrounds/netmask/
cp -f assets/loading.png         mkosi.extra/usr/share/backgrounds/netmask/
cp -f assets/scanlines.png       mkosi.extra/usr/share/backgrounds/netmask/
cp -f assets/plymouth/*          mkosi.extra/usr/share/plymouth/themes/netmask/
cp -f assets/grub_theme/*        mkosi.extra/usr/share/netmask/grub-theme/
# start-button icon for the Windows-style taskbar
cp -f assets/netmask-start.png     mkosi.extra/usr/share/icons/hicolor/256x256/apps/netmask-start.png
cp -f assets/netmask-start-48.png  mkosi.extra/usr/share/icons/hicolor/48x48/apps/netmask-start.png

# content pack + runtime helpers
mkdir -p mkosi.extra/usr/share/netmask mkosi.extra/usr/local/bin
cp -r tutorials crackmes mkosi.extra/usr/share/netmask/
install -m755 scripts/netmask-welcome   mkosi.extra/usr/local/bin/netmask-welcome
install -m755 scripts/netmask-learn     mkosi.extra/usr/local/bin/netmask-learn
install -m755 scripts/netmask-crackmes  mkosi.extra/usr/local/bin/netmask-crackmes

# vendor the installer modules + versions.env + docs INTO the image
# (mkosi chroot scripts cannot see host files; mkosi.extra is synced early)
step "vendoring installer modules -> mkosi.extra/opt/netmask-installer"
rm -rf mkosi.extra/opt/netmask-installer
mkdir -p mkosi.extra/opt/netmask-installer
cp -r scripts versions.env mkosi.extra/opt/netmask-installer/
mkdir -p mkosi.extra/usr/share/doc/netmask
cp -f README.md INSTALL.md SECURITY.md CHANGELOG.md KNOWN-LIMITATIONS.md LICENSE \
    mkosi.extra/usr/share/doc/netmask/ 2>/dev/null || true
# optional: pre-seed Ghidra for offline builds — place ghidra.zip next to build.sh
[ -f ghidra.zip ] && cp -f ghidra.zip mkosi.extra/opt/netmask-installer/ghidra.zip || true
# keep the runtime helpers available in the image
mkdir -p mkosi.extra/usr/local/lib/netmask/optional
cp -f scripts/verify-tools.sh mkosi.extra/usr/local/lib/netmask/verify-tools.sh
cp -f scripts/optional/*.sh mkosi.extra/usr/local/lib/netmask/optional/ 2>/dev/null || true

# soft pre-flight: verify names against the live bookworm indexes (warning only)
if command -v curl >/dev/null 2>&1; then
    step "pre-flight package-name check against bookworm main+non-free+non-free-firmware"
    IDX="$(mktemp)"; IDXGZ="${IDX}.gz"
    OKIDX=1
    for comp in main non-free non-free-firmware; do
        curl -fsS --max-time 180 -o "${IDXGZ}.${comp}" \
            "https://deb.debian.org/debian/dists/bookworm/${comp}/binary-amd64/Packages.gz" \
            || OKIDX=0
        gzip -dc "${IDXGZ}.${comp}" >> "$IDX" 2>/dev/null || OKIDX=0
    done
    if [ "$OKIDX" -eq 1 ]; then
        BAD=0
        while read -r p; do
            grep -qxF "Package: $p" "$IDX" || { warn "not in bookworm: $p"; BAD=1; }
        done < <(grep -vE '^\s*(#|$)' packages-full.txt)
        [ "$BAD" -eq 0 ] && echo "all packages present in bookworm ✓"
    else
        warn "could not fetch the Packages indexes — skipping pre-flight check"
    fi
    rm -f "$IDX" "$IDXGZ" "${IDXGZ}".main "${IDXGZ}".non-free "${IDXGZ}".non-free-firmware
fi

# ---------------------------------------------------------------- build
step "mkosi build (rootfs + package installs + toolchain modules)"
# Ubuntu 24.04 restricts unprivileged userns -> fall back to sudo automatically.
if ! "$MKOSI" build "$@"; then
    warn "unprivileged build failed — retrying with sudo"
    if [ "$(id -u)" -eq 0 ]; then "$MKOSI" build "$@"
    else sudo env "PATH=$PATH" "$MKOSI" build "$@"; fi
fi

# ---------------------------------------------------------------- artifacts
step "collecting artifacts"
mkdir -p output
ISO="output/netmask-os-hacker.iso"
[ -f "$ISO" ] || ISO="$(find output -maxdepth 2 -name 'netmask-os-hacker.iso' -print -quit)"
[ -n "${ISO:-}" ] && [ -f "$ISO" ] || { echo "ERROR: ISO not found in output/" >&2; exit 1; }

STAMP="$(date -u +%Y%m%d)"
FINAL="output/netmask-os-hacker-${STAMP}.iso"
mv -f "$ISO" "$FINAL"

# artifact finalizer: dated name + sha256 + optional GPG + BUILD-INFO.json
if command -v python3 >/dev/null 2>&1 && [ -f scripts/post_build.py ]; then
    python3 scripts/post_build.py "$FINAL" || true
fi

echo
echo "${GRN}============================================================${RST}"
echo "${GRN} Netmask OS (hacker edition) build finished${RST}"
echo "   ISO     : $FINAL"
echo "   SHA256  : ${FINAL}.sha256"
echo "   size    : $(du -h "$FINAL" | cut -f1)"
echo "   boot    : BIOS + UEFI · grub timeout=0 hidden · plymouth matrix rain"
echo "   login   : autologin netmask -> i3 (zero interaction)"
echo "   content : tutorials/ + crackmes/ on the desktop paths"
echo "   tooling : see the verify-tools table printed during the build"
echo "${GRN}============================================================${RST}"
