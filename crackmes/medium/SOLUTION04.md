# crackme04 — SOLUTION (medium · 250 pts)

## Goal
Defeat the anti-debug gate, then supply the real key.

## Step 1 — see the trap
```bash
gdb -q ./crackme04
(gdb) run              # decoy flag prints — ptrace(TRACEME) failed
```
On Linux the check is `ptrace(PTRACE_TRACEME) == -1` (a tracer already
owns us). On Windows it is `IsDebuggerPresent()` (reads the PEB flag).

## Step 2 — beat it (pick a lane)
1. **Patch**: in Ghidra, NOP the `jz/jnz` after the check call, or force
   the function to `return 0`.
2. **gdb, no patch**:
   ```gdb
   catch syscall ptrace        # or: break *address_of_check
   ```
   then set `$rax = 0` on return (Linux), or `set $peb BeingDebugged = 0`
   style edits via `info proc` + memory write (Windows/Wine).
3. **Environment**: LD_PRELOAD a stub `ptrace` returning 0.

## Step 3 — the key
`ant1ant1debug` → flag `netmask{watch3rs_bec0m3_watch3d}` (visible in
`strings` once you know the decoy path never touches it — compare which
strings the *taken* branch references).

## What you learned
* Anti-debug ≠ anti-reversing: it only filters lazy instrumentation
* Every environment check is a *branch*, and every branch is patchable
* Real-world packers stack 10+ such checks (PEB, NtQueryInformationProcess,
  timing, exceptions) — same recipe every time
