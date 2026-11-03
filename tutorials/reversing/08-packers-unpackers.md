# 08 — Packers & Unpackers

> A packer compresses/encrypts a binary and wraps it in a stub that
> restores the original at runtime. You meet them constantly in malware.

## Recognizing a pack

```bash
diec ./target                  # UPX? VMProtect? Themida? custom?
checksec --file=./target
objdump -h ./target | grep -E 'text|data'
# signs: 2-3 sections only, high entropy, no imports except LoadLibrary/
# GetProcAddress (Win) or dlopen (Linux), huge .text, small strings count
```

Entropy heuristic (Cutter dashboard or `binwalk -E`): > 7.2 per section
= compressed/encrypted.

## UPX — the polite packer

```bash
upx -d ./target -o ./target.unpacked
upx -t ./target      # integrity test
```
Malware often corrupts the UPX header while keeping the algorithm —
see the manual unpack below.

## Generic manual unpacking (any packer)

The original code must exist in memory at some point:

1. Break **after** the unpacking stub, **before** OEP
   (original entry point)
2. Dump memory to disk
3. Rebuild the import table

Linux approach:
```bash
gdb -q ./packed
(gdb) catch syscall mprotect      # or break on the last stub call
(gdb) run
(gdb) info proc mappings          # find the r-x region
(gdb) dump binary memory /tmp/dump.bin 0x400000 0x600000
```
Then fix up with rizin/Ghidra (load as raw at base).

Windows approach: x64dbg + Scylla (IAT rebuild + dump).

## QEMU-user trick for library-level unpacking

```bash
qemu-x86_64 -g 1234 ./packed     # gdb remote debugging from another shell
gdb -ex 'target remote :1234'
```

## Other families on this OS

| Family | Tool here |
|---|---|
| UPX (fixed) | `upx -d` |
| Generic/unknown | gdb + dump (above) |
| Firmware/squashfs/cpio | `binwalk -Me`, `sasquatch` |
| .NET | not shipped — Windows VM + dnSpy |
| VM-based (VMProtect) | the VM tutorials (05/07 of crackmes) |

## Practice

```bash
upx --best -o /tmp/c01.packed crackmes/easy/binary/crackme01
upx -d /tmp/c01.packed -o /tmp/c01.unpacked && /tmp/c01.unpacked
binwalk -E /tmp/c01.packed    # compare entropy before/after
```
