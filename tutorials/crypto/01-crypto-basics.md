# 01 — Crypto Basics for Hackers

> You don't break AES. You break key management, modes, randomness, and
> implementations. This lesson is the vocabulary that pays rent.

## Symmetric vs asymmetric (30-second recap)

| Type | Primitives | Speed | Key question |
|---|---|---|---|
| Symmetric | AES, ChaCha20, 3DES(legacy) | fast | how are keys shared/stored? |
| Asymmetric | RSA, ECC (X25519, ECDSA) | slow | who validates the public key? |
| Hash | SHA-256, BLAKE2 | n/a | collision or preimage? |
| MAC | HMAC, Poly1305 | fast | is the key included? |

## Modes of operation — where most bugs live

| Mode | Property | Failure mode |
|---|---|---|
| ECB | identical blocks → identical ciphertext | pattern leak (the penguin) |
| CBC | chained, needs random IV | IV reuse, padding oracles |
| CTR | keystream, seekable | **nonce reuse = catastrophic** |
| GCM | CTR + auth tag | nonce reuse breaks auth too |

## The numbers that matter

* AES-128: 2^128 keys — brute force is science fiction
* RSA-2048: factoring hard *today*; RSA-1024 = borderline, don't ship
* SHA-256: no collisions known; MD5/SHA1 = broken for collisions
* Everything is XOR at heart (one-time pad = perfect, key reuse = death)

## Tooling on this OS

```bash
echo -n "data" | openssl dgst -sha256
openssl enc -aes-256-cbc -in f -out f.enc -K <hex> -iv <hex>
python3 -c "import Crypto; print('pycryptodome via venv:', Crypto.__version__)" 2>/dev/null || \
python3 -c "from Crypto.Cipher import AES; print('ok')" 2>/dev/null || \
/opt/netmask-py/bin/python -c "from Crypto.Cipher import AES; print('ok (venv)')"
sage -c "print(Zmod(11)(3)^7)"     # sagemath for CTF math
RsaCtfTool --help | head -3        # RSA CTF automation
hashid 'scrypt$...'                # identify hash formats
```

## The hacker's crypto checklist (every implementation you meet)

1. Randomness: `rand()` seeded how? `/dev/urandom`? Math.random()?
2. Mode: ECB spotted? → penguin attack / block pattern analysis
3. Nonce/IV: fixed? reused? predictable?
4. Key storage: hardcoded? derived from hostname/user?
5. Padding: PKCS7 oracle? (lesson 02)
6. Auth: MAC-then-encrypt? unauthenticated ciphertext = malleable

## What "break crypto" actually means

99% of practical breaks = reuse, downgrade, oracle, or side channel —
not math. Lesson 02 covers exactly those.
