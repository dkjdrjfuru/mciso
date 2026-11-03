# Changelog

## v3.1.0-windesk — Windows-style desktop (bottom taskbar + start menu + icons)

### Changed
* **Windows-style desktop shell**: polybar replaced by an **xfce4-panel
  bottom taskbar** — Start button (bottom-left) opens the whisker start
  menu, icon-only buttons for running windows (grouped, mouse-wheel
  cycles, click raises/minimizes), system tray (nm-applet) and a
  time-over-date digital clock on the right. `xfdesktop` draws the
  wallpaper and shows desktop icons (Terminal, Files, Netmask Toolkit,
  Tutorials, Crackmes) plus Home/trash — the "This PC / Recycle Bin" feel.
* **Windows muscle-memory keys**: Win key alone (via `xcape` → F13) or
  `Super+D` opens the start menu, `Super+R` = run box, `Super+E` =
  file manager, `Alt+F4` = close window, `Ctrl+Alt+L` = lock.
  i3 windows now use real title bars with no gaps; cyan focus accent
  behaves like the Windows accent color.
* **Look**: Arc-Dark GTK theme, Papirus-Dark icons, Inter (Segoe-UI-like)
  UI font, taskbar bg `#0D0D1A` with `#00D9FF` active/selected accents
  (`configs/gtk-3.0/{settings.ini,gtk.css}`, `configs/xfce4/*`,
  `configs/desktop/*.desktop`, custom `netmask-start` taskbar icon).
* Session now runs under `dbus-run-session` (`.xinitrc`) so xfconfd,
  the taskbar and `nm-applet` get a proper session bus.

### Removed
* polybar (taskbar role taken over by xfce4-panel) and `feh`
  (wallpaper now handled by xfdesktop).

## v3.0.0-hacker — full hacker edition (boot UX + content pack + 60+ new tools)

### Added
* **Zero-interaction boot**: GRUB `timeout=0` + hidden menu (hold ESC for
  debug entries), themed GRUB (matrix background + FiraCode pf2 generated
  at build time), kernel params `netmask.autologin=1 netmask.noroot=1`.
* **Custom boot screen**: plymouth `script` theme with matrix rain
  (pre-rendered fading glyph strips), netmask emblem fade-in, progress
  bar frames, and question/password dialog support (LUKS2 persistence
  prompt) — `assets/plymouth/netmask.{plymouth,script}`.
