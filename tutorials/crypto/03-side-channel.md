# 03 — Side-Channel Attacks

> The implementation leaks; the algorithm never had to break. Timing,
> power, cache, EM — physical reality is an oracle.

## The classes

| Channel | Example | Practicality |
|---|---|---|
| Timing | early-exit compares, branch-dependent latency | remote-timing realistic |
| Cache | Flush+Reload on shared pages, Prime+Probe | co-located VM/cloud |
| Power | DPA/SPA on smartcards | needs hardware |
| EM/acoustic | TEMPEST-style | exotic |
| Error messages | padding oracles (lesson 02!) | very practical |

## Timing attacks — the classic

Non-constant-time compare:
```c
for (i = 0; i < len; i++) if (a[i] != b[i]) return 0;  // leaks prefix length
```
Attack: byte-by-byte — measure response time per candidate, the winner
is consistently slower by a whisker. Statistical tests over thousands
of samples beat noise.

```python
# sketch: per candidate byte, median of 500 timings, pick argmax
```

The fix (know it to find its absence): constant-time compare
(`diff |= a[i]^b[i]`), no data-dependent branches on secrets.

## Cache attacks — the cloud era threat

* Flush+Reload: attacker flushes a shared library line; victim's use
  re-loads it → timing reveals *which* code/data was touched
* Spectre/Meltdown: speculative execution as an oracle — patched by
  KPTI (this kernel boots with it), retpoline, microcode

## The remote-timing reality check

Real networks add jitter; you need: many samples, robust stats (medians,
percentiles), server-side warming, and patience. Local/co-located = far
easier (co-tenant VMs).

## Your lab (honest version)

```bash
# build two compare functions: naive vs constant-time
# measure with a tight loop + clock_gettime, plot medians
# the difference teaches more than any diagram
```

Then: hunt real code for `strcmp` on secrets, early returns on secret
lengths, secret-indexed array lookups (`table[secret[i]]` — cache leak!).

## Where it bites in practice

* Padding oracles (error-message channel) — lesson 02
* Password-check timing in web apps (string compares, DB index)
* Embedded/smartcard: power analysis on AES = the academic classic
