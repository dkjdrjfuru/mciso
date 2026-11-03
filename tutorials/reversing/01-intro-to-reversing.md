# 01 — Introduction to Reverse Engineering

> Netmask OS tutorial pack · tutorials/reversing · read with `netmask-learn 01-intro`

## What RE is (and is not)

Reverse engineering is understanding a system from its artifacts — binaries,
firmware, traffic, memory — without source code. It powers vulnerability
research, malware analysis, interoperability, CTF, and software theft
investigations. **Ethics line:** reverse things you own, are licensed to
test, or that a CTF hands you. Everything else needs written authorization.

## The three levels of understanding

| Level | Question | Tools on this OS |
|---|---|---|
| Strings/metadata | "What does it mention?" | `strings`, `diec`, `file`, `exiftool` |
| Structural | "What is the layout?" | `readelf`, `objdump`, Ghidra, `pev` |
| Behavioral | "What does it do at runtime?" | gdb+GEF, `ltrace`, `strace`, Frida |

## Your first pass — every binary, always

```bash
file ./target                 # format, arch, static/dynamic, not stripped?
diec ./target                 # compiler, packer, language (DIE)
checksec --file=./target      # RELRO, NX, PIE, canary — sets your exploit lane
strings -n 8 ./target | head  # URLs, messages, format strings
ldd ./target                  # imported libraries (dynamic targets)
```

## The working loop

1. **Recon** — the five commands above
2. **Orient** — load in Ghidra, find `main`, name the big functions
3. **Hypothesis** — "this parses a header, then decrypts a blob"
4. **Test** — breakpoint, trace, patch, or script against the hypothesis
5. **Iterate** — every dead end is still a mapped area

## Files on this OS to practice on

```bash
crackmes/easy/binary/crackme01    # strcmp gate
crackmes/expert/binary/crackme11  # layered defenses
```

## Where to go next

* 02 — x86-64 assembly (the substrate of everything)
* 03 — Ghidra (your main decompiler)
* 07 — anti-debug (when targets fight back)

> Rule zero of RE: the binary always tells the truth. If your model and
> the behavior disagree, your model is wrong.
