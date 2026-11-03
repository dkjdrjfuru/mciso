# crackme08 — SOLUTION (hard · 500 pts)

## Goal
6 chars driving the state machine to `acc == 0x2A5F0B1E`.

## Reading it is a trap
The dispatcher mixes 5 real states (0→2→5→7→8→6) with 4 decoys (9,1,4,3),
guarded by the opaque predicate `n*(n+1) % 2 == 0` — always true, but
your decompiler can't prove it, so both edges stay alive and the CFG
explodes. Classic obfuscation-by-CFG.

## Practical attacks
1. **Trace it**: run under `ltrace`/gdb, log `(state, acc)` per char —
   you'll see only the real path executes.
2. **Defuse the predicate**: in Ghidra, patch `opaque` to constant 1 and
   re-decompile — the decoy states become dead and vanish.
3. **Symbolic execution** (angr, installed on this OS):
   ```python
   import angr
   p = angr.Project("./crackme08", auto_load_libs=False)
   st = p.factory.entry_state(args=["./crackme08"])
   sm = p.factory.simulation_manager(st)
   sm.explore(find=lambda s: b"you walked" in s.posix.dumps(1),
              avoid=lambda s: b"[-]" in s.posix.dumps(1))
   print(sm.found[0].posix.dumps(0))
   ```
   The 6-char keyspace is tiny for a concretizing solver.

## Answer
```
flag: netmask{0paque_pr3dic4tes_st1ll_us3_cmp}
key:  one of the 6-char preimages of 0x2A5F0B1E (trace/angr gives it)
```

## What you learned
* Opaque predicates are just always-true branches — defuse, don't decode
* When the CFG is a lie, switch from static reading to dynamic tracing
  or symbolic execution
* Decoy states are noise; find which edges actually execute
