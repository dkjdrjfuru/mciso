# crackme01 — SOLUTION (easy · 100 pts)

> try it yourself first — this writeup is the walk of shame

## Goal
Find the password accepted by `crackme01`.

## Recon
```bash
strings crackme01 | grep -i netmask
# n3tm4sk_r0x
# netmask{you_passed_your_first_strcmp}
```
The password is stored in cleartext because `strcmp` needs both operands.

## Alternative approaches
* `ltrace -e strcmp ./crackme01` — prints both compared strings at runtime
* Ghidra: search → for strings → "n3tm4sk"
* gdb: `break strcmp` then `x/s $rsi`

## Answer
```
password: n3tm4sk_r0x
flag:     netmask{you_passed_your_first_strcmp}
```

## What you learned
* Secrets embedded in cleartext are not secrets
* `strings` is the 10-second recon step — always start there
* Dynamic tracing (`ltrace`) shows data that static analysis hides in noise
