# crackme11 — SOLUTION (expert · 1000 pts)

## Goal
Pass all four defenses and let the binary hand you the flag:
1. anti-debug · 2. data-integrity (FNV-1a) · 3. passphrase digest ·
4. flag stored only as a rolling-XOR table.

## Defense 1 — anti-debug
`ptrace(TRACEME)` / `IsDebuggerPresent()`. Same treatment as crackme04.
Run clean first; attach later read-only if you must.

## Defense 2 — data integrity
`fnv1a(enc) == 0x557E0C7D`. Every byte of the secret table is checksummed
at runtime. **Patching the table** (e.g. to plant your own flag) trips
this. Attack the algorithm, not the data.

## Defense 3 — passphrase digest
The passphrase is folded through FNV-1a with seed `0xC0FFEE` and compared
to `0xCE29E4D1`. It is a one-way gate — but 12 printable chars is
brute-forceable *only* if you cheat. The intended solve: recognize the
FNV shape, then hunt the passphrase in memory (`strings`, or dump after
the compare) — it is `n3tm4sk_b0ss`.

## Defense 4 — the flag table
```
flag[i] = enc[i] ^ ((i * 167 + 19) & 0xFF)
```
Invert it offline; the binary does it for you once defenses pass.

## Answer
```
passphrase: n3tm4sk_b0ss
flag:       netmask{k3rn3l_cr4ckm3_v1ct0ry}
```

## The kernel-mode variant (design notes)
A real kernel crackme needs a signed driver (WDK/EWDK; test-signing or
EV cert) — out of scope for a live ISO. The design would be:
* an LKM/WDK driver that hooks a device IOCTL and checks the key in
  ring-0, with `MmIsAddressValid`-based anti-tamper
* userland client must pass the driver's challenge to read the flag
  from a pool allocation that never touches user memory until success
* Linux equivalent: a kernel module exporting a `/proc/netmask` file
  whose read handler validates the passphrase in kernel space
Same methodology: fingerprint constants, defeat checks one by one, mine
the data path. The kernel only changes *where* the checks live.

## What you learned
* Layered defenses are sequential, not parallel — peel one at a time
* Integrity checks defend *data*; digest checks defend *decisions*;
  neither protects the *algorithm* — that is the always-open door
* End-to-end methodology: fingerprint → isolate → invert → verify offline
