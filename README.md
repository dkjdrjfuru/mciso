# Netmask OS — hacker edition

**Netmask OS** is a live-bootable Debian 12 (bookworm) x86-64 desktop that
boots **straight to a hacker-styled i3 desktop** — insert the ISO, power on,
zero interaction — packed with the **complete reverse-engineering &
ethical-hacking toolchain**, a 33-lesson tutorial pack and an 11-challenge
crackme pack with solutions.

Brand palette: bg `#0D0D1A` · fg `#E0E0E0` · neon cyan `#00D9FF` ·
matrix green `#27AE60` · blood red `#E94560` · amber `#F39C12`
Fonts: FiraCode Nerd Font (terminal/UI) + JetBrains Mono Nerd Font (vendored)

```
        power on
           │  GRUB (timeout=0, menu hidden, themed)
           ▼
   plymouth matrix-rain splash  (netmask emblem + progress bar)
           ▼
   getty autologin as netmask (no password)
           ▼
   i3 + Windows-style bottom taskbar (Start · running apps · tray · clock)
   + desktop icons + kitty (scanline texture) + rofi + picom + dunst
```

---

## What's inside

| Category | Highlights (all on PATH at boot) |
|---|---|
| **RE core** | Ghidra 11.4.2, radare2 + rizin (source-built), Cutter, **ImHex**, GDB (**GEF default**, `pwndbg` wrapper), LLDB, edb-debugger, objdump/readelf/objcopy, checksec, pwntools, ROPgadget, ropper, one_gadget, libc-database, patchelf, LIEF, upx, Detect-It-Easy, binwalk |
| **Dynamic** | Frida (CLI + frida-server service), DynamoRIO, qemu-user, strace, ltrace, rr |
| **Exploit** | Metasploit Framework (+ `netmask-msfdb-init`), searchsploit (exploitdb), AFL++, honggfuzz, msfvenom, donut, shellcraft, angrop + **angr/qiling** (symbolic) |
| **Web** | Burp Suite Community, OWASP ZAP, sqlmap, ffuf, nuclei (+templates), **httpx/naabu/dnsx/katana**, dalfox, **feroxbuster**, wfuzz, wafw00f, arjun, dirsearch, XSStrike, mitmproxy |
| **Mobile** | apktool, jadx (+gui), dex2jar, objection, apkleaks, MobSF, adb/fastboot |
| **AD / network** | **netexec (nxc), impacket, smbmap, enum4linux-ng, bloodhound-python, certipy, kerbrute, Responder**, bettercap (+caplets), ettercap, dsniff, sslsplit |
| **Wireless** | aircrack-ng suite, wifite, hcxdumptool/hcxtools, macchanger, hostapd, wifi firmware included |
| **Malware** | YARA, yarGen, capa, floss, peframe, PE-bear, MemProcFS, Volatility 3, clamav, sasquatch, firmware-mod-kit, **wine** (run PE samples) |
| **CTF / forensics** | sage, **RsaCtfTool**, hashcat, john, fcrackzip, steghide, **stegseek**, **zsteg**, outguess, stegsnow, autopsy, sleuthkit, foremost, scalpel, photorec, bulk_extractor, exiftool, binwalk |
| **OSINT** | theHarvester, sherlock, recon-ng, subfinder, amass, gobuster, waybackurls, shodan |
| **Cloud** | trivy, kube-bench, kube-hunter, scout-suite, prowler |
| **Dev** | Python 3.11 (system) **+ 3.12 side-build**, Go 1.27, Rust (rustup), Node 20, **mingw-w64** (PE targets), gcc/g++/multilib, clang/llvm, cmake/ninja/meson, VS Code (telemetry off), Neovim, Vim |
| **Desktop** | i3 + **Windows-style taskbar** (xfce4-panel: Start menu, running-app buttons, tray, clock), **desktop icons** (xfdesktop), kitty (+CRT scanlines), **rofi, picom, dunst**, Firefox ESR (telemetry off), CyberChef (offline) |

`netmask-tools` (or Super+F1) shows the categorized cheat-sheet;
`netmask-tools doctor` re-runs the **PASS/FAIL audit table** (~170 rows)
that also prints at the end of every build.

## Content pack

