# 05 — radare2 Basics

> `r2` is preinstalled (source-built). It is cryptic for a week and then
> the fastest RE tool you own.

## The universal session

```bash
r2 -A ./crackmes/easy/binary/crackme01   # -A = analyze all
```

## Twenty commands that matter

```text
aa / aaa        analyze (aaa = deeper)
pdf @ main      disassemble function (p=print, d=disasm, f=function)
pdf @ sym.main
afl             list functions
izz             list all strings
ii              imports
axt @ addr      xrefs to
s main          seek; s+ / s- undo/redo
px 64 @ rsp     hexdump memory (debug mode)
af+ 0x401100 my_func   define function manually
q               quit (!!)
```

## Command grammar (once you see it, r2 stops being cryptic)

```
[p][f][unction] [@(addr)]   →  pdf, px, pxa...
[a]nalysis: afl, axt, aa
[i]nfo: ii, iz, iS (sections)
[d]ebug: db (breakpoint), dc (continue), dr (registers), dso (step)
[w]rite: wx (hex), wa (assemble)
```

## Debugging a crackme

```bash
r2 -d crackmes/medium/binary/crackme06
[0x...]> db main; dc
[0x...]> dso            ; step over
[0x...]> dr rdi         ; peek registers
[0x...]> px @ rsi       ; the compared string
```

## Visual mode

Press `V` then `p` — hex/asm/debug screens without memorizing commands.

## r2 on firmware/odd blobs

```bash
r2 -a mips -b 32 -e cfg.bigendian=true ./firmware.bin
r2 -q -c 'e bin.relocs.apply=true; aaa; afl' ./libtarget.so
```

## When to drop to r2 (vs Cutter/Ghidra)

* scripting bulk analysis (`r2 -q -c 'afl' bin | wc -l`)
* headless boxes / SSH-only sessions
* tiny edits and quick xref checks mid-exploit-dev

> Next: 06 — IDA & the commercial landscape.
