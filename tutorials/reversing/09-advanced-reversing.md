# 09 — Advanced Reversing

> The techniques that separate "can use Ghidra" from "can reverse
> anything": deobfuscation, devirtualization, protocol RE, and scale.

## 1. Deobfuscating control flow (crackme08 style)

Opaque predicates: conditions that are constant but unprovable for the
decompiler. Options:

* **Trace-based truth**: run once under `ltrace`/gdb coverage, record
  executed edges, mark everything else dead
* **Symbolic pruning**: feed angr/SAGE the predicate; solvers prove
  `n*(n+1) % 2 == 0` instantly
* **Patch & re-decompile**: force predicates to constants, rebuild CFG

## 2. Devirtualizing custom VMs (crackme05/07 style)

VM protection = bytecode + interpreter. The kill chain:

1. Identify the dispatch loop (`switch` in a `while`) → note the opcode
   fetch/decode/execute pattern
2. Enumerate opcodes by their handlers — name them (`OP_ROL`, `OP_XORS`)
3. Dump the bytecode array
4. Write a lifter: bytecode → pseudo-assembly → readable form
5. Reason about the lifted program (solve with z3/angr if needed)

Tools here: Ghidra (p-code helps!), `angr` (symbolic + lifting),
pwntools for scripting.

## 3. Reversing network protocols

```bash
tshark -i any -w /tmp/cap.pcapng          # capture the app
tshark -r /tmp/cap.pcapng -x | less        # hex view, find structure
```
* Look for length prefixes, magic values, XOR-rolls, checksum fields
* Fuzz the parser: mutate one field, watch `strace`/crashes
* Wireshark → Follow stream → export → diff across actions

## 4. Reversing at scale (thousands of binaries)

```bash
for f in samples/*; do
    diec -j "$f" > "$f.json" 2>/dev/null
done
# triage pipeline: DIE json → classify → route to capa/floss/yara
capa ./sample --rules /opt/capa-rules 2>/dev/null || capa ./sample
floss ./sample | head -50
```

## 5. Symbolic execution as a routine tool

```python
import angr
p = angr.Project("./crackmes/hard/binary/crackme08", auto_load_libs=False)
st = p.factory.entry_state(args=["./crackme08"])
sm = p.factory.simulation_manager(st)
sm.explore(find=lambda s: b"you walked" in s.posix.dumps(1),
           avoid=lambda s: b"[-]" in s.posix.dumps(1))
print(sm.found[0].posix.dumps(0))
```
Works when: constraints are numeric, inputs bounded, no heavy anti-symex.
Breaks when: checksums of symbolic data, floats, time — learn the smell.

## 6. Firmware RE quickstart

```bash
binwalk -Me firmware.bin       # recursive extraction
sasquatch squashfs-lzma.img    # non-standard squashfs
ubi-reader / jefferson         # UBI / JFFS2
strings -n 6 squashfs-root/etc/passwd
```

## Practice path on this OS

1. crackme08 with angr → 2. crackme07 lifter → 3. capture + reverse a
   protocol with `mitmproxy` against a local service → 4. `binwalk` a
   router image (any vendor's public firmware).
