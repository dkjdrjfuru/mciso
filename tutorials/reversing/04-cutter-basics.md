# 04 — Cutter Basics

> Launch: `cutter` (Super+C). Cutter = radare2 + Qt GUI.

## When Cutter instead of Ghidra

* Quick triage: smaller/faster startup for a first look
* Native radare2 console right in the GUI
* Live graph with patching (great for crackmes)

## First session

1. **File → Open** → `crackmes/easy/binary/crackme02` → defaults → OK
2. Cutter auto-analyzes; you land in the **Dashboard**
3. Open the **Disassembly** view; the **Graph** view shows the CFG

## The views that matter

| View | Purpose |
|---|---|
| Dashboard | binary info, entropy (packed? → high entropy) |
| Disassembly / Graph | the code |
| Decompiler (right panel) | rizin's decompiler (pdc) |
| Strings / Imports | quick recon lists |
| Console | raw rizin/rizin commands |

## Rename / retype / patch

* Right-click a function → **Rename** (or `A` in graph)
* Right-click an instruction → **Edit → Instruction(s)** to patch bytes
* **File → Save patch** writes a patched binary — do this on a copy

## The embedded rizin console

```text
pdf @ main          ; disassemble main
axt @ 0x40120a      ; xrefs to an address
izz~flag            ; search strings for "flag"
```

## Triage recipe (60 seconds, any binary)

1. Dashboard → entropy per section (>7.5 = likely packed)
2. Strings → interesting messages?
3. Imports → networking? crypto? anti-debug APIs?
4. Entry → main → biggest function → decompile

## Practice

Open `crackmes/hard/binary/crackme08` — watch the graph explode from
opaque predicates, then try the decompiler anyway.

> Next: 05 — raw radare2 for when GUIs are too slow.
