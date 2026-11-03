# crackme06 — SOLUTION (medium · 250 pts)

## Goal
Recover the plaintext key from the positionally-encoded string
`"tpnmaor|co~zgmpd"`.

## The transform (visible in the decompiler)
```
expected[i] = stored[i] - ((i * 7) % 13)
```
Position-dependent shift — that's why `strings` shows only garbage and
why every wrong attempt reports the *exact byte* that failed (a free
oracle; a real crackme would not leak that).

## Invert it
```python
stored = "tpnmaor|co~zgmpd"
out = "".join(chr((ord(c) - (i * 7) % 13) & 0xFF) for i, c in enumerate(stored))
print(out)   # time_for_dynamic
```

## Answer
```
key:  time_for_dynamic
flag: netmask{enc0de_n0t_encrype_either}
```

## What you learned
* Encoding ≠ encryption: no key, no entropy — just an invertible map
* Rolling/position-dependent shifts are the bread of "custom crypto"
* Compare-fail oracles let you rebuild secrets byte by byte even without
  reading the disassembly
