# crackme10 — SOLUTION (expert · 1000 pts)

## Goal
8 chars whose TEA encryption (with the in-binary key) equals
`0x0B8AC80A / 0x6A5CA0BD`.

## Step 1 — fingerprint the cipher
Decompiler shows: `0x9E3779B9` (golden-ratio delta), 32 iterations,
`<<4 / >>5`, four key words. That is textbook **TEA** — you never
reverse it, you *recognise* it. Keep a mental (or real) library of
magic constants: TEA/XTEA, RC4 (`0x100` S-box swap loop), MD5/SHA
round constants, CRC32 poly `0xEDB88320`.

## Step 2 — extract the key
`KEY[0..3] = 6E 33 74 6D | 34 73 6B 5F | 74 65 61 5F | 6B 65 79 21`
→ `"n3tm4sk_tea_key!"` (little-endian u32s:
`0x6D74336E 0x5F6B7334 0x5F616574 0x2179656B`).

## Step 3 — implement the decryptor
```python
M, D = 0xFFFFFFFF, 0x9E3779B9
k = [0x6D74336E, 0x5F6B7334, 0x5F616574, 0x2179656B]
def dec(v0, v1):
    s = (D * 32) & M
    for _ in range(32):
        v1 = (v1 - (((v0 << 4) + k[2]) ^ (v0 + s) ^ ((v0 >> 5) + k[3]))) & M
        v0 = (v0 - (((v1 << 4) + k[0]) ^ (v1 + s) ^ ((v1 >> 5) + k[1]))) & M
        s = (s - D) & M
    return v0, v1
v0, v1 = dec(0x0B8AC80A, 0x6A5CA0BD)
print((v0.to_bytes(4, "little") + v1.to_bytes(4, "little")))
# b'cr4ckm3!'
```

## Answer
```
key:  cr4ckm3!
flag: netmask{t1ny_c1ph3r_t1ny_eff0rt}
```

## What you learned
* Crypto in crackmes is *identified*, not broken — the key is always near
* Endianness is the #1 source of "correct algorithm, wrong constant" pain
* Writing the inverse cipher in Python is a core RE muscle
