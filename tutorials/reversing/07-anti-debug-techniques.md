# 07 — Anti-Debug Techniques (and how to defeat them)

> Every technique here is implemented somewhere in the crackme pack —
> practice on real binaries, not slides.

## The catalog

| Technique | Windows | Linux | Defeat |
|---|---|---|---|
| PEB flag | `IsDebuggerPresent` | — | zero the PEB byte / patch branch |
| Self-trace | `int 3` + SEH | `ptrace(TRACEME)` | handle it, patch return |
| API checks | `NtQueryInformationProcess(ProcessDebugPort)` | `proc/self/status TracerPid` | hook/spoof the API |
| Timing | `rdtsc`, `QueryPerformanceCounter` | `clock()`, wall clock | virtualize or play by rules |
| Exception-based | `int 2d`, SEH stepping | `SIGTRAP`/`SIGSEGV` flow | pass exceptions to target |
| Hardware BP detect | `GetThreadContext` DRx | `ptrace(GETREGS)` | clear DR registers |
| Checksums | code CRC | `.text` hash (crackme11) | attack data, not code |
| VM detect | CPUID/hypervisor bit | dmesg, DMI strings | hide flags / patch |

## Reading the *defender's* logic

The universal shape:
```c
if (being_debugged()) { decoy_path(); } else { real_path(); }
```
Both paths exist in the binary. Your job is only to make the branch go
the right way — three ways to do that:

1. **Patch the branch** (NOP / invert) — 30 seconds, trips checksums
2. **Spoof the environment** (ScyllaHide, LD_PRELOAD stubs, gdb set $rax)
3. **Don't debug** — static analysis + offline solvers never trip checks

## Lab: the crackme pack

```bash
crackmes/medium/binary/crackme04     # ptrace / IsDebuggerPresent
crackmes/hard/binary/crackme07       # anti-debug + timing canary
crackmes/expert/binary/crackme11     # anti-debug + data integrity
```

## gdb anti-anti-debug on Linux

```gdb
catch syscall ptrace
# on stop: set $rax = 0 ; continue
```
Or pre-spoof:
```bash
LD_PRELOAD=/tmp/fakeptrace.so ./target   # stub returning 0
```

## Mindset

Anti-debug is a *filter for tools*, not a lock. Defenders know this —
that's why real protection layers obfuscation + integrity + server-side
checks. Client-side secrets are always extractable; see
crackme11's writeup for the reasoning.
