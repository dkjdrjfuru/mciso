# crackme03 — SOLUTION (easy · 100 pts)

## Goal
Craft ANY input whose transformed sum equals `0x1DB` (475).

## The transform
```
acc = Σ ( c_i XOR 0x20 ) + 2*i
```
`XOR 0x20` on ASCII = case toggle for letters. The constraint is a SUM —
not an equality — so infinitely many keys satisfy it. The decompiler
shows the constant `475` directly.

## Solve it as a constraint (z3-style thinking)
Pick 4 lowercase letters `aaaa` baseline and adjust: any string whose
transformed total is 475 works, e.g. `jjjj` :
`('j'^0x20)=0x4A` → 4 chars × 0x4A = 0x128; plus 2*(0+1+2+3)=12 → 0x134.
Keep walking letters up until the total hits 475 — or brute force in Python:

```python
for a in range(0x21, 0x7f):
    for b in range(0x21, 0x7f):
        for c in range(0x21, 0x7f):
            for d in range(0x21, 0x7f):
                s = sum((x ^ 0x20) + 2*i for i, x in enumerate((a,b,c,d)))
                if s == 475:
                    print(chr(a)+chr(b)+chr(c)+chr(d)); raise SystemExit
```

## Answer
```
example keys: "@Q__"  "@R^_"  "@S]_"   (16,876 valid 4-char keys in printable ASCII)
flag: netmask{c0nstra1nts_have_1nfinite_s0lut10ns}
```

## What you learned
* Check-sum gates accept *families* of inputs, not one password
* This is exactly why symbolic executors (angr — installed here) exist
* Patching the `JNZ` is the 30-second win; crafting a real key is the lesson