* **tutorials/** — 33 lessons (reversing ×10, exploiting ×8, malware ×7,
  crypto ×4, forensics ×4), each wired to the tools on this OS.
  Browse with `netmask-learn` (Super+F2).
* **crackmes/** — 11 original challenges (easy→expert) with C source,
  solution writeups, and binaries built at ISO compile time:
  Linux ELF **and** Windows PE x64 (mingw-w64). Run with
  `netmask-crackmes` (Super+F3); PE targets also work under `wine`.

## Requirements

* Build host: **Ubuntu 22.04+ / Debian 12+** (x86_64). `build.sh` installs
  host deps and bootstraps a current mkosi (≥ 25) itself — via pipx.
* **Disk: ~60 GB free** (rootfs + cache + squashfs + ISO). The ISO is
  ~5–8 GB depending on skip flags.
* Internet (module downloads; pre-seed `ghidra.zip` next to `build.sh`
  for offline Ghidra).

## Build (one command)

```bash
./build.sh
# → output/netmask-os-hacker-YYYYMMDD.iso
#   output/netmask-os-hacker-YYYYMMDD.iso.sha256      (+ .BUILD-INFO.json)
#   SIGN=1 ./build.sh          # also emits a detached GPG signature (.sig)
```

Useful toggles: `NETMASK_SKIP_SAGE=1` (−1 GB), `NETMASK_SKIP_WINE=1`
(−1.2 GB), `NETMASK_SKIP_PY312=1`, `NETMASK_SKIP_METASPLOIT=1`,
`NETMASK_SKIP_BURP=1`, `NETMASK_SKIP_VSCODE=1`,
`NETMASK_SKIP_VBOXGUEST=1` — none needed by default.

## Boot it (VirtualBox / real hardware)

1. **Machine → New** → *Linux / Debian (64-bit)*, ≥ **4096 MB** RAM, 2+ CPUs.
2. Storage: attach the ISO. BIOS boot = EFI off; UEFI = tick *Enable EFI*.
3. Start → **hands off** — splash → desktop in under a minute.
4. Guest additions are preinstalled: display auto-resizes, clipboard works.

## Persistence (optional, LUKS2)

Default entry boots with `persistent` — live-boot finds a LUKS2
persistence partition automatically and asks for the passphrase (through
the plymouth splash). Create the stick:

```bash
sudo scripts/create-persistent-usb.sh output/netmask-os-hacker-YYYYMMDD.iso /dev/sdX
```

## CI

* **GitHub Actions** (`.github/workflows/build.yml`): build → **BIOS and
  UEFI QEMU smoke tests** → sha256/BUILD-INFO via `scripts/post_build.py`
  → optional GPG sign (`GPG_PRIVATE_KEY` secret) → artifact upload.
* **GitLab CI** (`.gitlab-ci.yml`): build + artifact.

## Repo layout

```
configs/      i3 · xfce4 taskbar + desktop · gtk · kitty · zsh · rofi · picom · dunst
assets/       wallpaper · loading screen · plymouth theme · grub theme
tutorials/    33 lessons (netmask-learn)
crackmes/     11 challenges + solutions (netmask-crackmes)
scripts/      installer modules · asset generator · post_build.py · smoke test
packages-full.txt   auditable APT list (verified against bookworm indexes)
```

## How the build works

```
./build.sh
 ├─ 0. host deps + mkosi bootstrap (pipx, upstream) + package pre-flight
 ├─ 1. content sync: configs/ assets/ tutorials/ crackmes/ → mkosi.extra/
 ├─ 2. mkosi: Debian 12 rootfs (packages-full.txt → generated drop-in)
 ├─ 3. mkosi.postinst.chroot: Rust/Node/Ghidra/Python3.12 + 12 installer
 │       modules + crackme compilation — failures collected, never fatal
 ├─ 4. verify-tools.sh → PASS/FAIL table in the build log
 ├─ 5. mkosi.finalize.chroot: user/services/plymouth/initramfs/content links
 └─ 6. mkosi.postoutput: squashfs + themed grub (timeout=0, hidden)
         → grub-mkrescue hybrid ISO → post_build.py (sha256/BUILD-INFO/sig)
```

## Customization

* **Wallpaper/boot assets** — `scripts/make_wallpaper.py` regenerates
  everything in `assets/` (matrix rain, splash, GRUB background, rain
  strips for plymouth).
* **Colors** — mandated palette in `configs/*`, `assets` generator.
* **Add/remove tools** — APT: `packages-full.txt`; non-APT: extend
  `scripts/install-*.sh`; pin versions in `versions.env`.

## Ethics

Netmask OS exists for **authorized** security testing, education and CTF.
Every tutorial and the LICENSE state the same rule: own systems,
authorized engagements, or public training ranges only.

## Licenses

* Project files: MIT (see `LICENSE`).
* Fonts: SIL OFL 1.1 + MIT (Nerd Fonts patch) — license files vendored.
* Upstream tools keep their own licenses; this project only installs them.
* Generated artwork (wallpaper, splash, icons): CC0.
