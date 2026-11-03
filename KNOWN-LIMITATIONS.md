# KNOWN-LIMITATIONS — what is NOT in the image, and why

Every requested tool that cannot be shipped is listed here with the reason
and the supported workaround. The build never fails because of these; the
`netmask-tools doctor` table is the runtime source of truth.

## Not installable on Debian 12 bookworm

| Requested | Reason | Workaround |
|---|---|---|
| Binary Ninja (demo) | **no demo build exists** — license-gated commercial product, no redistributable binary | install manually: download from binary.ninja with your license, drop it in `/opt/binaryninja` |
| x64dbg / WinDbg | Windows GUI debuggers; Wine layer = ~1.5 GB + fragile | `sudo /usr/local/lib/netmask/optional/install-x64dbg-wine.sh` (opt-in) — or use GEF/x64 via QEMU-user |
| PEiD | abandoned Windows-only tool | `diec` (Detect-It-Easy) covers the same detection use-case |
| Cryptool | Windows-only | sage / hashcat / RsaCtfTool (pip) |
| sysdig | removed from Debian bookworm (out-of-tree kernel module) | `apt install` from the sysdig.com repo at runtime, or use `strace` + `bpftrace` |
| Rekall | project abandoned (~2019), incompatible with py3.11 | Volatility 3 is installed |
| dumpit / WinPMEM | Windows memory acquisition binaries | MemProcFS + LiME (module built against running kernel headers) cover Linux |
| Cuckoo Sandbox | upstream abandoned, breaks on py3.11 | CAPE requires Docker + KVM orchestration — out of scope for a live ISO; run it in a VM on your host |
| CAPE sandbox | needs Docker daemon + nested KVM | same as above; `trivy`/`capa`/`floss` cover the static side |
| veil / shelley | unmaintained, Kali-specific installers break on bookworm | `msfvenom` + `donut` + `sRDI` (vendored) |
| eaphammer / hostapd-wpe | heavy source builds with pinning issues | standard `hostapd` + `aircrack-ng` workflow; build scripts on request |
| Autopsy 4 (GUI) | Debian ships the old CLI `autopsy` only; Autopsy 4 is Windows-first | CLI autopsy + sleuthkit are installed; Autopsy 4 runs fine in a Windows VM |
| bulk_extractor | removed from bookworm | `sudo /usr/local/lib/netmask/optional/install-bulk-extractor.sh` (opt-in) |
| kismet | removed from bookworm | `sudo /usr/local/lib/netmask/optional/install-kismet-source.sh` (opt-in) |

## Version notes

| Tool | Shipped | Note |
|---|---|---|
| Ghidra | **11.4.2** (pinned) | last release supporting JDK 17; bookworm has no JDK 21 anywhere. To move to Ghidra 12.x: install openjdk-21 (trixie/backports) and bump `GHIDRA_VERSION` in `versions.env` |
| Python | 3.11 (system) + **3.12 side-build** in `/opt/python3.12` | bookworm's system python is 3.11; pwntools/capstone/keystone/unicorn/lief are installed for both worlds |
| Metasploit | omnibus **nightly** | Rapid7 does not publish pinned-version debs; recorded in the build log |
| rust | stable channel via rustup | pin `RUST_PROFILE=1.90.0` (or any) in `versions.env` for hard reproducibility |
| go-installed tools (ffuf, subfinder, nuclei, httpx, naabu, dnsx, katana, dalfox, gobuster, chisel, amass, gau, waybackurls, kerbrute) | `@latest` at build time | pin by replacing `@latest` with `@vX.Y.Z` in `scripts/install-go.sh` |
| VirtualBox guest additions | latest stable from virtualbox.org | override with `VBOX_VERSION=7.1.6 ./build.sh`; skip with `NETMASK_SKIP_VBOXGUEST=1` |

## Boot-screen notes

* The plymouth **script** theme (matrix rain) implements the
  question/password dialogs itself. If a very unusual GPU refuses it,
  plymouth falls back to the text splash — the LUKS persistence prompt
  then appears on the console. A guaranteed-dialog alternative is one
  command away inside the live session:
  `sudo plymouth-set-default-theme spinner -R`.
* GRUB menu is **hidden by design** (`timeout=0`): hold ESC at power-on
  to surface the (verbose / serial / no-persistence) entries.

## Crackme notes

* crackme11 documents the **kernel-mode variant** design in its
  SOLUTION — shipping it needs a signed driver (WDK), out of scope for a
  live ISO.
* Windows PE crackme builds require mingw-w64 (~500 MB, included in
  `packages-full.txt`); without it the build silently falls back to
  ELF-only (see `crackmes/*/binary/*.build.log`).

## Structural notes

* The ISO is a **live system**: root is a read-only squashfs. Runtime writes
  live in RAM; persistence is the optional LUKS2 partition
  (`scripts/create-persistent-usb.sh`).
* Secure Boot: the ISO's GRUB is unsigned (VirtualBox EFI does not enforce
  Secure Boot by default). Signing support = future work (shim + sbattach).
* GitHub-hosted runners have ~20 GB of usable disk after cleanup: the build
  fits, but a self-hosted runner with 60 GB+ is recommended for frequent runs.
* Some pip packages (MobSF, theHarvester) move fast; modules are non-fatal so
  one bad release never blocks a build — check the doctor table.
