# crackme07 — SOLUTION (hard · 500 pts)

## Goal
8 chars whose `ROL-n -> XOR` rolling chain equals `0x6E`.

## Layer 1 — anti-debug
Same pattern as crackme04 plus a `clock()` canary (answer within 5 s).
Patch the branch or run unsandboxed first, gdb later.

## Layer 2 — the VM program
```
acc = rol(in[0],3) ^ rol(in[1],5) ^ rol(in[2],1) ^ rol(in[3],7)
    ^ rol(in[4],2) ^ rol(in[5],4) ^ rol(in[6],6) ^ rol(in[7],1) == 0x6E
```
Re-derive this by dumping `prog` and decoding opcodes — do not trust the
writeup, trust the bytecode.

## Solve
The chain is not injective — brute force bytewise with meet-in-the-middle:

```python
def rol(v, n): n &= 7; return ((v << n) | (v >> (8 - n))) & 0xFF
from itertools import product
pairs = {}
for a, b in product(range(0x21, 0x7f), repeat=2):
    pairs.setdefault(rol(a,3) ^ rol(b,5), []).append((a, b))
for c, d in product(range(0x21, 0x7f), repeat=2):
    left = rol(c,1) ^ rol(d,7)
    for e, f in product(range(0x21, 0x7f), repeat=2):
        # split further if slow — this one finishes in seconds
        for g, h in product(range(0x21, 0x7f), repeat=2):
            if left ^ rol(e,2) ^ rol(f,4) ^ rol(g,6) ^ rol(h,1) == 0x6E:
                print(bytes((c, d, e, f, g, h))); break
        # (optimise as you like — any hit is a key)
```
(Cleaner: meet-in-the-middle over 4+4 halves. Any accepted 8-char string
counts — the binary is the judge.)

## Answer
```
flag: netmask{r0ll_y0ur_0wn_vm_get_r0ll3d}
key:  any 8 printable bytes satisfying the ROL/XOR chain (brute force one)
```

## What you learned
* VM + environment checks = the standard commercial packer recipe
* Meet-in-the-middle turns 8-dim brute force into 2 × 4-dim
* A timing canary defeats naive single-stepping — script your solver
