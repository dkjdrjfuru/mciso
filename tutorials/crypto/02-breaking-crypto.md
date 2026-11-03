# 02 — Breaking Crypto (the practical classes)

> Realistic breaks, ordered by how often they pay out.

## Class 1 — Key reuse / nonce reuse

* One-time pad reused: `C1 ^ C2 = P1 ^ P2` → crib-dragging recovers both
* AES-CTR with repeated nonce: same keystream → XOR pairs, known plaintext
* Detect: two ciphertexts whose XOR looks like ASCII-XOR structure

```python
# many-time pad: statistical crack (space heuristic)
cts = [bytes.fromhex(h) for h in ct_list]
xored = [a ^ b for a in b for ...]   # crib ' the ' scoring per position
```

## Class 2 — Padding oracles (CBC)

Server tells you `padding error` vs `MAC error` → decrypt block by block
without the key:

```python
# per byte: flip prev-block bytes until padding valid, derive P_i
# tools: padbuster (classic); write your own in ~40 lines
```
Counter: encrypt-then-MAC (or AEAD like GCM) — never raw CBC + error diffs.

## Class 3 — Weak randomness

* `srand(time(0))` → brute-force the seed window (lesson 06 ransomware)
* `rand()` (glibc) = LCG, state recoverable from 624 samples (MT19937)
* Detect: repeated ciphertexts across boots/instances

```python
# MT19937 untwister is a classic CTF: collect outputs, clone state, predict
```

## Class 4 — RSA traps (CTF gold)

| Trap | Attack | Tool here |
|---|---|---|
| small e, no padding | e-th root | sage: `Integer(c).nth_root(e)` |
| common modulus | gcd(e1,e2)=1 → combined attack | RsaCtfTool |
| close primes | Fermat factorization | sage |
| small modulus | brute/factor (factordb) | RsaCtfTool |
| d leak / partial key | lattice (lattice-based attacks) | sage |

```bash
RsaCtfTool --publickey key.pub --uncipher cipher --attack all
sage -c "n=...; print(factor(n))"   # small factors via ECM/trial
```

## Class 5 — Hash function misuse

* Unsalted password DB → rainbow tables / hashcat (rockyou in seclists)
* Length extension (MD5/SHA1/SHA256 with `H(k||m)` construction) →
  hashp/extender-style attacks
* Collision forgery on MD5/SHA1 (chosen-prefix) — proof-of-concept level

```bash
hashcat -m 0 -a 0 hashes.txt /usr/share/seclists/Passwords/rockyou.txt
john --wordlist=/usr/share/seclists/Passwords/rockyou.txt hashfile
```

## Class 6 — Protocol-level

Downgrades (TLS), replay (no nonce/timestamp), JWT `alg:none`, ECB in
tokens (cookie penguin). Read the protocol, test the edges.

## Method

1. Identify primitives + parameters (fingerprint constants)
2. Assume implementation bug before math break
3. Write the attack offline (crackme10 taught TEA decryption — same skill)
4. Verify on captured data; document the exact faulty assumption