* **Hacker desktop**: mandated palette everywhere (#0D0D1A / #E0E0E0 /
  #00D9FF / #27AE60 / #E94560 / #F39C12); top polybar with live matrix
  ticker (`matrix.sh`), kitty CRT scanline texture (background_image),
  rofi matrix launcher, picom translucency, dunst neon notifications,
  matrix-green i3 borders, `netmask@netmask-os:~$` zsh prompt.
* **60+ new tools**: ImHex, CyberChef (offline), stegseek, zsteg, wpscan,
  feroxbuster, sherlock, RsaCtfTool, mitmproxy, bettercap (+caplets),
  ettercap, dsniff, sslsplit, sslscan, testssl.sh, netsniff-ng, nbtscan,
  snmp/onesixtyone/ike-scan, hydra/medusa/ncrack, hashid, edb-debugger,
  hexedit/bvi/vbindiff/ghex/hexyl/bless, pev, elfutils/dwarves/nasm,
  valgrind, exiftool, clamav, dc3dd/dcfldd/gddrescue/hashdeep,
  ewf/afflib/vhdi/vmdk, ntfs-3g/exfatprogs, zstd/lz4, mupdf/qpdf/exiv2,
  pngcheck/zbar-tools, outguess/stegsnow, hcxdumptool/hcxtools,
  macchanger/netdiscover/arp-scan/hping3/mtr/iperf3, tor/openvpn/
  wireguard, scapy, bluez, adb/fastboot, mingw-w64, angr, qiling,
  impacket, netexec (nxc), smbmap, enum4linux-ng, bloodhound-python,
  certipy, kerbrute, naabu/dnsx/katana/httpx/gau/waybackurls (go),
  rb gems, wifi firmware (non-free-firmware), JetBrains Mono Nerd Font.
* **Content pack**: `tutorials/` — 33 lessons across reversing/exploiting/
  malware/crypto/forensics, wired to the shipped tools (`netmask-learn`,
  Super+F2). `crackmes/` — 11 original challenges with C sources,
  SOLUTION writeups and binaries compiled at build time (ELF + Windows
  PE via mingw-w64; `netmask-crackmes`, Super+F3, PE under wine).
* **VirtualBox experience**: guest additions built from the official ISO
  (`scripts/install-vbox-guest.sh`) → auto-resize display, shared
  clipboard, drag&drop, time sync; `VBoxClient-all` on session start.
* **`scripts/post_build.py`** artifact finalizer: dated rename, sha256,
  optional GPG sig, BUILD-INFO.json audit record (wired into build.sh+CI).
* LICENSE (MIT + content terms), `netmask-welcome` boot banner, expanded
  `netmask-tools` navigator (11 categories) and doctor table (~170 rows).

### Changed
* ISO name: `netmask-os-full-*` → **`netmask-os-hacker-YYYYMMDD.iso`**
  (volid `NETMASK_OS`).
* `mkosi.conf`: archive areas now `main contrib non-free non-free-firmware`
  (nikto, wifi firmware).
* polybar moved to a **top** bar; i3 gained rofi/tutorial/crackme/ImHex
  keybinds; boot order documented (splash → autologin → i3).
* build.sh syncs `configs/ assets/ tutorials/ crackmes/` into
  `mkosi.extra/` (single canonical source at repo root).

## v2.0.0-full — full RE toolchain edition

### Added
* **Full RE toolchain** across RE core, dynamic analysis, exploit dev,
  web/mobile/cloud, network/protocol, malware analysis, CTF/forensics,
  OSINT and dev tooling — pre-installed and in PATH
  (see README toolchain table).
* `packages-full.txt` — auditable APT list (every name verified against
  bookworm indexes) + `build.sh` pre-flight check + generated
  `mkosi.conf.d/20-full-packages.conf` drop-in.
* `versions.env` — pinned upstream versions (Ghidra 11.4.2, Go 1.27.3,
  Node 20.20.2, kube-bench 0.16.0).
* `mkosi.postinst.chroot` — modular installer orchestration:
  guarded `scripts/install-*.sh` modules (failures collected, never fatal)
  + `scripts/lib/gh-release.sh` resolver + `scripts/verify-tools.sh`
  PASS/FAIL audit table in the build log.
* In-image helpers: `netmask-tools` navigator + doctor, `pwndbg` GDB wrapper
  (GEF default), `libc-database`, `netmask-msfdb-init`, `burp`/`ghidra`/`zap`
  launchers, desktop entries, frida-server systemd unit (loopback).
* Kernel hardening: sysctl profile (`/etc/sysctl.d/80-netmask-hardening.conf`),
  AppArmor on the kernel cmdline, documented RE exceptions (ptrace/perf).
* **LUKS2 persistence**: default GRUB entry boots with `persistent`
  (live-boot auto-detect + passphrase prompt) and
  `scripts/create-persistent-usb.sh` builds the stick.
* **CI**: GitHub Actions build + **BIOS and UEFI QEMU smoke tests**
  (`scripts/qemu-smoke.sh`) + sha256/GPG artifacts; GitLab CI updated.
* Docs: README, INSTALL, SECURITY, CHANGELOG, KNOWN-LIMITATIONS —
  all vendored into the image at `/usr/share/doc/netmask/`.
* `build.sh` — single command: host deps, mkosi bootstrap (≥ 25 via pipx),
  package pre-flight, vendoring, build, dated ISO + sha256 + optional GPG sig.

### Changed
* ISO name: `netmask-os-minimal.iso` → `netmask-os-full-YYYYMMDD.iso`
  (volid `NETMASK_FULL`, `-iso-level 3` for >4 GB squashfs).
* GRUB: 4 entries (default=persistent, no-persistence, verbose, serial);
  AppArmor flags on all entries.
* `.zshrc`: RE paths + aliases; i3 tool keybinds.
* EDITOR default → nvim.

### Kept from minimal
i3 (gaps) + polybar + kitty + wallpaper + auto-login + zsh + hybrid
BIOS/UEFI ISO + `mkosi build` pipeline (directory rootfs → live squashfs).

## v1.0.0 — minimal edition
Initial minimal ISO: Debian 12, i3-wm 4.22, polybar, kitty, feh wallpaper,
auto-login, hybrid BIOS+UEFI live ISO via mkosi + grub-mkrescue.
