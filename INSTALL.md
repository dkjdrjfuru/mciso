# INSTALL — building and running Netmask OS (hacker edition)

## 1. Build host

Ubuntu 22.04/24.04 or Debian 12/13, x86_64, **~60 GB free disk**, internet.

```bash
# nothing to install manually — build.sh does it:
#   pipx, squashfs-tools, xorriso, grub-pc-bin, grub-efi-amd64-bin, grub-common,
#   mtools, debian-archive-keyring, dosfstools, cpio, zstd, xz-utils, curl
#   + a current mkosi (>= 25) via pipx if your distro's is older
./build.sh
```

Build time: ~60–90 min (2 cores; sagemath, metasploit, MobSF and wine
dominate). Speed-ups: `NETMASK_SKIP_SAGE=1 ./build.sh` (−1 GB),
`NETMASK_SKIP_WINE=1` (−1.2 GB).

On **Windows**: build inside WSL2 (`wsl --install -d Ubuntu-24.04`), then
`./build.sh` inside Ubuntu; copy the ISO out with
`cp output/*.iso /mnt/c/Users/lanin/Downloads/`.

## 2. Artifacts

```
output/netmask-os-hacker-YYYYMMDD.iso         hybrid ISO (BIOS + UEFI)
output/netmask-os-hacker-YYYYMMDD.iso.sha256  checksum
output/netmask-os-hacker-YYYYMMDD.iso.sig     detached GPG signature (SIGN=1)
output/netmask-os-hacker-YYYYMMDD.iso.BUILD-INFO.json  audit record
```

Verify on another machine: `sha256sum -c *.sha256` and
`gpg --verify *.sig *.iso` (import the release key first).

## 3. Boot — zero interaction by design

Power on → GRUB (timeout=0, menu hidden) → plymouth matrix-rain splash →
getty autologin as `netmask` → i3 desktop with the welcome terminal.
No keystrokes anywhere. To reach the GRUB menu for debugging, hold
**ESC** during boot (it is hidden, not removed) — or rebuild with
`set timeout=3` in `mkosi.postoutput`.

* **VirtualBox** — Linux/Debian 64-bit, ≥ 4 GB RAM (Ghidra wants more),
  2+ CPUs, no disk required; attach ISO; BIOS (default) or *Enable EFI*
  for UEFI; Secure Boot off. Guest additions are preinstalled:
  auto-resize display, shared clipboard and drag&drop work immediately.
* **Real hardware** — `dd` to USB works for testing, but for persistence use
  `sudo scripts/create-persistent-usb.sh <iso> /dev/sdX` (destroys the stick).
* **QEMU** — `./scripts/qemu-smoke.sh [--uefi] output/*.iso`.

## 4. First boot inside

| Keys | Action |
|---|---|
| `Super`+`Enter` | kitty |
| `Super`+`D` | rofi launcher (apps + commands) |
| `Super`+`F1` / `F2` / `F3` | tools navigator / tutorials / crackmes |
| `Super`+`G` / `C` / `F4` | Ghidra / Cutter / ImHex |
| `Super`+`Shift+W` / `B` | Burp / Firefox |
| `netmask-tools doctor` | full PASS/FAIL tool audit |

The tutorials (`~/tutorials`) and crackme pack (`~/crackmes`) are
symlinked into the home directory; compiled binaries live under
`crackmes/<tier>/binary/` (ELF + Windows PE — run PE ones with `wine`).

## 5. Persistence (optional, LUKS2)

The default GRUB entry boots with `persistent` — live-boot scans for a
persistence partition at every boot: none found → normal boot; LUKS2
container found → plymouth passphrase prompt → `/home` is overlaid from
it. Create the stick with:

```bash
sudo scripts/create-persistent-usb.sh output/netmask-os-hacker-YYYYMMDD.iso /dev/sdX
# PERSIST_SIZE=32768 sudo scripts/create-persistent-usb.sh <iso> /dev/sdX
```

## 6. Troubleshooting

* **Black screen after splash** — press ESC (plymouth drops to console
  messages); check `dmesg` for the failing unit.
* **Persistence prompt missing** — the plymouth script theme shows it;
  if your GPU misbehaves, switch to the plain two-step splash:
  `sudo plymouth-set-default-theme spinner -R` inside the live session.
* **Tool missing** — `netmask-tools doctor`; failed build modules are
  listed in the build log (search `FAILED (continuing`).
* **VM graphics slow** — VirtualBox: enable 3D acceleration; more VRAM.
