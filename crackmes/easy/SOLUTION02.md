# crackme02 — SOLUTION (easy · 100 pts)

## Goal
Recover the phrase hidden behind a single-byte XOR.

## Recon
In Ghidra the loop looks like:
```
DAT[xxx + i] = DAT_table[i] ^ 0x5A;
```
A 22-byte table XORed with a constant — the classic single-byte XOR shape.
No `strcmp` string pops out with `strings` because the plaintext never
exists in the binary; it is constructed at runtime.

## Brute-force the key (universal trick)
Single-byte XOR: only 256 candidates, and printable output narrows it fast:

```python
enc = bytes.fromhex(
  "226a28056b2905346a2e053f343928232a2e6b6a3474")
for k in range(256):
    out = bytes(b ^ k for b in enc)
    if all(32 <= c < 127 for c in out):
        print(hex(k), out.decode())
# 0x5a -> b'x0r_1s_n0t_encrypt10n.'
```

## Answer
```
phrase: x0r_1s_n0t_encrypt10n.
flag:   netmask{x0r_1s_n0t_encrypt10n}
key:    0x5A
```

## What you learned
* XOR is reversible: knowing ANY plaintext byte gives you the key
* Known-plaintext + 256 key space = trivial brute force
* If data appears as a raw table with no string reference — suspect XOR
