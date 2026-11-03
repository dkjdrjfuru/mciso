# 06 — IDA Pro Basics (and IDA-Free on Linux)

> IDA is the industry-standard disassembler. This OS does not ship it
> (license-gated) — this lesson is the field guide for when you meet it,
> plus what to use here instead.

## IDA concepts (transfer to Ghidra/rizin too)

| IDA | Meaning | Ghidra equivalent |
|---|---|---|
| IDB | IDA's analysis database | Ghidra project |
| `N` | rename | `L` |
| `Y` | set type | `T` |
| `X` | xrefs | right-click → References |
| Hex-Rays | decompiler (F4) | Decompiler window |
| FLIRT | library-signature matching | FunctionID (built-in) |

## IDA-Free / practicalities

* Hex-Rays publishes **IDA Free** (Windows; limited decompiler) — run it
  in a Windows VM, or
* **Ghidra here is the daily driver** — 90% workflow parity
* `idat` = headless batch mode; Ghidra-headless covers the same niche

## If you must script IDA (IDAPython)

```python
import idautils, idc
for f in idautils.Functions():
    if "check" in idc.get_func_name(f):
        print(hex(f), idc.get_func_name(f))
```

The same automations exist here:

```bash
ghidra-headless /tmp/p p -import ./target -postScript ListFuncs.java
r2 -q -c 'afl' ./target
```

## Choosing your disassembler (a senior's cheat sheet)

| Situation | Tool |
|---|---|
| Deep structured RE, big projects | Ghidra (here) / IDA |
| Quick triage, GUI + console | Cutter (here) |
| Scripting, headless, odd archs | rizin/radare2 (here) |
| Java/Android | jadx-gui (here) |
| .NET | ILSpy/dnSpy in a VM (not shipped) |

> Next: 06b — OllyDbg/x64dbg, the Windows debuggers.
