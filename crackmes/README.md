# Netmask OS // Crackme Pack

Original challenges, built for this OS. Every challenge ships with:

| Item | Where |
|---|---|
| Challenge binary (Linux ELF + Windows PE x64) | `<tier>/binary/` |
| Full C source | `<tier>/crackmeNN.c` |
| Complete solution writeup | `<tier>/SOLUTIONNN.md` |

**Read the source AFTER your attempt** — the solutions teach methodology,
not just answers.

## Tiers

| Tier | Points | Challenges | Skills |
|---|---|---|---|
| `easy/` | 100 | 01–03 | strings, XOR, constraint solving |
| `medium/` | 250 | 04–06 | anti-debug, bytecode VM, custom encodings |
| `hard/` | 500 | 07–09 | VM+jumps, obfuscated control flow, timing gates |
| `expert/` | 1000 | 10–11 | TEA crypto, integrity checks, layered defenses |

## Running

```bash
netmask-crackmes                  # list everything
netmask-crackmes run crackme01    # launch an ELF challenge
netmask-crackmes wine crackme04   # launch the Windows PE build
gdb -q crackmes/easy/binary/crackme01
ghidra &                          # import → analyze → decompile
```

## Suggested toolchain per tier

* easy: `strings`, `ltrace`, Ghidra decompiler
* medium: gdb + GEF, Ghidra, write a tiny emulator in Python
* hard: meet-in-the-middle brute force, **angr** symbolic execution
  (`angr` is preinstalled), tracing
* expert: crypto fingerprinting (TEA constants), FNV recognition, patch
  vs. data-attack decisions

## Flag format

`netmask{...}` — grep-able, spoiler-free.

## Ethics

These are self-contained binaries built for learning on your own machine.
Apply the same skills only to software you own or are authorized to test.
