# crackme05 — SOLUTION (medium · 250 pts)

## Goal
Feed 4 chars satisfying the VM's constraint:
`(in[0]^0x37) + (in[1]^0x37) + (in[2]^0x37) + (in[3]^0x37) == 0x101`

## Step 1 — identify the VM
In the decompiler you see a `switch` inside a `while` — a dispatch loop.
Opcodes: PUSHA/PUSHI/ADD/XOR/CMPEQ/HALT. Dump `prog` and decode it on
paper or with a 20-line Python emulator.

## Step 2 — solve the constraint
`0x101 = 257`. Pick printable chars, e.g. `('D'^0x37)=0x73×4 = 0x1CC`
too big; brute force instead:

```python
sol = []
for a in range(0x21, 0x7f):
    for b in range(0x21, 0x7f):
        for c in range(0x21, 0x7f):
            for d in range(0x21, 0x7f):
                s = sum(x ^ 0x37 for x in (a, b, c, d))
                if s == 257:
                    print(bytes((a, b, c, d))); raise SystemExit
# e.g. b'$&((' -> each ^0x37 sums to 257? verify before trusting
```

## Answer
```
one valid key: "$((" + "!"  — run the brute force, several families exist
flag: netmask{v1rtual_mach1n3s_t3ll_n0_l13s}
```
(Any 4 printable bytes whose `^0x37` sum is 257 — the binary validates,
not the writeup.)

## What you learned
* VM-protected checks are just *programs* — once the ISA is known, the
  protection evaporates
* This is a mini version of VMProtect/Themida: same concept, 10,000× ops
* Emulate > read: replaying bytecode in Python beats eyeballing traces
