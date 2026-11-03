# 06b — OllyDbg / x64dbg (Windows debuggers)

> OllyDbg is legacy (Win32 era); x64dbg is its modern successor. Both are
> Windows apps. On this OS they run under Wine (x64dbg via
> `optional/install-x64dbg-wine.sh`), but the *real* workflow is a
> Windows VM with the ISO's tools for host-side analysis.

## Why Windows debuggers matter

Userland RE of Windows targets (crackmes, game clients, packers) happens
in x64dbg: plugins (SharpOD anti-anti-debug), scriptable, hot-patching.

## The x64dbg mental model

* Four panes: CPU (asm), Memory map, Stack, Registers
* `F7` step-into, `F8` step-over, `F9` run, `F2` breakpoint
* Command bar: `bp 0x401000`, `bp GetWindowTextA` (API breakpoints are
  the crackme cheat code)

## The classic crackme loop in x64dbg

1. Run → enter a wrong password → note the "wrong" string
2. Right-click → Search for → All referenced strings → find "wrong"
3. Follow in disassembler → scroll up to the `test/cmp` that branches
4. Patch the jump (`jnz`→`jmp` or NOP) → correct path reveals the flag
5. For clean solutions: dump the compared string from memory instead

## Anti-anti-debug quick hits

* Options → Preferences → Exceptions: pass to program
* ScyllaHide plugin (hide PEB flags, NtQueryInformationProcess)
* Timing checks: watch `rdtsc` deltas; patch or virtualize the compare

## On this OS

```bash
# optional, adds ~1.5 GB (wine):
sudo /usr/local/lib/netmask/optional/install-x64dbg-wine.sh
x64dbg                    # launches under wine
wine crackmes/easy/binary/crackme01.exe    # PE targets
```

For serious Windows work: VirtualBox VM (the OS auto-boots into it fine)
+ host x64dbg + shared folders.

> Next: 07 — anti-debug techniques from the defender's side.
