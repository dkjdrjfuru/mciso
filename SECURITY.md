# SECURITY — Netmask OS (full)

## Build integrity

* Every non-APT component is pulled from a pinned source (`versions.env`) or
  resolved from the project's official GitHub releases at build time; the
  verify-tools table in each build log records what landed in the image.
* Artifacts ship with `sha256` checksums; releases are signed with GPG
  (`SIGN=1 ./build.sh`, CI: `GPG_PRIVATE_KEY` secret). Import the release key
  and verify before running any ISO on production hardware.
* No telemetry, no phones home: VS Code telemetry is disabled in the image
  (`settings.json`), no analytics in any config, frida-server binds to
  127.0.0.1 only.

## Kernel & system posture

| Control | State |
|---|---|
| KASLR / KPTI / SMEP / SMAP | stock Debian bookworm kernel defaults (enabled) |
| AppArmor | enabled (`apparmor=1 security=apparmor` on the kernel cmdline, `apparmor.service` enabled) |
| BPF | `kernel.unprivileged_bpf_disabled=1`, `bpf_jit_harden=2` |
| kexec | disabled at runtime (`kexec_load_disabled=1`) |
| kptr / dmesg | restricted (`2` / `1`) |
| fs protection | hardlinks/symlinks/fifos/regular: strict |
| Auto-login | `netmask` user, no password, tty1 — **by design, it is a live appliance**; root account locked |
| sudo | passwordless for `netmask` — required for the tooling workflow |

## Deliberate exceptions (RE workstation, documented)

* `kernel.yama.ptrace_scope=0` — GDB/Frida/objection must attach to processes.
* `kernel.perf_event_paranoid=-1` — fuzzing/profiling workflows (AFL++, rr).
* Live system has no firewall enabled by default — networks you attack labs
  on are isolated by you; add nftables rules in a persistence overlay
  (`/etc/netmask/`) if you need them.

## Dual-use notice

The toolchain includes offensive-security tooling (exploitation frameworks,
fuzzers, wireless tools). Use only on systems you are authorized to test.
The distribution itself adds no exploits and contains no malicious code; all
tools are unmodified upstream releases.

## Reporting

Security issues in the build system: open a private security advisory / email
the maintainers. Vulnerabilities in shipped tools: report upstream; list of
sources in `versions.env` + `scripts/`.
