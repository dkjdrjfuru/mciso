# 03 — Ghidra Basics

> Launch: `ghidra` (or Super+G). Pinned to 11.4.2 on this OS.

## First import

1. **File → New Project → Non-Shared**, pick a folder
2. **File → Import File** → choose `crackmes/easy/binary/crackme03`
3. Double-click the file → **Analyze** → accept defaults → OK
4. Auto-analysis takes seconds for these binaries, minutes for real ones

## The five windows

| Window | Use it for |
|---|---|
| Listing | assembly, the ground truth |
| Decompiler | pseudo-C (click any function) |
| Symbol Tree | functions/imports/classes navigation |
| Data Type Manager | structs — define them, code becomes readable |
| Function Graph | CFG when you need the shape |

## Workflow that works

1. `Window → Functions`, jump to `main` (or `entry`)
2. Rename everything: `L` on a name (or right-click → Rename). Names
   compound — 30 renames in, the program explains itself
3. Retype variables: right-click → **Retype Variable** (`char *`, `int`)
4. Comments: `;` in listing, decompiler right-click → Comment
5. **Search → For Strings** → the annotated string list is your map

## Decompiler literacy

* `undefined8` = "Ghidra doesn't know" — you can often type it
* Wrong signatures corrupt everything downstream — fix them (`L`)
* `DAT_xxx` references = data; press `D` to make it a defined type
* If the decompiler shows soup inside a switch — it's a VM (see
  crackme05/07) or obfuscation (crackme08)

## Headless scripting (installed as `ghidra-headless`)

```bash
ghidra-headless /tmp/proj proj -import ./target \
  -postScript ghidra_scripts/FindStrings.java
```

## Cheat keys

`L` rename · `T` retype · `;` comment · `G` goto address ·
`Ctrl+Shift+E` export C · `Ctrl+Shift+T` data type manager

## Practice

```bash
ghidra &     # import crackmes/medium/binary/crackme05, find run_vm, decode prog[]
```

> Next: 04 — Cutter (radare2 with a GUI) for quicker triage.
